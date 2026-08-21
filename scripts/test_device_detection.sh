#!/bin/bash

# [GPU] Test détection automatique GPU/CPU pour SAM3

set -e

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo "════════════════════════════════════════════════════════════════════════════"
echo "[GPU] TEST DÉTECTION AUTOMATIQUE GPU/CPU - SAM3"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

if [ "$VENV_ACTIVE" = true ]; then
    echo "[SUCCESS] Venv trouvé: $VENV_PATH"
else
    echo "[INFO] Utilisation de Python système"
fi
echo ""

# Test détection
echo "[CHECK] Test 1: Détection du device Python"
echo "────────────────────────────────────────────"
"$PYTHON_BIN" << 'PYEOF'
import torch

print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA compiled: {torch.version.cuda is not None}")

if torch.cuda.is_available():
    print(f"\n[GPU] GPU DÉTECTÉ:")
    print(f"   Device name: {torch.cuda.get_device_name(0)}")
    print(f"   VRAM: {torch.cuda.get_device_properties(0).total_memory / (1024**3):.1f}GB")
    print(f"   Compute capability: {torch.cuda.get_device_capability(0)}")
    print(f"   CUDA version: {torch.version.cuda}")
else:
    print(f"\n[CPU] AUCUN GPU - Utilisation du CPU")
    print(f"   CPU cores: {torch.get_num_threads()}")

PYEOF

echo ""
echo "[CHECK] Test 2: Détection SAM3Wrapper"
echo "────────────────────────────────────────────"
cd "$BACKEND_DIR" && "$PYTHON_BIN" << 'PYEOF'
import sys
sys.path.insert(0, '.')

try:
    from app.models.sam3.sam3_wrapper import SAM3Wrapper
    print("Initialisation SAM3Wrapper...")
    print("[SUCCESS] Import SAM3Wrapper réussi")
except Exception as e:
    print(f"[ERROR] Échec import SAM3Wrapper: {e}")

PYEOF

echo ""
echo "[CHECK] Test 3: Détection ModelManager"
echo "────────────────────────────────────────────"
cd "$BACKEND_DIR" && "$PYTHON_BIN" << 'PYEOF'
import sys
sys.path.insert(0, '.')

from app.models.model_manager import model_manager

info = model_manager.get_model_info()
print(f"ModelManager Info:")
print(f"   Device: {info['device'].upper()}")
print(f"   Device name: {info['device_name']}")
if info.get('vram_gb'):
    print(f"   VRAM: {info['vram_gb']}GB")
print(f"   Model type: {info['model_type']}")
print(f"   Is loaded: {info['is_loaded']}")
print(f"   CUDA available: {info['cuda_available']}")

PYEOF

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "[SUCCESS] TEST DÉTECTION COMPLÉTÉ"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
