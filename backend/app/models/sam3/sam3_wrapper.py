import logging
import torch
import numpy as np
from PIL import Image
from transformers import Sam3Processor, Sam3Model
from config import settings

logger = logging.getLogger(__name__)

class SAM3Wrapper:
    def __init__(self, device: str = None):
        # Détection automatique du GPU (CUDA est fortement recommandé pour SAM 3)
        if device is None:
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device

        self.model_id = settings.SAM3_MODEL_ID
            
        try:
            logger.info(f"Chargement de SAM 3 sur {self.device}...")
            self.processor = Sam3Processor.from_pretrained(self.model_id)
            self.model = Sam3Model.from_pretrained(self.model_id).to(self.device)
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
            
            # Post-processing SAM3: retour d'instances avec masks/scores/boxes
            target_size = (image_pil.height, image_pil.width)
            predictions = self.processor.post_process_instance_segmentation(
                outputs,
                threshold=threshold,
                target_sizes=[target_size],
            )
            
            # Construire la liste des résultats
            results = []

            if predictions and isinstance(predictions[0], dict):
                pred = predictions[0]
                masks = pred.get("masks")
                scores = pred.get("scores")
                boxes = pred.get("boxes")

                if isinstance(masks, torch.Tensor):
                    masks = masks.cpu().numpy()
                if isinstance(scores, torch.Tensor):
                    scores = scores.cpu().numpy()
                if isinstance(boxes, torch.Tensor):
                    boxes = boxes.cpu().numpy()

                masks = np.array(masks) if masks is not None else np.empty((0,))
                scores = np.array(scores) if scores is not None else np.empty((0,))
                boxes = np.array(boxes) if boxes is not None else np.empty((0, 4))

                for idx, mask in enumerate(masks):
                    mask_np = (mask > 0).astype(np.uint8)
                    score = float(scores[idx]) if idx < len(scores) else 0.0

                    if idx < len(boxes):
                        x1, y1, x2, y2 = boxes[idx].tolist()
                        bbox = {
                            "x1": int(x1),
                            "y1": int(y1),
                            "x2": int(x2),
                            "y2": int(y2),
                        }
                    else:
                        bbox = self._compute_bbox_from_mask(mask_np)

                    results.append({
                        "mask": mask_np,
                        "score": score,
                        "bbox": bbox,
                    })
            
            logger.info(f"✓ SAM 3 détecté {len(results)} objets pour prompt: '{prompt}'")
            return results
            
        except Exception as e:
            logger.error(f" Erreur dans segment_by_text: {e}", exc_info=True)
            return []