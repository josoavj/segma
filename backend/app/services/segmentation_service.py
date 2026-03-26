import logging
import numpy as np
import os
from pathlib import Path
from app.exceptions import SegmentationException, ImageProcessingException
from app.models.sam3.image_processor import ImageProcessor
from app.services.object_detector import get_object_detector
from app.models.model_manager import model_manager

logger = logging.getLogger(__name__)

class SegmentationService:
    """Service orchestrateur pour la segmentation SAM 3 et l'étiquetage YOLO"""
    
    def __init__(self):
        # On récupère le wrapper SAM 3 via le manager singleton
        self.sam3_wrapper = model_manager.get_model()
        self.detector = get_object_detector()

    async def segment_by_prompt(
        self,
        image_path: str,
        prompt: str,
        confidence_threshold: float = 0.25,
        save_dir: str = None
    ) -> dict:
        """
        Pipeline complet : Charge l'image -> Segment avec SAM 3 -> 
        Étiquette avec YOLO -> Sauvegarde en .bin
        """
        try:
            logger.info(f"🚀 Démarrage Pipeline SAM 3 pour: {image_path} (Prompt: '{prompt}')")
            
            # 1. Chargement de l'image via ImageProcessor
            image = ImageProcessor.load_image(image_path)
            height, width = image.shape[:2]

            # 2. Détermination du répertoire de stockage (Contrainte client)
            if not save_dir:
                image_name = Path(image_path).stem
                # On crée un dossier dédié par image pour ne pas mélanger les .bin
                seg_dir = Path(image_path).parent / f".segmentation_{image_name}"
            else:
                seg_dir = Path(save_dir)
            
            seg_dir.mkdir(parents=True, exist_ok=True)

            # 3. Inférence SAM 3 (Promptable Concept Segmentation)
            # Utilise la méthode native du wrapper harmonisé
            raw_masks = self.sam3_wrapper.segment_by_text(image, prompt, threshold=confidence_threshold)
            
            if not raw_masks:
                logger.warning(f"Aucun objet trouvé pour le concept '{prompt}'")
                return {"objects": [], "count": 0}

            # 4. Traitement et enrichissement avec YOLO
            objects_data = []
            
            # On extrait les bboxes pour YOLO d'un coup pour optimiser les performances
            bboxes_for_yolo = [obj["bbox"] for obj in raw_masks]
            labels_map = self.detector.detect_labels(image, bboxes_for_yolo)

            for idx, obj in enumerate(raw_masks):
                # Conversion du tenseur en numpy binaire (0 ou 255)
                mask_np = ImageProcessor.tensor_to_mask(obj["mask"])
                
                # Calcul des pixels pour filtrer le bruit
                pixel_count = np.count_nonzero(mask_np)
                if pixel_count < 100: # Seuil de bruit
                    continue

                # Sauvegarde au format .bin (Brut / Même taille que l'originale)
                mask_filename = f"mask_{idx}.bin"
                mask_path = seg_dir / mask_filename
                
                # Écriture binaire directe
                mask_np.tofile(str(mask_path))

                # Construction de l'objet de retour
                objects_data.append({
                    "object_id": idx,
                    "label": labels_map.get(idx, prompt), # Priorité au label YOLO
                    "confidence": float(obj["score"]),
                    "bbox": obj["bbox"],
                    "mask_path": str(mask_path.absolute()),
                    "pixels_count": int(pixel_count)
                })

            return {
                "image_path": image_path,
                "resolution": f"{width}x{height}",
                "objects_count": len(objects_data),
                "objects": objects_data,
                "segmentation_dir": str(seg_dir.absolute())
            }

        except Exception as e:
            logger.error(f"❌ Erreur critique SegmentationService: {e}", exc_info=True)
            raise SegmentationException(f"Échec de la segmentation : {str(e)}")