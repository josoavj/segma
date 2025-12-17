#!/bin/bash
# Script pour configurer SAM3 avec votre venv

VENV_PATH="/home/shadowcraft/.pyenv"
PROJECT_PATH="/home/shadowcraft/Projets/segma"

echo ""
echo "=================================================="
echo "  🔐 CONFIGURATION HUGGINGFACE POUR SAM3"
echo "=================================================="
echo ""
echo "SAM3 nécessite un token HuggingFace pour télécharger le modèle."
echo ""
echo "📋 Étapes:"
echo ""
echo "1. Allez sur: https://huggingface.co/settings/tokens"
echo "2. Créez un nouveau token (type: Read)"
echo "3. Copier le token"
echo "4. Exécutez:"
echo ""
echo "   $VENV_PATH/bin/huggingface-cli login"
echo ""
echo "5. Collez votre token quand demandé"
echo ""
echo "6. ⚠️  IMPORTANT: Acceptez les conditions du modèle SAM3:"
echo "   https://huggingface.co/facebook/sam3"
echo "   (Bouton 'I have read the license and agree with the terms')"
echo ""
echo "7. Une fois configuré, testez:"
echo ""
echo "   cd $PROJECT_PATH/backend"
echo "   $VENV_PATH/bin/python test_sam3.py"
echo ""
echo "=================================================="
echo ""

# Proposer de commencer l'authentification
read -p "Voulez-vous configurer HuggingFace maintenant? (o/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    $VENV_PATH/bin/huggingface-cli login
fi
