# Dockerfile pour le déploiement de la partie Backend (FastAPI + SAM 3)
FROM nvidia/cuda:12.1.0-base-ubuntu22.04

# Éviter les interactions lors de l'install
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les requirements et installer
COPY backend/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Installer SAM 3 depuis le repo officiel
RUN pip3 install 'git+https://github.com/facebookresearch/segment-anything.git'

# Copier le code source du backend
COPY backend/ .

# Exposer le port
EXPOSE 8000

# Lancer l'application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
