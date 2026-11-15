#!/usr/bin/env bash
# Construit le paquet .deb : build-deb.sh <version> <dossier_stage> <dossier_icones> <sortie>
set -euo pipefail

VERSION="$1"; STAGE="$2"; ICONS="$3"; OUT="$4"
HERE="$(cd "$(dirname "$0")" && pwd)"
PKG="segma_${VERSION}_amd64"
WORK="$(mktemp -d)/$PKG"

mkdir -p "$WORK/DEBIAN" "$WORK/opt/segma" "$WORK/usr/bin" "$WORK/usr/share/applications" "$OUT"
cp -a "$STAGE/." "$WORK/opt/segma/"
ln -s /opt/segma/segma.sh "$WORK/usr/bin/segma"
install -Dm644 "$HERE/segma.desktop" "$WORK/usr/share/applications/segma.desktop"
for s in 48 128 256 512; do
  install -Dm644 "$ICONS/segma-$s.png" "$WORK/usr/share/icons/hicolor/${s}x${s}/apps/segma.png"
done

# Permissions propres (dpkg-deb refuse des modes exotiques)
find "$WORK" -type d -exec chmod 755 {} +
find "$WORK/opt" -type f -exec chmod a+r {} +
chmod 755 "$WORK/opt/segma/segma.sh" "$WORK/opt/segma/app/segma"

SIZE="$(du -sk "$WORK/opt" "$WORK/usr" | awk '{s+=$1} END {print s}')"
cat > "$WORK/DEBIAN/control" <<CTRL
Package: segma
Version: ${VERSION}
Section: graphics
Priority: optional
Architecture: amd64
Installed-Size: ${SIZE}
Depends: python3 (>= 3.10), python3-venv, python3-pip, libgtk-3-0
Recommends: git, libnotify-bin
Maintainer: josoavj <josoavj@users.noreply.github.com>
Homepage: https://github.com/josoavj/segma
Description: Segmentation d'images avec SAM 3
 SEGMA associe une interface Flutter et un backend FastAPI pour segmenter
 des images avec Segment Anything Model 3 (SAM 3) de Meta : prompts texte,
 affinage interactif, traitement par lot et historique.
 Au premier lancement, l'environnement Python (PyTorch, SAM 3) est configuré
 automatiquement dans ~/.local/share/segma.
CTRL

cat > "$WORK/DEBIAN/postinst" <<'SH'
#!/bin/sh
set -e
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
exit 0
SH
cat > "$WORK/DEBIAN/postrm" <<'SH'
#!/bin/sh
set -e
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
exit 0
SH
chmod 755 "$WORK/DEBIAN/postinst" "$WORK/DEBIAN/postrm"

dpkg-deb --root-owner-group -Zxz --build "$WORK" "$OUT/$PKG.deb"
echo "Paquet : $OUT/$PKG.deb"
