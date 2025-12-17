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

# Essayer d'importer SAM et le modèle
try:
    from app.models.sam_model import get_sam_model
    SAM_AVAILABLE = True
except ImportError:
    SAM_AVAILABLE = False
    logger.warning("SAM 3 non disponible - mode simulation")


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
            
            # Utiliser SAM 3 réel si disponible, sinon simulation
            if SAM_AVAILABLE:
                logger.info("🚀 Mode SAM 3 réel")
                sam_model = get_sam_model()
                if sam_model.is_model_loaded():
                    objects_data = SegmentationService._segment_with_sam3(
                        image, sam_model, prompt, confidence_threshold, seg_dir
                    )
                else:
                    logger.warning("Modèle SAM3 non chargé, passage en simulation")
                    objects_data = SegmentationService._simulate_segmentation(
                        image, prompt, confidence_threshold, width, height, seg_dir
                    )
            else:
                logger.info("📊 Mode simulation (SAM 3 non installé)")
                objects_data = SegmentationService._simulate_segmentation(
                    image, prompt, confidence_threshold, width, height, seg_dir
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
    def _segment_with_sam3(image, sam_model, prompt, threshold, seg_dir):
        """Segmentation réelle avec SAM 3 + labels YOLO"""
        try:
            # Obtenir la segmentation du modèle
            objects_raw = sam_model.segment_by_prompt(image, prompt)
            
            if not objects_raw:
                logger.warning("Aucun objet détecté par SAM 3")
                return []
            
            # Normaliser les scores SAM
            scores = [obj["confidence"] for obj in objects_raw]
            min_score = min(scores) if scores else 0
            max_score = max(scores) if scores else 1
            score_range = max_score - min_score if max_score > min_score else 1
            
            # Préparer les bboxes pour la détection d'objets (normaliser le format)
            bboxes = []
            for obj in objects_raw:
                bbox = obj["bbox"]
                # Convertir de {"x": int, "y": int, "width": int, "height": int} 
                # à {"x1": int, "y1": int, "x2": int, "y2": int}
                if "x1" in bbox:
                    bboxes.append(bbox)
                else:
                    # Format SAM: x, y, width, height
                    bboxes.append({
                        "x1": bbox["x"],
                        "y1": bbox["y"],
                        "x2": bbox["x"] + bbox["width"],
                        "y2": bbox["y"] + bbox["height"]
                    })
            
            # Détecter les labels avec YOLO
            detector = get_object_detector()
            detected_labels = detector.detect_labels(image, bboxes)
            logger.debug(f"Labels détectés par YOLO: {detected_labels}")
            
            objects = []
            for idx, obj in enumerate(objects_raw):
                # Normaliser la confiance
                normalized_confidence = (obj["confidence"] - min_score) / score_range if score_range > 0 else 0.5
                normalized_confidence = max(0, min(1, normalized_confidence))
                
                # Garder les objets avec une bonne zone de pixels (minimum 50 pixels)
                if obj["pixels"] < 50:
                    logger.debug(f"Objet ignoré (trop petit): {obj['pixels']} pixels")
                    continue
                
                # Obtenir le label depuis YOLO
                label = detected_labels.get(idx, f"object_{obj['id']}")
                
                # Normaliser la bbox SAM
                bbox = obj["bbox"]
                if "x1" not in bbox:
                    normalized_bbox = {
                        "x1": bbox["x"],
                        "y1": bbox["y"],
                        "x2": bbox["x"] + bbox["width"],
                        "y2": bbox["y"] + bbox["height"]
                    }
                else:
                    normalized_bbox = bbox
                
                mask = obj["mask"]
                mask_filename = f"mask_{obj['id']}.bin"
                mask_path = seg_dir / mask_filename
                
                try:
                    mask.tofile(str(mask_path))
                    logger.debug(f"Masque SAM3 sauvegardé: {mask_path}")
                except Exception as e:
                    logger.error(f"Erreur sauvegarde masque: {e}")
                    continue
                
                objects.append({
                    "object_id": obj["id"],
                    "label": label,  # Label YOLO en anglais
                    "confidence": round(normalized_confidence, 4),
                    "bbox": normalized_bbox,
                    "mask_path": str(mask_path),
                    "pixels_count": int(obj["pixels"])
                })
            
            logger.info(f"Après normalisation et labels: {len(objects)} objets conservés")
            return objects
        except Exception as e:
            logger.error(f"Erreur SAM3: {e}", exc_info=True)
            raise
    
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
                "label": "person",
                "confidence": 0.95,
                "bbox": {"x1": 50, "y1": 50, "x2": 300, "y2": 300},
                "region": (50, 50, 250, 250)  # (y1, x1, y2, x2)
            },
            {
                "id": 2,
                "label": "dog",
                "confidence": 0.87,
                "bbox": {"x1": 320, "y1": 100, "x2": 550, "y2": 350},
                "region": (100, 320, 250, 550)
            },
            {
                "id": 3,
                "label": "cat",
                "confidence": 0.72,
                "bbox": {"x1": 200, "y1": 350, "x2": 450, "y2": 550},
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
            bbox = detection["bbox"]
            
            objects.append({
                "object_id": detection["id"],
                "label": detection["label"],
                "confidence": round(detection["confidence"], 4),
                "bbox": bbox,
                "mask_path": str(mask_path),
                "pixels_count": int(pixels)
            })
        
        return objects
