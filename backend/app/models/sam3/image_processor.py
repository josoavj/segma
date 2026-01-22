import numpy as np
import cv2
from PIL import Image
import logging

logger = logging.getLogger(__name__)

class ImageProcessor:
    """Utilitaire complet pour le traitement d'images et de masques pour SAM 3"""

    @staticmethod
    def load_image(image_path: str) -> np.ndarray:
        """Charge une image et la convertit en RGB pour SAM 3"""
        image = cv2.imread(image_path)
        if image is None:
            raise FileNotFoundError(f"Impossible de charger l'image : {image_path}")
        return cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    @staticmethod
    def get_image_dimensions(image_path: str):
        """Récupère (width, height) sans charger toute l'image en mémoire (via PIL)"""
        with Image.open(image_path) as img:
            return img.size  # Retourne (largeur, hauteur)

    @staticmethod
    def tensor_to_mask(mask_tensor) -> np.ndarray:
        """
        Convertit un tenseur de sortie SAM 3 en masque numpy binaire.
        Le masque est redimensionné automatiquement par SAM 3, 
        on s'assure ici du format uint8 (0 ou 255).
        """
        # Conversion CPU et extraction numpy
        mask = mask_tensor.cpu().numpy().squeeze()
        
        # Seuil de binarisation (True/False -> 255/0)
        return (mask > 0).astype(np.uint8) * 255

    @staticmethod
    def save_binary_mask(mask_np: np.ndarray, save_path: str):
        """
        Sauvegarde le masque au format binaire brut (.bin).
        Chaque pixel = 1 octet.
        """
        try:
            mask_np.tofile(save_path)
            return True
        except Exception as e:
            logger.error(f"Erreur lors de l'écriture du fichier .bin : {e}")
            return False

    @staticmethod
    def overlay_mask(image_rgb: np.ndarray, mask_np: np.ndarray, alpha: float = 0.5):
        """
        Optionnel : Superpose le masque sur l'image (pour debug ou export visuel).
        Utile si tu veux vérifier tes masques côté serveur.
        """
        color_mask = np.zeros_like(image_rgb)
        color_mask[mask_np > 0] = [0, 255, 0]  # Vert pour l'objet
        return cv2.addWeighted(image_rgb, 1, color_mask, alpha, 0)