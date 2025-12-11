import cv2
import numpy as np
from PIL import Image
import logging

logger = logging.getLogger(__name__)


class ImageProcessor:
    """Classe utilitaire pour le traitement d'images"""
    
    @staticmethod
    def load_image(image_path: str) -> np.ndarray:
        """
        Charge une image à partir d'un chemin fichier
        
        Args:
            image_path: Chemin de l'image
        
        Returns:
            Image en format RGB (numpy array)
        """
        try:
            # Utiliser PIL pour lire
            img = Image.open(image_path).convert('RGB')
            # Convertir en numpy array
            img_array = np.array(img)
            return img_array
        except Exception as e:
            logger.error(f"Erreur lors du chargement de l'image {image_path}: {e}")
            raise
    
    @staticmethod
    def get_image_dimensions(image_path: str) -> tuple[int, int]:
        """
        Récupère les dimensions d'une image
        
        Returns:
            tuple: (largeur, hauteur)
        """
        try:
            img = Image.open(image_path)
            return img.width, img.height
        except Exception as e:
            logger.error(f"Erreur lors de la lecture des dimensions: {e}")
            raise
    
    @staticmethod
    def resize_image(image: np.ndarray, max_size: int = 1024) -> np.ndarray:
        """
        Redimensionne une image pour qu'elle rentre dans max_size
        
        Args:
            image: Image en numpy array
            max_size: Taille maximale (largeur ou hauteur)
        
        Returns:
            Image redimensionnée
        """
        height, width = image.shape[:2]
        if max(width, height) > max_size:
            scale = max_size / max(width, height)
            new_width = int(width * scale)
            new_height = int(height * scale)
            image = cv2.resize(image, (new_width, new_height))
        return image
    
    @staticmethod
    def save_mask(mask: np.ndarray, output_path: str) -> None:
        """
        Sauvegarde un masque binaire
        
        Args:
            mask: Masque en numpy array (0-255)
            output_path: Chemin de sortie
        """
        try:
            Image.fromarray(mask).save(output_path)
            logger.info(f"Masque sauvegardé: {output_path}")
        except Exception as e:
            logger.error(f"Erreur lors de la sauvegarde du masque: {e}")
            raise
    
    @staticmethod
    def mask_to_bytes(mask: np.ndarray) -> bytes:
        """
        Convertit un masque en bytes (format PNG)
        
        Args:
            mask: Masque en numpy array
        
        Returns:
            Bytes de l'image PNG
        """
        try:
            img = Image.fromarray(mask)
            # Sauvegarder en mémoire
            import io
            buffer = io.BytesIO()
            img.save(buffer, format='PNG')
            return buffer.getvalue()
        except Exception as e:
            logger.error(f"Erreur lors de la conversion du masque: {e}")
            raise
