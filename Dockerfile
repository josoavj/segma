# Stage 1: Builder
FROM python:3.13-slim as builder

WORKDIR /build

# Arguments de build
ARG HF_TOKEN=""

# Installer les dépendances système pour compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copier requirements
COPY backend/requirements.txt .

# Créer venv isolé
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Installer dépendances Python
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Pré-télécharger SAM3 depuis HuggingFace (optionnel mais recommandé)
RUN if [ -n "$HF_TOKEN" ]; then \
        python -c "import os; os.environ['HF_TOKEN']='$HF_TOKEN'; from huggingface_hub import login; login(token='$HF_TOKEN')" && \
        python -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='facebook/sam3', filename='sam3.pt', cache_dir='/opt/hf_cache')" \
    ; fi

# Stage 2: Runtime - Image de production légère
FROM python:3.13-slim

WORKDIR /app

# Labels pour métadonnées
LABEL maintainer="SEGMA Team"
LABEL description="SEGMA Backend - SAM3 + YOLO Segmentation Service"
LABEL version="1.0"

# Installer uniquement les dépendances runtime (pas de dev tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copier venv du builder (contient tous les packages)
COPY --from=builder /opt/venv /opt/venv

# Copier SAM3 pré-téléchargé (optionnel)
# COPY --from=builder /opt/hf_cache /root/.cache/huggingface

# Copier code backend
COPY backend/ /app/

# Variables d'environnement
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    CUDA_VISIBLE_DEVICES="" \
    TORCH_HOME=/root/.cache/torch \
    HF_HOME=/root/.cache/huggingface

# Créer répertoire de sortie
RUN mkdir -p /app/segmentation_output

# Health check pour vérifier que le service est opérationnel
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

# Expose le port FastAPI
EXPOSE 8000

# Commande de démarrage
CMD ["python", "-m", "uvicorn", "main:app", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--log-level", "info", \
     "--access-log"]
