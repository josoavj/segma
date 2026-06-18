from fastapi import APIRouter, HTTPException, File, UploadFile
from app.api.schemas import (
    SegmentationRequest, SegmentationResponse, ImageUploadResponse,
    ModelConfigResponse, ModelInfoResponse, ModelChangeRequest
)
from app.services.segmentation_service import SegmentationService
from app.services.upload_service import UploadService, UploadValidationError
from app.models.model_manager import model_manager
import logging
import os

logger = logging.getLogger(__name__)

# Mise à jour du préfixe pour SAM 3
router = APIRouter(prefix="/api/v3", tags=["segmentation"])

# Instanciation du service orchestrateur
segmentation_service = SegmentationService()
upload_service = UploadService()

from fastapi.responses import StreamingResponse
import json

@router.post("/segment/batch")
async def segment_batch(request: SegmentationRequest):
    """Traitement par lot d'un dossier complet avec streaming des résultats."""
    # Si image_path est un dossier, on liste les images
    if os.path.isdir(request.image_path):
        paths = [
            os.path.join(request.image_path, f)
            for f in os.listdir(request.image_path)
            if f.lower().endswith(('.png', '.jpg', '.jpeg', '.webp'))
        ]
    else:
        paths = [request.image_path]

    if not paths:
        raise HTTPException(status_code=400, detail="Aucune image trouvée.")

    async def event_generator():
        async for update in segmentation_service.segment_batch(
            image_paths=paths,
            prompt=request.prompt,
            confidence_threshold=request.confidence_threshold
        ):
            # On envoie chaque résultat suivi d'un saut de ligne (NDJSON)
            yield json.dumps(update) + "\n"

    return StreamingResponse(event_generator(), media_type="application/x-ndjson")
    """Segmente une image par prompt texte (SAM 3 - Promptable Concept Segmentation)"""
    
    # Validation du chemin de l'image
    if not request.image_path or not os.path.exists(request.image_path):
        raise HTTPException(
            status_code=404,
            detail=f"Image non trouvée au chemin: {request.image_path}",
        )
    
    # Validation du prompt (SAM 3 nécessite un concept clair)
    if not request.prompt or len(request.prompt.strip()) < 2:
        raise HTTPException(status_code=400, detail="Le prompt est trop court pour être traité.")
    
    try:
        # Appel du service (maintenant asynchrone pour ne pas bloquer l'API)
        result = await segmentation_service.segment_by_prompt(
            image_path=request.image_path,
            prompt=request.prompt,
            confidence_threshold=request.confidence_threshold,
            save_dir=request.save_dir,
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
        return await upload_service.save_image(file)
    except UploadValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=str(e))
    except Exception as e:
        logger.error(f"Erreur Upload: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Échec du téléchargement de l'image.")


@router.get("/model/info", response_model=ModelInfoResponse)
async def get_model_info():
    """Récupère l'état de santé du modèle SAM 3 et YOLO"""
    try:
        return model_manager.get_model_info()
    except Exception as e:
        logger.error(f"Erreur Model Info: {e}")
        raise HTTPException(status_code=500, detail="Impossible de récupérer les infos modèle.")


@router.post("/model/change", response_model=ModelConfigResponse)
async def change_model_config(request: ModelChangeRequest):
    """Change le modèle/device actif puis recharge SAM 3."""
    try:
        return model_manager.change_model(
            model_type=request.model_type,
            device=request.device,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Erreur Model Change: {e}")
        raise HTTPException(
            status_code=500,
            detail="Impossible de changer la configuration du modèle.",
        )
