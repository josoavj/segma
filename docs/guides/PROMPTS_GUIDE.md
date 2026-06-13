# 📖 Guide Expert : L'Art des Prompts SAM 3

Un prompt texte est une description en langage naturel qui guide l'intelligence artificielle pour identifier et isoler des objets spécifiques dans une image.

## 🧠 Principes Fondamentaux

### 1. Langue : Anglais Uniquement
Le modèle SAM 3 a été entraîné principalement sur des jeux de données anglophones. Pour une précision maximale, utilisez toujours l'anglais.
-   ❌ "voiture rouge"
-   ✅ "red car"

### 2. Privilégiez les Termes Génériques
SAM 3 excelle dans la reconnaissance de catégories d'objets (concepts) plutôt que de noms propres ou de marques spécifiques.
-   ❌ "iPhone 15 Pro"
-   ✅ "smartphone" ou "mobile phone"

### 3. Simplicité et Clarté
Plus votre prompt est direct, moins l'IA risque de se tromper.
-   ❌ "le petit oiseau bleu qui vole au-dessus de l'arbre"
-   ✅ "blue bird"

---

## 🛠️ Stratégies de Segmentation

### Énumération
Utile pour segmenter plusieurs types d'objets simultanément.
-   **Prompt** : "cars and trees"
-   **Résultat** : Génère des masques distincts pour chaque voiture et chaque arbre détecté.

### Adjectifs Descriptifs
Affinez la sélection en ajoutant des caractéristiques visuelles.
-   **Couleur** : "yellow flower"
-   **Taille** : "large building"
-   **Matière** : "wooden table"

### Segmentation Globale
Si vous voulez que SAM 3 détecte tout ce qu'il voit sans distinction.
-   **Prompt** : "all objects" ou "anything"

---

## 💡 Conseils pour de Meilleurs Résultats

1.  **Ajustez le Seuil de Confiance** : Si vous avez trop de "faux positifs" (des objets segmentés par erreur), augmentez le seuil de confiance dans les paramètres de l'application (ex: passez de 0.25 à 0.50).
2.  **Affinement Interactif** : Si un prompt texte ne suffit pas, utilisez l'**Éditeur Interactif** de SEGMA. Cliquez sur l'objet pour l'inclure ou sur les zones erronées pour les exclure.
3.  **Singulier vs Pluriel** : Généralement, SAM 3 comprend les deux de la même manière ("cat" vs "cats"), mais le pluriel peut parfois aider à mieux capturer les groupes serrés.

---

## 📋 Tableau de Référence Rapide

| Objectif | Exemple de Prompt |
| :--- | :--- |
| **Tout isoler** | `all objects`, `everything` |
| **Personnes** | `person`, `people`, `human face` |
| **Véhicules** | `car`, `truck`, `bicycle`, `wheels` |
| **Mobilier** | `chair`, `table`, `lamp`, `furniture` |
| **Nature** | `sky`, `grass`, `water`, `mountains` |

---
*SEGMA - Guide des Prompts v1.0*
