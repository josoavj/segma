"""Gestionnaire global du modèle SAM - Singleton pattern"""

import logging
from typing import Optional
from app.models.sam_model import SAMModel

logger = logging.getLogger(__name__)


class ModelManager:
    """Gestionnaire singleton du modèle SAM"""
    
    _instance: Optional['ModelManager'] = None
    _sam_model: Optional[SAMModel] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ModelManager, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        if self._sam_model is None:
            self._sam_model = SAMModel()
    
    def get_model(self) -> SAMModel:
        """Retourne le modèle SAM"""
        return self._sam_model
    
    def change_model(self, model_type: str, device: Optional[str] = None) -> dict:
        """Change le modèle SAM"""
        try:
            self._sam_model.change_model(model_type, device)
            logger.info(f"✓ Modèle changé: {model_type} sur {self._sam_model.device}")
            return self.get_model_info()
        except Exception as e:
            logger.error(f"✗ Erreur lors du changement de modèle: {e}")
            raise
    
    def get_model_info(self) -> dict:
        """Retourne les infos du modèle"""
        if self._sam_model:
            return self._sam_model.get_model_info()
        return {
            "model_type": "unknown",
            "device": "unknown",
            "is_loaded": False,
            "available_models": ["vit_b", "vit_l", "vit_h"],
            "cuda_available": False
        }


# Instance globale
model_manager = ModelManager()
