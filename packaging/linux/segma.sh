#!/usr/bin/env bash
# Lanceur SEGMA (Linux) : configure l'environnement au 1er lancement,
# démarre le backend FastAPI puis l'application Flutter.
# Fonctionne en archive portable (tar.gz) comme installé via le .deb (/opt/segma).
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DATA_DIR="${SEGMA_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/segma}"
VENV="$DATA_DIR/venv"
PORT="${SEGMA_PORT:-8000}"
APP_BIN="$ROOT/app/${SEGMA_BIN:-segma}"
REQ="$ROOT/backend/requirements.txt"
ENV_FILE="$DATA_DIR/.env"
# À aligner sur ce que fait scripts/init_project.sh pour installer SAM 3 :
SAM3_SPEC="${SAM3_SPEC-git+https://github.com/facebookresearch/sam3.git}"

mkdir -p "$DATA_DIR"
HEADLESS=0; [ -t 1 ] || HEADLESS=1          # lancé depuis le menu (pas de terminal)
LOG="$DATA_DIR/segma.log"
[ "$HEADLESS" = 1 ] && exec >>"$LOG" 2>&1

notify() {
  echo "$*"
  if [ "$HEADLESS" = 1 ] && command -v notify-send >/dev/null 2>&1; then
    notify-send -i segma "SEGMA" "$*" || true
  fi
}
fail() { notify "$*"; exit 1; }
step() { "$@" || fail "Échec : $* (voir $LOG)"; }

find_python() {
  for p in python3.12 python3.11 python3.10 python3; do
    if command -v "$p" >/dev/null 2>&1 && \
       "$p" -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)'; then
      echo "$p"; return 0
    fi
  done
  return 1
}

req_hash() { sha256sum "$REQ" | cut -d' ' -f1; }

setup() {
  local py; py="$(find_python)" || \
    fail "Python >= 3.10 (avec le module venv) est requis : sudo apt install python3 python3-venv"
  notify "Première configuration de SEGMA (quelques minutes, ne fermez pas)…"
  step "$py" -m venv "$VENV"
  step "$VENV/bin/python" -m pip install --upgrade pip

  local index="${TORCH_INDEX_URL:-}"
  if [ -z "$index" ]; then
    if command -v nvidia-smi >/dev/null 2>&1; then
      index="https://download.pytorch.org/whl/cu126"
    else
      index="https://download.pytorch.org/whl/cpu"
      echo "!! Aucun GPU NVIDIA détecté : la segmentation sera lente (CPU)."
    fi
  fi
  step "$VENV/bin/python" -m pip install -r "$REQ"
  step "$VENV/bin/python" -m pip install --force-reinstall --index-url "$index" torch==2.7.0 torchvision==0.22.0
  if [ -n "$SAM3_SPEC" ]; then step "$VENV/bin/python" -m pip install "$SAM3_SPEC"; fi
  req_hash > "$DATA_DIR/.setup-hash"
  notify "Configuration terminée."
}

# (Ré)installe si le venv est absent ou si requirements.txt a changé
if [ ! -x "$VENV/bin/python" ] || [ "$(cat "$DATA_DIR/.setup-hash" 2>/dev/null)" != "$(req_hash)" ]; then
  rm -rf "$VENV"; setup
fi

[ -f "$ENV_FILE" ] || cp "$ROOT/.env.example" "$ENV_FILE"
set -a; . "$ENV_FILE"; set +a

echo "==> Démarrage du backend sur 127.0.0.1:$PORT"
cd "$DATA_DIR"
"$VENV/bin/python" -m uvicorn main:app --app-dir "$ROOT/backend" \
  --host 127.0.0.1 --port "$PORT" >"$DATA_DIR/backend.log" 2>&1 &
BACK_PID=$!
trap 'kill "$BACK_PID" 2>/dev/null || true' EXIT INT TERM

ready=0
for _ in $(seq 1 180); do
  if "$VENV/bin/python" -c "import urllib.request as u; u.urlopen('http://127.0.0.1:$PORT/docs', timeout=1)" 2>/dev/null; then
    ready=1; break
  fi
  kill -0 "$BACK_PID" 2>/dev/null || fail "Le backend s'est arrêté, voir $DATA_DIR/backend.log"
  sleep 1
done
[ "$ready" = 1 ] || fail "Le backend ne répond pas, voir $DATA_DIR/backend.log"

"$APP_BIN"
