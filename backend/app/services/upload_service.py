import aiofiles
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

    allowed_extensions = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

    async def save_image(self, file: UploadFile) -> ImageUploadResponse:
        filename = file.filename or ""
        extension = Path(filename).suffix.lower()

        if extension not in self.allowed_extensions:
            raise UploadValidationError("Seuls JPG, PNG, BMP et WebP sont supportés.")

        ensure_runtime_dirs()
        stored_filename = f"{uuid.uuid4().hex}{extension}"
        file_path = Path(settings.UPLOAD_DIR) / stored_filename

        try:
            file_size = 0
            async with aiofiles.open(file_path, "wb") as output:
                while chunk := await file.read(1024 * 1024):
                    if file_size + len(chunk) > settings.MAX_FILE_SIZE:
                        raise UploadValidationError(
                            "L'image est trop lourde.", status_code=413
                        )
                    await output.write(chunk)
                    file_size += len(chunk)

            if file_size == 0:
                raise UploadValidationError("Le fichier uploadé est vide.")

            from PIL import Image

            with Image.open(file_path) as image:
                width, height = image.size
                image.verify()
        except UploadValidationError:
            file_path.unlink(missing_ok=True)
            raise
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
