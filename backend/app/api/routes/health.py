from fastapi import APIRouter
from app.api.schemas import HealthResponse
from app.models.model_manager import model_manager
from config import settings
import logging

logger = logging.getLogger(__name__)

router = APIRouter(tags=["system"])

# Version alignée avec SAM 3
API_VERSION = "1.0.0"

@router.get("/api/v3/health", response_model=HealthResponse)
async def health():
    """
    Endpoint de santé du serveur SEGMA.
    Vérifie l'état du moteur d'IA (SAM 3 + YOLO) et du dispositif de calcul.
    """
    try:
        # Récupération des infos temps réel depuis le manager singleton
        model_info = model_manager.get_model_info()
        
        return HealthResponse(
            status="healthy",
            device=model_info['device'],
            model_loaded=model_info['is_loaded'],
            model_type="SAM 3", # On force le type cohérent avec ton projet
            api_version=API_VERSION
        )
    except Exception as e:
        logger.error(f"🚨 Santé serveur compromise : {e}")
        return HealthResponse(
            status="unhealthy",
            device="unknown",
            model_loaded=False,
            model_type="SAM 3",
            api_version=API_VERSION
        )