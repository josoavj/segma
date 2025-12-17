from fastapi import APIRouter, HTTPException, File, UploadFile
from app.api.schemas import (
    SegmentationRequest, SegmentationResponse, ImageUploadResponse,
    ModelConfigRequest, ModelConfigResponse, ModelInfoResponse
)
from app.services.segmentation_service import SegmentationService
from app.models.image_processor import ImageProcessor
from app.models.model_manager import model_manager
from config import settings
import logging
import os
from pathlib import Path

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1", tags=["segmentation"])


@router.post("/segment", response_model=SegmentationResponse)
async def segment_by_prompt(request: SegmentationRequest):
    """Segmente une image par prompt texte (SAM3)"""
    # Validation express
    if not request.image_path or not os.path.exists(request.image_path):
        raise HTTPException(status_code=404, detail="Image non trouvée")
    if not request.prompt or len(request.prompt.strip()) < 3:
        raise HTTPException(status_code=400, detail="Prompt invalide")
    if not (0.0 <= request.confidence_threshold <= 1.0):
        raise HTTPException(status_code=400, detail="Threshold: 0.0-1.0")
    
    try:
        result = SegmentationService.segment_by_prompt(
            image_path=request.image_path,
            prompt=request.prompt,
            confidence_threshold=request.confidence_threshold,
            save_dir=request.save_dir
        )
        return SegmentationResponse(**result)
    except (ValueError, FileNotFoundError) as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Segmentation error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Segmentation failed")


@router.post("/upload", response_model=ImageUploadResponse)
async def upload_image(file: UploadFile = File(...)):
    """Télécharge et valide une image"""
    try:
        if not file.filename or Path(file.filename).suffix.lower() not in {'.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tiff'}:
            raise HTTPException(status_code=400, detail="Format invalide")
        
        content = await file.read()
        if len(content) > settings.MAX_FILE_SIZE:
            raise HTTPException(status_code=413, detail=f"Max size: {settings.MAX_FILE_SIZE/(1024*1024)}MB")
        
        os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
        file_path = os.path.join(settings.UPLOAD_DIR, file.filename)
        
        with open(file_path, 'wb') as f:
            f.write(content)
        
        width, height = ImageProcessor.get_image_dimensions(file_path)
        
        return ImageUploadResponse(
            filename=file.filename,
            image_path=os.path.abspath(file_path),
            width=width,
            height=height,
            size_mb=round(len(content) / (1024 * 1024), 2)
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Upload error: {e}")
        raise HTTPException(status_code=500, detail="Upload failed")


@router.get("/model/info", response_model=ModelInfoResponse)
async def get_model_info():
    """Récupère les infos du modèle SAM"""
    try:
        return ModelInfoResponse(**model_manager.get_model_info())
    except Exception as e:
        logger.error(f"Model info error: {e}")
        raise HTTPException(status_code=500, detail="Model info failed")


@router.post("/model/change", response_model=ModelConfigResponse)
async def change_model(request: ModelConfigRequest):
    """Change le modèle SAM et/ou le device"""
    if request.model_type not in ["vit_b", "vit_l", "vit_h"]:
        raise HTTPException(status_code=400, detail=f"Model invalide: {request.model_type}")
    
    if request.device and request.device not in ["cpu", "cuda"]:
        raise HTTPException(status_code=400, detail=f"Device invalide: {request.device}")
    
    try:
        info = model_manager.change_model(request.model_type, request.device)
        return ModelConfigResponse(status="success", **info)
    except Exception as e:
        logger.error(f"Model change error: {e}")
        raise HTTPException(status_code=500, detail="Model change failed")
