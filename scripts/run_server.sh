#!/bin/bash
set -e

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo "[BACKEND] Lancement du serveur backend SAM3 & YOLO..."
echo "Racine du projet: $PROJECT_ROOT"
echo "Utilisation de Python: $PYTHON_BIN"

# Lancer le point d'entrée pour que HOST, PORT et DEBUG du backend soient appliqués.
cd "$BACKEND_DIR"
exec "$PYTHON_BIN" main.py
