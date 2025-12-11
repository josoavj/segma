# SEGMA - Image Segmentation Application

Une application complète de segmentation d'images combinant Flutter pour l'interface utilisateur et PyTorch/SAM (Segment Anything Model) pour le backend de segmentation.

## 🏗️ Architecture

### Frontend (Flutter)
- **UI deux colonnes** : Arborescence des dossiers | Galerie d'images | Visualisation
- **Gestion d'état** : Riverpod (modern et performant)
- **Interaction interactive** : Clic sur l'image pour déclencher la segmentation

### Backend (Python)
- **Framework** : FastAPI (haute performance)
- **Modèle** : Segment Anything Model (SAM) de Meta
- **Endpoints** : 
  - `POST /api/v1/segment/point` - Segmentation par point cliqué
  - `POST /api/v1/segment/box` - Segmentation par boîte délimitatrice
  - `GET /api/v1/health` - Santé du serveur

## 📦 Structure du Projet

```
segma/
├── lib/                           # Code Flutter
│   ├── main.dart                  # Point d'entrée
│   ├── config/                    # Configuration
│   ├── core/                      # Code partagé
│   ├── models/                    # Modèles de données
│   ├── providers/                 # Riverpod providers
│   ├── screens/
│   │   └── home_page.dart         # Page principale (2 colonnes)
│   ├── services/
│   │   ├── file_service.dart      # Gestion fichiers/dossiers
│   │   └── backend_service.dart   # Communication API
│   └── widgets/
│       ├── folder_tree_widget.dart    # Arborescence
│       ├── image_grid_widget.dart     # Galerie
│       └── image_viewer_widget.dart   # Visualisation + interaction
├── backend/                       # Code Python
│   ├── main.py                    # Application FastAPI
│   ├── config.py                  # Configuration
│   ├── requirements.txt           # Dépendances Python
│   ├── app/
│   │   ├── api/
│   │   │   ├── routes/
│   │   │   │   └── segmentation.py
│   │   │   └── schemas.py
│   │   ├── models/
│   │   │   ├── sam_model.py       # Modèle SAM
│   │   │   └── image_processor.py
│   │   └── services/
│   │       └── segmentation_service.py
│   └── .env                       # Variables d'environnement
└── pubspec.yaml                   # Dépendances Flutter
```

## 🚀 Installation & Utilisation

### Backend

```bash
cd backend

# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Télécharger le modèle SAM (une seule fois)
# Voir: https://github.com/facebookresearch/segment-anything

# Lancer le serveur
python main.py
# L'API sera disponible sur http://localhost:8000
```

### Frontend

```bash
# À la racine du projet
flutter pub get

# Lancer l'application
flutter run -d linux  # ou macos, windows, etc
```

## 🎯 Fonctionnalités

### ✅ Implémenté
- Navigation des dossiers (arborescence)
- Affichage des images d'un dossier (grille)
- Visualisation d'une image en grand
- Clic sur l'image pour déclencher la segmentation
- Affichage du masque de segmentation
- Sauvegarde des masques binaires (même taille que l'originale)

### 🔄 En cours/À venir
- Sauvegarde des masques sur disque
- Historique des segmentations
- Export en différents formats
- Support du box-prompting (boîte délimitatrice)
- Améliorations UI/UX

## 🔌 Flux de Communication

```
Flutter App
    ↓
[Clique sur image] → récupère (x, y)
    ↓
BackendService.segmentImageByPoint(path, x, y)
    ↓
FastAPI POST /api/v1/segment/point
    ↓
SegmentationService
    ↓
SAMModel (PyTorch)
    ↓
Retourne masque (base64) + confiance
    ↓
Flutter affiche le masque en overlay
```

## 🔑 Modèles SAM Disponibles

- `vit_b` : Petit (95MB) - Rapide
- `vit_l` : Moyen (308MB) - Équilibré
- `vit_h` : Grand (2.5GB) - Meilleure qualité

Configurable via variable d'environnement `SAM_MODEL_TYPE` dans `backend/.env`

## 💾 Format des Données

### Masques
- **Type** : Binaire (0 et 255)
- **Format** : PNG ou numpy array
- **Taille** : Identique à l'image originale
- **Stockage** : Uint8List en mémoire, transfert en base64

### Résultats de Segmentation
```dart
SegmentationResult {
  imageId,
  imagePath,
  maskData (Uint8List),
  width,
  height,
  confidence (float),
  createdAt
}
```

## 🛠️ Configuration

### Backend (.env)
```env
SAM_MODEL_TYPE=vit_b    # Modèle à utiliser
DEVICE=cpu              # cpu ou cuda pour GPU
DEBUG=False             # Mode debug
PORT=8000               # Port du serveur
CORS_ORIGINS=...        # Origines autorisées
```

### Frontend (config/app_config.dart)
```dart
const String backendUrl = 'http://localhost:8000';
const String initialFolder = '/home';
```

## 📚 Dépendances Clés

### Flutter
- `flutter_riverpod` - Gestion d'état
- `image_picker` - Sélection d'images
- `dio` - Requêtes HTTP
- `image` - Traitement d'images

### Python
- `fastapi` - Framework API
- `torch` - ML framework
- `segment-anything` - Modèle SAM
- `pillow` - Traitement d'images
- `opencv-python` - Vision par ordinateur

## 📝 Licence

Projet développé avec Flutter et SAM (Meta)

## 🤝 Contribution

Les contributions sont bienvenues ! Veuillez soumettre un pull request.
