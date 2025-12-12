# SEGMA API - Guide d'Utilisation Rapide

## 🚀 Démarrer le serveur

```bash
cd backend
export PYTHONPATH=.
python -m uvicorn main:app --port 8000
```

Serveur accessible: **http://localhost:8000**
Docs interactives: **http://localhost:8000/docs**

---

## 📋 Endpoints Disponibles

### 1. Health Check
Vérifie que le serveur fonctionne

```bash
curl -X GET http://localhost:8000/api/v1/health
```

**Réponse:**
```json
{
  "status": "healthy",
  "device": "cpu",
  "model_loaded": false,
  "model_type": "sam3",
  "api_version": "1.0.0"
}
```

---

### 2. Upload d'Image
Télécharge une image sur le serveur

```bash
curl -X POST -F "file=@mon_image.jpg" \
  http://localhost:8000/api/v1/upload
```

**Réponse:**
```json
{
  "filename": "mon_image.jpg",
  "image_path": "/home/user/uploads/mon_image.jpg",
  "width": 1920,
  "height": 1080,
  "size_mb": 2.5
}
```

---

### 3. Segmentation par Prompt
**Endpoint Principal** - Segmente les objets par description textuelle

#### Requête Simple (répertoire par défaut):
```bash
curl -X POST http://localhost:8000/api/v1/segment \
  -H "Content-Type: application/json" \
  -d '{
    "image_path": "/home/user/uploads/mon_image.jpg",
    "prompt": "détecte tous les animaux",
    "confidence_threshold": 0.5
  }'
```

#### Requête avec Répertoire Personnalisé:
```bash
curl -X POST http://localhost:8000/api/v1/segment \
  -H "Content-Type: application/json" \
  -d '{
    "image_path": "/home/user/uploads/mon_image.jpg",
    "prompt": "détecte tous les animaux",
    "confidence_threshold": 0.5,
    "save_dir": "/chemin/custom/segmentation"
  }'
```

#### Réponse:
```json
{
  "image_path": "/home/user/uploads/mon_image.jpg",
  "width": 1920,
  "height": 1080,
  "objects_count": 3,
  "objects": [
    {
      "object_id": 1,
      "label": "objet 1",
      "confidence": 0.95,
      "bbox": {
        "x1": 50,
        "y1": 50,
        "x2": 300,
        "y2": 300
      },
      "mask_path": "/home/user/uploads/.segmentation_mon_image/mask_1.bin",
      "pixels_count": 45000
    },
    {
      "object_id": 2,
      "label": "objet 2",
      "confidence": 0.87,
      "bbox": {
        "x1": 320,
        "y1": 100,
        "x2": 550,
        "y2": 350
      },
      "mask_path": "/home/user/uploads/.segmentation_mon_image/mask_2.bin",
      "pixels_count": 52000
    },
    {
      "object_id": 3,
      "label": "objet 3",
      "confidence": 0.72,
      "bbox": {
        "x1": 200,
        "y1": 350,
        "x2": 450,
        "y2": 550
      },
      "mask_path": "/home/user/uploads/.segmentation_mon_image/mask_3.bin",
      "pixels_count": 38000
    }
  ],
  "segmentation_dir": "/home/user/uploads/.segmentation_mon_image"
}
```

---

## 🎯 Format des Masques Binaires

Chaque masque est un fichier **`.bin`** (raw binary):

```
Format: uint8 (1 byte par pixel)
Valeurs: 
  - 255 = BLANC (zone segmentée)
  - 0   = NOIR  (reste de l'image)
  
Dimensions: Exactement width × height de l'image originale
```

### Exemple de lecture en Python:
```python
import numpy as np
from PIL import Image

# Lire le masque binaire
mask = np.fromfile("mask_1.bin", dtype=np.uint8)
mask = mask.reshape((1080, 1920))  # height, width

# Afficher
Image.fromarray(mask, mode='L').save("mask_1.png")

# Ou superposer sur l'image originale
image = Image.open("mon_image.jpg")
segmented = Image.new('RGB', image.size, color='black')
segmented.paste(image, mask=Image.fromarray(mask))
segmented.save("segmented.jpg")
```

---

## 📁 Structure de Sauvegarde

### Par Défaut (sans `save_dir`):
```
uploads/
├── mon_image.jpg
└── .segmentation_mon_image/
    ├── mask_1.bin      (zone segmentée = blanc, reste = noir)
    ├── mask_2.bin
    └── mask_3.bin
```

### Personnalisé (avec `save_dir`):
```
/chemin/custom/segmentation/
├── mask_1.bin
├── mask_2.bin
└── mask_3.bin
```

---

## 🔍 Exemples Complets

### Python (Requests + PIL):
```python
import requests
import numpy as np
from PIL import Image

BASE_URL = "http://localhost:8000/api/v1"

# 1. Upload image
with open("photo.jpg", "rb") as f:
    response = requests.post(
        f"{BASE_URL}/upload",
        files={"file": f}
    )
    image_path = response.json()["image_path"]

# 2. Segmentation
response = requests.post(
    f"{BASE_URL}/segment",
    json={
        "image_path": image_path,
        "prompt": "tous les animaux",
        "confidence_threshold": 0.6
    }
)

result = response.json()

# 3. Traiter les masques
for obj in result["objects"]:
    mask_path = obj["mask_path"]
    confidence = obj["confidence"]
    
    # Lire masque
    mask = np.fromfile(mask_path, dtype=np.uint8)
    mask = mask.reshape((result["height"], result["width"]))
    
    # Sauvegarder
    Image.fromarray(mask, mode='L').save(f"mask_{obj['object_id']}.png")
    print(f"Objet {obj['object_id']}: {confidence:.2%} confiance")
```

---

## ⚙️ Configuration

### Variables d'environnement (.env):
```dotenv
# Server
HOST=0.0.0.0
PORT=8000
DEBUG=False

# Model (pour futur)
SAM_MODEL_TYPE=vit_b  # vit_b, vit_l, vit_h
DEVICE=cpu            # cpu ou cuda

# Files
MAX_FILE_SIZE=52428800  # 50 MB
UPLOAD_DIR=./uploads

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

---

## 📦 Installation des Dépendances

### Minimum (mode simulation):
```bash
pip install fastapi uvicorn pillow python-dotenv pydantic pydantic-settings python-multipart
```

### Complet (mode réel avec SAM 3):
```bash
pip install -r requirements.txt
# + PyTorch et SAM 3 (sera disponible)
```

---

## 🐛 Codes d'Erreur

| Code | Erreur | Solution |
|------|--------|----------|
| 400  | Paramètres invalides | Vérifier prompt, threshold, chemins |
| 404  | Image non trouvée | Vérifier `image_path` |
| 413  | Fichier trop gros | Max 50MB, réduire la taille |
| 500  | Erreur serveur | Consulter les logs |

---

## 📝 Notes

- **Masques**: Sauvegardés en format binaire brut (`.bin`)
- **Format**: uint8, même résolution que l'image source
- **Répertoire**: Créé automatiquement, nécessite pas de préparation
- **Mode Simulation**: Jusqu'à l'installation de SAM 3
- **CORS**: Configuré pour Flutter (localhost:3000)

---

## 🔗 Intégration avec Flutter

L'app Flutter peut:
1. Uploader des images: `POST /api/v1/upload`
2. Envoyer le prompt: `POST /api/v1/segment`
3. Récupérer les masques: Accéder aux fichiers `.bin` depuis le chemin retourné
4. Afficher les masques: Lire les fichiers binaires et les convertir en images

---

**Version API**: 1.0.0  
**État**: Opérationnel (mode simulation)  
**SAM Version**: En attente de SAM 3
