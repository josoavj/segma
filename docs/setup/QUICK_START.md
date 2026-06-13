# 🚀 Démarrage Rapide

Ce guide vous aide à lancer SEGMA sur votre environnement local en quelques étapes simples.

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :
- **Python 3.10+** (avec `pip`)
- **Flutter SDK 3.6+**
- Un compte **HuggingFace** (pour télécharger le modèle SAM 3)

---

## 🛠️ Étapes de Lancement

### 1. Authentification HuggingFace
Le modèle SAM 3 est hébergé sur HuggingFace. Vous devez vous authentifier une seule fois :
```bash
pip install huggingface_hub
huggingface-cli login
```
*Note: Acceptez les conditions d'utilisation du modèle ici : [facebook/sam3](https://huggingface.co/facebook/sam3)*

### 2. Démarrer le Serveur (Backend)
Le backend gère l'intelligence artificielle.
```bash
cd backend
# Créer et activer l'environnement virtuel
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
# Installer les dépendances
pip install -r requirements.txt
# Lancer le serveur
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 3. Lancer l'Application (Frontend)
Dans un nouveau terminal :
```bash
# Installer les dépendances Flutter
flutter pub get
# Lancer l'application (Desktop recommandé)
flutter run -d linux # ou windows
```

---

## ✅ Vérification du Setup

Une fois le serveur lancé, vous pouvez vérifier son état via cette commande :
```bash
curl http://localhost:8000/api/v3/health
```
**Réponse attendue :**
```json
{
  "status": "healthy",
  "device": "cuda",
  "model_type": "facebook/sam3"
}
```

---

## 💡 Conseils de Productivité

1. **Premier lancement** : Le premier traitement d'image sera plus long car SAM 3 télécharge les poids du modèle (~2.4 Go). Soyez patient.
2. **GPU NVIDIA** : Pour une expérience fluide dans l'éditeur interactif, un GPU avec support CUDA est fortement recommandé.
3. **Prompts** : SAM 3 est plus performant avec des prompts en anglais (ex: "all objects", "car", "human face").

**Besoin d'aide ?** Consultez la [FAQ](../troubleshooting/FAQ.md).
