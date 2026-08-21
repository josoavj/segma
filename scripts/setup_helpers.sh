#!/bin/bash
# Alias et helpers pour SEGMA (Version Portable)

# Charger l'environnement global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/env_setup.sh"

echo "[ADD] Ajout des fonctions helper pour SEGMA"
echo ""

# Créer un fichier de configuration pour les alias
# On injecte les variables dynamiquement au moment de la génération
cat > ~/.segma_helpers << EOF
#!/bin/bash
# SEGMA Helpers (Généré automatiquement)

export SEGMA_PROJECT_ROOT="$PROJECT_ROOT"
export SEGMA_VENV="$VENV_PATH"
export SEGMA_PYTHON="$PYTHON_BIN"

# Démarrer le backend SAM3
function segma-backend() {
    cd "\$SEGMA_PROJECT_ROOT/backend"
    echo "[BACKEND] Démarrage backend SAM3..."
    "\$SEGMA_PYTHON" -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
}

# Tester l'installation SAM3
function segma-test() {
    echo "[TEST] Test SAM3..."
    bash "\$SEGMA_PROJECT_ROOT/scripts/test_sam3.sh"
}

# Vérifier le health check
function segma-health() {
    echo "[HEALTH] Health Check..."
    curl -s http://localhost:8000/api/v3/health | "\$SEGMA_PYTHON" -m json.tool
}

# Lancer Flutter
function segma-flutter() {
    cd "\$SEGMA_PROJECT_ROOT"
    echo "[FLUTTER] Démarrage Flutter..."
    flutter run -d linux
}

# Configuration HuggingFace
function segma-hf() {
    echo "[AUTH] Configuration HuggingFace..."
    bash "\$SEGMA_PROJECT_ROOT/scripts/setup_hf.sh"
}

# Vérifier la setup
function segma-check() {
    echo ""
    echo "[INFO] Vérification SEGMA Setup"
    echo "================================"
    echo "Root: \$SEGMA_PROJECT_ROOT"
    echo "Venv: \$SEGMA_VENV"
    echo ""

    echo -n "[CHECK] Python: "
    "\$SEGMA_PYTHON" --version
    
    echo -n "[CHECK] PyTorch: "
    "\$SEGMA_PYTHON" -c "import torch; print(torch.__version__)" 2>/dev/null || echo "[ERROR] Non installé"
    
    echo -n "[CHECK] CUDA: "
    "\$SEGMA_PYTHON" -c "import torch; print('Disponible [SUCCESS]' if torch.cuda.is_available() else 'CPU seulement')" 2>/dev/null
    
    echo ""
}

# Help
function segma-help() {
    echo ""
    echo "[HELP] Commandes SEGMA"
    echo "================================"
    echo ""
    echo "  segma-backend    - Démarrer le backend FastAPI"
    echo "  segma-test       - Tester l'installation SAM3"
    echo "  segma-health     - Vérifier l'API"
    echo "  segma-flutter    - Lancer l'appli Flutter"
    echo "  segma-hf         - Configurer HuggingFace"
    echo "  segma-check      - Vérifier la setup"
    echo "  segma-help       - Afficher cette aide"
    echo ""
}

# Alias courts
alias sb="segma-backend"
alias st="segma-test"
alias sh="segma-health"
alias sf="segma-flutter"
alias shf="segma-hf"
alias scheck="segma-check"
EOF

# Charger les helpers dans le shell courant
source ~/.segma_helpers

echo "[SUCCESS] Fonctions chargées dans ~/.segma_helpers"
echo ""
echo "Pour utiliser dans les futurs terminaux, assurez-vous d'avoir ceci dans ~/.bashrc:"
echo "  source ~/.segma_helpers"
echo ""
