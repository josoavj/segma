#!/bin/bash

# [TEST] Test SAM3 - Vérification de l'installation
# Ce script teste si SAM3 est correctement installé et fonctionne

set -e

echo "════════════════════════════════════════════════════════════════════════════"
echo "[TEST] TEST SAM3 - Vérification de l'installation"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# [STEP] Déterminer le chemin du venv
VENV_PATH="${VENV_PATH:-./.venv}"
if [ ! -d "$VENV_PATH" ]; then
    VENV_PATH="/home/shadowcraft/.pyenv"
fi

if [ ! -d "$VENV_PATH" ]; then
    echo "[ERROR] Erreur: Virtualenv non trouvé"
    echo "   Utilisez: export VENV_PATH=/chemin/vers/venv"
    exit 1
fi

echo "[SUCCESS] Venv trouvé: $VENV_PATH"
echo ""

# [STEP] Activer le virtualenv
source "$VENV_PATH/bin/activate"
echo "[SUCCESS] Virtualenv activé"
echo ""

# [STEP] Vérifier Python
echo "[PYTHON] Version Python:"
python --version
echo ""

# [STEP] Vérifier les dépendances critiques
echo "[DEPENDENCY] Vérification des dépendances:"
python -c "import torch; print(f'   [SUCCESS] PyTorch: {torch.__version__}')" || echo "   [ERROR] PyTorch manquant"
python -c "import torchvision; print(f'   [SUCCESS] TorchVision: {torchvision.__version__}')" || echo "   [ERROR] TorchVision manquant"
python -c "from transformers import Sam3Processor, Sam3Model; print('   [SUCCESS] Transformers SAM3: OK')" || echo "   [ERROR] Transformers SAM3 manquant"
python -c "import huggingface_hub; print(f'   [SUCCESS] HuggingFace Hub: OK')" || echo "   [WARNING]  HuggingFace Hub manquant"
python -c "import fastapi; print(f'   [SUCCESS] FastAPI: OK')" || echo "   [WARNING]  FastAPI manquant"
echo ""

# [STEP] Test d'import SAM3
echo "[DETAIL] Test d'import SAM3 détaillé:"
python << 'EOF'
try:
    from transformers import Sam3Processor, Sam3Model
    print("   [SUCCESS] Sam3Processor importable")
    print("   [SUCCESS] Sam3Model importable")

    processor = Sam3Processor.from_pretrained("facebook/sam3")
    model = Sam3Model.from_pretrained("facebook/sam3")
    print(f"   [SUCCESS] Processor chargé: {processor.__class__.__name__}")
    print(f"   [SUCCESS] Modèle chargé: {model.__class__.__name__}")
    
    print("\n   [SUCCESS] SAM3 est correctement installé!")
    
except Exception as e:
    print(f"   [ERROR] Erreur lors de l'import: {e}")
    import traceback
    traceback.print_exc()
EOF

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "[SUCCESS] Test terminé!"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "[INFO] Prochaines étapes:"
echo "   1. Configuration HuggingFace: segma-hf ou bash scripts/setup_hf.sh"
echo "   2. Démarrer le backend: segma-backend ou bash ../backend/start.sh"
echo "   3. Tester l'API: segma-health"
echo ""
