import os
import torch
import logging
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

# Configuration globale avant tout import de modèles
if not torch.cuda.is_available():
    os.environ["CUDA_VISIBLE_DEVICES"] = ""
    device_status = "🖥️ CPU"
else:
    device_status = f"🎮 GPU: {torch.cuda.get_device_name(0)}"

# Import local de tes modules harmonisés
from app.models.model_manager import model_manager
from app.api import api_router
from config import settings

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("SEGMA")

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialisation au démarrage et nettoyage à la fermeture"""
    logger.info("╔════════════════════════════════════════════════════════════╗")
    logger.info("║           DÉMARRAGE DU MOTEUR SEGMA (SAM 3)                ║")
    logger.info("╚════════════════════════════════════════════════════════════╝")
    
    # Pré-chargement du modèle SAM 3 via le manager pour éviter la latence à la 1ère requête
    logger.info(f"Système détecté : {device_status}")
    try:
        model_info = model_manager.get_model_info()
        logger.info(f"✓ Modèle {model_info['model_type']} prêt sur {model_info['device']}")
    except Exception as e:
        logger.error(f"❌ Échec de l'initialisation du modèle : {e}")

    yield
    
    logger.info("🛑 Arrêt du serveur SEGMA...")

app = FastAPI(
    title="SEGMA API v3",
    description="Segmentation d'images haute précision avec SAM 3 (PCS) & YOLOv8",
    version="3.0.0",
    lifespan=lifespan
)

# Configuration CORS améliorée
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS if isinstance(settings.CORS_ORIGINS, list) else [settings.CORS_ORIGINS],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclusion des routes API
app.include_router(api_router)

@app.get("/")
async def root():
    return {
        "app": "SEGMA API",
        "engine": "SAM 3 (Segment Anything Model 3)",
        "status": "online",
        "docs": "/docs"
    }

@app.exception_handler(Exception)
async def generic_exception_handler(request, exc):
    logger.error(f"🚨 ERREUR CRITIQUE : {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Une erreur interne est survenue sur le serveur SEGMA."}
    )

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )