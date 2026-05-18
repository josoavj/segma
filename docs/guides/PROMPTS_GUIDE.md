# 📖 GUIDE DES PROMPTS - SAM3

## Fonctionnement des Prompts Texte

Un prompt texte est une description naturelle des objets que vous voulez segmenter.

```
Text Prompt: "all red cars"
            ↓
        Text Encoder
            ↓
    Embedded as concept
            ↓
    SAM3 cherche dans l'image
    tous les objets correspondant
    à ce concept
            ↓
        Output: Masks
```

---

## Principes de Base

### 1. Langue: Anglais SEULEMENT

SAM3 a été entraîné en **anglais**.

❌ **Mauvais (français):**

```
"la voiture"
"tous les objets rouges"
"le chat"
```

✅ **Bon (anglais):**

```
"the car"
"all red objects"
"the cat"
```

### 2. Termes Génériques

SAM3 fonctionne mieux avec des **termes génériques** plutôt que spécifiques.

❌ **Trop spécifique:**

```
"Toyota Camry 2024"
"John Smith"
"Rolex watch"
```

✅ **Générique:**

```
"cars"
"people"
"watches"
```

### 3. Clarté et Simplicité

Préférez les **prompts simples et clairs**.

❌ **Complexe/Ambigu:**

```
"le truc bleu là-bas qui ressemble un peu à un oiseau"
"choses brillantes"
"machin"
```

✅ **Simple/Clair:**

```
"blue object"
"shiny objects"
"object"
```

---

## Stratégies Efficaces

### Stratégie 1: Énumération

**Meilleur pour**: Plusieurs catégories différentes

```
Prompt: "cars and people"
Result: Segmente les voitures ET les gens

Prompt: "vehicles, trees, and buildings"
Result: Trois catégories distinctes
```

### Stratégie 2: Adjectifs Descriptifs

**Meilleur pour**: Caractéristiques visuelles

```
Prompt: "red objects"
Result: Tous les objets rouges

Prompt: "large cars"
Result: Voitures grandes uniquement

Prompt: "metal objects"
Result: Objets métalliques
```

### Stratégie 3: Relation Spatiale

**Meilleur pour**: Contexte spatial

```
Prompt: "people on bikes"
Result: Personnes sur des vélos

Prompt: "trees on mountains"
Result: Arbres sur des montagnes

Prompt: "objects on table"
Result: Objets sur une table
```

### Stratégie 4: Généralisation

**Meilleur pour**: Tout segmenter

```
Prompt: "all objects"
Result: TOUS les objets possibles

Prompt: "things"
Result: Équivalent vague

Prompt: "anything"
Result: Très large
```

---

## Exemples Réels par Catégorie

### Personnes

✅ Bon:
- "person"
- "people"
- "person wearing red"
- "people running"
- "people sitting"

❌ Mauvais:
- "the man in the photo"
- "Barack Obama"
- "people named John"

### Véhicules

✅ Bon:
- "car"
- "cars"
- "bike"
- "truck"
- "vehicles"
- "red cars"
- "cars on road"

❌ Mauvais:
- "Tesla Model S"
- "my car"
- "expensive vehicles"

### Animaux

✅ Bon:
- "dog"
- "cat"
- "bird"
- "animals"
- "dogs playing"
- "animals in nature"

❌ Mauvais:
- "German Shepherd"
- "my pet"
- "rare species"

### Objets Généraux

✅ Bon:
- "furniture"
- "table"
- "chair"
- "objects"
- "wooden objects"
- "round objects"

❌ Mauvais:
- "IKEA furniture"
- "brand X products"

### Scènes/Contexte

✅ Bon:
- "sky"
- "water"
- "grass"
- "tree"
- "building"
- "road"
- "outdoor scene"

❌ Mauvais:
- "beautiful sunset"
- "modern architecture"

---

## Tips pour Meilleurs Résultats

### Tip 1: Tester Différentes Variantes

```
Image avec des voitures:

1. "cars" ✅
2. "all cars" ✅
3. "vehicles" ✅
4. "red cars" (si vous les voulez rouge)

Voir laquelle fonctionne le mieux!
```

### Tip 2: Combiner Avec Confidence Threshold

```python
# Si "cars" détecte trop d'objets:
confidence_threshold = 0.5  # Plus strict

# Si "cars" détecte trop peu:
confidence_threshold = 0.0  # Plus loose
```

### Tip 3: Progressive Refinement

```
1ère tentative: "objects"
   └─ Détecte tout (baseline)

2e tentative: "cars"
   └─ Plus spécifique

3e tentative: "red cars"
   └─ Très spécifique
```

### Tip 4: Plural vs Singular

```
"car" vs "cars" - généralement pareil
"person" vs "people" - pareil
"dog" vs "dogs" - pareil

Utilisez la forme qui vous semble naturelle.
```

### Tip 5: Short vs Long Prompts

```
Court: "cars"        # Souvent mieux!
Long:  "all red cars on the road"  # Peut être plus précis

Tester les deux!
```

---

## Anti-Patterns (À Éviter)

### ❌ Anti-Pattern 1: Français

```
"les voitures"  MAUVAIS
"cars"          BON
```

### ❌ Anti-Pattern 2: Noms Propres

```
"Obama"              MAUVAIS
"person"             BON

"Toyota Camry"       MAUVAIS
"car"                BON
```

### ❌ Anti-Pattern 3: Concepts Abstraits

```
"beautiful"          MAUVAIS
"red"                BON

"expensive"          MAUVAIS
"large"              BON
```

### ❌ Anti-Pattern 4: Descriptions Poétiques

```
"the majestic flying creatures"  MAUVAIS
"bird"                           BON

"those shiny things"             MAUVAIS
"metal objects"                  BON
```

### ❌ Anti-Pattern 5: Typos/Orthographe

```
"carr"      MAUVAIS → ne sera pas reconnu
"car"       BON

"peple"     MAUVAIS
"people"    BON
```

---

## Tableau de Référence Rapide

| Cas d'Usage | Bon Prompt | Notes |
|-------------|-----------|-------|
| Tous les objets | "objects", "things", "anything" | Très large |
| Objets d'une couleur | "red objects", "blue things" | Fonctionne bien |
| Personnels | "person", "people", "person sitting" | Utiliser forme générique |
| Véhicules | "car", "cars", "vehicle", "bike" | Plural/singular pareil |
| Animaux | "dog", "cat", "bird", "animal" | Termes génériques |
| Scènes | "tree", "sky", "water", "building" | Noms simples |
| Groupes | "cars and people" | Énumérez avec "and" |
| Textures | "wooden", "metal", "plastic" | Adjectifs matériaux |
| Tailles | "large", "small", "tiny" | Combinez avec objet |

---

## Exemples Pratiques

### Exemple 1: Photo de Rue

```python
# Prompt 1: Tous les objets
"objects"
# → Détecte voitures, gens, arbres, bâtiments, tout

# Prompt 2: Seulement les voitures
"cars"
# → Détecte uniquement les voitures

# Prompt 3: Voitures rouges
"red cars"
# → Détecte les voitures rouges uniquement
```

### Exemple 2: Photo de Groupe

```python
# Prompt 1: Tous les gens
"people"
# → Chaque personne est un masque

# Prompt 2: Gens debout
"people standing"
# → Seulement ceux debout

# Prompt 3: Femmes
"women"
# → ⚠️ ATTENTION: Peut être imprécis
#    Mieux utiliser "people" si on ne sait pas
```

### Exemple 3: Photo de Scène Naturelle

```python
# Prompt 1: Éléments naturels
"trees, water, sky"
# → Trois catégories

# Prompt 2: Végétation
"trees and plants"
# → Toute la végétation

# Prompt 3: Tout
"objects"
# → Absolument tout
```

---

## Debugging

### Aucun objet détecté

```
1. Vérifier que le prompt est en anglais ✅
2. Essayer un prompt plus générique
   "cars" ne marche pas? → essayer "objects"
3. Réduire confidence_threshold
   "confidence_threshold": 0.5 → 0.0
4. L'objet existe vraiment dans l'image?
```

### Trop d'objets détectés

```
1. Augmenter confidence_threshold
   0.0 → 0.5
2. Utiliser un prompt plus spécifique
   "objects" → "red objects"
3. Combiner avec point/box prompts
```

### Mauvaise segmentation

```
1. Vérifier que le prompt est pertinent
   "cars" ne marche pas? → essayer "vehicles"
2. Essayer différentes variantes
   Plural/singular, long/court
3. Limiter la région avec box prompt
   (si possible dans l'interface)
```

---

## Stratégies Avancées

### Cascade de Prompts

```python
# 1. Segmenter tout d'abord
results_all = segment("objects")

# 2. Puis affiner
if want_only_cars:
    results = segment("cars")
    # Ou filtrer manuellement par labels
```

### Utiliser la Confiance

```python
# Prompts génériques = scores souvent bas
results = segment("objects", threshold=0.1)

# Prompts spécifiques = scores hauts
results = segment("cars", threshold=0.5)
```

### Combinaisons Multi-Prompts

```python
results_cars = segment("cars")
results_people = segment("people")
results_all = merge(results_cars, results_people)
```

---

## Ressources

- OpenAI CLIP: https://github.com/openai/CLIP
- SAM3 Official: https://github.com/facebookresearch/sam3
- Vocabulary research: https://arxiv.org/abs/2401.xxxxx

---

**✨ L'art des prompts: simple mais puissant! ✨**

Prochains guides:
👉 [API_ENDPOINTS.md](API_ENDPOINTS.md) - Intégrer les prompts dans votre code
