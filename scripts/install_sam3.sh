#!/bin/bash
# Script d'installation SAM3 pour venv existant
# Utilise: /home/shadowcraft/.pyenv

set -e

VENV_PATH="/home/shadowcraft/.pyenv"
PROJECT_PATH="/home/shadowcraft/Projets/segma"

echo "🚀 Installation SAM3 pour SEGMA"
echo "=================================="
echo ""
echo "✅ venv trouvé: $VENV_PATH"
echo "✅ Python: $($VENV_PATH/bin/python --version)"
echo ""

# Activer le venv
source $VENV_PATH/bin/activate

echo "📦 Packages actuels:"
pip list | grep -E "torch|fastapi|sam"

echo ""
echo "⚡ Installation de SAM3 et dépendances..."

# Installer les dépendances manquantes
pip install -U pip setuptools wheel

# Installer SAM3 et dépendances critiques
pip install sam3>=1.0
pip install huggingface-hub>=0.20.0
pip install pillow>=9.0
pip install opencv-python>=4.8.0
pip install numpy>=1.24.0
pip install pydantic>=2.7.0
pip install python-multipart==0.0.6
pip install uvicorn==0.27.0

echo ""
echo "✅ Installation complète!"
echo ""
echo "📦 Packages finaux:"
$VENV_PATH/bin/pip list | grep -E "torch|fastapi|sam|huggingface"

echo ""
echo "🔐 Prochaine étape: Authentification HuggingFace"
echo ""
echo "   $VENV_PATH/bin/huggingface-cli login"
echo ""
echo "   Puis acceptez les conditions sur:"
echo "   https://huggingface.co/facebook/sam3"
