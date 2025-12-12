"""
Service de segmentation avec SAM 3 et prompts textuels
Sauvegarde les masques binaires dans .segmentation/
"""

import logging
import numpy as np
import os
from pathlib import Path
from app.exceptions import SegmentationException, ImageProcessingException
from app.models.image_processor import ImageProcessor

logger = logging.getLogger(__name__)


class SegmentationService:
    """Service de segmentation multi-objets par prompt"""
    
    @staticmethod
    def segment_by_prompt(
        image_path: str,
        prompt: str,
        confidence_threshold: float = 0.5,
        save_dir: str = None
    ) -> dict:
        """
        Segmente une image à partir d'un prompt texte
        
        Sauvegarde chaque masque segmenté dans un répertoire
        avec la même taille que l'image originale
        
        Chaque masque: zone segmentée = 255 (blanc), reste = 0 (noir)
        
        Args:
            image_path: Chemin absolu de l'image
            prompt: Description des objets (ex: "tous les animaux")
            confidence_threshold: Seuil minimum de confiance
            save_dir: Répertoire de sauvegarde (optionnel)
                      Par défaut: .segmentation_<image_name> à côté de l'image
        
        Returns:
            Dict contenant la liste des objets segmentés
        """
        try:
            logger.info(f"Début segmentation: {image_path}")
            logger.info(f"  Prompt: '{prompt}'")
            logger.info(f"  Threshold: {confidence_threshold}")
            
            # Charger l'image
            try:
                image = ImageProcessor.load_image(image_path)
                height, width = image.shape[:2]
                logger.debug(f"Image chargée: {width}x{height}")
            except FileNotFoundError:
                logger.error(f"Image non trouvée: {image_path}")
                raise
            except Exception as e:
                logger.error(f"Erreur chargement image: {e}")
                raise ImageProcessingException(f"Erreur chargement: {str(e)}")
            
            # Déterminer le répertoire de sauvegarde
            if save_dir:
                seg_dir = Path(save_dir)
                logger.info(f"Répertoire personnalisé spécifié: {seg_dir}")
            else:
                # Répertoire par défaut à côté de l'image
                image_name = Path(image_path).stem
                seg_dir = Path(image_path).parent / f".segmentation_{image_name}"
                logger.info(f"Répertoire par défaut: {seg_dir}")
            
            # Créer le répertoire
            seg_dir.mkdir(parents=True, exist_ok=True)
            
            # SIMULATION: SAM 3 avec prompt texte
            # En production: from segment_anything_3 import SAM3
            # sam = SAM3()
            # objects = sam.predict(image, text_prompt=prompt)
            
            simulated_objects = SegmentationService._simulate_segmentation(
                image, prompt, confidence_threshold, width, height, seg_dir
            )
            
            logger.info(f"✓ Segmentation réussie: {len(simulated_objects)} objets détectés")
            
            return {
                "image_path": image_path,
                "width": width,
                "height": height,
                "objects_count": len(simulated_objects),
                "objects": simulated_objects,
                "segmentation_dir": str(seg_dir.absolute())
            }
        
        except (ImageProcessingException, SegmentationException):
            raise
        except Exception as e:
            logger.error(f"Erreur non attendue: {e}", exc_info=True)
            raise SegmentationException(f"Erreur interne: {str(e)}")
    
    @staticmethod
    def _simulate_segmentation(image, prompt, threshold, width, height, seg_dir):
        """
        Simulation: génère des masques binaires pour la démo
        En production, ce code sera remplacé par SAM 3
        """
        objects = []
        
        # Simulation de 3 objets détectés
        simulated_detections = [
            {
                "id": 1,
                "label": "objet 1",
                "confidence": 0.95,
                "bbox": (50, 50, 300, 300),
                "region": (50, 50, 250, 250)  # (y1, x1, y2, x2)
            },
            {
                "id": 2,
                "label": "objet 2",
                "confidence": 0.87,
                "bbox": (320, 100, 550, 350),
                "region": (100, 320, 250, 550)
            },
            {
                "id": 3,
                "label": "objet 3",
                "confidence": 0.72,
                "bbox": (200, 350, 450, 550),
                "region": (350, 200, 400, 450)
            }
        ]
        
        for detection in simulated_detections:
            if detection["confidence"] < threshold:
                continue
            
            # Créer masque binaire
            mask = np.zeros((height, width), dtype=np.uint8)
            y1, x1, y2, x2 = detection["region"]
            mask[y1:y2, x1:x2] = 255
            
            # Sauvegarder masque
            mask_filename = f"mask_{detection['id']}.bin"
            mask_path = seg_dir / mask_filename
            
            try:
                mask.tofile(str(mask_path))
                logger.debug(f"Masque sauvegardé: {mask_path}")
                pixels = np.count_nonzero(mask)
            except Exception as e:
                logger.error(f"Erreur sauvegarde masque: {e}")
                continue
            
            # Calculer boîte englobante
            bbox_x1, bbox_y1, bbox_x2, bbox_y2 = detection["bbox"]
            
            objects.append({
                "object_id": detection["id"],
                "label": detection["label"],
                "confidence": round(detection["confidence"], 4),
                "bbox": {
                    "x1": bbox_x1,
                    "y1": bbox_y1,
                    "x2": bbox_x2,
                    "y2": bbox_y2
                },
                "mask_path": str(mask_path),
                "pixels_count": int(pixels)
            })
        
        return objects
