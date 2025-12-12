"""
Application principale SEGMA
Backend FastAPI pour la segmentation d'images avec SAM
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
from app.api import api_router
from app.models.sam_model import get_sam_model
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
    
    logger.info(f"📦 Configuration:")
    logger.info(f"   • API Version: 1.0.0")
    logger.info(f"   • Modèle SAM: {settings.SAM_MODEL_TYPE}")
    logger.info(f"   • Dispositif: {settings.DEVICE}")
    logger.info(f"   • Host: {settings.HOST}:{settings.PORT}")
    logger.info(f"   • CORS Origins: {', '.join(settings.CORS_ORIGINS)}")
    
    logger.info("🚀 Initialisation du modèle SAM...")
    try:
        sam_model = get_sam_model()
        if sam_model.is_model_loaded():
            logger.info("✓ Modèle SAM chargé avec succès!")
        else:
            logger.warning("⚠ Modèle SAM non chargé - sera chargé à la première requête")
    except Exception as e:
        logger.error(f"✗ Erreur d'initialisation du modèle: {e}")
    
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
        "description": "API de segmentation d'images utilisant Segment Anything",
        "docs": "http://localhost:8000/docs",
        "openapi": "http://localhost:8000/openapi.json",
        "health": "http://localhost:8000/api/v1/health"
    }


@app.exception_handler(Exception)
async def generic_exception_handler(request, exc):
    """Gestionnaire d'exceptions générique"""
    logger.error(f"Erreur non gérée: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Erreur serveur interne. Consultez les logs pour plus de détails."}
    )


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
    )
