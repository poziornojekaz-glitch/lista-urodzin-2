#!/usr/bin/env python3
"""Dodaje szare marginesy do logo.png aby zmiescil sie w okraglej ikonie."""
from pathlib import Path
from PIL import Image

src = Path('assets/images/logo.png')
dst = Path('assets/images/logo_icon.png')

if not src.exists():
    print('BLAD: brak logo.png!')
    raise SystemExit(1)

img = Image.open(src).convert('RGBA')

# Rozmiar 1.7x wiekszy od oryginalu (margines)
w, h = img.size
new_w = int(w * 1.7)
new_h = int(h * 1.7)

# ── SZARE TŁO (zamiast białego) ──
# #E0E0E0 = (224, 224, 224)
canvas = Image.new('RGBA', (new_w, new_h), (224, 224, 224, 255))

offset_x = (new_w - w) // 2
offset_y = (new_h - h) // 2
canvas.paste(img, (offset_x, offset_y), img)

canvas.save(dst, 'PNG')
print(f'Utworzono {dst} ({new_w}x{new_h}, {dst.stat().st_size} bajtow)')
