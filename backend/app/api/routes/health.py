from fastapi import APIRouter
from app.api.schemas import HealthResponse
from app.models.sam_model import get_sam_model
from config import settings
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

API_VERSION = "1.0.0"


@router.get("/api/v1/health", response_model=HealthResponse)
async def health():
    """
    Endpoint de santé du serveur
    
    Retourne l'état du serveur, le dispositif utilisé et le statut du modèle SAM
    """
    try:
        sam_model = get_sam_model()
        model_loaded = sam_model is not None
        device = settings.DEVICE
        
        if model_loaded and hasattr(sam_model, 'device'):
            device = str(sam_model.device)
        
        return HealthResponse(
            status="healthy",
            device=device,
            model_loaded=model_loaded,
            model_type=settings.SAM_MODEL_TYPE,
            api_version=API_VERSION
        )
    except Exception as e:
        logger.error(f"Erreur dans health check: {e}")
        return HealthResponse(
            status="unhealthy",
            device=settings.DEVICE,
            model_loaded=False,
            model_type=settings.SAM_MODEL_TYPE,
            api_version=API_VERSION
        )
