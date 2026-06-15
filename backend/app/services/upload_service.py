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

        content = await file.read()
        if not content:
            raise UploadValidationError("Le fichier uploadé est vide.")

        if len(content) > settings.MAX_FILE_SIZE:
            raise UploadValidationError("L'image est trop lourde.", status_code=413)

        ensure_runtime_dirs()
        stored_filename = f"{uuid.uuid4().hex}{extension}"
        file_path = Path(settings.UPLOAD_DIR) / stored_filename

        with open(file_path, "wb") as output:
            output.write(content)

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
            image_path=os.path.abspath(file_path),
            width=width,
            height=height,
            size_mb=round(len(content) / (1024 * 1024), 2),
        )
