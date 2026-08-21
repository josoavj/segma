#!/bin/bash
set -e

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo "[BACKEND] Lancement du serveur backend SAM3 & YOLO..."
echo "Racine du projet: $PROJECT_ROOT"
echo "Utilisation de Python: $PYTHON_BIN"

cd "$BACKEND_DIR"

# Lancer le serveur avec l'interpréteur détecté
export PYTHONPATH="$BACKEND_DIR:$PYTHONPATH"
"$PYTHON_BIN" -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
