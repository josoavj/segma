import logging
import re
import uuid

import anyio
import numpy as np
from pathlib import Path

from app.exceptions import SegmentationException
from app.models.model_manager import model_manager
from config import settings

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

    def _segment_by_prompt_sync(
        self,
        filename: str,
        prompt: str | None,
        confidence_threshold: float = 0.25,
        points: list[dict] | None = None,
    ) -> dict:
        """
        Pipeline synchrone autonome exécuté dans un Worker Thread.
        Inférence SAM 3 -> Étiquetage YOLO -> Écriture binaire du masque.
        """
        try:
            upload_root = Path(settings.UPLOAD_DIR).resolve()
            image_path = (upload_root / filename).resolve()
            try:
                safe_filename = image_path.relative_to(upload_root).as_posix()
            except ValueError as e:
                raise SegmentationException("Chemin d'image invalide.") from e

            if not image_path.is_file():
                raise SegmentationException(f"L'image {safe_filename} n'existe pas sur le serveur.")

            concept_prompt = self._normalize_text_prompt(prompt) if prompt else None
            logger.info(
                "🚀 Démarrage Pipeline SAM 3 Worker Thread pour: %s (Prompt: '%s')",
                safe_filename,
                concept_prompt or "zones visuelles",
            )
            from app.models.sam3.image_processor import ImageProcessor
            
            # 1. Chargement de l'image via ImageProcessor
            image = ImageProcessor.load_image(str(image_path))
            height, width = image.shape[:2]

            # 2. Détermination du répertoire de stockage avec tag unique UUID (Empêche les collisions)
            image_stem = image_path.stem
            unique_tag = uuid.uuid4().hex[:6]
            seg_dir = Path(settings.OUTPUT_DIR) / f"seg_{image_stem}_{unique_tag}"
            seg_dir.mkdir(parents=True, exist_ok=True)

            # 3. Inférence SAM 3 par concept textuel
            input_boxes = []
            input_boxes_labels = []
            for point in points or []:
                center_x = float(point["x"]) * width
                center_y = float(point["y"]) * height
                half_width = max(2.0, width * 0.015)
                half_height = max(2.0, height * 0.015)
                input_boxes.append([
                    max(0.0, center_x - half_width),
                    max(0.0, center_y - half_height),
                    min(float(width), center_x + half_width),
                    min(float(height), center_y + half_height),
                ])
                input_boxes_labels.append(int(point["label"]))

            raw_masks = self.sam3_wrapper.segment_by_text(
                image,
                concept_prompt,
                threshold=confidence_threshold,
                input_boxes=input_boxes or None,
                input_boxes_labels=input_boxes_labels or None,
            )
            
            if not raw_masks:
                logger.warning("Aucun objet trouvé pour le prompt '%s'", concept_prompt or "zones visuelles")
                return {
                    "image_path": safe_filename,
                    "resolution": f"{width}x{height}",
                    "objects_count": 0,
                    "objects": [],
                    "segmentation_dir": str(seg_dir.absolute())
                }

            # 4. Traitement et enrichissement avec YOLO
            objects_data = []
            bboxes_for_yolo = [obj["bbox"] for obj in raw_masks]
            labels_map = self.detector.detect_labels(image, bboxes_for_yolo)

            for idx, obj in enumerate(raw_masks):
                mask_np = ImageProcessor.tensor_to_mask(obj["mask"])
                pixel_count = np.count_nonzero(mask_np)
                if pixel_count < 100:
                    continue

                mask_filename = f"mask_{idx}.bin"
                mask_path = seg_dir / mask_filename
                mask_np.tofile(str(mask_path))

                objects_data.append({
                    "object_id": idx,
                    "label": labels_map.get(idx, concept_prompt or "objet sélectionné"),
                    "confidence": float(obj["score"]),
                    "bbox": obj["bbox"],
                    "mask_path": str(mask_path.absolute()),
                    "pixels_count": int(pixel_count)
                })

            return {
                "image_path": safe_filename,
                "resolution": f"{width}x{height}",
                "objects_count": len(objects_data),
                "objects": objects_data,
                "segmentation_dir": str(seg_dir.absolute())
            }

        except Exception as e:
            logger.error(f"❌ Erreur critique SegmentationService: {e}", exc_info=True)
            raise SegmentationException(f"Échec de la segmentation : {str(e)}")

    async def segment_by_prompt(
        self,
        filename: str,
        prompt: str | None,
        confidence_threshold: float = 0.25,
        points: list[dict] | None = None,
    ) -> dict:
        """
        Méthode asynchrone non-bloquante.
        Déporte l'inférence lourde sur un Worker Thread et libère la VRAM à la fin.
        """
        try:
            return await anyio.to_thread.run_sync(
                self._segment_by_prompt_sync,
                filename,
                prompt,
                confidence_threshold,
                points,
            )
        finally:
            model_manager.clear_vram_cache()
