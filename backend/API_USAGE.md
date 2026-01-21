#SEGMA API V3 - Guide d'Utilisation Complet

Ce guide détaille comment interagir avec le moteur de segmentation **SAM 3 (Promptable Concept Segmentation)** et **YOLOv8**.

## Points d'entrée (Endpoints)

| Méthode | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/api/v3/health` | État du système (GPU, SAM 3, Version) |
| `POST` | `/api/v3/upload` | Téléchargement de l'image source |
| `POST` | `/api/v3/segment` | Inférence IA (Image → Masques .bin) |

---

## 1. Vérification de l'état (Health Check)

Avant de lancer des calculs lourds, vérifiez si le GPU est disponible et si le modèle SAM 3 est chargé.

**Requête :**

```bash
curl -X GET http://localhost:8000/api/v3/health

```

**Réponse (JSON) :**

```json
{
  "status": "healthy",
  "device": "cuda",
  "model_loaded": true,
  "model_type": "SAM 3",
  "api_version": "3.0.0"
}

```

---

## 2. Upload de l'image

L'IA a besoin d'un chemin local pour traiter l'image. Cette étape sauvegarde le fichier sur le serveur.

**Requête :**

```bash
curl -X POST -F "file=@ma_machine.jpg" http://localhost:8000/api/v3/upload

```

**Réponse (JSON) :**

```json
{
  "filename": "ma_machine.jpg",
  "image_path": "/absolut/path/to/segma/data/uploads/ma_machine.jpg",
  "width": 1920,
  "height": 1080,
  "size_mb": 1.45
}

```

---

## 3. Segmentation par Prompt (PCS)

C'est ici que SAM 3 identifie les objets par leur nom et génère les masques binaires.

**Requête :**

```bash
curl -X POST http://localhost:8000/api/v3/segment \
  -H "Content-Type: application/json" \
  -d '{
    "image_path": "/path/to/ma_machine.jpg",
    "prompt": "boulons de fixation et écrous",
    "confidence_threshold": 0.3
  }'

```

**Réponse (JSON) :**

```json
{
  "status": "success",
  "objects_count": 2,
  "objects": [
    {
      "object_id": 0,
      "label": "bolt",
      "confidence": 0.92,
      "bbox": {"x1": 450, "y1": 300, "x2": 510, "y2": 360},
      "mask_path": "/data/masks/seg_ma_machine/mask_0.bin",
      "pixels_count": 3200
    }
  ]
}

```

---

## 4. Comprendre le format des masques (.bin)

Le format `.bin` est un flux binaire brut (**raw data**) sans en-tête ni compression.

* **Type de données** : `uint8` (1 octet par pixel).
* **Valeurs** : `255` (Zone sélectionnée), `0` (Fond).
* **Taille du fichier** : Exactement  de l'image originale.

### Exemple de conversion .bin vers PNG (Python) :

```python
import numpy as np
from PIL import Image

# Charger le fichier binaire
w, h = 1920, 1080
mask_data = np.fromfile("mask_0.bin", dtype=np.uint8)
mask_array = mask_data.reshape((h, w))

# Sauvegarder en image classique
Image.fromarray(mask_array).save("visual_mask.png")

```

---

## 5. Structure de stockage

Le backend organise les fichiers pour éviter les conflits :

```text
data/
├── uploads/              # Images originales (ma_machine.jpg)
└── masks/
    └── seg_ma_machine/   # Dossier spécifique à l'image
        ├── mask_0.bin    # Masque du premier objet
        ├── mask_1.bin    # Masque du second objet
        └── metadata.json # (Optionnel) Copie des infos YOLO

```

---

## 6. Dépannage & Erreurs

| Code HTTP | Cause possible | Solution |
| --- | --- | --- |
| **413** | Image trop lourde | Augmenter `MAX_FILE_SIZE` dans le `.env` |
| **404** | Image path invalide | Vérifier que le chemin envoyé est bien celui retourné par `/upload` |
| **500** | CUDA Out of Memory | Réduire la résolution de l'image ou utiliser `DEVICE=cpu` |
| **500** | SAM 3 Timeout | Augmenter le timeout de votre client (Inférence > 2s) |

---

## 7. Note pour l'intégration Flutter

Pour afficher les masques sur mobile :

1. Utilisez `File(path).readAsBytesSync()` pour obtenir un `Uint8List`.
2. Ne convertissez pas tout en PNG sur le serveur (trop lent).
3. Utilisez un `CustomPainter` dans Flutter pour dessiner le masque binaire directement sur l'image originale.

---

**Version API** : 3.0.0 (Janvier 2026)