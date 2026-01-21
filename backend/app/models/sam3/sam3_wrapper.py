import logging
import torch
import numpy as np
from PIL import Image
from transformers import Sam3Processor, Sam3Model

logger = logging.getLogger(__name__)

class SAM3Wrapper:
    def __init__(self, device: str = None):
        # Détection automatique du GPU (CUDA est fortement recommandé pour SAM 3)
        if device is None:
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device
            
        try:
            logger.info(f"Chargement de SAM 3 sur {self.device}...")
            self.processor = Sam3Processor.from_pretrained("facebook/sam3")
            self.model = Sam3Model.from_pretrained("facebook/sam3").to(self.device)
            self.is_loaded = True
            logger.info("✓ SAM 3 opérationnel (Mode PCS activé)")
        except Exception as e:
            logger.error(f"Erreur chargement SAM 3: {e}")
            self.is_loaded = False

    def _compute_bbox_from_mask(self, mask: np.ndarray) -> dict:
        """Calcule la boîte englobante à partir d'un masque binaire"""
        coords = np.argwhere(mask > 0)
        if len(coords) == 0:
            h, w = mask.shape
            return {"x1": 0, "y1": 0, "x2": w, "y2": h}
        
        y_coords = coords[:, 0]
        x_coords = coords[:, 1]
        y1, y2 = y_coords.min(), y_coords.max()
        x1, x2 = x_coords.min(), x_coords.max()
        
        return {
            "x1": int(x1),
            "y1": int(y1),
            "x2": int(x2),
            "y2": int(y2)
        }

    def segment_by_text(self, image: np.ndarray, prompt: str, threshold: float = 0.25):
        """
        Segment tous les objets correspondant au concept textuel (SAM 3 PCS).
        
        Args:
            image: numpy array (H, W, 3) en RGB
            prompt: Texte décrivant les objets (ex: "boulons rouillés")
            threshold: Seuil de confiance pour le post-processing
        
        Returns:
            Liste de dictionnaires avec structure:
            [
                {
                    "mask": np.ndarray (H, W) binaire,
                    "score": float confiance,
                    "bbox": {"x1", "y1", "x2", "y2"}
                },
                ...
            ]
        """
        if not self.is_loaded:
            return []

        try:
            # Convertir l'image numpy en PIL si nécessaire
            if isinstance(image, np.ndarray):
                image_pil = Image.fromarray(image.astype(np.uint8))
            else:
                image_pil = image
            
            # Traiter l'image avec le processor (conversion en tenseur + normalisation)
            inputs = self.processor(
                images=image_pil, 
                text=prompt, 
                return_tensors="pt"
            ).to(self.device)
            
            # Inférence du modèle
            with torch.no_grad():
                outputs = self.model(**inputs)
            
            # Post-processing pour redimensionner les masques à la taille originale
            masks = self.processor.post_process_masks(
                outputs.pred_masks, 
                inputs.original_sizes, 
                inputs.reshaped_input_sizes,
                threshold=threshold
            )
            
            # Récupérer les scores de confiance
            scores = outputs.iou_predictions if hasattr(outputs, 'iou_predictions') else None
            
            # Construire la liste des résultats
            results = []
            
            if masks is not None:
                # Convertir les masques en numpy s'ils sont des tenseurs
                if hasattr(masks, 'cpu'):
                    masks = masks.cpu().numpy()
                elif isinstance(masks, torch.Tensor):
                    masks = masks.numpy()
                
                # S'assurer que masks est un array (H, W, N) ou (N, H, W)
                if masks.ndim == 4:  # (1, N, H, W)
                    masks = masks.squeeze(0)
                elif masks.ndim == 2:  # Un seul masque (H, W)
                    masks = masks.unsqueeze(0) if hasattr(masks, 'unsqueeze') else masks[np.newaxis, ...]
                
                # Traiter chaque masque
                for idx, mask in enumerate(masks):
                    # Normaliser le masque à 0-1 ou 0-255
                    if mask.max() > 1:
                        mask = (mask > 0).astype(np.uint8)
                    else:
                        mask = (mask > 0.5).astype(np.uint8)
                    
                    # Obtenir le score (par défaut 0.9 si pas disponible)
                    if scores is not None:
                        if hasattr(scores, 'cpu'):
                            scores_np = scores.cpu().numpy()
                        else:
                            scores_np = np.array(scores)
                        
                        # Gérer les dimensions multiples
                        if scores_np.ndim > 1:
                            score = float(scores_np.flatten()[idx]) if idx < len(scores_np.flatten()) else 0.9
                        else:
                            score = float(scores_np[idx]) if idx < len(scores_np) else 0.9
                    else:
                        score = 0.9
                    
                    # Calculer la boîte englobante
                    bbox = self._compute_bbox_from_mask(mask)
                    
                    results.append({
                        "mask": mask,
                        "score": score,
                        "bbox": bbox
                    })
            
            logger.info(f"✓ SAM 3 détecté {len(results)} objets pour prompt: '{prompt}'")
            return results
            
        except Exception as e:
            logger.error(f" Erreur dans segment_by_text: {e}", exc_info=True)
            return []