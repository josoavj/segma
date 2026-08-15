import aiofiles
import os
import uuid
from pathlib import Path

from fastapi import UploadFile

from app.api.schemas import ImageUploadResponse
from config import ensure_runtime_dirs, settings


class UploadValidationError(Exception):
    """Erreur de validation contrôlée pour les fichiers uploadés."""

    def __init__(self, message: str, status_code: int = 400):
        super().__init__(message)
        self.status_code = status_code


class UploadService:
    """Gère la validation et la persistance des images entrantes."""

    allowed_extensions = {".jpg", ".jpeg", ".png", ".bmp"}

    async def save_image(self, file: UploadFile) -> ImageUploadResponse:
        filename = file.filename or ""
        extension = Path(filename).suffix.lower()

        if extension not in self.allowed_extensions:
            raise UploadValidationError("Seuls JPG, PNG et BMP sont supportés.")

        # On ne charge pas tout en mémoire d'un coup (content = await file.read())
        # On stream le contenu pour économiser de la RAM sur les gros fichiers

        ensure_runtime_dirs()
        stored_filename = f"{uuid.uuid4().hex}{extension}"
        file_path = Path(settings.UPLOAD_DIR) / stored_filename

        # Utilisation de aiofiles pour ne pas bloquer le thread principal
        async with aiofiles.open(file_path, "wb") as output:
            while chunk := await file.read(1024 * 1024):  # 1MB chunks
                await output.write(chunk)

        file_size = os.path.getsize(file_path)
        if file_size > settings.MAX_FILE_SIZE:
            os.remove(file_path)
            raise UploadValidationError("L'image est trop lourde.", status_code=413)

        if file_size == 0:
            os.remove(file_path)
            raise UploadValidationError("Le fichier uploadé est vide.")

        try:
            from PIL import Image

            with Image.open(file_path) as image:
                width, height = image.size
        except Exception as e:
            file_path.unlink(missing_ok=True)
            raise UploadValidationError(
                "Le fichier uploadé n'est pas une image valide."
            ) from e

        return ImageUploadResponse(
            filename=stored_filename,
            image_path=stored_filename,  # On ne renvoie que le nom du fichier pour la sécurité
            width=width,
            height=height,
            size_mb=round(file_size / (1024 * 1024), 2),
        )
