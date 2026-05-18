# 📚 SEGMA SAM3 - Documentation

> **Application complète de segmentation d'images avec SAM3**

---

## 🎯 Commencer

### ⏱️ 5 minutes

[QUICK_START.md](docs/setup/QUICK_START.md)

### ⏱️ 30 minutes

[INSTALLATION.md](docs/setup/INSTALLATION.md)

### ⏱️ 1 heure

[ARCHITECTURE.md](docs/guides/ARCHITECTURE.md) + [PROMPTS_GUIDE.md](docs/guides/PROMPTS_GUIDE.md)

---

## 📋 Index

### 🚀 Installation (`docs/setup/`)

| Fichier | Durée | Description |
|---------|-------|-------------|
| [QUICK_START.md](docs/setup/QUICK_START.md) | 5 min | ⭐ Démarrage rapide |
| [INSTALLATION.md](docs/setup/INSTALLATION.md) | 30 min | Guide complet |

### 🎓 Guides (`docs/guides/`)

| Fichier | Durée | Description |
|---------|-------|-------------|
| [ARCHITECTURE.md](docs/guides/ARCHITECTURE.md) | 30 min | Comment fonctionne SAM3 |
| [PROMPTS_GUIDE.md](docs/guides/PROMPTS_GUIDE.md) | 30 min | Écrire de bons prompts |

### 🆘 Aide (`docs/troubleshooting/`)

| Fichier | Description |
|---------|-------------|
| [FAQ.md](docs/troubleshooting/FAQ.md) | Questions fréquentes |

---

## 🗂️ Structure

```
/home/shadowcraft/Projets/segma/
│
├── docs/                    Documentation
│   ├── setup/              Installation
│   ├── guides/             Concepts
│   └── troubleshooting/    Aide
│
├── scripts/                Automatisation
│   ├── setup_hf.sh
│   ├── setup_helpers.sh
│   └── install_sam3.sh
│
├── lib/                    Code Flutter
└── backend/                Code FastAPI + SAM3
```

---

## 🚀 TL;DR

```bash
# 1. Config HuggingFace (une fois)
bash scripts/setup_hf.sh

# 2. Démarrer backend
segma-backend

# 3. Lancer Flutter (autre terminal)
segma-flutter
```

---

## 📖 Par Cas d'Usage

### Je commence

→ [QUICK_START.md](docs/setup/QUICK_START.md)

### J'ai une erreur

→ [FAQ.md](docs/troubleshooting/FAQ.md)

### Je veux comprendre SAM3

→ [ARCHITECTURE.md](docs/guides/ARCHITECTURE.md)

### Je veux écrire de bons prompts

→ [PROMPTS_GUIDE.md](docs/guides/PROMPTS_GUIDE.md)

---

## ✨ Commandes Helper

```bash
segma-backend       # Démarrer FastAPI
segma-flutter       # Lancer Flutter
segma-test          # Tester SAM3
segma-health        # Health check API
segma-check         # Vérifier setup
segma-hf            # Config HuggingFace
segma-help          # Voir toutes les commandes
```

Alias courts: `sb`, `st`, `sh`, `sf`, `shf`

---

## 📊 Votre Setup

```
✅ Venv:        /home/shadowcraft/.pyenv
✅ Python:      3.13.9
✅ PyTorch:     2.9.1
✅ SAM3:        0.1.2 ✅ INSTALLÉ
✅ FastAPI:     0.124.4
✅ Status:      Prêt à utiliser!
```

---

## 🔗 Documentation Complète

[docs/README.md](docs/README.md) pour plus de détails

---

**Prochaine étape**: [QUICK_START.md](docs/setup/QUICK_START.md)

✨ Bonne segmentation!
