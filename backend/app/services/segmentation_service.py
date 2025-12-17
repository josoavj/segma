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
from app.services.object_detector import get_object_detector

logger = logging.getLogger(__name__)

# Importer SAM3 officiel
try:
    from app.models.sam3_model import get_sam3_model
    SAM3_AVAILABLE = True
except ImportError as e:
    SAM3_AVAILABLE = False
    logger.error(f"SAM3 non disponible: {e}")


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
            
            # Utiliser SAM3 réel
            if not SAM3_AVAILABLE:
                raise SegmentationException(
                    "SAM3 non installé. Exécutez: pip install -r requirements.txt"
                )
            
            logger.info("🚀 Utilisation SAM3 officiel")
            sam3_model = get_sam3_model()
            objects_data = SegmentationService._segment_with_sam3(
                image, sam3_model, prompt, confidence_threshold, seg_dir, width, height
            )
            
            logger.info(f"✓ Segmentation réussie: {len(objects_data)} objets détectés")
            
            return {
                "image_path": image_path,
                "width": width,
                "height": height,
                "objects_count": len(objects_data),
                "objects": objects_data,
                "segmentation_dir": str(seg_dir.absolute())
            }
        
        except (ImageProcessingException, SegmentationException):
            raise
        except Exception as e:
            logger.error(f"Erreur non attendue: {e}", exc_info=True)
            raise SegmentationException(f"Erreur interne: {str(e)}")
    
    @staticmethod
    def _segment_with_sam3(image, sam3_model, prompt, threshold, seg_dir, width, height):
        """Segmentation réelle avec SAM3 officiel"""
        try:
            logger.info(f"SAM3: Segmentation '{prompt}'")
            
            # Obtenir la segmentation SAM3
            # Retourne une liste de dicts avec keys: object_id, label, confidence, bbox, mask, pixels_count
            objects_raw = sam3_model.segment_by_text_prompt(
                image, prompt, confidence_threshold=threshold
            )
            
            if not objects_raw:
                logger.warning(f"SAM3: Aucun objet détecté pour '{prompt}'")
                return []
            
            # Préparer bboxes pour YOLO (optionnel si on veut affiner les labels)
            bboxes = []
            for obj in objects_raw:
                bbox = obj["bbox"]
                bboxes.append(bbox)
            
            # Optionnel: détecter labels avec YOLO pour plus de précision
            detector = get_object_detector()
            detected_labels = detector.detect_labels(image, bboxes) if bboxes else {}
            
            objects = []
            for idx, obj in enumerate(objects_raw):
                mask = obj["mask"]
                
                # Convertir masque en format binaire (0-255)
                if mask.dtype != np.uint8:
                    mask = (mask.astype(bool).astype(np.uint8)) * 255
                
                # Filtrer les petites zones (bruit)
                pixels = np.count_nonzero(mask)
                if pixels < 50:
                    logger.debug(f"SAM3: Objet #{obj['object_id']} ignoré (trop petit: {pixels} px)")
                    continue
                
                # Sauvegarder le masque
                object_id = obj["object_id"]
                mask_filename = f"mask_{object_id}.bin"
                mask_path = seg_dir / mask_filename
                
                try:
                    mask.tofile(str(mask_path))
                    logger.debug(f"SAM3: Masque sauvegardé #{object_id} ({pixels} px)")
                except Exception as e:
                    logger.error(f"SAM3: Erreur sauvegarde masque: {e}")
                    continue
                
                # Label: préférer YOLO si disponible, sinon utiliser concept SAM3
                label = detected_labels.get(idx, obj.get("label", f"object_{object_id}"))
                
                # Bounding box - s'assurer qu'elle est dans les limites
                bbox = obj["bbox"]
                bbox_dict = {
                    "x1": int(max(0, bbox["x1"])),
                    "y1": int(max(0, bbox["y1"])),
                    "x2": int(min(width, bbox["x2"])),
                    "y2": int(min(height, bbox["y2"]))
                }
                
                objects.append({
                    "object_id": object_id,
                    "label": label,
                    "confidence": float(round(float(obj["confidence"]), 4)),
                    "bbox": bbox_dict,
                    "mask_path": str(mask_path),
                    "pixels_count": int(pixels)
                })
            
            logger.info(f"SAM3: {len(objects)} objet(s) détecté(s)")
            return objects
        
        except Exception as e:
            logger.error(f"SAM3 segmentation error: {e}", exc_info=True)
            raise SegmentationException(f"Erreur SAM3: {str(e)}")
