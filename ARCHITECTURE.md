# Documentation de l'Architecture - SEGMA

SEGMA utilise une architecture client-serveur découplée pour offrir une expérience fluide de segmentation d'IA haute performance.

## 🏗️ Architecture Globale

### 1. Frontend (Flutter)
Interface utilisateur réactive et multiplateforme (Linux/Windows).
- **Gestion d'État** : Riverpod (AsyncNotifier) pour une logique asynchrone robuste.
- **Réseau** : Dio avec des intercepteurs configurés pour la sécurité en production.
- **Interaction** : Normalisation des coordonnées de clics pour une compatibilité parfaite avec SAM, quel que soit l'écran.

### 2. Backend (Python/FastAPI)
Moteur d'exécution pour SAM 3.
- **Modèle** : `facebook/sam3` (Segment Anything Model 3).
- **Accélération** : Support CUDA pour des temps de réponse inférieurs à la seconde.
- **APIs (v3)** :
    - `GET /api/v3/health` : État du serveur.
    - `POST /api/v3/upload` : Envoi d'images.
    - `POST /api/v3/segment` : Segmentation hybride (Texte + Points).
    - `POST /api/v3/segment/batch` : Traitement par lot asynchrone (Streaming NDJSON).
    - `GET /api/v3/model/info` : Statut du GPU et du modèle chargé.

## 📦 Structure du Code Source

### Flutter (`lib/`)
- `config/` : Configuration dynamique (URLs, Timeouts).
- `models/` : Modèles de données typés.
- `providers/` : Logique métier et gestion d'état réactive (Riverpod).
- `screens/` : Points d'entrée des pages (épurés).
- `services/` : Services d'infrastructure (API, Système de fichiers, Logs).
- `widgets/` : Composants UI organisés par modules :
    - `common/` : Boutons, tuiles et cartes réutilisables.
    - `home/` : Composants spécifiques à la page d'accueil.
    - `image_viewer/` : Panneaux et overlays du visualiseur d'images.
    - `layout/` : Structure globale (Sidebar, Background).
    - `dialogs/` : Boîtes de dialogue et popups.
- `utils/` : Fonctions utilitaires (formatage, UI).

### Backend (`backend/`)
- `main.py` : Point d'entrée FastAPI.
- `app/` : Logique métier Python (Services, API, Modèles SAM3).
- `requirements.txt` : Dépendances IA.

## 🧪 Architecture de Test

Le projet utilise une suite de tests structurée dans le dossier `test/` :

1.  **Tests Unitaires (`test/unit/`)** : validation des modèles et des services en isolation.
2.  **Tests de Providers (`test/providers/`)** : validation de la logique métier et des flux de données (ex: streaming NDJSON).
3.  **Tests de Widgets (`test/widgets/`)** : validation du rendu et des interactions UI.

L'utilisation de `mocktail` permet de simuler le backend et le système de fichiers pour des tests rapides et déterministes.

## 🔌 Flux d'Interaction Interactif

1. **Chargement** : L'utilisateur sélectionne une image. Elle est uploadée une seule fois sur le backend.
2. **Interaction** : L'utilisateur clique sur l'image (Inclusion ou Exclusion).
3. **Traitement** : Flutter envoie les coordonnées normalisées `(0.0 à 1.0)` au backend.
4. **Calcul** : SAM 3 traite l'image avec les nouveaux points en utilisant le cache d'embedding.
5. **Rendu** : Flutter reçoit le nouveau masque et le dessine instantanément via un overlay.

## 🚀 Optimisations de Production

- **Streaming Temps Réel** : Le traitement par lot utilise le protocole NDJSON pour envoyer les résultats au fil de l'eau, évitant les timeouts et permettant une UI réactive.
- **Mise en cache** : Les images ne sont pas ré-uploadées inutilement.
- **Isolats de Rendu** : Utilisation de `RepaintBoundary` pour isoler les animations d'interface du contenu d'image statique.
- **Sécurité** : Les logs techniques sont automatiquement désactivés en mode production pour protéger la vie privée des utilisateurs.
- **Dockerisation** : Le backend est prêt pour le déploiement via Docker avec support GPU.

---
*Mis à jour : 2026*
