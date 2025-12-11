import torch
import numpy as np
from segment_anything import sam_model_registry, SamPredictor
from PIL import Image
import logging
from config import settings

logger = logging.getLogger(__name__)


class SAMModel:
    """Gestionnaire du modèle Segment Anything"""
    
    def __init__(self):
        self.device = settings.DEVICE if torch.cuda.is_available() else "cpu"
        self.model = None
        self.predictor = None
        self._load_model()
    
    def _load_model(self):
        """Charge le modèle SAM de Meta"""
        try:
            logger.info(f"Chargement du modèle SAM ({settings.SAM_MODEL_TYPE}) sur {self.device}...")
            
            sam = sam_model_registry[settings.SAM_MODEL_TYPE](
                checkpoint=f"./checkpoints/sam_{settings.SAM_MODEL_TYPE}_20231211.pth"
            )
            sam.to(device=self.device)
            self.model = sam
            self.predictor = SamPredictor(sam)
            
            logger.info("Modèle SAM chargé avec succès")
        except Exception as e:
            logger.error(f"Erreur lors du chargement du modèle: {e}")
            raise
    
    def segment_by_point(self, image: np.ndarray, x: int, y: int) -> tuple[np.ndarray, float]:
        """
        Segmente une région en fonction d'un point cliqué
        
        Args:
            image: Image en numpy array (RGB)
            x: Coordonnée X du point
            y: Coordonnée Y du point
        
        Returns:
            tuple: (masque binaire, confiance)
        """
        try:
            # Définir l'image
            self.predictor.set_image(image)
            
            # Prédiction avec le point
            input_point = np.array([[x, y]])
            input_label = np.array([1])  # 1 pour point de premier plan
            
            masks, scores, _ = self.predictor.predict(
                point_coords=input_point,
                point_labels=input_label,
                multimask_output=False,
            )
            
            # Retourner le meilleur masque
            mask = masks[0].astype(np.uint8) * 255
            confidence = float(scores[0])
            
            return mask, confidence
        
        except Exception as e:
            logger.error(f"Erreur lors de la segmentation par point: {e}")
            raise
    
    def segment_by_box(
        self, 
        image: np.ndarray, 
        x1: int, y1: int, 
        x2: int, y2: int
    ) -> tuple[np.ndarray, float]:
        """
        Segmente une région en fonction d'une boîte délimitatrice
        
        Args:
            image: Image en numpy array (RGB)
            x1, y1: Coin supérieur gauche
            x2, y2: Coin inférieur droit
        
        Returns:
            tuple: (masque binaire, confiance)
        """
        try:
            self.predictor.set_image(image)
            
            # Boîte délimitatrice
            input_box = np.array([x1, y1, x2, y2])
            
            masks, scores, _ = self.predictor.predict(
                box=input_box,
                multimask_output=False,
            )
            
            mask = masks[0].astype(np.uint8) * 255
            confidence = float(scores[0])
            
            return mask, confidence
        
        except Exception as e:
            logger.error(f"Erreur lors de la segmentation par boîte: {e}")
            raise
    
    def is_model_loaded(self) -> bool:
        """Vérifie si le modèle est chargé"""
        return self.model is not None and self.predictor is not None


# Instance globale du modèle
sam_model = None


def get_sam_model() -> SAMModel:
    """Getter pour l'instance globale du modèle SAM"""
    global sam_model
    if sam_model is None:
        sam_model = SAMModel()
    return sam_model
