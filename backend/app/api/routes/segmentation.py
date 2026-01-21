from fastapi import APIRouter, HTTPException, File, UploadFile
from app.api.schemas import (
    SegmentationRequest, SegmentationResponse, ImageUploadResponse,
    ModelConfigResponse, ModelInfoResponse
)
from app.services.segmentation_service import SegmentationService
from app.models.image_processor import ImageProcessor
from app.models.model_manager import model_manager
from config import settings
import logging
import os
from pathlib import Path

logger = logging.getLogger(__name__)

# Mise à jour du préfixe pour SAM 3
router = APIRouter(prefix="/api/v3", tags=["segmentation"])

# Instanciation du service orchestrateur
segmentation_service = SegmentationService()

@router.post("/segment", response_model=SegmentationResponse)
async def segment_by_prompt(request: SegmentationRequest):
    """Segmente une image par prompt texte (SAM 3 - Promptable Concept Segmentation)"""
    
    # Validation du chemin de l'image
    if not request.image_path or not os.path.exists(request.image_path):
        raise HTTPException(status_code=404, detail=f"Image non trouvée au chemin: {request.image_path}")
    
    # Validation du prompt (SAM 3 nécessite un concept clair)
    if not request.prompt or len(request.prompt.strip()) < 2:
        raise HTTPException(status_code=400, detail="Le prompt est trop court pour être traité.")
    
    try:
        # Appel du service (maintenant asynchrone pour ne pas bloquer l'API)
        result = await segmentation_service.segment_by_prompt(
            image_path=request.image_path,
            prompt=request.prompt,
            confidence_threshold=request.confidence_threshold,
            save_dir=request.save_dir
        )
        
        # Le format de retour est compatible avec SegmentationResponse
        # Note: SegmentationService gère déjà la sauvegarde en .bin
        return result
        
    except Exception as e:
        logger.error(f"Erreur lors de la segmentation SAM 3: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/upload", response_model=ImageUploadResponse)
async def upload_image(file: UploadFile = File(...)):
    """Télécharge l'image depuis Flutter et renvoie le chemin local pour SAM 3"""
    try:
        # Vérification extension
        ext = Path(file.filename).suffix.lower()
        if ext not in {'.jpg', '.jpeg', '.png', '.bmp'}:
            raise HTTPException(status_code=400, detail="Seuls JPG, PNG et BMP sont supportés.")
        
        content = await file.read()
        
        # Validation taille
        if len(content) > settings.MAX_FILE_SIZE:
            raise HTTPException(status_code=413, detail="L'image est trop lourde.")
        
        # Sauvegarde
        os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
        file_path = os.path.join(settings.UPLOAD_DIR, file.filename)
        
        with open(file_path, 'wb') as f:
            f.write(content)
        
        # Extraction des dimensions pour Flutter
        width, height = ImageProcessor.get_image_dimensions(file_path)
        
        return ImageUploadResponse(
            filename=file.filename,
            image_path=os.path.abspath(file_path),
            width=width,
            height=height,
            size_mb=round(len(content) / (1024 * 1024), 2)
        )
    except Exception as e:
        logger.error(f"Erreur Upload: {e}")
        raise HTTPException(status_code=500, detail="Échec du téléchargement de l'image.")


@router.get("/model/info", response_model=ModelInfoResponse)
async def get_model_info():
    """Récupère l'état de santé du modèle SAM 3 et YOLO"""
    try:
        return model_manager.get_model_info()
    except Exception as e:
        logger.error(f"Erreur Model Info: {e}")
        raise HTTPException(status_code=500, detail="Impossible de récupérer les infos modèle.")