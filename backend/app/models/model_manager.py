import logging
import torch
from typing import Optional, Dict
from app.models.sam3_wrapper import SAM3Wrapper 
from config import settings

logger = logging.getLogger(__name__)

class ModelManager:
    """Singleton pour gérer le cycle de vie des modèles IA (SAM 3)"""
    
    _instance: Optional['ModelManager'] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self.sam3_model: Optional[SAM3Wrapper] = None
        self.device = self._get_device()
        self.is_loaded = False
        
        # Chargement immédiat au démarrage du serveur
        self._load_model()
        self._initialized = True
    
    def _get_device(self) -> str:
        """Détermine le device à utiliser (cuda ou cpu)"""
        # On priorise le réglage du .env mais on valide la capacité réelle
        req_device = settings.DEVICE.lower()
        
        if req_device == "cuda" and torch.cuda.is_available():
            logger.info(f"✓ CUDA détecté: {torch.cuda.get_device_name(0)}")
            return "cuda"
        
        if req_device == "mps" and torch.backends.mps.is_available():
            logger.info("✓ Apple Silicon GPU (MPS) détecté")
            return "mps"
            
        logger.warning(f"⚠️ {req_device.upper()} non disponible, repli sur CPU")
        return "cpu"
    
    def _load_model(self):
        """Charge le modèle SAM 3 via le wrapper"""
        try:
            logger.info(f"📥 Initialisation de SAM 3 sur {self.device}...")
            # SAM3Wrapper gère déjà son propre try/except interne
            self.sam3_model = SAM3Wrapper(device=self.device)
            self.is_loaded = self.sam3_model.is_loaded
            
            if self.is_loaded:
                logger.info("✅ SAM 3 prêt à l'emploi")
            else:
                logger.error("❌ Échec de l'initialisation de SAM 3")
        except Exception as e:
            logger.error(f"❌ Erreur critique au chargement du manager: {e}")
            self.is_loaded = False
    
    def get_model(self) -> SAM3Wrapper:
        """Retourne l'instance unique du modèle"""
        if self.sam3_model is None or not self.is_loaded:
            self._load_model()
        return self.sam3_model
    
    def get_model_info(self) -> Dict:
        """Retourne les métadonnées pour l'endpoint /health"""
        return {
            "model_type": "facebook/sam3",
            "device": self.device,
            "is_loaded": self.is_loaded,
            "vram_gb": self._get_gpu_memory_info() if self.device == "cuda" else 0.0,
            "cuda_available": torch.cuda.is_available(),
            "api_version": "3.0.0"
        }
    
    def _get_gpu_memory_info(self) -> float:
        """Calcul de la VRAM totale en Go pour monitoring"""
        try:
            if torch.cuda.is_available():
                props = torch.cuda.get_device_properties(0)
                return round(props.total_memory / (1024 ** 3), 2)
        except:
            pass
        return 0.0

# Instance globale pour tout l'import du backend
model_manager = ModelManager()