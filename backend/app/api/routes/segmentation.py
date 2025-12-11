from fastapi import APIRouter, HTTPException
from app.api.schemas import SegmentationRequest, SegmentationResponse, HealthResponse
from app.services.segmentation_service import SegmentationService
from app.models.sam_model import get_sam_model
from config import settings
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1", tags=["segmentation"])


@router.post("/segment/point", response_model=SegmentationResponse)
async def segment_image_by_point(request: SegmentationRequest):
    """
    Segmente une image à partir d'un point cliqué
    
    - **image_path**: Chemin absolu de l'image
    - **x, y**: Coordonnées du point cliqué
    """
    try:
        result = SegmentationService.segment_image_by_point(
            request.image_path,
            request.x,
            request.y,
        )
        return SegmentationResponse(**result)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Image non trouvée")
    except Exception as e:
        logger.error(f"Erreur de segmentation: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur de segmentation: {str(e)}")


@router.post("/segment/box", response_model=SegmentationResponse)
async def segment_image_by_box(request: SegmentationRequest):
    """
    Segmente une image à partir d'une boîte délimitatrice
    
    - **image_path**: Chemin absolu de l'image
    - **box_x1, box_y1, box_x2, box_y2**: Coordonnées de la boîte
    """
    try:
        if not all([request.box_x1, request.box_y1, request.box_x2, request.box_y2]):
            raise HTTPException(
                status_code=400,
                detail="Les coordonnées de la boîte sont requises (box_x1, box_y1, box_x2, box_y2)"
            )
        
        result = SegmentationService.segment_image_by_box(
            request.image_path,
            request.box_x1,
            request.box_y1,
            request.box_x2,
            request.box_y2,
        )
        return SegmentationResponse(**result)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Image non trouvée")
    except Exception as e:
        logger.error(f"Erreur de segmentation: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur de segmentation: {str(e)}")


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """Vérifie l'état du serveur et du modèle SAM"""
    try:
        sam = get_sam_model()
        return HealthResponse(
            status="healthy",
            device=sam.device,
            model_loaded=sam.is_model_loaded(),
        )
    except Exception as e:
        logger.error(f"Erreur lors du health check: {e}")
        raise HTTPException(status_code=500, detail="Erreur du serveur")
