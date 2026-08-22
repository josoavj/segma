#!/bin/bash

# [INIT] Initialisation complète du projet SEGMA
# Ce script configure tout ce qui est nécessaire pour démarrer le projet

set -e

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo "════════════════════════════════════════════════════════════════════════════"
echo "[INIT] INITIALISATION COMPLÈTE DU PROJET SEGMA"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

echo "[DIR] Racine du projet: $PROJECT_ROOT"
if [ "$VENV_ACTIVE" = true ]; then
    echo "[PYTHON] Environnement détecté: $VENV_PATH"
else
    echo "[PYTHON] Utilisation du Python système"
fi
echo ""

# [STEP] Étape 1: Vérification de l'environnement
echo "[CHECK] Étape 1: Vérification de l'environnement..."
if [ "$VENV_ACTIVE" = false ]; then
    echo "[WARNING] Aucun virtualenv détecté."
    read -p "   Voulez-vous continuer sur le Python système? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "[INFO] Annulation. Créez un venv avec: python3 -m venv .venv"
        exit 1
    fi
fi
echo "[SUCCESS] Prêt à installer"
echo ""

# [STEP] Installer SAM3
echo "[STEP] Étape 2: Installation de SAM3..."
bash "$SCRIPT_DIR/install_sam3.sh"
echo ""

# [STEP] Tester SAM3
echo "[TEST] Étape 3: Test de SAM3..."
bash "$SCRIPT_DIR/test_sam3.sh" || {
    echo "[WARNING] Attention: Le test de SAM3 a échoué"
    read -p "   Continuer tout de même? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
}
echo ""

# [STEP] Setup HF
echo "[AUTH] Étape 4: Configuration HuggingFace..."
bash "$SCRIPT_DIR/setup_hf.sh"
echo ""

# [STEP] Setup des helpers
echo "[HELPERS] Étape 5: Configuration des commandes helper..."
bash "$SCRIPT_DIR/setup_helpers.sh"
echo ""

# [STEP] Vérification finale du projet
echo "[SUCCESS] Étape 6: Vérification finale..."
echo ""
echo "   Statut des composants:"
[ -f "$PROJECT_ROOT/pubspec.yaml" ] && echo "   [SUCCESS] Flutter Frontend" || echo "   [WARNING] Flutter Frontend non détecté"
[ -f "$BACKEND_DIR/main.py" ] && echo "   [SUCCESS] Python Backend" || echo "   [ERROR] Python Backend manquant"
[ -d "$PROJECT_ROOT/scripts" ] && echo "   [SUCCESS] Scripts de gestion" || echo "   [ERROR] Dossier scripts manquant"

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "[SUCCESS] INITIALISATION RÉUSSIE!"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "[INFO] Commandes disponibles après avoir chargé ~/.segma_helpers:"
echo ""
echo "   • segma-backend    - Lancer le serveur"
echo "   • segma-test       - Diagnostiquer SAM3"
echo "   • segma-flutter    - Lancer l'interface"
echo "   • segma-check      - Vérifier la configuration"
echo ""
echo "[TIP] Exécutez 'source ~/.segma_helpers' pour activer les commandes."
echo ""
