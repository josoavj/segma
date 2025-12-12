import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Configuration globale de l'application"""
    
    # API
    API_V1_STR = "/api/v1"
    PROJECT_NAME = "SEGMA - Image Segmentation"
    DEBUG = os.getenv("DEBUG", "False").lower() == "true"
    
    # Server
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8000))
    
    # Model
    SAM_MODEL_TYPE = os.getenv("SAM_MODEL_TYPE", "vit_b")  # vit_b, vit_l, vit_h
    DEVICE = os.getenv("DEVICE", "cpu")  # cpu ou cuda
    
    # File handling
    MAX_FILE_SIZE = int(os.getenv("MAX_FILE_SIZE", 50 * 1024 * 1024))  # 50MB
    UPLOAD_DIR = os.getenv("UPLOAD_DIR", "./uploads")
    
    # CORS
    CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")


settings = Settings()
