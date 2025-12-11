"""
Application principale SEGMA
Backend FastAPI pour la segmentation d'images avec SAM
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
from app.api import api_router
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
    logger.info("Démarrage de l'application SEGMA...")
    logger.info(f"Dispositif: {settings.DEVICE}")
    logger.info(f"Modèle SAM: {settings.SAM_MODEL_TYPE}")
    
    yield
    
    # Shutdown
    logger.info("Arrêt de l'application SEGMA...")


# Créer l'application FastAPI
app = FastAPI(
    title=settings.PROJECT_NAME,
    lifespan=lifespan,
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclure les routes API
app.include_router(api_router)


@app.get("/")
async def root():
    """Endpoint racine"""
    return {
        "name": settings.PROJECT_NAME,
        "version": "1.0.0",
        "docs": "/docs",
    }


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
    )
