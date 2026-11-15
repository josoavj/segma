#!/usr/bin/env python3
"""Génère les icônes (PNG + ICO) à partir du logo : make_icons.py assets/logo/main.png build/icons"""
import sys
from pathlib import Path
from PIL import Image

if len(sys.argv) != 3:
    sys.exit("usage: make_icons.py <logo.png> <dossier_sortie>")

src, out = Path(sys.argv[1]), Path(sys.argv[2])
if not src.is_file():
    sys.exit(f"Logo introuvable : {src}")
out.mkdir(parents=True, exist_ok=True)

img = Image.open(src).convert("RGBA")
side = max(img.size)
canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))   # carré, fond transparent
canvas.paste(img, ((side - img.width) // 2, (side - img.height) // 2))

for s in (16, 32, 48, 64, 128, 256, 512):
    canvas.resize((s, s), Image.LANCZOS).save(out / f"segma-{s}.png")

canvas.save(out / "segma.ico",
            sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
print(f"Icônes générées dans {out}")
