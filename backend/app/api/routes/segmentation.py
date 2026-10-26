from fastapi import APIRouter, HTTPException, File, UploadFile
from fastapi.responses import StreamingResponse
import json
import logging
import os

from app.api.schemas import (
    SegmentationRequest, SegmentationResponse, ImageUploadResponse,
    ModelConfigResponse, ModelInfoResponse, ModelChangeRequest
)
from app.services.segmentation_service import SegmentationService
from app.services.upload_service import UploadService, UploadValidationError
from app.models.model_manager import model_manager

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v3", tags=["segmentation"])

segmentation_service = SegmentationService()
upload_service = UploadService()


@router.post("/segment/batch")
async def segment_batch(request: SegmentationRequest):
    """Traitement par lot d'un dossier complet avec streaming des résultats et verrou GPU."""
    async def event_generator():
        async with model_manager.inference_lock:
            async for update in segmentation_service.segment_batch(
                folder_path=request.filename,
                prompt=request.prompt,
                confidence_threshold=request.confidence_threshold
            ):
                yield json.dumps(update) + "\n"

    return StreamingResponse(event_generator(), media_type="application/x-ndjson")


@router.post("/segment", response_model=SegmentationResponse)
async def segment_image(request: SegmentationRequest):
    """Segmente une image par prompt texte (SAM 3 - Promptable Concept Segmentation)"""

    if not request.prompt or len(request.prompt.strip()) < 2:
        raise HTTPException(status_code=400, detail="Le prompt est trop court pour être traité.")
    
    try:
        # Acquisition du verrou asynchrone GPU pour garantir la sérialisation des inférences lourdes
        async with model_manager.inference_lock:
            result = await segmentation_service.segment_by_prompt(
                filename=request.filename,
                prompt=request.prompt,
                confidence_threshold=request.confidence_threshold,
            )
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
