# FAQ - SAM3 SEGMA

## Questions Générales

### Q: C'est quoi SAM3?

**R**: Segment Anything Model 3. Un modèle d'IA qui peut segmenter (découper) n'importe quel objet dans une image basé sur des descriptions texte, des points, ou des boîtes.

### Q: Pourquoi SAM3 et pas SAM1?

**R**: 

- SAM1: Peut faire points/boxes seulement
- SAM3: Points/boxes **+ segmentation par texte**
- SAM3 est plus puissant et c'est la version officielle actuelle

### Q: Ça coûte combien?

**R**: Gratuit! SAM3 est open-source par Meta. Il y a un petit coût CPU/GPU mais c'est gratuit du côté service.

### Q: Ça fonctionne hors-ligne?

**R**: Non. Besoin de:

- Internet pour télécharger le modèle (première fois)
- Token HuggingFace pour l'authentification

Une fois le modèle téléchargé (~2-3 GB), il peut fonctionner local.

---

## Installation & Configuration

### Q: J'ai quelle version de Python?

**R**: Vérifiez:
```bash
/home/shadowcraft/.pyenv/bin/python --version
```

### Q: SAM3 est installé?

**R**: Vérifiez:
```bash
/home/shadowcraft/.pyenv/bin/python -c "import sam3; print(sam3.__version__)"
```

### Q: Comment créer un token HuggingFace?

**R**:

1. Allez sur https://huggingface.co/settings/tokens
2. Cliquez "New token"
3. Donnez un nom (ex: "segma")
4. Type: "Read"
5. Copier le token

### Q: Où mettre le token HuggingFace?

**R**: Authentifier avec:
```bash
/home/shadowcraft/.pyenv/bin/huggingface-cli login
# Collez le token
```

Ou variable d'env:
```bash
export HF_TOKEN="hf_your_token_here"
```

### Q: Je dois accepter les conditions où?

**R**: https://huggingface.co/facebook/sam3

Bouton: "I have read the license and agree with the terms"

---

## Utilisation & Fonctionnement

### Q: Pourquoi SAM3 télécharge 2-3 GB?

**R**: C'est le **poids du modèle** neural. SAM3 est un grand modèle d'IA.

### Q: Ça met combien de temps?

**R**: 

- Téléchargement: 5-10 minutes (dépend internet)
- Première utilisation: 30-60 secondes (load modèle)
- Utilisation suivante: 100ms-1s (CPU) ou 50-100ms (GPU)

### Q: J'ai besoin d'un GPU?

**R**: Non obligatoire mais:

- Sans GPU: 2-5 secondes par image (CPU)
- Avec GPU: 100-300ms par image
- **Recommandé**: GPU pour une meilleure expérience

### Q: CUDA c'est quoi?

**R**: CUDA = interface NVIDIA pour utiliser les GPUs NVIDIA. Pas besoin si vous avez pas de GPU.

---

## Prompts Texte

### Q: Quels prompts fonctionnent?

**R**: Termes génériques en **anglais**:

- "cars"
- "people"
- "trees"
- "Toyota Camry" (Non recommandé)
- "la voiture" (français) (Non recommandé)

### Q: Le français marche?

**R**: Non. SAM3 est entraîné en anglais seulement.

### Q: Aucun objet détecté, pourquoi?

**R**: Vérifiez:

1. Prompt en anglais?
2. Objet vraiment dans l'image?
3. Essayez un prompt plus générique ("objects")
4. Réduisez confidence_threshold

### Q: Trop d'objets détectés?

**R**:

1. Prompt plus spécifique ("cars" au lieu de "objects")
2. Augmentez confidence_threshold
3. Testez différentes formulations

### Q: "Car" vs "cars" - différence?

**R**: Généralement aucune. Utilisez la forme naturelle.

---

## API & Backend

### Q: Backend démarre où?

**R**: Par défaut: http://localhost:8000

### Q: Comment tester l'API?

**R**:
```bash
# Health check
curl http://localhost:8000/api/v1/health

# Voir la documentation
http://localhost:8000/docs
```

### Q: Port 8000 déjà utilisé?

**R**:
```bash
# Utiliser autre port
/home/shadowcraft/.pyenv/bin/uvicorn app.main:app --port 8001
```

### Q: Comment je change le device (CPU/CUDA)?

**R**: Via l'API:
```bash
curl -X POST http://localhost:8000/api/v1/model/change \
  -H "Content-Type: application/json" \
  -d '{"model_type": "vit_b", "device": "cuda"}'
```

---

## Flutter & Frontend

### Q: Flutter ne trouve pas le backend?

**R**: 

1. Backend en cours d'exécution?
2. Port correct dans code Flutter?
3. Firewall bloque le port 8000?

### Q: Comment configurer l'URL du backend?

**R**: Dans `lib/config/backend_config.dart`:
```dart
const String backendUrl = "http://localhost:8000";
```

### Q: Les bounding boxes ne s'affichent pas?

**R**: Vérifiez que SAM3 détecte des objets (via curl).

---

## Dépannage

### Q: "SAM3 non disponible"?

**R**: SAM3 pas installé:
```bash
/home/shadowcraft/.pyenv/bin/pip install sam3>=1.0
```

### Q: "Unauthorized"?

**R**: Problème HuggingFace:
```bash
/home/shadowcraft/.pyenv/bin/huggingface-cli login
# Accepter conditions: https://huggingface.co/facebook/sam3
```

### Q: "CUDA out of memory"?

**R**: Votre GPU n'a pas assez de VRAM:

1. Utiliser CPU (plus lent)
2. Réduire taille image
3. Utiliser ViT-B au lieu de ViT-H

### Q: ModuleNotFoundError?

**R**: Mauvais chemin ou venv:
```bash
# Vérifier Python
/home/shadowcraft/.pyenv/bin/python --version

# Vérifier imports
/home/shadowcraft/.pyenv/bin/python -c "import sam3"
```

### Q: Backend crashe sans raison?

**R**: Regardez les logs:
```bash
LOGLEVEL=DEBUG /home/shadowcraft/.pyenv/bin/uvicorn app.main:app --reload --log-level debug
```

---

## Performance

### Q: Pourquoi c'est lent?

**R**: Causes possibles:

- CPU seulement (au lieu de GPU)
- Grosse image
- Gros modèle (ViT-H)
- Première utilisation (load du modèle)

### Q: Combien de temps une segmentation?

**R**:

- GPU ViT-B: 100-150ms
- GPU ViT-H: 200-500ms
- CPU ViT-B: 1-2s
- CPU ViT-H: 5-10s

### Q: Comment accélérer?

**R**:

1. Utiliser GPU
2. Réduire taille image
3. Utiliser ViT-B au lieu de ViT-H

---

## Erreurs Courantes

### Q: "No module named 'app'"?

**R**: Mauvais répertoire:
```bash
# BON:
cd /home/shadowcraft/Projets/segma/backend
/home/shadowcraft/.pyenv/bin/uvicorn app.main:app --reload

# MAUVAIS:
cd /home/shadowcraft/Projets/segma
/home/shadowcraft/.pyenv/bin/uvicorn backend.app.main:app
```

### Q: "PermissionError: Cannot open file"?

**R**: Permissions d'accès:
```bash
chmod -R 755 /home/shadowcraft/Projets/segma
```

### Q: Les masques ne se sauvegardent pas?

**R**:

1. Espace disque insuffisant?
2. Permissions d'écriture?
3. Répertoire .segmentation existe?

```bash
# Vérifier
df -h
ls -la /tmp/test/.segmentation_*/
```

---

## Modèles

### Q: Différence ViT-B, L, H?

**R**:

| Model | Size | Speed | Quality | GPU |
|-------|------|-------|---------|-----|
| B | 95 MB | Rapide | 75% | 2GB |
| L | 308 MB | Normal | 78% | 3GB |
| H | 2.5GB | Lent | 80% | 4GB |

### Q: Quel modèle choisir?

**R**: 

- Commencez par ViT-B
- Si trop lent→ GPU
- Si pas assez précis→ ViT-H

### Q: Comment changer de modèle?

**R**:
```python
# Via API
POST /api/v1/model/change
{"model_type": "vit_h", "device": "cuda"}
```

---

## Résolution des Problèmes

### Q: J'ai une erreur, comment je la rapporte?

**R**: 

1. Notez l'erreur **exacte**
2. Consultez [TROUBLESHOOTING_SAM3.md](../troubleshooting/TROUBLESHOOTING_SAM3.md)
3. Essayez les solutions suggérées
4. Regardez les logs avec `LOGLEVEL=DEBUG`

### Q: Comment je regarde les logs?

**R**:
```bash
# Lancer avec logs verbose
LOGLEVEL=DEBUG /home/shadowcraft/.pyenv/bin/uvicorn app.main:app --log-level debug 2>&1 | tee /tmp/segma.log

# Voir logs après
tail -100 /tmp/segma.log
```

---

**Besoin d'aide? Consultez les guides complets dans docs/**
