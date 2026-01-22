import os
from pathlib import Path
from dotenv import load_dotenv

# Charger le fichier .env s'il existe
load_dotenv()

class Settings:
    """Configuration globale de l'application SEGMA"""
    
    # --- API ---
    PROJECT_NAME = "SEGMA - Image Segmentation SAM 3"
    # Mise à jour vers V3 pour marquer le saut technologique
    API_V3_STR = "/api/v3"
    DEBUG = os.getenv("DEBUG", "False").lower() == "true"
    
    # --- Server ---
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8000))
    
    # --- Model SAM 3 ---
    # SAM 3 utilise des checkpoints spécifiques (ex: facebook/sam3)
    # On laisse le choix du device (cpu, cuda, mps pour Mac)
    SAM3_MODEL_ID = os.getenv("SAM3_MODEL_ID", "facebook/sam3")
    DEVICE = os.getenv("DEVICE", "cuda") # Par défaut cuda en 2026 pour SAM 3
    
    # --- YOLO Configuration ---
    YOLO_MODEL = os.getenv("YOLO_MODEL", "yolov8n.pt")
    
    # --- File Handling ---
    MAX_FILE_SIZE = int(os.getenv("MAX_FILE_SIZE", 100 * 1024 * 1024))  # Augmenté à 100MB
    BASE_DIR = Path(__file__).resolve().parent.parent
    UPLOAD_DIR = os.getenv("UPLOAD_DIR", str(BASE_DIR / "data" / "uploads"))
    OUTPUT_DIR = os.getenv("OUTPUT_DIR", str(BASE_DIR / "data" / "masks"))
    
    # Création automatique des dossiers si absents
    for path in [UPLOAD_DIR, OUTPUT_DIR]:
        os.makedirs(path, exist_ok=True)
    
    # --- CORS ---
    # Autoriser localhost pour Flutter Web et l'IP du serveur pour Flutter Mobile
    CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080,*").split(",")

settings = Settings()