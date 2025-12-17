# Configuration du Modèle SAM

## 🎯 Nouveaux Endpoints

### 1. Obtenir les informations du modèle
```bash
GET /api/v1/model/info
```

**Réponse:**
```json
{
  "model_type": "vit_b",
  "device": "cpu",
  "is_loaded": true,
  "available_models": ["vit_b", "vit_l", "vit_h"],
  "cuda_available": false
}
```

---

### 2. Changer le modèle ou le device
```bash
POST /api/v1/model/change
Content-Type: application/json

{
  "model_type": "vit_l",
  "device": "cuda"
}
```

**Paramètres:**
- `model_type` (string, requis): Type de modèle
  - `vit_b`: Petit modèle (~96MB), rapide, pour CPU
  - `vit_l`: Modèle intermédiaire (~312MB), précis
  - `vit_h`: Grand modèle (~1.2GB), très précis
  
- `device` (string, optionnel): Processeur
  - `cpu`: Processeur central
  - `cuda`: GPU NVIDIA

**Réponse:**
```json
{
  "status": "success",
  "model_type": "vit_l",
  "device": "cuda",
  "is_loaded": true,
  "available_models": ["vit_b", "vit_l", "vit_h"],
  "cuda_available": true
}
```

---

## 📊 Temps de Chargement Estimé

| Modèle | RAM | Temps (CPU) | Temps (GPU) |
|--------|-----|------------|------------|
| **vit_b** | ~380MB | 2-3s | 1s |
| **vit_l** | ~1.2GB | 5-10s | 2-3s |
| **vit_h** | ~2.5GB | 15-30s | 5-10s |

---

## 🚀 Cas d'Usage

### Configuration Rapide (Temps réel)
```json
{
  "model_type": "vit_b",
  "device": "cpu"
}
```
✅ Idéal pour le prototypage et les tests
⚠️ Moins précis

### Configuration Balancée
```json
{
  "model_type": "vit_l",
  "device": "cpu"
}
```
✅ Bon équilibre vitesse/précision
⚠️ Requiert ~1.2GB RAM

### Configuration Précise
```json
{
  "model_type": "vit_h",
  "device": "cuda"
}
```
✅ Résultats très précis
⚠️ Requiert GPU et 2.5GB VRAM

---

## 🔄 Variables d'Environnement

Dans `.env`:
```bash
# Modèle par défaut au démarrage
SAM_MODEL_TYPE=vit_b

# Device par défaut
DEVICE=cpu
```

---

## 💡 Amélioration de la Segmentation

Le nouvel algorithme utilise:

1. **Grille multi-densité**: 
   - Grille 8x8 pour les objets standards
   - Grille 12x12 pour les petits objets

2. **Déduplication intelligente**:
   - Détecte les masques dupliqués par IoU
   - Seuil: 70% d'IoU

3. **Filtrage par taille**:
   - Minimum: 30 pixels (capte les petits objets)
   - Maximum: 95% de l'image (évite tout l'image)

4. **Détection YOLO améliorée**:
   - Labels en anglais automatiques
   - Matching IoU pour chaque objet

---

## 📝 Exemples Complets

### Changer vers vit_l sur CPU
```bash
curl -X POST http://localhost:8000/api/v1/model/change \
  -H "Content-Type: application/json" \
  -d '{
    "model_type": "vit_l",
    "device": "cpu"
  }'
```

### Changer vers vit_h sur GPU
```bash
curl -X POST http://localhost:8000/api/v1/model/change \
  -H "Content-Type: application/json" \
  -d '{
    "model_type": "vit_h",
    "device": "cuda"
  }'
```

### Vérifier la configuration actuelle
```bash
curl http://localhost:8000/api/v1/model/info
```

---

## ⚠️ Notes Importantes

1. **Changement de modèle**: Les requêtes pendant le changement attendront la fin du chargement
2. **CUDA**: Disponible uniquement si PyTorch CUDA est installé
3. **Mémoire**: Vérifiez que votre système a assez de RAM/VRAM
4. **Première utilisation**: Chaque modèle télécharge ses poids la première fois (~1-2 minutes)

