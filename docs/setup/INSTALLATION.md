# Guide d'Installation Complète

Ce guide détaille l'installation de SEGMA. Nous recommandons l'utilisation des scripts automatisés pour une expérience simplifiée.

## ⚙️ Méthode Recommandée (Scripts)

Le backend et l'application Flutter tournent sur le poste de travail. Le backend écoute sur `127.0.0.1` par défaut.

### 1. Initialisation
```bash
bash scripts/init_project.sh
```
Ce script détecte l'environnement Python puis installe les dépendances IA. Il ne crée pas de virtualenv automatiquement : créez-le d'abord si nécessaire. Il propose également des vérifications et la configuration des helpers.

### 2. Configuration Personnalisée (Optionnel)
Si vous utilisez un environnement spécifique (ex: `pyenv`), créez un fichier `scripts/local_env.sh` (ce fichier est ignoré par Git) :
```bash
export VENV_PATH="/votre/chemin/vers/.pyenv"
```

---

## 🛠️ Installation Manuelle

Si vous préférez tout gérer vous-même :

### 1. Environnement Backend (Python)

Depuis la racine du dépôt :

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r backend/requirements.txt
```

L'initialisation guidée peut ensuite être lancée avec `bash scripts/init_project.sh`.

### Accès au modèle Hugging Face
Le téléchargement du modèle peut nécessiter l'acceptation des conditions Hugging Face et une authentification locale.
1. Créez un compte sur [huggingface.co](https://huggingface.co).
2. Acceptez les conditions du modèle [facebook/sam3](https://huggingface.co/facebook/sam3).
3. Si l'accès est demandé, connectez-vous via le CLI :
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
source .venv/bin/activate
bash scripts/run_server.sh
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
Le backend télécharge les poids si nécessaire puis charge SAM 3 en mémoire. La durée dépend de la connexion Internet, du stockage et du matériel.
