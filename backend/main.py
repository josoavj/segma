"""
Application principale SEGMA
Backend FastAPI pour la segmentation d'images avec SAM
"""

import os
import torch

# Détection automatique du device AVANT d'importer SAM3
# Cela empêche SAM3 de forcer CUDA sur un système sans GPU
if not torch.cuda.is_available():
    os.environ["CUDA_VISIBLE_DEVICES"] = ""
    print("🖥️  Pas de GPU détecté - Désactivation CUDA")
else:
    print(f"🎮 GPU détecté: {torch.cuda.get_device_name(0)}")

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
from app.api import api_router
from app.models.model_manager import model_manager
from config import settings

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gestion du cycle de vie de l'application"""
    # Startup
    logger.info("╔════════════════════════════════════════════════════════════╗")
    logger.info("║           Démarrage de l'application SEGMA                  ║")
    logger.info("╚════════════════════════════════════════════════════════════╝")
    
    model_info = model_manager.get_model_info()
    
    logger.info(f"📦 Configuration:")
    logger.info(f"   • API Version: 1.0.0")
    logger.info(f"   • Modèle SAM: {model_info['model_type']}")
    logger.info(f"   • Dispositif: {model_info['device']}")
    logger.info(f"   • CUDA disponible: {model_info['cuda_available']}")
    logger.info(f"   • Host: {settings.HOST}:{settings.PORT}")
    logger.info(f"   • CORS Origins: {', '.join(settings.CORS_ORIGINS)}")
    
    logger.info("🚀 Modèle SAM:")
    if model_info['is_loaded']:
        logger.info(f"   ✓ Modèle chargé: {model_info['model_type']} sur {model_info['device']}")
    else:
        logger.warning(f"   ⚠ Modèle {model_info['model_type']} en cours de chargement...")
    logger.info(f"   • Modèles disponibles: {', '.join(model_info['available_models'])}")
    
    logger.info("📚 Documentation API: http://localhost:8000/docs")
    logger.info("")
    
    yield
    
    # Shutdown
    logger.info("")
    logger.info("🛑 Arrêt de l'application SEGMA...")
    logger.info("Au revoir!")


# Créer l'application FastAPI
app = FastAPI(
    title="SEGMA API",
    description="API de segmentation d'images utilisant Segment Anything (SAM)",
    version="1.0.0",
    lifespan=lifespan,
)

# Configuration CORS
cors_origins = settings.CORS_ORIGINS
if isinstance(cors_origins, str):
    cors_origins = [origin.strip() for origin in cors_origins.split(",")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclure les routes API
app.include_router(api_router)


@app.get("/")
async def root():
    """Endpoint racine - Information de l'API"""
    return {
        "name": "SEGMA API",
        "version": "1.0.0",
        "description": "API de segmentation d'images utilisant Segment Anything 3 + YOLO",
        "endpoints": {
            "health": "GET /api/v1/health",
            "upload": "POST /api/v1/upload",
            "segment": "POST /api/v1/segment"
        },
        "docs": "http://localhost:8000/docs"
    }


@app.exception_handler(Exception)
async def generic_exception_handler(request, exc):
    """Gestionnaire d'exceptions générique"""
    logger.error(f"Erreur non gérée: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Erreur serveur interne"}
    )


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
    )
