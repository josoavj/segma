# Guide d'Installation Complète

Ce guide détaille l'installation de SEGMA. Nous recommandons l'utilisation des scripts automatisés pour une expérience simplifiée.

## ⚙️ Méthode Recommandée (Scripts)

Le projet utilise un système de détection d'environnement intelligent.

### 1. Initialisation
```bash
bash scripts/init_project.sh
```
Ce script va :
- Détecter ou créer un environnement virtuel (`.venv`).
- Installer toutes les dépendances Python nécessaires.
- Vérifier la compatibilité CUDA.
- Configurer les raccourcis de commande.

### 2. Configuration Personnalisée (Optionnel)
Si vous utilisez un environnement spécifique (ex: `pyenv`), créez un fichier `scripts/local_env.sh` (ce fichier est ignoré par Git) :
```bash
export VENV_PATH="/votre/chemin/vers/.pyenv"
```

---

## 🛠️ Installation Manuelle

Si vous préférez tout gérer vous-même :

### 1. Environnement Backend (Python)
...

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

## Dépannage Courant

### CUDA non détecté
Si le backend affiche `device: cpu` alors que vous avez un GPU :
- Vérifiez l'installation de vos drivers NVIDIA.
- Réinstallez PyTorch avec la version CUDA correspondante (ex: `cu118`, `cu121`).

### Erreurs de droits (Linux)
Si Flutter ne parvient pas à lire certains dossiers, vérifiez que votre utilisateur a les permissions nécessaires ou lancez en mode utilisateur (pas root).

### Latence au premier lancement
C'est normal. Le premier chargement de SAM 3 peut prendre jusqu'à 5 minutes pour charger les poids du modèle en mémoire vidéo.
