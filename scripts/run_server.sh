#!/bin/bash
set -e

BACKEND_DIR="/home/shadowcraft/Projets/segma/backend"
PYENV_BIN="/home/shadowcraft/.pyenv/bin/python"

echo "🚀 Lancement du serveur backend SAM3 & YOLO..."
echo "Backend: $BACKEND_DIR"

cd "$BACKEND_DIR"

# Lancer le serveur avec l'interpréteur pyenv
export PYTHONPATH="$BACKEND_DIR:$PYTHONPATH"
"$PYENV_BIN" -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload