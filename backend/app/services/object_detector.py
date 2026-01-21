import logging
import numpy as np
from pathlib import Path
from config import settings

logger = logging.getLogger(__name__)

try:
    from ultralytics import YOLO
    YOLO_AVAILABLE = True
except ImportError:
    YOLO_AVAILABLE = False
    logger.warning("⚠️ YOLO non disponible (pip install ultralytics)")

class ObjectDetector:
    """Détecteur singleton YOLOv8 pour l'étiquetage des masques SAM 3"""
    
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self.model = None
        self.available = False
        self.class_names = {}
        
        if YOLO_AVAILABLE:
            try:
                # Utilise le chemin défini dans config.py
                model_name = settings.YOLO_MODEL 
                logger.info(f"Chargement de YOLO ({model_name})...")
                self.model = YOLO(model_name)
                self.class_names = self.model.names
                self.available = True
                logger.info(f"✅ YOLO prêt ({len(self.class_names)} classes)")
            except Exception as e:
                logger.error(f"❌ Erreur chargement YOLO: {e}")
                self.available = False
        
        self._initialized = True

    def detect_labels(self, image: np.ndarray, bboxes: list) -> dict:
        """
        Associe un label textuel à chaque bounding box de SAM 3 via l'IoU.
        bboxes: [{'x1', 'y1', 'x2', 'y2'}, ...]
        """
        labels = {}
        if not self.available or not bboxes:
            return {i: "object" for i in range(len(bboxes))}

        try:
            # Inférence YOLO sur toute l'image
            results = self.model(image, verbose=False, conf=0.2)
            if not results or not results[0].boxes:
                return {i: "object" for i in range(len(bboxes))}

            yolo_boxes = results[0].boxes.xyxy.cpu().numpy()
            yolo_classes = results[0].boxes.cls.cpu().numpy()

            for i, seg_bbox in enumerate(bboxes):
                best_iou = 0.0
                best_label = "object"

                for j, y_box in enumerate(yolo_boxes):
                    iou = self._compute_iou(seg_bbox, y_box)
                    if iou > best_iou:
                        best_iou = iou
                        class_id = int(yolo_classes[j])
                        best_label = self.class_names.get(class_id, "object")

                # On n'attribue le label que si la correspondance est décente (IoU > 30%)
                labels[i] = best_label if best_iou > 0.3 else "unidentified"
            
            return labels

        except Exception as e:
            logger.error(f"Erreur lors de l'étiquetage YOLO: {e}")
            return {i: "object" for i in range(len(bboxes))}

    @staticmethod
    def _compute_iou(bbox1: dict, bbox2: np.ndarray) -> float:
        """Intersection over Union entre une box dict et une box numpy [x1, y1, x2, y2]"""
        # 
        x1 = max(bbox1['x1'], bbox2[0])
        y1 = max(bbox1['y1'], bbox2[1])
        x2 = min(bbox1['x2'], bbox2[2])
        y2 = min(bbox1['y2'], bbox2[3])

        intersection = max(0, x2 - x1) * max(0, y2 - y1)
        if intersection == 0: return 0.0

        area1 = (bbox1['x2'] - bbox1['x1']) * (bbox1['y2'] - bbox1['y1'])
        area2 = (bbox2[2] - bbox2[0]) * (bbox2[3] - bbox2[1])
        union = area1 + area2 - intersection

        return intersection / union if union > 0 else 0.0

def get_object_detector() -> ObjectDetector:
    return ObjectDetector()