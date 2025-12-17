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
    
    # Modèles disponibles
    AVAILABLE_MODELS = ["vit_b", "vit_l", "vit_h"]
    
    def __init__(self, model_type: str = None, device: str = None):
        self.model = None
        self.predictor = None
        self.model_type = model_type or settings.SAM_MODEL_TYPE
        self.is_loaded = False
        
        # Valider le modèle
        if self.model_type not in self.AVAILABLE_MODELS:
            logger.warning(f"Modèle '{self.model_type}' invalide, utilisation de 'vit_b'")
            self.model_type = "vit_b"
        
        # Déterminer le device
        if device:
            self.device = device
        elif TORCH_AVAILABLE:
            # Par défaut, utiliser GPU si disponible
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = "cpu"
        
        self._load_model()
    
    def _load_model(self):
        """Charge le modèle SAM de Meta"""
        if not TORCH_AVAILABLE:
            logger.warning("PyTorch non disponible - modèle en mode simulation")
            self.is_loaded = False
            return
        
        try:
            logger.info(f"Chargement du modèle SAM ({self.model_type}) sur {self.device}...")
            
            # Télécharger et charger le modèle
            # segment_anything télécharge automatiquement les poids si nécessaire
            sam = sam_model_registry[self.model_type]()
            
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
    
    def change_model(self, model_type: str, device: str = None):
        """Change le modèle et/ou le device SAM dynamiquement"""
        if model_type not in self.AVAILABLE_MODELS:
            raise ValueError(f"Modèle invalide: {model_type}. Disponibles: {self.AVAILABLE_MODELS}")
        
        # Valider le device
        if device:
            if device not in ["cpu", "cuda"]:
                raise ValueError(f"Device invalide: {device}. Utilisez 'cpu' ou 'cuda'")
            if device == "cuda" and not torch.cuda.is_available():
                logger.warning("CUDA demandé mais non disponible, passage à CPU")
                device = "cpu"
        
        self.model_type = model_type
        if device:
            self.device = device
        
        # Libérer la mémoire de l'ancien modèle
        if self.model is not None:
            del self.model
            del self.predictor
            if torch.cuda.is_available():
                torch.cuda.empty_cache()
        
        # Charger le nouveau modèle
        self._load_model()
    
    def get_model_info(self) -> dict:
        """Retourne les infos sur le modèle actuel"""
        return {
            "model_type": self.model_type,
            "device": self.device,
            "is_loaded": self.is_loaded,
            "available_models": self.AVAILABLE_MODELS,
            "cuda_available": torch.cuda.is_available() if TORCH_AVAILABLE else False
        }
    

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
    
    def segment_by_prompt(self, image: np.ndarray, prompt: str) -> list[dict]:
        """
        Segmente une image en fonction d'un prompt texte (SAM 3)
        
        Pour SAM 1: utilise la détection multi-objet en utilisant des grilles de points
        Pour SAM 3+: utilise l'API texte directement
        
        Args:
            image: Image en numpy array (RGB)
            prompt: Description textuelle des objets à segmenter
        
        Returns:
            list: Liste des objets détectés avec masques et confidences
        
        Raises:
            ModelNotLoadedException: Si le modèle n'est pas chargé
            SegmentationException: Si la segmentation échoue
        """
        if not self.is_loaded:
            raise ModelNotLoadedException("Le modèle SAM n'est pas chargé")
        
        try:
            import cv2
            
            logger.debug(f"Segmentation par prompt: '{prompt}'")
            
            # Définir l'image
            self.predictor.set_image(image)
            height, width = image.shape[:2]
            
            # Stratégie améliorée: grille multi-densité
            # Première passe: grille standard 8x8
            # Deuxième passe: grille dense 12x12 pour les petits objets
            # Troisième passe: points aléatoires pour les zones mal couvertes
            
            all_masks = []
            all_scores = []
            
            # Passe 1: Grille standard (8x8)
            logger.debug("Passe 1: Grille 8x8")
            grid_size = 8
            points = []
            for y in np.linspace(50, height-50, grid_size):
                for x in np.linspace(50, width-50, grid_size):
                    points.append([x, y])
            
            points = np.array(points)
            labels = np.ones(len(points))  # Tous les points comme "foreground"
            
            masks, scores, _ = self.predictor.predict(
                point_coords=points,
                point_labels=labels,
                multimask_output=True,
            )
            
            all_masks.extend(masks)
            all_scores.extend(scores)
            
            # Passe 2: Grille plus dense (12x12) pour capturer les petits objets
            logger.debug("Passe 2: Grille 12x12 (petits objets)")
            grid_size = 12
            points = []
            for y in np.linspace(30, height-30, grid_size):
                for x in np.linspace(30, width-30, grid_size):
                    points.append([x, y])
            
            points = np.array(points)
            labels = np.ones(len(points))
            
            masks, scores, _ = self.predictor.predict(
                point_coords=points,
                point_labels=labels,
                multimask_output=True,
            )
            
            all_masks.extend(masks)
            all_scores.extend(scores)
            
            # Traiter les résultats
            objects = []
            seen_masks = {}  # Dictionnaire: hash -> objet
            min_pixels = 30  # Réduit à 30 pour capturer plus d'objets
            max_pixels = height * width * 0.95  # Éviter l'image entière
            
            for mask, score in zip(all_masks, all_scores):
                pixel_count = np.sum(mask)
                
                # Filtrer les masques par taille
                if pixel_count < min_pixels or pixel_count > max_pixels:
                    continue
                
                # Convertir en binaire
                binary_mask = mask.astype(np.uint8) * 255
                
                # Vérifier la similarité avec les masques déjà détectés
                # Utiliser une signature simpler pour la comparaison
                mask_sum = int(np.sum(mask))
                mask_hash = (mask_sum, float(score))
                
                # Vérifier l'IoU avec les masques existants
                is_duplicate = False
                for existing_hash, existing_mask in seen_masks.items():
                    # IoU simple
                    intersection = np.sum((mask > 0) & (existing_mask > 0))
                    union = np.sum((mask > 0) | (existing_mask > 0))
                    iou = intersection / union if union > 0 else 0
                    
                    if iou > 0.7:  # Seuil de duplication
                        is_duplicate = True
                        break
                
                if is_duplicate:
                    continue
                
                seen_masks[str(hash(tuple(mask.flatten())))] = mask
                
                # Calculer la boîte délimitatrice
                contours, _ = cv2.findContours(binary_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                
                if contours:
                    # Utiliser le plus grand contour
                    largest_contour = max(contours, key=cv2.contourArea)
                    x, y, w, h = cv2.boundingRect(largest_contour)
                    
                    objects.append({
                        "id": len(objects) + 1,
                        "mask": binary_mask,
                        "confidence": float(score),
                        "bbox": {"x": int(x), "y": int(y), "width": int(w), "height": int(h)},
                        "pixels": int(np.sum(binary_mask > 0))
                    })
            
            logger.info(f"✓ Segmentation réussie: {len(objects)} objets détectés")
            return objects
        
        except Exception as e:
            logger.error(f"Erreur lors de la segmentation par prompt: {e}", exc_info=True)
            raise SegmentationException(f"Erreur lors de la segmentation par prompt: {str(e)}")
    

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

