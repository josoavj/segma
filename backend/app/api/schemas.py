from pydantic import BaseModel, Field
from typing import Optional, List, Dict


class InteractivePointInput(BaseModel):
    x: float = Field(..., ge=0.0, le=1.0)
    y: float = Field(..., ge=0.0, le=1.0)
    label: int = Field(..., ge=0, le=1)


class SegmentationRequest(BaseModel):
    """Requête de segmentation textuelle ou guidée par zones cliquées."""
    filename: str = Field(..., description="Nom du fichier image dans le dossier d'upload")
    prompt: Optional[str] = Field(None, description="Concept textuel à segmenter")
    points: List[InteractivePointInput] = Field(
        default_factory=list,
        description="Zones normalisées (0..1) et étiquettes 1=inclure, 0=exclure",
    )
    confidence_threshold: float = Field(0.25, ge=0.0, le=1.0, description="Seuil de confiance")


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
    image_path: str = Field(..., description="Nom relatif à réutiliser pour la segmentation")
    width: int = Field(..., description="Largeur originale")
    height: int = Field(..., description="Hauteur originale")
    size_mb: float = Field(..., description="Poids du fichier en MegaBytes")


class HealthResponse(BaseModel):
    """État de santé du moteur d'IA"""
    status: str = Field("healthy", description="healthy, degraded ou unhealthy")
    device: str = Field(..., description="Dispositif actif (cpu/cuda/mps)")
    model_loaded: bool = Field(..., description="Indique si SAM 3 est en mémoire")
    model_type: str = Field("SAM 3", description="Version du modèle")
    api_version: str = Field("1.0.0")

# --- Schemas pour la gestion dynamique (Optionnel) ---

class ModelConfigResponse(BaseModel):
    """Configuration actuelle du backend"""
    status: str
    model_type: str
    device: str
    is_loaded: bool
    cuda_available: bool


class ModelChangeRequest(BaseModel):
    """Requête de changement de configuration modèle/device"""
    model_type: Optional[str] = Field(
        None,
        description="Identifiant du modèle (SAM 3 unique dans cette version)",
    )
    device: Optional[str] = Field(
        None,
        description="Device cible (cpu/cuda/mps selon disponibilité)",
    )

class ModelInfoResponse(BaseModel):
    """Informations détaillées du modèle SAM 3"""
    model_type: str = Field(..., description="Type de modèle")
    device: str = Field(..., description="Device utilisé (cpu/cuda/mps)")
    device_name: str = Field(..., description="Nom du device (CPU/GPU)")
    vram_gb: Optional[float] = Field(None, description="VRAM disponible en GB")
    is_loaded: bool = Field(..., description="Indique si le modèle est chargé")
    available_models: List[str] = Field(..., description="Modèles disponibles")
    cuda_available: bool = Field(..., description="CUDA disponible")
    mps_available: bool = Field(False, description="Apple Silicon GPU disponible")
