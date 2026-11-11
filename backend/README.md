# Backend SEGMA

Le backend FastAPI est exécuté localement par l'application de bureau Flutter. Il reçoit les images choisies par l'utilisateur, exécute SAM 3 et écrit les masques dans `backend/data/` par défaut.

## Installation locale

Depuis la racine du dépôt, utilisez l'environnement Python destiné au projet puis installez les dépendances :

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r backend/requirements.txt
```

Le modèle `facebook/sam3` peut demander l'acceptation de ses conditions Hugging Face et une authentification locale avec `huggingface-cli login`.

## Démarrage

Depuis la racine du dépôt :

```bash
bash scripts/run_server.sh
```

Ou depuis `backend/` avec l'environnement activé :

```bash
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

La configuration se fait avec les variables de `backend/config.py`; un fichier `.env` à la racine peut les remplacer. Les principales sont `HOST`, `PORT`, `DEVICE`, `SAM3_MODEL_ID`, `MAX_FILE_SIZE`, `UPLOAD_DIR` et `OUTPUT_DIR`.

## API

L'API v3 expose le health check, l'upload, la segmentation texte ou guidée par clics, les informations modèle et le changement de device. Les exemples de requêtes et la structure de réponse sont dans [API_USAGE.md](API_USAGE.md).

Le traitement par lot est orchestré par Flutter, qui envoie les images une à une. Il n'y a pas de route batch dans le backend.
