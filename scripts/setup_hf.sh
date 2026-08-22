#!/bin/bash
# Script pour configurer SAM3 avec l'environnement détecté

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  [AUTH] CONFIGURATION HUGGINGFACE POUR SAM3"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "SAM3 nécessite un token HuggingFace pour télécharger le modèle."
echo ""
echo "[INFO] Étapes:"
echo ""
echo "1. Allez sur: https://huggingface.co/settings/tokens"
echo "2. Créez un nouveau token (type: Read)"
echo "3. Copier le token"
echo "4. Exécutez le login ci-dessous"
echo ""
echo "5. [WARNING] IMPORTANT: Acceptez les conditions du modèle SAM3:"
echo "   https://huggingface.co/facebook/sam3"
echo ""

# Proposer de commencer l'authentification
read -p "Voulez-vous configurer HuggingFace maintenant? (o/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    # Essayer de trouver huggingface-cli dans le venv
    HF_CLI="$VENV_PATH/bin/huggingface-cli"
    if [ ! -f "$HF_CLI" ]; then
        HF_CLI="huggingface-cli" # Fallback système
    fi

    "$HF_CLI" login
fi

echo ""
echo "=================================================="
echo "[INFO] Pour tester la configuration:"
echo "   bash scripts/test_sam3.sh"
echo "=================================================="
echo ""
