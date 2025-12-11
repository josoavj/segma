from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


class SegmentationType(str, Enum):
    POINT = "point"
    BOX = "box"


class SegmentationRequest(BaseModel):
    """Requête de segmentation par point ou boîte"""
    image_path: str = Field(..., description="Chemin absolu de l'image")
    x: int = Field(..., description="Coordonnée X du point")
    y: int = Field(..., description="Coordonnée Y du point")
    box_x1: Optional[int] = Field(None, description="Coin supérieur gauche X de la boîte")
    box_y1: Optional[int] = Field(None, description="Coin supérieur gauche Y de la boîte")
    box_x2: Optional[int] = Field(None, description="Coin inférieur droit X de la boîte")
    box_y2: Optional[int] = Field(None, description="Coin inférieur droit Y de la boîte")


class SegmentationResponse(BaseModel):
    """Réponse de segmentation"""
    mask: str = Field(..., description="Masque encodé en base64")
    width: int = Field(..., description="Largeur de l'image")
    height: int = Field(..., description="Hauteur de l'image")
    confidence: float = Field(..., description="Confiance de la segmentation")


class HealthResponse(BaseModel):
    """Réponse de santé du serveur"""
    status: str = Field(..., description="État du serveur")
    device: str = Field(..., description="Dispositif utilisé (CPU/GPU)")
    model_loaded: bool = Field(..., description="Modèle SAM chargé")
