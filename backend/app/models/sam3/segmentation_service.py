import os
from pathlib import Path
from app.models.sam3_wrapper import SAM3Wrapper
from app.models.image_processor import ImageProcessor
from app.services.object_detector import get_object_detector

class SegmentationService:
    def __init__(self):
        self.sam3 = SAM3Wrapper()
        self.detector = get_object_detector()

    async def segment_concept(self, image_np, prompt, save_path, format="png"):
        """Pipeline complet : Image -> SAM3 -> YOLO -> Stockage"""
        raw_results = self.sam3.segment_by_text(image_np, prompt)
        
        final_objects = []
        for i, obj in enumerate(raw_results):
            mask_np = ImageProcessor.tensor_to_mask(obj["mask"])
            
            # 1. Sauvegarde physique (Contrainte client : même taille que l'original)
            mask_data = ImageProcessor.encode_mask(mask_np, format=format)
            mask_name = f"obj_{i}.{format}"
            full_path = Path(save_path) / mask_name
            full_path.write_bytes(mask_data)
            
            # 2. Identification fine avec YOLO
            bbox = obj["bbox"] # Format [x1, y1, x2, y2]
            labels = self.detector.detect_labels(image_np, [bbox])
            
            final_objects.append({
                "id": i,
                "label": labels.get(0, prompt),
                "confidence": float(obj["score"]),
                "mask_file": mask_name
            })
            
        return final_objects