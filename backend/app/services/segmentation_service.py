import logging
from app.models.sam_model import get_sam_model
from app.models.image_processor import ImageProcessor
import numpy as np

logger = logging.getLogger(__name__)


class SegmentationService:
    """Service de segmentation d'images"""
    
    @staticmethod
    def segment_image_by_point(
        image_path: str,
        x: int,
        y: int
    ) -> dict:
        """
        Segmente une image à partir d'un point cliqué
        
        Args:
            image_path: Chemin de l'image
            x, y: Coordonnées du point
        
        Returns:
            Dictionnaire contenant le masque et les métadonnées
        """
        try:
            # Charger l'image
            image = ImageProcessor.load_image(image_path)
            original_height, original_width = image.shape[:2]
            
            # Obtenir le modèle SAM
            sam = get_sam_model()
            
            # Segmenter
            mask, confidence = sam.segment_by_point(image, x, y)
            
            # Redimensionner le masque à la taille originale si nécessaire
            if mask.shape != (original_height, original_width):
                mask = np.uint8(mask > 128)
                mask = np.array(mask) * 255
            
            # Encoder le masque en base64
            import base64
            mask_bytes = ImageProcessor.mask_to_bytes(mask)
            mask_b64 = base64.b64encode(mask_bytes).decode('utf-8')
            
            return {
                'mask': mask_b64,
                'width': original_width,
                'height': original_height,
                'confidence': confidence,
            }
        
        except Exception as e:
            logger.error(f"Erreur lors de la segmentation: {e}")
            raise
    
    @staticmethod
    def segment_image_by_box(
        image_path: str,
        x1: int, y1: int,
        x2: int, y2: int
    ) -> dict:
        """
        Segmente une image à partir d'une boîte délimitatrice
        
        Args:
            image_path: Chemin de l'image
            x1, y1, x2, y2: Coordonnées de la boîte
        
        Returns:
            Dictionnaire contenant le masque et les métadonnées
        """
        try:
            # Charger l'image
            image = ImageProcessor.load_image(image_path)
            original_height, original_width = image.shape[:2]
            
            # Obtenir le modèle SAM
            sam = get_sam_model()
            
            # Segmenter
            mask, confidence = sam.segment_by_box(image, x1, y1, x2, y2)
            
            # Redimensionner le masque à la taille originale si nécessaire
            if mask.shape != (original_height, original_width):
                mask = np.uint8(mask > 128)
                mask = np.array(mask) * 255
            
            # Encoder le masque en base64
            import base64
            mask_bytes = ImageProcessor.mask_to_bytes(mask)
            mask_b64 = base64.b64encode(mask_bytes).decode('utf-8')
            
            return {
                'mask': mask_b64,
                'width': original_width,
                'height': original_height,
                'confidence': confidence,
            }
        
        except Exception as e:
            logger.error(f"Erreur lors de la segmentation: {e}")
            raise
