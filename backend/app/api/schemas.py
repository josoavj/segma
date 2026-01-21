from pydantic import BaseModel, Field
from typing import Optional, List, Dict


class SegmentationRequest(BaseModel):
    """Requête de segmentation par prompt texte (SAM 3 PCS)"""
    image_path: str = Field(..., description="Chemin absolu de l'image sur le serveur")
    prompt: str = Field(..., description="Concept textuel à segmenter (ex: 'boulons rouillés')")
    confidence_threshold: float = Field(0.25, ge=0.0, le=1.0, description="Seuil de confiance")
    save_dir: Optional[str] = Field(None, description="Répertoire de destination pour les .bin")


class SegmentedObject(BaseModel):
    """Métadonnées d'un objet extrait par SAM 3"""
    object_id: int = Field(..., description="Index de l'objet")
    label: str = Field(..., description="Label identifié par YOLO ou prompt")
    confidence: float = Field(..., description="Score de confiance du modèle")
    # Utilisation d'un Dict pour la flexibilité de la BBox {x1, y1, x2, y2}
    bbox: Dict[str, int] = Field(..., description="Boîte englobante en pixels")
    mask_path: str = Field(..., description="Chemin absolu vers le fichier .bin")
    pixels_count: int = Field(..., description="Surface de l'objet en pixels")


class SegmentationResponse(BaseModel):
    """Réponse complète après traitement SAM 3 + YOLO"""
    image_path: str = Field(..., description="Chemin de l'image source")
    resolution: str = Field(..., description="Format 'Largeur x Hauteur'")
    objects_count: int = Field(..., description="Nombre d'objets trouvés")
    objects: List[SegmentedObject] = Field(..., description="Détails de chaque segment")
    segmentation_dir: str = Field(..., description="Dossier contenant les masques binaires")


class ImageUploadResponse(BaseModel):
    """Réponse après upload de l'image depuis Flutter"""
    filename: str = Field(..., description="Nom du fichier stocké")
    image_path: str = Field(..., description="Chemin complet pour traitement")
    width: int = Field(..., description="Largeur originale")
    height: int = Field(..., description="Hauteur originale")
    size_mb: float = Field(..., description="Poids du fichier en MegaBytes")


class HealthResponse(BaseModel):
    """État de santé du moteur d'IA"""
    status: str = Field("ready", description="État du serveur")
    device: str = Field(..., description="Dispositif actif (cpu/cuda)")
    model_loaded: bool = Field(..., description="Indique si SAM 3 est en mémoire")
    model_type: str = Field("SAM 3", description="Version du modèle")
    api_version: str = Field("3.0.0")

# --- Schemas pour la gestion dynamique (Optionnel) ---

class ModelConfigResponse(BaseModel):
    """Configuration actuelle du backend"""
    status: str
    model_type: str
    device: str
    is_loaded: bool
    cuda_available: bool

class ModelInfoResponse(BaseModel):
    """Informations détaillées du modèle SAM 3"""
    model_type: str = Field(..., description="Type de modèle")
    device: str = Field(..., description="Device utilisé (cpu/cuda)")
    device_name: str = Field(..., description="Nom du device (CPU/GPU)")
    vram_gb: Optional[float] = Field(None, description="VRAM disponible en GB")
    is_loaded: bool = Field(..., description="Indique si le modèle est chargé")
    available_models: List[str] = Field(..., description="Modèles disponibles")
    cuda_available: bool = Field(..., description="CUDA disponible")