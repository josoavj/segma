from fastapi import APIRouter
from app.api.schemas import HealthResponse
from app.models.model_manager import model_manager
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
        model_info = model_manager.get_model_info()
        
        return HealthResponse(
            status="healthy",
            device=model_info['device'],
            model_loaded=model_info['is_loaded'],
            model_type=model_info['model_type'],
            api_version=API_VERSION
        )
    except Exception as e:
        logger.error(f"Erreur dans health check: {e}")
        return HealthResponse(
            status="unhealthy",
            device="unknown",
            model_loaded=False,
            model_type=settings.SAM_MODEL_TYPE,
            api_version=API_VERSION
        )
