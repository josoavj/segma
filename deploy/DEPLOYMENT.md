# Guide de Déploiement SEGMA avec Docker

## 📋 Table des matières
1. [Vue d'ensemble](#vue-densemble)
2. [Installation](#installation)
3. [Démarrage](#démarrage)
4. [Configuration](#configuration)
5. [Maintenance](#maintenance)
6. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

### Architecture Docker

```
┌─────────────────────────────────────────┐
│         Machine Client (Linux)          │
├─────────────────────────────────────────┤
│  Docker Engine                          │
│  ├─ Conteneur Backend (FastAPI)        │
│  │  ├─ Python 3.13                     │
│  │  ├─ SAM3 (HuggingFace)              │
│  │  ├─ YOLO v8                        │
│  │  └─ Port 8000                       │
│  │                                      │
│  ├─ Volume: hf_cache                    │
│  │  └─ Cache HuggingFace (~3.5 GB)     │
│  │                                      │
│  └─ Volume: segmentation_data           │
│     └─ Résultats segmentation          │
└─────────────────────────────────────────┘
```

### Avantages
- ✅ **Isolation complète** - Aucune dépendance système
- ✅ **Reproductibilité** - Même config partout
- ✅ **Persistance** - Volumes Docker conservent les données
- ✅ **Facilité de déploiement** - Une commande pour tout
- ✅ **Scalabilité** - Multi-instances possibles

---

## 🚀 Installation

### Prérequis

#### Sur Linux (Debian/Ubuntu)
```bash
# 1. Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Installer Docker Compose
sudo apt-get install docker-compose-plugin

# 3. Ajouter ton utilisateur au groupe docker (optionnel)
sudo usermod -aG docker $USER
newgrp docker

# 4. Vérifier l'installation
docker --version
docker-compose --version
```

#### Sur autres distributions
Consulte: https://docs.docker.com/install/

### Configuration HuggingFace

Si tu veux pré-télécharger SAM3 lors du build:

```bash
# Dans le répertoire racine du projet:
export HF_TOKEN="hf_xxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Ou créer un fichier .env:
cat > .env << EOF
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxx
BACKEND_PORT=8000
EOF
```

---

## 🎬 Démarrage

### Option 1: Avec le script `deploy.sh` (Recommandé)

```bash
# Rendre le script exécutable
chmod +x deploy/deploy.sh

# Construire l'image Docker
./deploy/deploy.sh build

# Démarrer les services
./deploy/deploy.sh start

# Vérifier que tout fonctionne
./deploy/deploy.sh health

# Voir les logs
./deploy/deploy.sh logs
```

### Option 2: Directement avec Docker Compose

```bash
# Construire et démarrer
docker-compose up -d

# Attendre 60 secondes (chargement SAM3)
sleep 60

# Tester l'API
curl http://localhost:8000/api/v1/health
```

### Premiers tests

```bash
# 1. Vérifier que le backend répond
curl http://localhost:8000/api/v1/health | python -m json.tool

# Résultat attendu:
# {
#   "status": "healthy",
#   "models": {
#     "sam3": {
#       "loaded": true,
#       "device": "cpu"
#     },
#     "yolo": {
#       "loaded": true
#     }
#   }
# }

# 2. Voir les logs de démarrage
docker-compose logs backend

# 3. Accéder au shell du conteneur
docker-compose exec backend bash
```

---

## ⚙️ Configuration

### Variables d'environnement (`.env`)

```env
# Port d'écoute du backend
BACKEND_PORT=8000

# Token HuggingFace pour SAM3
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxx

# Niveau de logging
LOG_LEVEL=info  # ou: debug, warning, error

# Configuration SAM3
DEVICE=cpu      # ou: cuda (si GPU disponible)
CONFIDENCE_THRESHOLD=0.5

# Max image size (pixels)
MAX_IMAGE_SIZE=2048
```

### Limiter les ressources (optionnel)

Éditer `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'          # Max 2 CPU cores
          memory: 8G         # Max 8 GB RAM
        reservations:
          cpus: '1'          # Réserver 1 CPU core
          memory: 4G         # Réserver 4 GB RAM
```

---

## 🔧 Maintenance

### Redémarrer les services

```bash
# Redémarrage simple
docker-compose restart

# Ou via le script
./deploy/deploy.sh restart
```

### Mises à jour

```bash
# 1. Arrêter les services
docker-compose down

# 2. Récupérer les changements
git pull

# 3. Reconstruire l'image
docker-compose up -d --build

# 4. Vérifier la santé
./deploy/deploy.sh health
```

### Voir les logs

```bash
# Logs du backend
docker-compose logs -f backend

# Dernières 100 lignes
docker-compose logs --tail=100 backend

# Avec timestamps
docker-compose logs -f --timestamps backend
```

### Accéder à l'intérieur du conteneur

```bash
# Bash shell
docker-compose exec backend bash

# Python REPL
docker-compose exec backend python

# Exécuter une commande
docker-compose exec backend python -m pip list
```

### Nettoyage

```bash
# Arrêter et supprimer les conteneurs
docker-compose down

# Supprimer les volumes (ATTENTION: perte de données!)
docker-compose down -v

# Supprimer l'image
docker rmi segma-backend:latest

# Nettoyer tout via le script
./deploy/deploy.sh clean
```

---

## 🐛 Dépannage

### Le backend ne démarre pas

```bash
# 1. Vérifier les logs
docker-compose logs backend

# 2. Vérifier les volumes
docker volume ls

# 3. Arrêter et nettoyer
docker-compose down -v

# 4. Redémarrer
docker-compose up -d
```

### Port déjà utilisé

```bash
# Si port 8000 est occupé:
# Option 1: Changer le port dans .env
BACKEND_PORT=8001

# Option 2: Tuer le processus sur le port
sudo lsof -i :8000
sudo kill -9 <PID>
```

### Problèmes de mémoire

```bash
# Vérifier la RAM disponible
free -h

# Limiter SAM3 dans docker-compose.yml
# Voir section "Configuration"
```

### SAM3 ne télécharge pas

```bash
# 2. Tester le token HF
grep HF_TOKEN .env

# 2. Tester le token HF via Python
docker-compose exec backend python -c "
from huggingface_hub import model_info
model_info('facebook/sam3')
"

# 3. Télécharger manuellement (hors conteneur)
huggingface-cli download facebook/sam3
```

### Cache HF pas persistant

```bash
# Vérifier le volume
docker volume inspect segma_hf_cache

# Si besoin, réinitialiser
docker volume rm segma_hf_cache
```

---

## 📊 Monitoring

### Vérifier la santé

```bash
# Script simple
while true; do
  curl -s http://localhost:8000/api/v1/health && echo "✓" || echo "✗"
  sleep 5
done
```

### Voir les stats Docker

```bash
# Utilisation CPU/RAM/réseau
docker stats segma-backend

# Détails complets
docker inspect segma-backend | grep -A 20 '"Memory'
```

### Logs en temps réel

```bash
./deploy/deploy.sh logs
```

---

## 📝 Résumé des commandes

```bash
# Déploiement initial
docker-compose build
docker-compose up -d
docker-compose logs -f

# Utilisation quotidienne
docker-compose up -d      # Démarrer
docker-compose down        # Arrêter
docker-compose restart     # Redémarrer

# Maintenance
docker-compose logs -f              # Logs
docker-compose exec backend bash    # Shell
./deploy/deploy.sh health          # Santé

# Nettoyage
docker-compose down -v     # Arrêt complet + volumes
docker system prune         # Nettoyer Docker
```

---

## 🆘 Support

Pour plus d'info sur Docker:
- https://docs.docker.com/
- https://docs.docker.com/compose/
- https://hub.docker.com/

Pour les problèmes SAM3/HuggingFace:
- https://github.com/facebookresearch/sam3
- https://huggingface.co/facebook/sam3
