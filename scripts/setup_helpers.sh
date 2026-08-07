#!/bin/bash
# Alias et helpers pour SEGMA

VENV="/home/shadowcraft/.pyenv"
PROJECT="/home/shadowcraft/Projets/segma"
BACKEND="$PROJECT/backend"

echo "[ADD] Ajout des fonctions helper pour SEGMA"
echo ""

# Créer un fichier bashrc avec les aliases
cat > ~/.segma_helpers << 'EOF'
#!/bin/bash
# SEGMA Helpers

VENV="/home/shadowcraft/.pyenv"
PROJECT="/home/shadowcraft/Projets/segma"
BACKEND="$PROJECT/backend"

# Démarrer le backend SAM3
function segma-backend() {
    cd $BACKEND
    echo "[BACKEND] Démarrage backend SAM3..."
    $VENV/bin/uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
}

# Tester l'installation SAM3
function segma-test() {
    cd $BACKEND
    echo "[TEST] Test SAM3..."
    $VENV/bin/python test_sam3.py
}

# Vérifier le health check
function segma-health() {
    echo "[HEALTH] Health Check..."
    curl -s http://localhost:8000/api/v1/health | python -m json.tool
}

# Lancer Flutter
function segma-flutter() {
    cd $PROJECT
    echo "[FLUTTER] Démarrage Flutter..."
    flutter run -d linux
}

# Configuration HuggingFace
function segma-hf() {
    echo "[AUTH] Configuration HuggingFace..."
    bash $PROJECT/scripts/setup_hf.sh
}

# Vérifier la setup
function segma-check() {
    echo ""
    echo "[INFO] Vérification SEGMA Setup"
    echo "================================"
    echo ""
    
    echo -n "[SUCCESS] Python: "
    $VENV/bin/python --version
    
    echo -n "[SUCCESS] SAM3: "
    $VENV/bin/python -c "import sam3; print(sam3.__version__)" 2>/dev/null || echo "[ERROR] Non installé"
    
    echo -n "[SUCCESS] PyTorch: "
    $VENV/bin/python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "[ERROR] Non installé"
    
    echo -n "[SUCCESS] CUDA: "
    $VENV/bin/python -c "import torch; print('Disponible [SUCCESS]' if torch.cuda.is_available() else 'CPU seulement')" 2>/dev/null
    
    echo ""
}

# Help
function segma-help() {
    echo ""
    echo "[HELP] Commandes SEGMA"
    echo "================================"
    echo ""
    echo "  segma-backend    [COMMAND] Démarrer le backend FastAPI"
    echo "  segma-test       [COMMAND] Tester l'installation SAM3"
    echo "  segma-health     [COMMAND] Vérifier l'API"
    echo "  segma-flutter    [COMMAND] Lancer l'appli Flutter"
    echo "  segma-hf         [COMMAND] Configurer HuggingFace"
    echo "  segma-check      [COMMAND] Vérifier la setup"
    echo "  segma-help       [COMMAND] Afficher cette aide"
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

echo ""
echo "[SUCCESS] Fonctions chargées!"
echo ""
echo "Commandes disponibles:"
echo ""
echo "  segma-backend   - Démarrer le backend"
echo "  segma-test      - Tester SAM3"
echo "  segma-health    - Health check"
echo "  segma-flutter   - Lancer Flutter"
echo "  segma-hf        - Config HF"
echo "  segma-check     - Vérifier setup"
echo "  segma-help      - Voir l'aide"
echo ""
echo "Pour utiliser dans les futurs terminaux, ajoutez à ~/.bashrc:"
echo "  source ~/.segma_helpers"
echo ""

# Optionnel: ajouter au bashrc
read -p "Ajouter à ~/.bashrc? (o/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    echo "" >> ~/.bashrc
    echo "# SEGMA Helpers" >> ~/.bashrc
    echo "source ~/.segma_helpers" >> ~/.bashrc
    echo "[SUCCESS] Ajouté à ~/.bashrc"
fi
