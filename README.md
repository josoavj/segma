<p align="center">
  <img src="https://github.com/josoavj/segma/blob/main/assets/logo/main.png" alt="Segma Logo" width="150"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue?style=for-the-badge" alt="Desktop Platforms">
  <img src="https://img.shields.io/badge/Version-1.0.0-green?style=for-the-badge" alt="Version">
</p>

<h1 align="center">SEGMA</h1>

<p align="center">
  <strong>Image Segmentation with SAM 3</strong>
</p>

<p align="center">
  SEGMA est une solution pour la segmentation d'images, combinant la puissance et l'interface fluide de **Flutter** pour l'interface utilisateur et de **SAM 3 (Segment Anything Model 3)** de Meta pour l'intelligence artificielle.
</p>

## Fonctionnalités Clés

- **Exploration Intelligente** : Arborescence de fichiers dynamique avec détection automatique des dossiers système (Documents, Images).
- **Segmentation SAM 3 Interactive** : 
    - **Mode Texte** : Segmentez des objets via des prompts en langage naturel.
    - **Mode Interactif** : Affinez vos masques en cliquant directement sur l'image (Inclusion/Exclusion).
- **Traitement par lot** : Traitez les images d'un dossier local les unes après les autres avec un suivi de progression.
- **Éditeur de Précision** : Interface dédiée pour l'ajustement des segments en temps réel avec retour visuel.
- **Gestion de l'Historique** : Suivez et triez vos segmentations par date, confiance ou nom de fichier.
- **Accélération** : Support CUDA et Apple MPS lorsque disponibles, avec repli CPU.
- **Sécurité & Logs** : Système de journalisation robuste avec rotation automatique et protection des données sensibles en production.

## Installation Rapide

### 1. Initialisation automatique (Recommandé)

Le projet inclut des scripts intelligents pour configurer votre environnement automatiquement.

```bash

# À la racine du projet

bash scripts/init_project.sh
```

*Ce script installera SAM 3, vérifiera votre installation CUDA et configurera vos alias de commande.*

### 2. Démarrage des Services

- **Backend** : `bash scripts/run_server.sh` (ou `segma-backend` si les alias sont installés).
- **Frontend** : `flutter run -d linux` (ou `segma-flutter`).

*Note: Un GPU NVIDIA avec CUDA est recommandé pour une réactivité optimale.*

## Architecture Technique

- **Frontend** : Flutter 3.6+, Riverpod (gestion d'état), Dio (réseau). Architecture organisée par fonctionnalités sous `lib/features/`, avec les composants d'application sous `lib/app/` et `lib/core/`.
- **Backend** : FastAPI, PyTorch, Segment Anything Model 3.
- **Exécution** : Application Flutter et backend lancés localement sur la machine de l’utilisateur.

## Tests

SEGMA inclut une suite de tests complète couvrant les modèles, les services et la logique métier.

```bash
# Lancer tous les tests
flutter test

# Lancer les tests avec couverture (génère un dossier coverage/)
flutter test --coverage
```

Consultez le [Guide des Tests](docs/guides/TESTING.md) pour plus de détails.

## Licence

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Editeur et mainteneur

- **[josoavj](https://github.com/josoavj)**
