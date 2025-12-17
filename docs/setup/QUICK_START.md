# 🚀 DÉMARRAGE RAPIDE - SEGMA SAM3 (Votre Setup)

## ✅ Votre Configuration

```
venv:     /home/shadowcraft/.pyenv
Python:   3.13.9
PyTorch:  2.9.1 (cu128 - CUDA disponible!)
SAM3:     0.1.2 ✅ INSTALLÉ
FastAPI:  0.124.4 ✅
```

**Status**: ✨ Prêt pour démarrer!

---

## 📋 Prochaines Étapes

### 1. Authentifier HuggingFace (une seule fois)

```bash
bash /home/shadowcraft/Projets/segma/scripts/setup_hf.sh
```

ou directement:

```bash
/home/shadowcraft/.pyenv/bin/huggingface-cli login
# Puis accepter les conditions: https://huggingface.co/facebook/sam3
```

### 2. Démarrer le Backend

```bash
cd /home/shadowcraft/Projets/segma/backend

# Utiliser votre venv
/home/shadowcraft/.pyenv/bin/uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Attendu dans 30-60s**:
```
INFO:     Started server process [XXXXX]
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 3. Vérifier le Backend

```bash
curl http://localhost:8000/api/v1/health | python -m json.tool
```

**Réponse attendue**:
```json
{
  "status": "healthy",
  "device": "cuda",
  "model_type": "SAM3",
  "api_version": "1.0.0"
}
```

### 4. Tester la Segmentation

```bash
cd /home/shadowcraft/Projets/segma/backend

# Tester SAM3 directement
/home/shadowcraft/.pyenv/bin/python test_sam3.py
```

**Attendu**: Tests verts ✅

### 5. Lancer Flutter

```bash
cd /home/shadowcraft/Projets/segma

flutter run -d linux
```

---

## 📝 Commands Utiles

### Activer le venv dans le terminal
```bash
source /home/shadowcraft/.pyenv/bin/activate
# Ou utiliser directement: /home/shadowcraft/.pyenv/bin/python
```

### Démarrer le backend en background
```bash
cd /home/shadowcraft/Projets/segma/backend
/home/shadowcraft/.pyenv/bin/uvicorn app.main:app --reload &
```

### Voir les logs du backend
```bash
# Terminal 1: Démarrer backend avec logs détaillés
LOGLEVEL=DEBUG /home/shadowcraft/.pyenv/bin/uvicorn app.main:app --reload --log-level debug

# Terminal 2: Faire une requête test
curl -X POST http://localhost:8000/api/v1/segment \
  -H "Content-Type: application/json" \
  -d '{"image_path": "/tmp/test.jpg", "prompt": "all objects", "confidence_threshold": 0.0}'
```

---

## 🐛 Dépannage Rapide

### "SAM3 non disponible"
```bash
/home/shadowcraft/.pyenv/bin/pip install sam3>=1.0
```

### "Unauthorized" lors du téléchargement
```bash
/home/shadowcraft/.pyenv/bin/huggingface-cli whoami
# Si erreur: relancer huggingface-cli login
# Et accepter les conditions: https://huggingface.co/facebook/sam3
```

### CUDA non disponible
```bash
# Le backend détecte auto et utilise CPU (plus lent)
# Pas de changement requis - fonctionne quand même
```

### Port 8000 déjà utilisé
```bash
# Utiliser un autre port
/home/shadowcraft/.pyenv/bin/uvicorn app.main:app --reload --port 8001
# Puis mettre à jour Flutter: http://localhost:8001
```

---

## 📊 Vérification Complète

```bash
#!/bin/bash
VENV="/home/shadowcraft/.pyenv/bin"

echo "🔍 Vérification SAM3 Setup..."
echo ""

# Python
echo -n "Python: "
$VENV/python --version

# Imports
echo -n "SAM3: "
$VENV/python -c "import sam3; print(sam3.__version__)"

echo -n "PyTorch: "
$VENV/python -c "import torch; print(torch.__version__)"

echo -n "FastAPI: "
$VENV/python -c "import fastapi; print(fastapi.__version__)"

# CUDA
echo -n "CUDA: "
$VENV/python -c "import torch; print('✅' if torch.cuda.is_available() else '⚠️  (CPU only)')"

echo ""
echo "✨ Tout est prêt!"
```

Sauvegardez ce script dans `check_setup.sh` et exécutez:
```bash
bash check_setup.sh
```

---

## 🎯 Checklist Avant de Démarrer

- [ ] HuggingFace authentifié (`huggingface-cli whoami`)
- [ ] Conditions SAM3 acceptées (https://huggingface.co/facebook/sam3)
- [ ] Backend démarré sans erreur
- [ ] Health check retourne SAM3 (pas SAM1)
- [ ] test_sam3.py passe tous les tests
- [ ] Flutter compile et démarre

---

## 💡 Pro Tips

1. **Première utilisation slow**: La première fois que vous lancez SAM3, il télécharge le modèle (~2-3 GB). C'est normal et ça prend 5-10 minutes. Les utilisation suivantes sont rapides.

2. **GPU Recommandé**: Votre GPU devrait être utilisé automatiquement (torch détecte CUDA). Vérifiez avec `nvidia-smi`.

3. **Prompts en Anglais**: SAM3 fonctionne mieux en anglais (entraîné sur données anglaises).
   - ✅ "all cars"
   - ✅ "red objects"
   - ❌ "les voitures"

4. **Port Firewall**: Si Flask/Uvicorn ne répond pas, vérifiez le firewall:
   ```bash
   sudo ufw allow 8000/tcp
   ```

---

**🚀 Vous êtes prêt! Lancez `bash setup_hf.sh` pour configurer HuggingFace.**
