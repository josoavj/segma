"""
Wrapper SAM3 corrigé pour éviter les problèmes CUDA
"""

import logging
import os
import torch
import numpy as np
from pathlib import Path
from typing import Optional, Dict, List
from config import settings

logger = logging.getLogger(__name__)

# Désactiver CUDA AVANT d'importer SAM3
if os.environ.get("CUDA_VISIBLE_DEVICES") != "" and not torch.cuda.is_available():
    os.environ["CUDA_VISIBLE_DEVICES"] = ""

try:
    # Import SAM3
    from sam3.model_builder import build_sam3_image_model
    from sam3.model.sam3_image_processor import Sam3Processor
    SAM3_AVAILABLE = True
    logger.info("✅ SAM3 importé avec succès")
except ImportError as e:
    SAM3_AVAILABLE = False
    logger.warning(f"⚠️ SAM3 non disponible: {e}")


class SAM3ModelWrapper:
    """Wrapper pour SAM3 avec gestion CPU"""
    
    def __init__(self, device: str = "cpu"):
        """
        Initialise SAM3
        
        Args:
            device: 'cpu' ou 'cuda'
        """
        self.device = device
        self.model = None
        self.processor = None
        self.is_loaded = False
        
        if SAM3_AVAILABLE:
            self._load_model()
        else:
            logger.warning("SAM3 non disponible")
    
    def _load_model(self):
        """Charge le modèle SAM3"""
        if not SAM3_AVAILABLE:
            return
        
        try:
            # Forcer CPU si CUDA n'est pas disponible
            device = self.device
            if device == "cuda" and not torch.cuda.is_available():
                logger.warning("CUDA demandé mais non disponible, utilisation de CPU")
                device = "cpu"
            
            logger.info(f"📥 Chargement SAM3 sur {device.upper()}...")
            
            # Charger le modèle avec les vrais poids depuis HuggingFace
            self.model = build_sam3_image_model(
                device=device, 
                eval_mode=True,
                checkpoint_path=None,
                load_from_HF=True  # Télécharger depuis HuggingFace
            )
            
            # Initialiser le processeur
            self.processor = Sam3Processor(self.model, device=device)
            
            self.device = device
            self.is_loaded = True
            
            logger.info(f"✅ SAM3 chargé sur {device.upper()}")
        
        except Exception as e:
            logger.error(f"❌ Erreur SAM3: {e}", exc_info=True)
            self.is_loaded = False
    
    def segment_by_text_prompt(
        self,
        image: np.ndarray,
        prompt: str,
        confidence_threshold: float = 0.0
    ) -> List[Dict]:
        """
        Segmente une image à partir d'un prompt texte
        
        Args:
            image: Image numpy (H, W, 3) RGB
            prompt: Description textuelle (ex: "person", "car")
            confidence_threshold: Seuil minimum de confiance
        
        Returns:
            Liste des objets segmentés
        """
        if not self.is_loaded:
            logger.error("SAM3 non chargé")
            return []
        
        try:
            from PIL import Image
            
            # Convertir numpy en PIL
            if isinstance(image, np.ndarray):
                image_pil = Image.fromarray(image.astype(np.uint8))
            else:
                image_pil = image
            
            logger.info(f"🔍 Segmentation SAM3: '{prompt}'")
            
            # Mettre l'image dans le processeur
            # SAM3 attend une image PIL ou tensor
            batched_mode = True
            inference_state = self.processor.set_image(image_pil)
            
            # Ajouter prompt texte
            masks, scores, logits = self.processor(
                image_pil,
                text_prompt=prompt,
                return_logits=False
            )
            
            # Extraire les résultats
            objects = []
            
            if masks is not None:
                masks = masks.cpu().numpy() if hasattr(masks, 'cpu') else np.array(masks)
                scores = scores.cpu().numpy() if hasattr(scores, 'cpu') else np.array(scores)
                
                for idx, (mask, score) in enumerate(zip(masks, scores)):
                    if score < confidence_threshold:
                        continue
                    
                    # Calculer la boîte englobante depuis le masque
                    h, w = image.shape[:2]
                    coords = np.argwhere(mask > 0)
                    if len(coords) > 0:
                        y1, x1 = coords.min(axis=0)
                        y2, x2 = coords.max(axis=0)
                    else:
                        x1, y1, x2, y2 = 0, 0, w, h
                    
                    objects.append({
                        "object_id": idx + 1,
                        "label": prompt,
                        "confidence": float(score),
                        "bbox": {
                            "x1": int(x1),
                            "y1": int(y1),
                            "x2": int(x2),
                            "y2": int(y2)
                        },
                        "mask": mask,
                        "pixels_count": int((mask > 0).sum())
                    })
            
            logger.info(f"✅ Segmentation réussie: {len(objects)} objets")
            return objects
        
        except Exception as e:
            logger.error(f"❌ Erreur segmentation SAM3: {e}", exc_info=True)
            return []
    
    def segment_by_point(
        self,
        image: np.ndarray,
        x: int,
        y: int
    ) -> tuple:
        """
        Segmente à partir d'un point
        
        Args:
            image: Image numpy
            x, y: Coordonnées du point
        
        Returns:
            (mask, confidence)
        """
        if not self.is_loaded:
            return None, 0.0
        
        try:
            from PIL import Image
            
            if isinstance(image, np.ndarray):
                image_pil = Image.fromarray(image.astype(np.uint8))
            else:
                image_pil = image
            
            # Mettre l'image dans le processeur
            self.processor.set_image(image_pil)
            
            # Segmenter avec un point
            masks, scores, logits = self.processor(
                image_pil,
                point_coords=np.array([[x, y]]),
                return_logits=False
            )
            
            if masks is not None and len(masks) > 0:
                mask = masks[0].cpu().numpy() if hasattr(masks[0], 'cpu') else np.array(masks[0])
                score = float(scores[0].cpu() if hasattr(scores[0], 'cpu') else scores[0])
                return mask, score
            
            return None, 0.0
        
        except Exception as e:
            logger.error(f"Erreur segmentation point: {e}")
            return None, 0.0
    
    def get_info(self) -> Dict:
        """Retourne les infos du modèle"""
        return {
            "model_type": "SAM3",
            "device": self.device,
            "is_loaded": self.is_loaded,
            "version": "3.0",
            "capabilities": [
                "text_prompts",
                "point_prompts",
            ]
        }


# Instance globale
_sam3_instance: Optional[SAM3ModelWrapper] = None


def get_sam3_model() -> SAM3ModelWrapper:
    """Singleton pattern pour SAM3"""
    global _sam3_instance
    if _sam3_instance is None:
        device = settings.DEVICE if hasattr(settings, 'DEVICE') else 'cpu'
        _sam3_instance = SAM3ModelWrapper(device=device)
    return _sam3_instance
