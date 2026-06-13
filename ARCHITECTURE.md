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
    - `GET /api/v3/model/info` : Statut du GPU et du modèle chargé.

## 📦 Structure du Code Source

### Flutter (`lib/`)
- `config/` : Configuration dynamique (URLs, Timeouts).
- `models/` : Modèles de données typés (SegmentationResult, InteractivePoint).
- `providers/` : Logique métier (Navigation, Fichiers, Segmentation).
- `screens/` : Pages de l'interface utilisateur.
- `services/` : Services de bas niveau (Fichiers, Logs, Réseau).
- `widgets/` : Composants UI réutilisables et Overlay graphiques.

### Backend (`backend/`)
- `main.py` : Point d'entrée FastAPI.
- `requirements.txt` : Dépendances (PyTorch, FastAPI, SAM 3).

## 🔌 Flux d'Interaction Interactif

1. **Chargement** : L'utilisateur sélectionne une image. Elle est uploadée une seule fois sur le backend.
2. **Interaction** : L'utilisateur clique sur l'image (Inclusion ou Exclusion).
3. **Traitement** : Flutter envoie les coordonnées normalisées `(0.0 à 1.0)` au backend.
4. **Calcul** : SAM 3 traite l'image avec les nouveaux points en utilisant le cache d'embedding.
5. **Rendu** : Flutter reçoit le nouveau masque et le dessine instantanément via un overlay.

## 🚀 Optimisations de Production

- **Mise en cache** : Les images ne sont pas ré-uploadées inutilement.
- **Isolats de Rendu** : Utilisation de `RepaintBoundary` pour isoler les animations d'interface du contenu d'image statique.
- **Sécurité** : Les logs techniques sont automatiquement désactivés en mode production pour protéger la vie privée des utilisateurs.
- **Dockerisation** : Le backend est prêt pour le déploiement via Docker avec support GPU.

---
*Mis à jour : 2026*
