#!/bin/bash

# [INIT] Initialisation complète du projet SEGMA
# Ce script configure tout ce qui est nécessaire pour démarrer le projet

set -e

echo "════════════════════════════════════════════════════════════════════════════"
echo "[INIT] INITIALISATION COMPLÈTE DU PROJET SEGMA"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="${VENV_PATH:-./.venv}"
if [ ! -d "$VENV_PATH" ]; then
    VENV_PATH="/home/shadowcraft/.pyenv"
fi

echo "[DIR] Projet: $PROJECT"
echo "[PYTHON] Venv: $VENV_PATH"
echo ""

# [STEP] Vérifier le venv
echo "[CHECK] Étape 1: Vérification du virtualenv..."
if [ ! -d "$VENV_PATH" ]; then
    echo "[ERROR] Erreur: Virtualenv non trouvé à $VENV_PATH"
    echo "   Créez un venv: python3 -m venv $VENV_PATH"
    exit 1
fi
echo "[SUCCESS] Virtualenv trouvé"
echo ""

# [STEP] Installer SAM3
echo "[STEP] Étape 2: Installation de SAM3..."
bash "$SCRIPT_DIR/install_sam3.sh"
echo ""

# [STEP] Tester SAM3
echo "[TEST] Étape 3: Test de SAM3..."
bash "$SCRIPT_DIR/test_sam3.sh" || {
    echo "[WARNING] Attention: Le test de SAM3 a échoué"
    echo "   Vérifiez l'installation: pip list | grep sam3"
    read -p "   Continuer? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
}
echo ""

# [STEP] Setup HF
echo "[AUTH] Étape 4: Configuration HuggingFace..."
echo "   Vous devez avoir un token HuggingFace pour utiliser SAM3"
echo "   Continuez? (o/n)"
read -p "   > " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    bash "$SCRIPT_DIR/setup_hf.sh"
else
    echo "[SKIP] Configuration HuggingFace ignorée"
    echo "   Vous pourrez la faire plus tard avec: segma-hf"
fi
echo ""

# [STEP] Setup des helpers
echo "[HELPERS] Étape 5: Configuration des commandes helper..."
bash "$SCRIPT_DIR/setup_helpers.sh"
echo ""

# [STEP] Vérification finale
echo "[SUCCESS] Étape 6: Vérification finale..."
echo ""
echo "   Vérification du projet:"
if [ -f "$PROJECT/pubspec.yaml" ]; then
    echo "   [SUCCESS] Flutter project trouvé"
else
    echo "   [WARNING] pubspec.yaml manquant"
fi

if [ -f "$PROJECT/backend/requirements.txt" ]; then
    echo "   [SUCCESS] Backend trouvé"
else
    echo "   [ERROR] Backend manquant"
fi

if [ -d "$PROJECT/scripts" ]; then
    echo "   [SUCCESS] Dossier scripts trouvé"
else
    echo "   [ERROR] Dossier scripts manquant"
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "[SUCCESS] INITIALISATION RÉUSSIE!"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "[INFO] Commandes utiles:"
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
echo "[TIP] Pour créer un alias global de ce script:"
echo "   alias segma-init='bash $SCRIPT_DIR/init_project.sh'"
echo ""
