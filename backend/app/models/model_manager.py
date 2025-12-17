"""Gestionnaire global du modèle SAM3 - Singleton pattern"""

import logging
import os
from typing import Optional
import torch
from app.models.sam3_model import SAM3ModelWrapper, get_sam3_model

logger = logging.getLogger(__name__)


class ModelManager:
    """Gestionnaire singleton du modèle SAM3"""
    
    _instance: Optional['ModelManager'] = None
    _sam3_model: Optional[SAM3ModelWrapper] = None
    _current_model_type: str = "vit_l"
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ModelManager, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        if self._sam3_model is None:
            self._sam3_model = get_sam3_model()
    
    def get_model(self) -> SAM3ModelWrapper:
        """Retourne le modèle SAM3"""
        return self._sam3_model
    
    def change_model(self, model_type: str, device: Optional[str] = None) -> dict:
        """
        Change le modèle SAM3
        
        Note: SAM3 ne supporte actuellement que les modèles vision transformers.
        Cette méthode maint la compatibilité API en changeant le device si nécessaire.
        
        Args:
            model_type: Type de modèle (vit_b, vit_l, vit_h) - compatibilité uniquement
            device: 'cpu' ou 'cuda'
        
        Returns:
            Infos du modèle actuel
        """
        if model_type not in ["vit_b", "vit_l", "vit_h"]:
            raise ValueError(f"Modèle invalide: {model_type}. Disponibles: vit_b, vit_l, vit_h")
        
        if device and device not in ["cpu", "cuda"]:
            raise ValueError(f"Device invalide: {device}. Utilisez 'cpu' ou 'cuda'")
        
        try:
            # SAM3 utilise un seul modèle, on stocke juste le type pour compatibilité API
            self._current_model_type = model_type
            
            # Si un device différent est spécifié, charger le modèle sur ce device
            if device and device != self._sam3_model.device:
                logger.info(f"📍 Changement device: {self._sam3_model.device} → {device}")
                self._sam3_model.device = device
                if self._sam3_model.is_loaded and self._sam3_model.model:
                    self._sam3_model.model = self._sam3_model.model.to(device)
            
            logger.info(f"✓ Configuration mise à jour: {model_type} sur {self._sam3_model.device}")
            return self.get_model_info()
        
        except Exception as e:
            logger.error(f"✗ Erreur lors du changement: {e}")
            raise
    
    def get_model_info(self) -> dict:
        """Retourne les infos du modèle SAM3"""
        if not self._sam3_model:
            return self._default_info()
        
        try:
            cuda_available = torch.cuda.is_available()
            cuda_disabled = os.environ.get("CUDA_VISIBLE_DEVICES") == ""
            
            device_name = "CPU"
            vram_gb = None
            
            if cuda_available and not cuda_disabled:
                try:
                    device_name = torch.cuda.get_device_name(0)
                    vram_gb = round(
                        torch.cuda.get_device_properties(0).total_memory / (1024**3), 2
                    )
                except:
                    device_name = "GPU (unavailable)"
            
            return {
                "model_type": self._current_model_type,
                "device": self._sam3_model.device,
                "device_name": device_name,
                "vram_gb": vram_gb,
                "is_loaded": self._sam3_model.is_loaded,
                "available_models": ["vit_b", "vit_l", "vit_h"],
                "cuda_available": cuda_available and not cuda_disabled
            }
        except Exception as e:
            logger.error(f"Erreur get_model_info: {e}")
            return self._default_info()
    
    def _default_info(self) -> dict:
        """Info par défaut"""
        return {
            "model_type": "vit_l",
            "device": "cpu",
            "device_name": "CPU",
            "vram_gb": None,
            "is_loaded": False,
            "available_models": ["vit_b", "vit_l", "vit_h"],
            "cuda_available": False
        }


# Instance globale
model_manager = ModelManager()
