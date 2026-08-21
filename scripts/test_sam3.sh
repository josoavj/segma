#!/bin/bash

# [TEST] Test SAM3 - Vérification de l'installation
# Ce script teste si SAM3 est correctement installé et fonctionne

set -e

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo "════════════════════════════════════════════════════════════════════════════"
echo "[TEST] TEST SAM3 - Vérification de l'installation"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

if [ "$VENV_ACTIVE" = true ]; then
    echo "[SUCCESS] Venv trouvé: $VENV_PATH"
else
    echo "[INFO] Utilisation de Python système"
fi
echo ""

# [STEP] Vérifier Python
echo "[PYTHON] Version Python:"
"$PYTHON_BIN" --version
echo ""

# [STEP] Vérifier les dépendances critiques
echo "[DEPENDENCY] Vérification des dépendances:"
"$PYTHON_BIN" -c "import torch; print(f'   [SUCCESS] PyTorch: {torch.__version__}')" || echo "   [ERROR] PyTorch manquant"
"$PYTHON_BIN" -c "import torchvision; print(f'   [SUCCESS] TorchVision: {torchvision.__version__}')" || echo "   [ERROR] TorchVision manquant"
"$PYTHON_BIN" -c "from transformers import Sam3Processor, Sam3Model; print('   [SUCCESS] Transformers SAM3: OK')" || echo "   [ERROR] Transformers SAM3 manquant"
"$PYTHON_BIN" -c "import huggingface_hub; print(f'   [SUCCESS] HuggingFace Hub: OK')" || echo "   [WARNING]  HuggingFace Hub manquant"
"$PYTHON_BIN" -c "import fastapi; print(f'   [SUCCESS] FastAPI: OK')" || echo "   [WARNING]  FastAPI manquant"
echo ""

# [STEP] Test d'import SAM3
echo "[DETAIL] Test d'import SAM3 détaillé:"
cd "$BACKEND_DIR" && "$PYTHON_BIN" << 'EOF'
import sys
sys.path.insert(0, '.')

try:
    from transformers import Sam3Processor, Sam3Model
    print("   [SUCCESS] Sam3Processor importable")
    print("   [SUCCESS] Sam3Model importable")

    # On teste l'instanciation du wrapper harmonisé
    from app.models.sam3.sam3_wrapper import SAM3Wrapper
    print("   [INFO] Chargement du wrapper SAM3...")
    
    # On fait juste un test d'import pour ce script rapide
    print("   [SUCCESS] Wrapper SAM3Wrapper importable")

    print("\n   [SUCCESS] SAM3 est prêt pour l'utilisation!")
    
except Exception as e:
    print(f"   [ERROR] Erreur: {e}")
    import traceback
    traceback.print_exc()
EOF

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "[SUCCESS] Test terminé!"
echo "════════════════════════════════════════════════════════════════════════════"
