# SEGMA - Backend API Documentation

## Vue d'ensemble

SEGMA est une application de segmentation d'images utilisant le modèle **Segment Anything (SAM)** de Meta. Le backend fournit une API REST pour l'analyse et la segmentation d'images.

### Technologies

- **Framework**: FastAPI 0.104.1
- **Server**: Uvicorn
- **ML/AI**: PyTorch 2.1.1 + Segment Anything
- **Image Processing**: Pillow, OpenCV
- **Data Validation**: Pydantic 2.5.0

## Installation et Configuration

### Prérequis

- Python 3.8+
- CUDA 11.8+ (optionnel, pour GPU)

### Installation

1. **Cloner le projet et naviguer au dossier backend**:
```bash
cd backend
```

2. **Créer un environnement virtuel**:
```bash
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
```

3. **Installer les dépendances**:
```bash
pip install -r requirements.txt
```

4. **Configurer les variables d'environnement**:
```bash
cp .env.example .env
# Éditer .env selon vos besoins
```

### Variables d'environnement (.env)

```dotenv
# Server
DEBUG=False
HOST=0.0.0.0
PORT=8000

# SAM Model Configuration
SAM_MODEL_TYPE=vit_b          # Options: vit_b, vit_l, vit_h
DEVICE=cpu                     # Auto-détecte CUDA si disponible

# File Upload
MAX_FILE_SIZE=52428800         # 50 MB en bytes
UPLOAD_DIR=./uploads

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

## Démarrage du serveur

```bash
# Mode développement avec rechargement automatique
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Mode production
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

Le serveur sera accessible à: `http://localhost:8000`

### Documentation Interactive

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Endpoints API

### 1. Health Check

**GET** `/api/v1/health`

Vérifie l'état du serveur et la disponibilité du modèle.

**Réponse**:
```json
{
  "status": "healthy",
  "device": "cuda",
  "model_loaded": true,
  "model_type": "vit_b",
  "api_version": "1.0.0"
}
```

**Codes de réponse**:
- `200`: Serveur opérationnel

---

### 2. Upload d'image

**POST** `/api/v1/upload`

Télécharge et sauvegarde une image sur le serveur.

**Paramètres** (multipart/form-data):
- `file`: Fichier image (JPEG, PNG, BMP, GIF, TIFF)

**Réponse**:
```json
{
  "filename": "mon_image.jpg",
  "image_path": "/home/user/uploads/mon_image.jpg",
  "width": 1920,
  "height": 1080,
  "size_mb": 2.5
}
```

**Codes de réponse**:
- `200`: Fichier téléchargé avec succès
- `400`: Format de fichier non supporté ou fichier vide
- `413`: Fichier trop volumineux
- `500`: Erreur serveur

**Formats acceptés**: `.jpg`, `.jpeg`, `.png`, `.bmp`, `.gif`, `.tiff`

**Limite de taille**: 50 MB par défaut

---

### 3. Segmentation par point

**POST** `/api/v1/segment/point`

Segmente une région à partir d'un point cliqué.

**Requête**:
```json
{
  "image_path": "/home/user/uploads/mon_image.jpg",
  "x": 500,
  "y": 300
}
```

**Réponse**:
```json
{
  "mask": "iVBORw0KGgoAAAANS...",  // Base64 encoded PNG
  "width": 1920,
  "height": 1080,
  "confidence": 0.95
}
```

**Codes de réponse**:
- `200`: Segmentation réussie
- `400`: Coordonnées invalides
- `404`: Image non trouvée
- `500`: Erreur de segmentation

---

### 4. Segmentation par boîte

**POST** `/api/v1/segment/box`

Segmente une région délimitée par une boîte rectangulaire.

**Requête**:
```json
{
  "image_path": "/home/user/uploads/mon_image.jpg",
  "box_x1": 200,
  "box_y1": 150,
  "box_x2": 800,
  "box_y2": 600
}
```

**Réponse**:
```json
{
  "mask": "iVBORw0KGgoAAAANS...",  // Base64 encoded PNG
  "width": 1920,
  "height": 1080,
  "confidence": 0.92
}
```

**Codes de réponse**:
- `200`: Segmentation réussie
- `400`: Coordonnées invalides ou boîte invalide
- `404`: Image non trouvée
- `500`: Erreur de segmentation

---

## Exemples d'utilisation

### Python

```python
import requests
import base64
from PIL import Image
from io import BytesIO

BASE_URL = "http://localhost:8000/api/v1"

# 1. Upload une image
with open("mon_image.jpg", "rb") as f:
    files = {"file": f}
    response = requests.post(f"{BASE_URL}/upload", files=files)
    upload_result = response.json()
    image_path = upload_result["image_path"]
    print(f"Image uploaded: {image_path}")

# 2. Segmentation par point
response = requests.post(f"{BASE_URL}/segment/point", json={
    "image_path": image_path,
    "x": 500,
    "y": 300
})
seg_result = response.json()

# Décoder le masque
mask_data = base64.b64decode(seg_result["mask"])
mask_image = Image.open(BytesIO(mask_data))
mask_image.save("mask.png")
print(f"Mask confidence: {seg_result['confidence']}")

# 3. Segmentation par boîte
response = requests.post(f"{BASE_URL}/segment/box", json={
    "image_path": image_path,
    "box_x1": 200,
    "box_y1": 150,
    "box_x2": 800,
    "box_y2": 600
})
seg_result = response.json()
mask_image = Image.open(BytesIO(base64.b64decode(seg_result["mask"])))
mask_image.save("mask_box.png")
```

### cURL

```bash
# Health check
curl http://localhost:8000/api/v1/health

# Upload image
curl -X POST -F "file=@mon_image.jpg" http://localhost:8000/api/v1/upload

# Segment by point
curl -X POST http://localhost:8000/api/v1/segment/point \
  -H "Content-Type: application/json" \
  -d '{
    "image_path": "/home/user/uploads/mon_image.jpg",
    "x": 500,
    "y": 300
  }'
```

## Architecture

```
backend/
├── main.py                      # Application FastAPI
├── config.py                    # Configuration
├── requirements.txt             # Dépendances Python
├── .env                         # Variables d'environnement
├── .env.example                 # Template .env
│
├── app/
│   ├── __init__.py
│   ├── exceptions.py            # Exceptions personnalisées
│   │
│   ├── api/
│   │   ├── __init__.py          # Assemblage des routes
│   │   ├── schemas.py           # Modèles Pydantic
│   │   └── routes/
│   │       ├── health.py        # Health check endpoint
│   │       └── segmentation.py  # Endpoints de segmentation
│   │
│   ├── models/
│   │   ├── sam_model.py         # Wrapper du modèle SAM
│   │   └── image_processor.py   # Traitement d'images
│   │
│   └── services/
│       └── segmentation_service.py  # Logique métier
│
└── checkpoints/                 # Modèles SAM (auto-téléchargés)
```

## Gestion des modèles SAM

### Téléchargement automatique

Les checkpoints SAM sont téléchargés automatiquement la première fois au démarrage du serveur. Les fichiers sont stockés dans `./checkpoints/`.

Les fichiers téléchargés:
- `sam_vit_b_01ec64.pth` (~375 MB)
- `sam_vit_l_0b3195.pth` (~1.2 GB)
- `sam_vit_h_6bcac11.pth` (~2.6 GB)

### Sélection du modèle

Modifiez `SAM_MODEL_TYPE` dans `.env`:
- `vit_b` (par défaut): Rapide, moins de mémoire, précision correcte
- `vit_l`: Équilibre performance/précision
- `vit_h`: Plus précis, consomme plus de ressources

## Performance et Optimisation

### Conseils

1. **GPU**: Utilisez CUDA pour des performances 5-10x meilleures
   ```bash
   DEVICE=cuda python -m uvicorn main:app --reload
   ```

2. **Modèle**: Commencez avec `vit_b` pour le développement
   
3. **Cache**: Le modèle est chargé une seule fois et réutilisé

4. **Production**: Utilisez plusieurs workers uvicorn
   ```bash
   python -m uvicorn main:app --workers 4
   ```

## Dépannage

### Le modèle prend du temps à charger

**Cause**: Premier téléchargement du checkpoint SAM

**Solution**: Attendez le premier démarrage. Les démarrages suivants seront plus rapides.

### Erreur: "CUDA out of memory"

**Solution**: 
1. Réduisez la taille des images
2. Changez pour `vit_b` (plus petit)
3. Utilisez `DEVICE=cpu`

### Import "segment_anything" non trouvé

**Solution**:
```bash
pip install segment-anything
```

### Port déjà utilisé

**Solution**:
```bash
# Changez le port dans .env ou utilisez
python -m uvicorn main:app --port 8001
```

## Tests

Pour tester les endpoints, utilisez l'interface Swagger:
1. Ouvrez `http://localhost:8000/docs`
2. Testez les endpoints directement depuis l'interface

## Logs

Les logs sont affichés dans la console. Pour un logging plus détaillé:
```python
# Dans main.py
import logging
logging.basicConfig(level=logging.DEBUG)
```

## Production Deployment

### Docker

À implémenter: `Dockerfile` et `docker-compose.yml`

### Environment Variables

Pour la production, assurez-vous de:
- `DEBUG=False`
- `CORS_ORIGINS` restreint aux domaines autorisés
- Utiliser un reverse proxy (nginx)
- Configuration SSL/TLS

## Support et Contribution

Pour des questions ou des contributions, consultez le README principal du projet.

---

**Version**: 1.0.0
**Dernière mise à jour**: 2024
