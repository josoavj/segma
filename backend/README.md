# SEGMA - Backend API Documentation (V3 - SAM 3 Edition)

## Vue d'ensemble

SEGMA est une solution de segmentation d'images de pointe utilisant **SAM 3 (Segment Anything Model 3)** de Meta. Contrairement aux versions précédentes, ce backend supporte le **Promptable Concept Segmentation (PCS)**, permettant de segmenter des objets complexes via de simples descriptions textuelles.

### Technologies Clés (2026)

* **Framework**: FastAPI 0.104.1
* **IA Moteur**: SAM 3 (via Transformers) + YOLOv8 (Ultralytics)
* **Calcul**: PyTorch 2.7.0+ (Optimisé pour FlashAttention)
* **Format de Sortie**: Fichiers binaires bruts (`.bin`) pour une précision chirurgicale.

## Installation et Configuration

### Prérequis

* **Python 3.12+**
* **CUDA 12.x** (Fortement recommandé pour SAM 3)
* **Accès Hugging Face** (Le modèle `facebook/sam3` est un modèle sous licence Meta).

### Installation rapide

1. **Installer les dépendances spécialisées**:

```bash
pip install -r requirements.txt
# Note: SAM 3 nécessite souvent l'installation de transformers depuis git

```

2. **Authentification Hugging Face**:

```bash
huggingface-cli login

```

3. **Variables d'environnement (.env)**:

```dotenv
SAM3_MODEL_ID=facebook/sam3
YOLO_MODEL=yolov8n.pt
DEVICE=cuda
MASK_FORMAT=bin

```

## Nouveaux Endpoints API (v3)

### 1. Segmentation par Concept (PCS)

**POST** `/api/v3/segment`

C'est le cœur du nouveau système. Au lieu de cliquer, vous décrivez ce que vous voulez extraire.

**Requête (Multipart/Form-Data)**:

* `file`: L'image à traiter.
* `prompt`: "tous les boulons", "les zones endommagées", etc.
* `confidence`: Seuil de détection (défaut: 0.25).

**Réponse**:

```json
{
  "status": "success",
  "objects_count": 12,
  "objects": [
    {
      "object_id": 0,
      "label": "bolt",
      "confidence": 0.89,
      "mask_path": "/data/masks/seg_img01/mask_0.bin",
      "bbox": {"x1": 120, "y1": 450, "x2": 200, "y2": 530}
    }
  ]
}

```

---

### 2. Format des Masques (.bin)

Pour répondre aux contraintes de précision et de performance, les masques sont sauvegardés en **binaire brut (raw binary)**.

* **Structure**: Un fichier `.bin` est un tableau de bytes (`uint8`).
* **Valeurs**: `255` pour l'objet, `0` pour le fond.
* **Dimensions**: La taille du fichier est exactement égale à  de l'image originale.
* **Usage Flutter**:
```dart
// Exemple de lecture en Flutter
Uint8List maskBytes = await File(maskPath).readAsBytes();
// Le pixel à (x, y) est à l'index : y * width + x

```



## Architecture du Projet (Harmonisée)

```text
backend/
├── main.py                  # Initialisation FastAPI & Lifespan
├── config.py                # Configuration SAM 3 / YOLO
├── app/
│   ├── api/
│   │   ├── schemas.py       # Contrats Pydantic v3
│   │   ├── health.py        # Diagnostic GPU/Modèle
│   │   └── segmentation.py  # Routes Upload & Segment
│   ├── models/
│   │   ├── sam3_wrapper.py  # Interface avec facebook/sam3
│   │   └── image_processor.py # Gestion des .bin et PIL
│   └── services/
│       ├── segmentation_service.py # Orchestrateur IA
│       └── object_detector.py      # Labeling YOLOv8
└── data/
    ├── uploads/             # Images originales
    └── masks/               # Dossiers de masques .bin

```
