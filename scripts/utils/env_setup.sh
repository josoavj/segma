#!/bin/bash

# Configuration globale et détection d'environnement pour SEGMA

# 1. Déterminer le répertoire racine du projet (deux niveaux au-dessus de scripts/utils/)
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd "$UTILS_DIR/../../" && pwd)"
export BACKEND_DIR="$PROJECT_ROOT/backend"

# 2. Charger les variables locales si elles existent (pour les chemins spécifiques machine)
if [ -f "$PROJECT_ROOT/scripts/local_env.sh" ]; then
    source "$PROJECT_ROOT/scripts/local_env.sh"
fi

# 3. Détecter le Virtualenv (VENV_PATH peut être défini dans local_env.sh)
if [ -z "$VENV_PATH" ]; then
    # Liste de recherche prioritaire pour le venv
    SEARCH_PATHS=(
        "$PROJECT_ROOT/.venv"
        "$PROJECT_ROOT/venv"
        "$PROJECT_ROOT/backend/venv"
        "/home/shadowcraft/.pyenv" # Fallback local spécifique (sera supprimé plus tard pour portabilité totale)
    )

    for path in "${SEARCH_PATHS[@]}"; do
        if [ -d "$path/bin" ]; then
            VENV_PATH="$path"
            break
        fi
    done
fi

# 4. Définir les binaires
if [ -n "$VENV_PATH" ]; then
    export PYTHON_BIN="$VENV_PATH/bin/python"
    export PIP_BIN="$VENV_PATH/bin/pip"
    export UVICORN_BIN="$VENV_PATH/bin/uvicorn"
    export VENV_ACTIVE=true
else
    # Fallback système si aucun venv trouvé
    export PYTHON_BIN="python3"
    export PIP_BIN="pip3"
    export UVICORN_BIN="uvicorn"
    export VENV_ACTIVE=false
fi

# Affichage debug (optionnel)
# echo "[INFO] Project Root: $PROJECT_ROOT"
# echo "[INFO] Python Bin: $PYTHON_BIN"
