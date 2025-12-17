# 📚 INSTALLATION COMPLÈTE - SAM3

## Prérequis

- Python 3.12+ (vous avez 3.13.9 ✅)
- pip/pip3
- ~5-10 GB d'espace disque (pour SAM3 + modèles)
- Connexion Internet (pour télécharger les modèles)
- Token HuggingFace (gratuit)

---

## Étape 1: Environnement Python

### Option A: Utiliser votre venv existant (RECOMMANDÉ)

```bash
# Vérifier la version
/home/shadowcraft/.pyenv/bin/python --version
# Python 3.13.9 ✅

# Pas besoin de créer un nouvel environnement!
```

### Option B: Créer un nouvel environnement

```bash
python3.13 -m venv /home/shadowcraft/venv_segma
source /home/shadowcraft/venv_segma/bin/activate
```

---

## Étape 2: Installer les Dépendances

### Méthode rapide (automatisée)

```bash
bash /home/shadowcraft/Projets/segma/scripts/install_sam3.sh
```

### Méthode manuelle

```bash
# Activer le venv
source /home/shadowcraft/.pyenv/bin/activate

# Mettre à jour pip
pip install --upgrade pip setuptools wheel

# Installer SAM3 et dépendances
pip install sam3>=1.0
pip install huggingface-hub>=0.20.0
pip install pillow opencv-python numpy
pip install uvicorn==0.27.0
pip install fastapi==1.0.0
pip install pydantic>=2.7.0
pip install python-multipart==0.0.6

# Vérifier l'installation
pip list | grep -E "sam|fastapi|torch"
```

---

## Étape 3: Authentification HuggingFace

### Configuration Interactive

```bash
/home/shadowcraft/.pyenv/bin/huggingface-cli login
```

**Étapes:**
1. Créez un token: https://huggingface.co/settings/tokens (type: Read)
2. Collez le token
3. Acceptez les conditions

### Configuration via Variable d'Environnement

```bash
export HF_TOKEN="hf_your_token_here"
```

### Accepter les Conditions du Modèle

Allez sur: https://huggingface.co/facebook/sam3

Cliquez: "I have read the license and agree with the terms"

---

## Étape 4: Vérifier l'Installation

### Test complet

```bash
cd /home/shadowcraft/Projets/segma/backend
/home/shadowcraft/.pyenv/bin/python test_sam3.py
```

**Attendu**: Tous les tests en vert ✅

### Test rapide

```bash
/home/shadowcraft/.pyenv/bin/python -c "
from app.models.sam3_model import get_sam3_model
model = get_sam3_model()
print('✅ SAM3 OK!' if model.is_loaded else '❌ SAM3 pas chargé')
"
```

### Test des imports

```bash
/home/shadowcraft/.pyenv/bin/python << 'EOF'
import sam3
import fastapi
import torch
import numpy as np
from PIL import Image

print('✅ sam3:', sam3.__version__)
print('✅ fastapi:', fastapi.__version__)
print('✅ torch:', torch.__version__)
print('✅ Tous les imports OK!')
EOF
```

---

## Étape 5: Configurer les Commandes Helper

```bash
bash /home/shadowcraft/Projets/segma/docs/setup/setup_helpers.sh
```

Cela crée les commandes pratiques:
- `segma-backend` - Démarrer le backend
- `segma-test` - Tester SAM3
- `segma-health` - Health check
- `segma-flutter` - Lancer Flutter
- `segma-hf` - Config HF
- `segma-check` - Vérifier setup

---

## Étape 6: Première Utilisation

### Démarrer le Backend

```bash
source /home/shadowcraft/.pyenv/bin/activate
cd /home/shadowcraft/Projets/segma/backend
uvicorn app.main:app --reload
```

**Première utilisation**: 
- SAM3 télécharge le modèle (~2-3 GB) 
- Ça prend 5-10 minutes
- Les utilisations suivantes sont instantanées

### Tester l'API

```bash
curl http://localhost:8000/api/v1/health
```

### Lancer l'App Flutter

```bash
cd /home/shadowcraft/Projets/segma
flutter run -d linux
```

---

## Dépannage d'Installation

### Erreur: "No module named 'sam3'"

```bash
# Vérifier que vous utilisez le bon Python
which python
# Doit afficher: /home/shadowcraft/.pyenv/bin/python

# Réinstaller
/home/shadowcraft/.pyenv/bin/pip install sam3>=1.0
```

### Erreur: "ModuleNotFoundError: No module named 'app'"

```bash
# Assurez-vous d'être dans le bon répertoire
cd /home/shadowcraft/Projets/segma/backend

# Puis:
/home/shadowcraft/.pyenv/bin/uvicorn app.main:app --reload
```

### Erreur: "CUDA out of memory"

```bash
# Le backend gère auto et bascule en CPU
# Aucun changement requis
```

### Erreur: "Unauthorized" HuggingFace

```bash
/home/shadowcraft/.pyenv/bin/huggingface-cli logout
/home/shadowcraft/.pyenv/bin/huggingface-cli login
# Accepter les conditions sur https://huggingface.co/facebook/sam3
```

---

## ✅ Checklist d'Installation

- [ ] Python 3.13.9 vérifié
- [ ] SAM3 installé (`pip list | grep sam3`)
- [ ] PyTorch installé (`pip list | grep torch`)
- [ ] FastAPI installé (`pip list | grep fastapi`)
- [ ] HuggingFace authentifié (`huggingface-cli whoami`)
- [ ] Conditions SAM3 acceptées (https://huggingface.co/facebook/sam3)
- [ ] test_sam3.py passe
- [ ] Backend démarre sans erreur
- [ ] Health check répond
- [ ] Flutter compile

---

## 📊 Vérification Finale

```bash
#!/bin/bash
VENV="/home/shadowcraft/.pyenv/bin"

echo "🔍 Vérification Installation SAM3"
echo "==================================="

echo -n "Python: "
$VENV/python --version

echo -n "SAM3: "
$VENV/python -c "import sam3; print(sam3.__version__)"

echo -n "PyTorch: "
$VENV/python -c "import torch; print(torch.__version__)"

echo -n "FastAPI: "
$VENV/python -c "import fastapi; print(fastapi.__version__)"

echo -n "CUDA: "
$VENV/python -c "import torch; print('Disponible ✅' if torch.cuda.is_available() else 'CPU')"

echo ""
echo "✅ Installation complète!"
```

---

👉 Ensuite: Voir [QUICK_START.md](QUICK_START.md)
