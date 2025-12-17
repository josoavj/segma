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
    """
    Segmente une image à partir d'un prompt texte (SAM 3)
    
    Détecte et segmente tous les objets correspondant à la description.
    **Chaque masque**: zone segmentée = BLANC (255), reste = NOIR (0)
    
    Les masques binaires sont sauvegardés dans:
    - `save_dir` si fourni
    - `.segmentation_<image_name>/` à côté de l'image sinon
    
    - **image_path**: Chemin absolu de l'image
    - **prompt**: Description (ex: "tous les animaux", "voitures")
    - **confidence_threshold**: Seuil minimum (0.0-1.0)
    - **save_dir**: Répertoire de sauvegarde personnalisé (optionnel)
    """
    if not request.image_path:
        raise HTTPException(status_code=400, detail="image_path requis")
    
    if not request.prompt or len(request.prompt.strip()) < 3:
        raise HTTPException(status_code=400, detail="prompt doit contenir ≥3 caractères")
    
    if not (0.0 <= request.confidence_threshold <= 1.0):
        raise HTTPException(status_code=400, detail="confidence_threshold: 0.0-1.0")
    
    if not os.path.exists(request.image_path):
        logger.warning(f"Image non trouvée: {request.image_path}")
        raise HTTPException(status_code=404, detail="Image non trouvée")
    
    try:
        logger.info(f"Segmentation: {request.image_path} | Prompt: '{request.prompt}'")
        if request.save_dir:
            logger.info(f"  Save directory: {request.save_dir}")
        
        result = SegmentationService.segment_by_prompt(
            image_path=request.image_path,
            prompt=request.prompt,
            confidence_threshold=request.confidence_threshold,
            save_dir=request.save_dir
        )
        return SegmentationResponse(**result)
    
    except ValueError as e:
        logger.error(f"Erreur validation: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Image non trouvée")
    except Exception as e:
        logger.error(f"Erreur segmentation: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Erreur segmentation")


@router.post("/upload", response_model=ImageUploadResponse)
async def upload_image(file: UploadFile = File(...)):
    """
    Télécharge une image et la sauvegarde sur le serveur
    
    - **file**: Fichier image (JPEG, PNG)
    
    Retourne le chemin où l'image a été sauvegardée
    """
    try:
        # Vérifier l'extension du fichier
        if not file.filename:
            raise HTTPException(status_code=400, detail="Nom de fichier vide")
        
        allowed_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tiff'}
        file_ext = Path(file.filename).suffix.lower()
        
        if file_ext not in allowed_extensions:
            raise HTTPException(
                status_code=400, 
                detail=f"Format de fichier non supporté. Formats acceptés: {', '.join(allowed_extensions)}"
            )
        
        # Créer le répertoire s'il n'existe pas
        os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
        
        # Lire le contenu du fichier
        content = await file.read()
        
        # Vérifier la taille du fichier
        file_size = len(content)
        if file_size > settings.MAX_FILE_SIZE:
            max_size_mb = settings.MAX_FILE_SIZE / (1024 * 1024)
            raise HTTPException(
                status_code=413,
                detail=f"Le fichier est trop volumineux (max: {max_size_mb}MB)"
            )
        
        # Sauvegarder le fichier
        file_path = os.path.join(settings.UPLOAD_DIR, file.filename)
        with open(file_path, 'wb') as f:
            f.write(content)
        
        # Obtenir les dimensions de l'image
        try:
            width, height = ImageProcessor.get_image_dimensions(file_path)
        except Exception as e:
            logger.error(f"Erreur lors de la lecture des dimensions: {e}")
            # Supprimer le fichier en cas d'erreur
            os.remove(file_path)
            raise HTTPException(status_code=400, detail="Impossible de lire le fichier image")
        
        size_mb = file_size / (1024 * 1024)
        logger.info(f"Image téléchargée: {file.filename} ({width}x{height}, {size_mb:.2f}MB)")
        
        return ImageUploadResponse(
            filename=file.filename,
            image_path=os.path.abspath(file_path),
            width=width,
            height=height,
            size_mb=round(size_mb, 2)
        )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur lors du téléchargement: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Erreur lors du téléchargement du fichier")


@router.get("/model/info", response_model=ModelInfoResponse)
async def get_model_info():
    """
    Récupère les informations du modèle SAM actuellement chargé
    
    Retourne:
    - model_type: Type de modèle (vit_b, vit_l, vit_h)
    - device: Device utilisé (cpu ou cuda)
    - is_loaded: Si le modèle est chargé
    - available_models: Liste des modèles disponibles
    - cuda_available: Si CUDA est disponible sur le système
    """
    try:
        info = model_manager.get_model_info()
        return ModelInfoResponse(**info)
    except Exception as e:
        logger.error(f"Erreur lors de la récupération des infos: {e}")
        raise HTTPException(status_code=500, detail="Impossible de récupérer les infos du modèle")


@router.post("/model/change", response_model=ModelConfigResponse)
async def change_model(request: ModelConfigRequest):
    """
    Change le modèle SAM et/ou le device
    
    Paramètres:
    - model_type: Nouveau type de modèle (vit_b, vit_l, vit_h)
    - device: Device (cpu ou cuda, optionnel)
    
    Les modèles disponibles:
    - **vit_b**: Petit modèle, rapide (~96MB)
    - **vit_l**: Modèle intermédiaire (~312MB)
    - **vit_h**: Grand modèle, plus précis (~1.2GB)
    
    Temps de chargement estimé:
    - vit_b: ~2-3 secondes
    - vit_l: ~5-10 secondes
    - vit_h: ~15-30 secondes
    """
    if request.model_type not in ["vit_b", "vit_l", "vit_h"]:
        raise HTTPException(
            status_code=400,
            detail=f"Modèle invalide: {request.model_type}. Disponibles: vit_b, vit_l, vit_h"
        )
    
    if request.device and request.device not in ["cpu", "cuda"]:
        raise HTTPException(
            status_code=400,
            detail=f"Device invalide: {request.device}. Utilisez 'cpu' ou 'cuda'"
        )
    
    try:
        logger.info(f"Changement de modèle: {request.model_type} sur {request.device or 'auto'}")
        info = model_manager.change_model(request.model_type, request.device)
        
        return ModelConfigResponse(
            status="success",
            **info
        )
    except ValueError as e:
        logger.error(f"Erreur de validation: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Erreur lors du changement de modèle: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Impossible de changer le modèle")
    except Exception as e:
        logger.error(f"Erreur lors du téléchargement: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Erreur lors du téléchargement du fichier")
