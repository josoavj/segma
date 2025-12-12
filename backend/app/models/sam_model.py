import numpy as np
import logging
import os
from config import settings
from app.exceptions import ModelNotLoadedException, SegmentationException

logger = logging.getLogger(__name__)

try:
    import torch
    from segment_anything import sam_model_registry, SamPredictor
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False
    logger.warning("⚠ PyTorch non installé - mode de développement sans segmentation réelle")


class SAMModel:
    """Gestionnaire du modèle Segment Anything"""
    
    def __init__(self):
        self.device = "cpu"
        self.model = None
        self.predictor = None
        self.model_type = settings.SAM_MODEL_TYPE
        self.is_loaded = False
        
        if TORCH_AVAILABLE:
            self.device = settings.DEVICE if torch.cuda.is_available() else "cpu"
        
        self._load_model()
    
    def _load_model(self):
        """Charge le modèle SAM de Meta"""
        if not TORCH_AVAILABLE:
            logger.warning("PyTorch non disponible - modèle en mode simulation")
            self.is_loaded = False
            return
        
        try:
            logger.info(f"Chargement du modèle SAM ({self.model_type}) sur {self.device}...")
            
            # Construire le chemin du checkpoint
            checkpoint_dir = "./checkpoints"
            checkpoint_name = f"sam_{self.model_type}_20231211.pth"
            checkpoint_path = os.path.join(checkpoint_dir, checkpoint_name)
            
            # Vérifier si le fichier existe
            if not os.path.exists(checkpoint_path):
                logger.warning(f"Checkpoint non trouvé: {checkpoint_path}")
                logger.info("Le modèle sera téléchargé automatiquement...")
                # segment_anything téléchargera le modèle automatiquement
            
            # Charger le modèle
            sam = sam_model_registry[self.model_type](
                checkpoint=checkpoint_path if os.path.exists(checkpoint_path) else None
            )
            
            # Déplacer le modèle vers le device
            sam.to(device=self.device)
            self.model = sam
            self.predictor = SamPredictor(sam)
            self.is_loaded = True
            
            logger.info(f"✓ Modèle SAM chargé avec succès ({self.model_type} sur {self.device})")
        
        except Exception as e:
            logger.error(f"✗ Erreur lors du chargement du modèle: {e}", exc_info=True)
            self.is_loaded = False
            # Ne pas lever l'exception ici, le modèle sera chargé à la première demande
    
    def segment_by_point(self, image: np.ndarray, x: int, y: int) -> tuple[np.ndarray, float]:
        """
        Segmente une région en fonction d'un point cliqué
        
        Args:
            image: Image en numpy array (RGB)
            x: Coordonnée X du point
            y: Coordonnée Y du point
        
        Returns:
            tuple: (masque binaire, confiance)
        
        Raises:
            ModelNotLoadedException: Si le modèle n'est pas chargé
            SegmentationException: Si la segmentation échoue
        """
        if not self.is_loaded:
            raise ModelNotLoadedException("Le modèle SAM n'est pas chargé")
        
        try:
            # Valider les coordonnées
            if image.shape[0] <= y or image.shape[1] <= x:
                raise ValueError(f"Coordonnées hors limites: ({x}, {y}) pour une image {image.shape[1]}x{image.shape[0]}")
            
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
            
            logger.debug(f"Segmentation par point réussie: ({x}, {y}) avec confiance {confidence:.3f}")
            return mask, confidence
        
        except ValueError as e:
            logger.error(f"Erreur de validation: {e}")
            raise SegmentationException(f"Erreur de validation: {str(e)}")
        except Exception as e:
            logger.error(f"Erreur lors de la segmentation par point: {e}", exc_info=True)
            raise SegmentationException(f"Erreur lors de la segmentation: {str(e)}")
    
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
        
        Raises:
            ModelNotLoadedException: Si le modèle n'est pas chargé
            SegmentationException: Si la segmentation échoue
        """
        if not self.is_loaded:
            raise ModelNotLoadedException("Le modèle SAM n'est pas chargé")
        
        try:
            # Valider les coordonnées
            if (x1 < 0 or y1 < 0 or x2 > image.shape[1] or y2 > image.shape[0] or
                x1 >= x2 or y1 >= y2):
                raise ValueError(
                    f"Coordonnées de boîte invalides: ({x1}, {y1}, {x2}, {y2}) "
                    f"pour une image {image.shape[1]}x{image.shape[0]}"
                )
            
            self.predictor.set_image(image)
            
            # Boîte délimitatrice
            input_box = np.array([x1, y1, x2, y2])
            
            masks, scores, _ = self.predictor.predict(
                box=input_box,
                multimask_output=False,
            )
            
            mask = masks[0].astype(np.uint8) * 255
            confidence = float(scores[0])
            
            logger.debug(f"Segmentation par boîte réussie: ({x1}, {y1}, {x2}, {y2}) avec confiance {confidence:.3f}")
            return mask, confidence
        
        except ValueError as e:
            logger.error(f"Erreur de validation: {e}")
            raise SegmentationException(f"Erreur de validation: {str(e)}")
        except Exception as e:
            logger.error(f"Erreur lors de la segmentation par boîte: {e}", exc_info=True)
            raise SegmentationException(f"Erreur lors de la segmentation: {str(e)}")
    
    def is_model_loaded(self) -> bool:
        """Vérifie si le modèle est chargé"""
        return self.is_loaded and self.model is not None and self.predictor is not None
    
    def reload_model(self):
        """Recharge le modèle"""
        logger.info("Rechargement du modèle SAM...")
        self._load_model()


# Instance globale du modèle
sam_model: SAMModel = None


def get_sam_model() -> SAMModel:
    """Getter pour l'instance globale du modèle SAM"""
    global sam_model
    if sam_model is None:
        logger.info("Initialisation du modèle SAM...")
        sam_model = SAMModel()
    return sam_model


def reload_sam_model():
    """Force le rechargement du modèle SAM"""
    global sam_model
    if sam_model is not None:
        sam_model.reload_model()

