#!/bin/bash
set -e

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  SEGMA Backend - Docker Deploy Script  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    exit 1
fi

# Vérifier Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker vérifié${NC}"
echo -e "${GREEN}✓ Docker Compose vérifié${NC}"

# Définir le répertoire de base
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Menu principal
case "${1:-}" in
    build)
        echo -e "\n${BLUE}📦 Construction de l'image Docker...${NC}"
        docker build -t segma-backend:latest .
        echo -e "${GREEN}✓ Image construite avec succès!${NC}"
        ;;
    
    start)
        echo -e "\n${BLUE}🚀 Démarrage des services...${NC}"
        docker-compose up -d
        echo -e "${GREEN}✓ Services démarrés!${NC}"
        echo -e "\n${BLUE}Attente du démarrage complet (60 secondes)...${NC}"
        sleep 60
        
        # Vérifier la santé
        if curl -s http://localhost:8000/api/v1/health > /dev/null; then
            echo -e "${GREEN}✓ Backend opérationnel à http://localhost:8000${NC}"
        else
            echo -e "${YELLOW}⚠ Backend en cours de démarrage, vérifiez les logs${NC}"
        fi
        ;;
    
    stop)
        echo -e "\n${BLUE}⛔ Arrêt des services...${NC}"
        docker-compose down
        echo -e "${GREEN}✓ Services arrêtés${NC}"
        ;;
    
    restart)
        echo -e "\n${BLUE}🔄 Redémarrage des services...${NC}"
        docker-compose restart
        echo -e "${GREEN}✓ Services redémarrés${NC}"
        ;;
    
    logs)
        echo -e "\n${BLUE}📋 Affichage des logs...${NC}"
        docker-compose logs -f backend
        ;;
    
    clean)
        echo -e "\n${BLUE}🧹 Nettoyage des conteneurs et images...${NC}"
        docker-compose down -v
        docker rmi segma-backend:latest 2>/dev/null || true
        echo -e "${GREEN}✓ Nettoyage complété${NC}"
        ;;
    
    shell)
        echo -e "\n${BLUE}🔧 Shell dans le conteneur...${NC}"
        docker-compose exec backend bash
        ;;
    
    health)
        echo -e "\n${BLUE}🏥 Vérification de la santé du service...${NC}"
        if curl -s http://localhost:8000/api/v1/health > /dev/null; then
            echo -e "${GREEN}✓ Backend est opérationnel${NC}"
            curl -s http://localhost:8000/api/v1/health | python -m json.tool
        else
            echo -e "${RED}❌ Backend n'est pas opérationnel${NC}"
        fi
        ;;
    
    *)
        echo -e "\n${YELLOW}Usage:${NC}"
        echo "  ./deploy.sh build      - Construire l'image Docker"
        echo "  ./deploy.sh start      - Démarrer les services"
        echo "  ./deploy.sh stop       - Arrêter les services"
        echo "  ./deploy.sh restart    - Redémarrer les services"
        echo "  ./deploy.sh logs       - Afficher les logs"
        echo "  ./deploy.sh shell      - Accéder au shell du conteneur"
        echo "  ./deploy.sh health     - Vérifier la santé du service"
        echo "  ./deploy.sh clean      - Nettoyer les conteneurs/images"
        ;;
esac
