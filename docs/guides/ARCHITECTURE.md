# 🏗️ ARCHITECTURE SAM3

## Vue d'Ensemble

SAM3 (Segment Anything Model 3) est un modèle de segmentation universal de Meta qui peut segmenter des images basé sur:
- **Prompts texte** (nouveau!) - "all cars", "red objects"
- **Prompts visuels** (points/boxes)
- **Prompts vidéo** (tracking)

---

## Architecture Détaillée

### SAM1 (Ancien)
```
┌─────────────┐
│    Image    │
│  640x640    │
└──────┬──────┘
       │
┌──────▼──────────────────┐
│   Vision Encoder (ViT)  │
│  - ViT-B/L/H            │
│  - Patch embeddings     │
└──────┬──────────────────┘
       │
┌──────▼─────────────────┐
│   Prompt Encoder       │
│  - Points/Boxes only   │
│  - NO Text support!    │
└──────┬─────────────────┘
       │
┌──────▼──────────────────────┐
│   Mask Decoder              │
│  - Génère masques binaires  │
│  - Upsampling 4x            │
└──────┬──────────────────────┘
       │
┌──────▼──────────────┐
│   Output Masks      │
│  H x W x 1          │
└─────────────────────┘
```

**Capacités SAM1:**
- ✅ Segmentation par points
- ✅ Segmentation par boxes
- ❌ **Segmentation par texte - IMPOSSIBLE**
- ❌ Open vocabulary

---

### SAM3 (Nouveau)
```
┌──────────────────────────────────────────────┐
│                    Input                      │
│  Image (H,W,3) + Text Prompt (description)  │
└──────────┬───────────────────────────────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼──────┐  ┌──▼─────────────┐
│   Image  │  │  Text Prompt   │
│Encoder   │  │  Encoder       │
│(ViT-H)   │  │  (CLIP/DINO)   │
│          │  │                │
└───┬──────┘  └──┬─────────────┘
    │           │
    │ Image     │ Text
    │ embedding │ embedding
    │           │
    └─────┬─────┘
          │
    ┌─────▼──────────────────┐
    │   Feature Fusion       │
    │  - Combine modalities  │
    │  - Attention mechanism │
    └─────┬──────────────────┘
          │
    ┌─────▼──────────────────┐
    │   Detection + Masking  │
    │  - Find object regions │
    │  - Generate masks      │
    │  - Optional: Tracking  │
    └─────┬──────────────────┘
          │
┌─────────▼─────────────────────────┐
│     Output                         │
│  - Masks (N, H, W)                │
│  - Bounding boxes (N, 4)          │
│  - Confidence scores (N,)         │
│  - Concepts (N,) [NEW!]           │
└────────────────────────────────────┘
```

**Capacités SAM3:**
- ✅ Segmentation par points
- ✅ Segmentation par boxes
- ✅ **Segmentation par texte - RÉEL!** 
- ✅ Open vocabulary (270K+ concepts)
- ✅ Video tracking (optionnel)
- ✅ ~75-80% accuracy (vs 60% SAM1)

---

## Composants Clés

### 1. Vision Encoder

**Modèle**: Vision Transformer (ViT)

**Variantes disponibles:**
- **ViT-B**: 95 MB, rapide (100ms CPU)
- **ViT-L**: 308 MB, modéré (300ms CPU)
- **ViT-H**: 2.5 GB, haute qualité (1s+ CPU)

**Rôle**: 
- Encode l'image en patch embeddings
- Crée une représentation spatial dense
- Base pour tous les prompts

### 2. Text Encoder (NOUVEAU!)

**Modèle**: CLIP ou équivalent

**Rôle**:
- Encode le texte (ex: "all cars")
- Produit un embedding textuel
- Aligné avec l'image encoder (CLIP training)

**Exemple**:
```
"all red cars" → [0.1, 0.5, -0.3, ..., 0.8]  (embeddin dimensionnalité 512)
"all people" → [0.2, -0.1, 0.7, ..., 0.1]
```

### 3. Attention Mechanism

**Rôle**:
- Aligne text embedding avec image features
- Focus sur régions pertinentes
- Génère attention maps

```
Text embedding: "cars"
    │
    ├─→ Attention sur les bords des objets
    ├─→ Attention sur les textures métalliques
    └─→ Attention sur les formes typiques de voitures
```

### 4. Mask Decoder

**Architecture**:
- Deconvolution avec résiduals
- Upsampling 4x
- Refine edges avec attention

**Output**:
- Masque binaire (0-1)
- Bounding box
- Score de confiance

---

## Flux de Traitement

### Exemple: "all cars"

```
1. Image chargée (480x640x3)
   └─ Preprocessing: normalize, resize

2. Vision Encoder
   └─ Output: (64, 64, 256) - feature map

3. Text Encoder
   └─ Input: "all cars"
   └─ Output: (512,) - text embedding

4. Fusion
   └─ Cross-attention entre image et texte
   └─ Result: (64, 64, 256) - refined features

5. Mask Decoder
   └─ Input: refined features
   └─ Output: masks (N, 480, 640), scores (N,)

6. Post-processing
   └─ Filter low confidence
   └─ Compute bounding boxes
   └─ Normalize output
```

---

## Performance

### Temps de Traitement

| Model | GPU (NVIDIA) | CPU (Intel) | Modèle Size |
|-------|------------|----------|----------|
| ViT-B | 50-80ms | 300-500ms | 95 MB |
| ViT-L | 80-150ms | 800-1200ms | 308 MB |
| ViT-H | 150-300ms | 2000-5000ms | 2.5 GB |

### Qualité (Accuracy)

**SAM1**: ~60% overlap with human annotations
**SAM3**: ~75-80% overlap with human annotations

### VRAM Nécessaire

- **GPU**: 2-4 GB (selon ViT size)
- **CPU**: 6-8 GB (très lent)

---

## Modes de Segmentation

### 1. Text-based (Nouveau!)

```python
model.segment_by_text_prompt(image, "all cars")
# Output: list of masks matching "cars"
```

**Avantages:**
- Intuitive pour l'utilisateur
- Flexible (270K+ concepts)
- Pas besoin de cliquer

**Inconvénients:**
- Peut être imprécis pour descriptions complexes
- Sensible à la qualité du prompt

### 2. Point-based

```python
model.segment_by_point(image, x=100, y=200)
# Output: mask for object at (100, 200)
```

**Avantages:**
- Très précis
- Utilisateur interactif

**Inconvénients:**
- Requiert action utilisateur

### 3. Box-based

```python
model.segment_by_box(image, x1=50, y1=100, x2=300, y2=400)
# Output: mask inside box
```

**Avantages:**
- Rapide à utiliser
- Bonne précision

**Inconvénients:**
- Pas pour les objets petits/dispersés

---

## Open Vocabulary

**Concept Clé**: SAM3 peut reconnaître ~270K concepts différents sans être explicitly entraîné sur eux.

**Exemples qui fonctionnent:**
```
"red objects"
"cars in traffic"
"people wearing hats"
"trees on mountains"
"water reflections"
"metal objects"
```

**Limites:**
- Meilleures pour les termes génériques
- Pire pour les noms propres ("Barack Obama")
- Pire pour les cas rares/spécialisés

---

## Architecture dans SEGMA

```
┌─ Backend (FastAPI)
│
├─ segmentation_service.py
│  ├─ segment_by_prompt()
│  └─ _segment_with_sam3()
│
└─ sam3_model.py
   ├─ SAM3Model class
   ├─ segment_by_text_prompt()
   ├─ segment_by_point()
   ├─ segment_by_box()
   └─ get_sam3_model() [singleton]

┌─ Frontend (Flutter)
│
├─ segmentation_provider.dart
│  ├─ Watch SAM3 segmentation
│  └─ Cache results
│
└─ image_viewer_widget.dart
   ├─ Display image
   ├─ Show bounding boxes
   └─ Real-time search
```

---

## Comparatif SAM1 vs SAM3

| Feature | SAM1 | SAM3 | SEGMA Now |
|---------|------|------|-----------|
| Text Prompts | ❌ | ✅ | ✅ |
| Point Prompts | ✅ | ✅ | ✅ |
| Box Prompts | ✅ | ✅ | ✅ |
| Open Vocab | ❌ | ✅ | ✅ |
| Video | ❌ | ✅ | ⏳ |
| Accuracy | 60% | 75-80% | 75-80% |
| Package | `segment-anything` | `sam3` | `sam3` |

---

## Prochaines Étapes

Pour une meilleure compréhension:

👉 [MIGRATION_SAM3.md](MIGRATION_SAM3.md) - Ce qui a changé
👉 [PROMPTS_GUIDE.md](PROMPTS_GUIDE.md) - Comment écrire de bons prompts
👉 [API_ENDPOINTS.md](API_ENDPOINTS.md) - API documentation
