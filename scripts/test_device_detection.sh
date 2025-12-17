#!/bin/bash

# 🎮 Test détection automatique GPU/CPU pour SAM3

set -e

echo "════════════════════════════════════════════════════════════════════════════"
echo "🎮 TEST DÉTECTION AUTOMATIQUE GPU/CPU - SAM3"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# Déterminer le venv
VENV_PATH="${VENV_PATH:-./.venv}"
if [ ! -d "$VENV_PATH" ]; then
    VENV_PATH="/home/shadowcraft/.pyenv"
fi

if [ ! -d "$VENV_PATH" ]; then
    echo "❌ Erreur: Virtualenv non trouvé"
    exit 1
fi

echo "✓ Venv trouvé: $VENV_PATH"
echo ""

# Activer le venv
source "$VENV_PATH/bin/activate"

# Test détection
echo "🔍 Test 1: Détection du device Python"
echo "────────────────────────────────────────────"
python << 'PYEOF'
import torch

print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA compiled: {torch.version.cuda is not None}")

if torch.cuda.is_available():
    print(f"\n🎮 GPU DÉTECTÉ:")
    print(f"   Device name: {torch.cuda.get_device_name(0)}")
    print(f"   VRAM: {torch.cuda.get_device_properties(0).total_memory / (1024**3):.1f}GB")
    print(f"   Compute capability: {torch.cuda.get_device_capability(0)}")
    print(f"   CUDA version: {torch.version.cuda}")
else:
    print(f"\n🖥️  AUCUN GPU - Utilisation du CPU")
    print(f"   CPU cores: {torch.get_num_threads()}")

PYEOF

echo ""
echo "🔍 Test 2: Détection SAM3Model"
echo "────────────────────────────────────────────"
cd /home/shadowcraft/Projets/segma/backend && python << 'PYEOF'
import sys
sys.path.insert(0, '.')

from app.models.sam3_model import get_sam3_model

print("Initialisation SAM3...")
sam3 = get_sam3_model()

info = sam3.get_info()
print(f"\nSAM3 Info:")
print(f"   Device utilisé: {sam3.device.upper()}")
print(f"   Model type: {info['model_type']}")
print(f"   Is loaded: {info['is_loaded']}")
print(f"   Capabilities: {', '.join(info['capabilities'])}")

PYEOF

echo ""
echo "🔍 Test 3: Détection ModelManager"
echo "────────────────────────────────────────────"
cd /home/shadowcraft/Projets/segma/backend && python << 'PYEOF'
import sys
sys.path.insert(0, '.')

from app.models.model_manager import model_manager

info = model_manager.get_model_info()
print(f"ModelManager Info:")
print(f"   Device: {info['device'].upper()}")
print(f"   Device name: {info['device_name']}")
if info['vram_gb']:
    print(f"   VRAM: {info['vram_gb']}GB")
print(f"   Model type: {info['model_type']}")
print(f"   Is loaded: {info['is_loaded']}")
print(f"   CUDA available: {info['cuda_available']}")

PYEOF

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "✅ TEST DÉTECTION COMPLÉTÉ"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📝 Résumé:"
echo "   • Si GPU détecté → SAM3 utilise CUDA automatiquement"
echo "   • Si pas de GPU → SAM3 utilise CPU automatiquement"
echo "   • Détection se fait au démarrage du backend"
echo ""
echo "💡 Pour utiliser GPU: Assurez-vous d'avoir:"
echo "   ✓ PyTorch compilé avec support CUDA"
echo "   ✓ Drivers NVIDIA installés"
echo "   ✓ CUDA Toolkit compatible"
echo ""
