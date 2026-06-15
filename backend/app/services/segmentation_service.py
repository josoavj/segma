import logging
import numpy as np
import os
import re
from pathlib import Path

from app.exceptions import SegmentationException
from app.models.model_manager import model_manager

logger = logging.getLogger(__name__)

class SegmentationService:
    """Service orchestrateur pour la segmentation SAM 3 et l'étiquetage YOLO"""
    
    def __init__(self):
        self._detector = None

    @property
    def sam3_wrapper(self):
        return model_manager.get_model()

    @property
    def detector(self):
        if self._detector is None:
            from app.services.object_detector import get_object_detector

            self._detector = get_object_detector()
        return self._detector

    def _normalize_text_prompt(self, prompt: str) -> str:
        """Transforme une question utilisateur en concept segmentable par SAM 3."""
        cleaned_prompt = prompt.strip()
        normalized = re.sub(r"\s+", " ", cleaned_prompt)

        query_patterns = [
            r"^(?:ou|où)\s+(?:est|sont)\s+(?:le|la|les|l'|un|une|des)?\s*(.+?)[?.!]*$",
            r"^where\s+(?:is|are)\s+(?:the|a|an)?\s*(.+?)[?.!]*$",
            (
                r"^(?:montre|montrez|trouve|trouvez|detecte|détecte|segmente)"
                r"\s+(?:moi\s+)?(?:le|la|les|l'|un|une|des)?\s*(.+?)[?.!]*$"
            ),
            r"^(?:show|find|detect|segment)\s+(?:me\s+)?(?:the|a|an)?\s*(.+?)[?.!]*$",
        ]

        for pattern in query_patterns:
            match = re.match(pattern, normalized, flags=re.IGNORECASE)
            if match:
                concept = match.group(1).strip(" .?!")
                return concept or cleaned_prompt

        return cleaned_prompt

    async def segment_by_prompt(
        self,
        image_path: str,
        prompt: str,
        confidence_threshold: float = 0.25,
        save_dir: str = None,
    ) -> dict:
        """
        Pipeline complet : Charge l'image -> Segment avec SAM 3 -> 
        Étiquette avec YOLO -> Sauvegarde en .bin
        """
        try:
            concept_prompt = self._normalize_text_prompt(prompt)
            logger.info(
                "🚀 Démarrage Pipeline SAM 3 pour: %s (Prompt: '%s')",
                image_path,
                concept_prompt,
            )
            from app.models.sam3.image_processor import ImageProcessor
            
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

            # 3. Inférence SAM 3 par concept textuel.
            raw_masks = self.sam3_wrapper.segment_by_text(
                image,
                concept_prompt,
                threshold=confidence_threshold,
            )
            
            if not raw_masks:
                logger.warning(f"Aucun objet trouvé pour le concept '{concept_prompt}'")
                return {
                    "image_path": image_path,
                    "resolution": f"{width}x{height}",
                    "objects_count": 0,
                    "objects": [],
                    "segmentation_dir": str(seg_dir.absolute())
                }

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
                    "label": labels_map.get(idx, concept_prompt), # Priorité au label YOLO
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
