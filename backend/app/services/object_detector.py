"""
Service de détection d'objets avec YOLO
Fournit des labels en anglais pour les objets détectés
"""

import logging
import numpy as np
from pathlib import Path

logger = logging.getLogger(__name__)

try:
    from ultralytics import YOLO
    YOLO_AVAILABLE = True
except ImportError:
    YOLO_AVAILABLE = False
    logger.warning("YOLO non disponible - labels génériques par défaut")


class ObjectDetector:
    """Détecteur d'objets utilisant YOLO"""
    
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
        self._initialized = True
        self.class_names = {}
        
        if YOLO_AVAILABLE:
            try:
                logger.info("Chargement du modèle YOLO...")
                self.model = YOLO("yolov8n.pt")  # nano model - très rapide
                self.available = True
                self.class_names = self.model.names
                logger.info(f"✓ Modèle YOLO chargé ({len(self.class_names)} classes)")
            except Exception as e:
                logger.warning(f"Impossible de charger YOLO: {e}")
                self.available = False
    
    def detect_labels(self, image: np.ndarray, bboxes: list) -> dict:
        """
        Détecte les labels des objets basés sur leurs bounding boxes
        
        Args:
            image: Image numpy array (RGB)
            bboxes: Liste des bounding boxes [{'x1': int, 'y1': int, 'x2': int, 'y2': int}]
        
        Returns:
            Dict mapping: {bbox_index: label_name}
        """
        
        labels = {}
        
        if not self.available or self.model is None:
            logger.debug("YOLO non disponible, utilisation de labels génériques")
            generic_labels = ['object', 'person', 'item', 'thing', 'entity', 'thing', 'stuff']
            for i, bbox in enumerate(bboxes):
                labels[i] = generic_labels[i % len(generic_labels)]
            return labels
        
        try:
            # Détecter les objets dans l'image avec confiance basse
            results = self.model(image, verbose=False, conf=0.1)  # Seuil de confiance bas pour tout détecter
            
            if not results or not results[0].boxes:
                logger.debug("Aucune détection YOLO, labels génériques")
                generic_labels = ['object', 'person', 'item', 'thing', 'entity', 'thing', 'stuff']
                for i, bbox in enumerate(bboxes):
                    labels[i] = generic_labels[i % len(generic_labels)]
                return labels
            
            # Pour chaque bbox de segmentation, trouver la détection YOLO la plus proche
            yolo_results = results[0]
            yolo_boxes = yolo_results.boxes.xyxy.numpy()
            yolo_classes = yolo_results.boxes.cls.numpy()
            yolo_confs = yolo_results.boxes.conf.numpy()
            
            logger.debug(f"YOLO: {len(yolo_boxes)} détections trouvées")
            
            for seg_idx, seg_bbox in enumerate(bboxes):
                best_label = f"object_{seg_idx + 1}"
                best_iou = 0
                best_conf = 0
                
                # Calculer IoU avec chaque détection YOLO
                for yolo_idx, (yolo_box, yolo_class, yolo_conf) in enumerate(
                    zip(yolo_boxes, yolo_classes, yolo_confs)
                ):
                    # Calculer IoU
                    iou = self._compute_iou(seg_bbox, yolo_box)
                    
                    # Choisir la meilleure détection avec le plus grand IoU et confiance
                    if iou > best_iou or (iou == best_iou and yolo_conf > best_conf):
                        best_iou = iou
                        best_conf = yolo_conf
                        # Obtenir le label YOLO
                        class_id = int(yolo_class)
                        label_name = self.class_names.get(class_id, f"object_{seg_idx + 1}")
                        best_label = label_name
                
                labels[seg_idx] = best_label
                logger.debug(f"Bbox {seg_idx}: {best_label} (IoU: {best_iou:.2f})")
            
            return labels
        
        except Exception as e:
            logger.warning(f"Erreur YOLO: {e}")
            generic_labels = ['object', 'person', 'item', 'thing', 'entity', 'thing', 'stuff']
            for i, bbox in enumerate(bboxes):
                labels[i] = generic_labels[i % len(generic_labels)]
            return labels
    
    @staticmethod
    def _compute_iou(bbox1: dict, bbox2: np.ndarray) -> float:
        """
        Calcule l'Intersection over Union entre deux boîtes
        
        Args:
            bbox1: {'x1': int, 'y1': int, 'x2': int, 'y2': int}
            bbox2: numpy array [x1, y1, x2, y2]
        
        Returns:
            float: IoU score entre 0 et 1
        """
        x1_min = max(bbox1['x1'], bbox2[0])
        y1_min = max(bbox1['y1'], bbox2[1])
        x2_max = min(bbox1['x2'], bbox2[2])
        y2_max = min(bbox1['y2'], bbox2[3])
        
        if x2_max < x1_min or y2_max < y1_min:
            return 0.0
        
        intersection = (x2_max - x1_min) * (y2_max - y1_min)
        
        area1 = (bbox1['x2'] - bbox1['x1']) * (bbox1['y2'] - bbox1['y1'])
        area2 = (bbox2[2] - bbox2[0]) * (bbox2[3] - bbox2[1])
        
        union = area1 + area2 - intersection
        
        return intersection / union if union > 0 else 0.0


def get_object_detector() -> ObjectDetector:
    """Getter pour l'instance singleton du détecteur"""
    return ObjectDetector()

