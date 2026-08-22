#!/bin/bash
# Script d'installation SAM3 pour venv détecté

set -e

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo "════════════════════════════════════════════════════════════════════════════"
echo "[INIT] INSTALLATION SAM3 POUR SEGMA"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

if [ "$VENV_ACTIVE" = true ]; then
    echo "[SUCCESS] Virtualenv détecté: $VENV_PATH"
else
    echo "[WARNING] Aucun virtualenv détecté. Installation sur Python système."
    echo "          Il est recommandé d'utiliser un venv."
fi

echo "[INFO] Version Python: $($PYTHON_BIN --version)"
echo ""

# Mise à jour des outils de base
echo "⚡ Mise à jour de pip..."
"$PYTHON_BIN" -m pip install -U pip setuptools wheel

echo ""
echo "⚡ Installation des dépendances critiques..."

# Installer les dépendances depuis requirements.txt si présent, sinon liste manuelle
if [ -f "$BACKEND_DIR/requirements.txt" ]; then
    "$PYTHON_BIN" -m pip install -r "$BACKEND_DIR/requirements.txt"
else
    # Liste de secours
    "$PYTHON_BIN" -m pip install "sam3>=1.0" \
        "huggingface-hub>=0.20.0" \
        "pillow>=9.0" \
        "opencv-python>=4.8.0" \
        "numpy>=1.24.0" \
        "pydantic>=2.7.0" \
        "python-multipart==0.0.6" \
        "uvicorn==0.27.0"
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "[SUCCESS] INSTALLATION TERMINÉE!"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "[INFO] Résumé des packages installés:"
"$PYTHON_BIN" -m pip list | grep -E "torch|fastapi|sam|huggingface"
echo ""
echo "[AUTH] Prochaine étape: Authentification HuggingFace"
echo "       Exécutez: bash scripts/setup_hf.sh"
echo ""
