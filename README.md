# SEGMA - Image Segmentation with SAM 3

SEGMA est une solution de pointe pour la segmentation d'images, combinant la puissance de **Flutter** pour l'interface utilisateur et de **SAM 3 (Segment Anything Model 3)** de Meta pour l'intelligence artificielle.

## 🌟 Fonctionnalités Clés

- **Exploration Intelligente** : Arborescence de fichiers dynamique avec détection automatique des dossiers système (Documents, Images).
- **Segmentation SAM 3 Interactive** : 
    - **Mode Texte** : Segmentez des objets via des prompts en langage naturel.
    - **Mode Interactif** : Affinez vos masques en cliquant directement sur l'image (Inclusion/Exclusion).
- **Traitement par Lot (Batch)** : Segmentez l'intégralité d'un dossier en un seul clic avec un suivi de progression en temps réel (Streaming NDJSON).
- **Éditeur de Précision** : Interface dédiée pour l'ajustement des segments en temps réel avec retour visuel.
- **Gestion de l'Historique** : Suivez et triez vos segmentations par date, confiance ou nom de fichier.
- **Performance Industrielle** : Support natif du GPU (CUDA) via un backend haute performance en FastAPI.
- **Sécurité & Logs** : Système de journalisation robuste avec rotation automatique et protection des données sensibles en production.

## 🚀 Installation Rapide

### 1. Backend (Python)
Le serveur gère l'exécution du modèle SAM 3.
```bash
cd backend
pip install -r requirements.txt
python main.py
```
*Note: Un GPU NVIDIA avec CUDA est recommandé pour une réactivité optimale.*

### 2. Frontend (Flutter)
Compilez l'application pour votre plateforme (Linux, Windows).
```bash
# Installation des dépendances
flutter pub get

# Lancement en mode développement
flutter run -d linux

# Build de production avec URL backend personnalisée
flutter build linux --release --dart-define=BACKEND_URL=http://VOTRE_IP:8000
```

## 🏗️ Architecture Technique

- **Frontend** : Flutter 3.6+, Riverpod (Gestion d'état), Dio (Réseau). Architecture modulaire organisée par composants (`common`, `layout`, `image_viewer`).
- **Backend** : FastAPI, PyTorch, Segment Anything Model 3.
- **Déploiement** : Prêt pour Docker (Dockerfile inclus).

## 🧪 Tests

SEGMA inclut une suite de tests complète couvrant les modèles, les services et la logique métier.

```bash
# Lancer tous les tests
flutter test

# Lancer les tests avec couverture (génère un dossier coverage/)
flutter test --coverage
```

Consultez le [Guide des Tests](docs/guides/TESTING.md) pour plus de détails.

## 📄 Licence

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
