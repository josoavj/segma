# 📚 Guide d'Installation Complète

Ce guide détaille l'installation de SEGMA et de ses composants (Backend Python et Frontend Flutter).

## 1. Environnement Backend (Python)

### Prérequis
- Python 3.10 ou supérieur
- Un GPU NVIDIA (optionnel mais recommandé pour CUDA)

### Installation manuelle
```bash
cd backend

# Création de l'environnement virtuel
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Mise à jour des outils de base
pip install --upgrade pip setuptools wheel

# Installation des dépendances principales
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121  # Pour CUDA 12.1
pip install fastapi uvicorn pillow opencv-python numpy huggingface-hub python-multipart

# Installation de SAM 3
pip install 'git+https://github.com/facebookresearch/segment-anything.git'
```

### Authentification HuggingFace
Le modèle SAM 3 nécessite une licence acceptée sur HuggingFace.
1. Créez un compte sur [huggingface.co](https://huggingface.co).
2. Acceptez les conditions du modèle [facebook/sam3](https://huggingface.co/facebook/sam3).
3. Connectez-vous via le CLI :
```bash
huggingface-cli login
```

---

## 2. Environnement Frontend (Flutter)

### Prérequis
- Flutter SDK 3.6.0 ou supérieur.
- Outils de build pour votre OS (C++ pour Windows, GTK pour Linux).

### Installation
```bash
# À la racine du projet
flutter pub get
```

---

## 3. Lancement des Services

### Démarrer le Backend
```bash
cd backend
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000
```
Le serveur sera disponible sur `http://localhost:8000`.

### Démarrer le Frontend (Mode Développement)
```bash
flutter run -d linux # ou windows
```

---

## 🛠️ Dépannage Courant

### CUDA non détecté
Si le backend affiche `device: cpu` alors que vous avez un GPU :
- Vérifiez l'installation de vos drivers NVIDIA.
- Réinstallez PyTorch avec la version CUDA correspondante (ex: `cu118`, `cu121`).

### Erreurs de droits (Linux)
Si Flutter ne parvient pas à lire certains dossiers, vérifiez que votre utilisateur a les permissions nécessaires ou lancez en mode utilisateur (pas root).

### Latence au premier lancement
C'est normal. Le premier chargement de SAM 3 peut prendre jusqu'à 5 minutes pour charger les poids du modèle en mémoire vidéo.
