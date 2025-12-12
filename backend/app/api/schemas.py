from pydantic import BaseModel, Field
from typing import Optional, List


class SegmentationRequest(BaseModel):
    """Requête de segmentation par prompt texte (SAM 3)"""
    image_path: str = Field(..., description="Chemin absolu de l'image")
    prompt: str = Field(..., description="Description des objets à segmenter (ex: 'tous les animaux', 'voitures')")
    confidence_threshold: float = Field(0.5, description="Seuil de confiance minimum (0.0-1.0)")
    save_dir: Optional[str] = Field(None, description="Chemin du répertoire de sauvegarde (optionnel, défaut: .segmentation_<image_name>)")


class SegmentedObject(BaseModel):
    """Un objet segmenté"""
    object_id: int = Field(..., description="ID de l'objet")
    label: str = Field(..., description="Label/description de l'objet")
    confidence: float = Field(..., description="Confiance de la segmentation")
    bbox: dict = Field(..., description="Boîte englobante {x1, y1, x2, y2}")
    mask_path: str = Field(..., description="Chemin du masque binaire sauvegardé")
    pixels_count: int = Field(..., description="Nombre de pixels du masque")


class SegmentationResponse(BaseModel):
    """Réponse de segmentation multi-objets"""
    image_path: str = Field(..., description="Chemin de l'image segmentée")
    width: int = Field(..., description="Largeur de l'image")
    height: int = Field(..., description="Hauteur de l'image")
    objects_count: int = Field(..., description="Nombre d'objets détectés")
    objects: List[SegmentedObject] = Field(..., description="Liste des objets segmentés")
    segmentation_dir: str = Field(..., description="Répertoire contenant les masques binaires")


class ImageUploadResponse(BaseModel):
    """Réponse du téléchargement d'image"""
    filename: str = Field(..., description="Nom du fichier sauvegardé")
    image_path: str = Field(..., description="Chemin absolu de l'image sauvegardée")
    width: int = Field(..., description="Largeur de l'image")
    height: int = Field(..., description="Hauteur de l'image")
    size_mb: float = Field(..., description="Taille du fichier en MB")


class HealthResponse(BaseModel):
    """Réponse de santé du serveur"""
    status: str = Field(..., description="État du serveur")
    device: str = Field(..., description="Dispositif utilisé (CPU/GPU)")
    model_loaded: bool = Field(..., description="Modèle SAM chargé")
    model_type: str = Field(..., description="Type de modèle SAM (sam3, vit_b, vit_l, vit_h)")
    api_version: str = Field(..., description="Version de l'API")
