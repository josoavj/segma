#!/bin/bash

# 🧪 Test SAM3 - Vérification de l'installation
# Ce script teste si SAM3 est correctement installé et fonctionne

set -e

echo "════════════════════════════════════════════════════════════════════════════"
echo "🧪 TEST SAM3 - Vérification de l'installation"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# 1️⃣ Déterminer le chemin du venv
VENV_PATH="${VENV_PATH:-./.venv}"
if [ ! -d "$VENV_PATH" ]; then
    VENV_PATH="/home/shadowcraft/.pyenv"
fi

if [ ! -d "$VENV_PATH" ]; then
    echo "❌ Erreur: Virtualenv non trouvé"
    echo "   Utilisez: export VENV_PATH=/chemin/vers/venv"
    exit 1
fi

echo "✓ Venv trouvé: $VENV_PATH"
echo ""

# 2️⃣ Activer le virtualenv
source "$VENV_PATH/bin/activate"
echo "✓ Virtualenv activé"
echo ""

# 3️⃣ Vérifier Python
echo "🐍 Version Python:"
python --version
echo ""

# 4️⃣ Vérifier les dépendances critiques
echo "📦 Vérification des dépendances:"
python -c "import torch; print(f'   ✓ PyTorch: {torch.__version__}')" || echo "   ❌ PyTorch manquant"
python -c "import torchvision; print(f'   ✓ TorchVision: {torchvision.__version__}')" || echo "   ❌ TorchVision manquant"
python -c "from transformers import Sam3Processor, Sam3Model; print('   ✓ Transformers SAM3: OK')" || echo "   ❌ Transformers SAM3 manquant"
python -c "import huggingface_hub; print(f'   ✓ HuggingFace Hub: OK')" || echo "   ⚠️  HuggingFace Hub manquant"
python -c "import fastapi; print(f'   ✓ FastAPI: OK')" || echo "   ⚠️  FastAPI manquant"
echo ""

# 5️⃣ Test d'import SAM3
echo "🔬 Test d'import SAM3 détaillé:"
python << 'EOF'
try:
    from transformers import Sam3Processor, Sam3Model
    print("   ✓ Sam3Processor importable")
    print("   ✓ Sam3Model importable")

    processor = Sam3Processor.from_pretrained("facebook/sam3")
    model = Sam3Model.from_pretrained("facebook/sam3")
    print(f"   ✓ Processor chargé: {processor.__class__.__name__}")
    print(f"   ✓ Modèle chargé: {model.__class__.__name__}")
    
    print("\n   ✅ SAM3 est correctement installé!")
    
except Exception as e:
    print(f"   ❌ Erreur lors de l'import: {e}")
    import traceback
    traceback.print_exc()
EOF

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "✅ Test terminé!"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Configuration HuggingFace: segma-hf ou bash scripts/setup_hf.sh"
echo "   2. Démarrer le backend: segma-backend ou bash ../backend/start.sh"
echo "   3. Tester l'API: segma-health"
echo ""
