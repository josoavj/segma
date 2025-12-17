#!/bin/bash

# 🚀 Initialisation complète du projet SEGMA
# Ce script configure tout ce qui est nécessaire pour démarrer le projet

set -e

echo "════════════════════════════════════════════════════════════════════════════"
echo "🚀 INITIALISATION COMPLÈTE DU PROJET SEGMA"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="${VENV_PATH:-./.venv}"
if [ ! -d "$VENV_PATH" ]; then
    VENV_PATH="/home/shadowcraft/.pyenv"
fi

echo "📂 Projet: $PROJECT"
echo "🐍 Venv: $VENV_PATH"
echo ""

# 1️⃣ Vérifier le venv
echo "🔍 Étape 1: Vérification du virtualenv..."
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ Erreur: Virtualenv non trouvé à $VENV_PATH"
    echo "   Créez un venv: python3 -m venv $VENV_PATH"
    exit 1
fi
echo "✓ Virtualenv trouvé"
echo ""

# 2️⃣ Installer SAM3
echo "📦 Étape 2: Installation de SAM3..."
bash "$SCRIPT_DIR/install_sam3.sh"
echo ""

# 3️⃣ Tester SAM3
echo "🧪 Étape 3: Test de SAM3..."
bash "$SCRIPT_DIR/test_sam3.sh" || {
    echo "⚠️  Attention: Le test de SAM3 a échoué"
    echo "   Vérifiez l'installation: pip list | grep sam3"
    read -p "   Continuer? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
}
echo ""

# 4️⃣ Setup HF
echo "🔐 Étape 4: Configuration HuggingFace..."
echo "   Vous devez avoir un token HuggingFace pour utiliser SAM3"
echo "   Continuez? (o/n)"
read -p "   > " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    bash "$SCRIPT_DIR/setup_hf.sh"
else
    echo "⏭️  Configuration HuggingFace ignorée"
    echo "   Vous pourrez la faire plus tard avec: segma-hf"
fi
echo ""

# 5️⃣ Setup des helpers
echo "🎯 Étape 5: Configuration des commandes helper..."
bash "$SCRIPT_DIR/setup_helpers.sh"
echo ""

# 6️⃣ Vérification finale
echo "✅ Étape 6: Vérification finale..."
echo ""
echo "   Vérification du projet:"
if [ -f "$PROJECT/pubspec.yaml" ]; then
    echo "   ✓ Flutter project trouvé"
else
    echo "   ⚠️  pubspec.yaml manquant"
fi

if [ -f "$PROJECT/backend/requirements.txt" ]; then
    echo "   ✓ Backend trouvé"
else
    echo "   ❌ Backend manquant"
fi

if [ -d "$PROJECT/scripts" ]; then
    echo "   ✓ Dossier scripts trouvé"
else
    echo "   ❌ Dossier scripts manquant"
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "🎉 INITIALISATION RÉUSSIE!"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📝 Commandes utiles:"
echo ""
echo "   Backend:"
echo "     • segma-backend     - Démarrer le serveur FastAPI"
echo "     • segma-health      - Vérifier l'API"
echo "     • segma-test        - Tester SAM3"
echo ""
echo "   Frontend:"
echo "     • segma-flutter     - Lancer l'app Flutter"
echo ""
echo "   Configuration:"
echo "     • segma-hf          - Configurer HuggingFace"
echo "     • segma-check       - Vérifier la configuration"
echo "     • segma-help        - Afficher l'aide"
echo ""
echo "💡 Pour créer un alias global de ce script:"
echo "   alias segma-init='bash $SCRIPT_DIR/init_project.sh'"
echo ""
