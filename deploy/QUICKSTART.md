# Quick Start - SEGMA Backend Docker

Déployer SEGMA en 5 minutes!

## 📦 Prérequis
- Docker & Docker Compose installés
- Token HuggingFace (optionnel)

## 🚀 Démarrage rapide

### 1. Configuration (optionnel)
```bash
# Créer fichier .env avec ton token HF (récupéré sur https://huggingface.co/settings/tokens)
cat > .env << EOF
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxx
BACKEND_PORT=8000
EOF
```

### 2. Lancer le backend
```bash
docker-compose up -d
```

### 3. Attendre le démarrage (60 secondes)
```bash
sleep 60
```

### 4. Vérifier que ça marche
```bash
curl http://localhost:8000/api/v1/health
```

✅ **C'est prêt!** Le backend tourne sur `localhost:8000`

---

## 🎮 Commandes essentielles

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer
docker-compose restart

# Voir les logs
docker-compose logs -f backend

# Shell dans le conteneur
docker-compose exec backend bash

# Vérifier la santé
curl http://localhost:8000/api/v1/health
```

---

## 📍 Emplacements importants

| Emplacement | Description |
|---|---|
| `/app` | Code Python du backend |
| `/app/segmentation_output` | Résultats segmentation |
| `/root/.cache/huggingface` | Cache SAM3 (3.5 GB) |

---

## 🔗 API Endpoints

- `GET /api/v1/health` - Santé du service
- `GET /api/v1/models/info` - Info des modèles
- `POST /api/v1/segment` - Segmenter une image

---

## ❓ Problèmes courants

| Problème | Solution |
|---|---|
| Port 8000 occupé | `docker-compose down` puis relancer |
| Backend lent au démarrage | Normal (120 sec max pour SAM3) |
| Cache pas persistant | Vérifier volumes: `docker volume ls` |
| HF pas reconnecté | Ajouter token dans `.env` |

---

Pour plus de détails, voir [DEPLOYMENT.md](DEPLOYMENT.md)
