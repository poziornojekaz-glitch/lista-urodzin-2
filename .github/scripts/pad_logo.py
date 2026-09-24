#!/usr/bin/env python3
"""Dodaje biale marginesy do logo.png aby zmiescil sie w okraglej ikonie."""
import subprocess
import sys
from pathlib import Path

# Upewnij sie ze Pillow jest zainstalowany
try:
    from PIL import Image
except ImportError:
    print('Instaluje Pillow...')
    subprocess.run([sys.executable, '-m', 'pip', 'install', '--quiet', 'Pillow'],
                   check=True)
    from PIL import Image

src = Path('assets/images/logo.png')
dst = Path('assets/images/logo_icon.png')

if not src.exists():
    print('BLAD: brak logo.png!')
    raise SystemExit(1)

# Otworz obraz
img = Image.open(src).convert('RGBA')

# Rozmiar docelowy - 140% oryginalu (20% marginesu z kazdej strony)
w, h = img.size
new_w = int(w * 1.4)
new_h = int(h * 1.4)

# Biale tlo (nieprzezroczyste)
canvas = Image.new('RGBA', (new_w, new_h), (255, 255, 255, 255))

# Wklej obraz na srodku
offset_x = (new_w - w) // 2
offset_y = (new_h - h) // 2
canvas.paste(img, (offset_x, offset_y), img)

# Zapisz jako PNG
canvas.save(dst, 'PNG')
print(f'Utworzono {dst} ({new_w}x{new_h}, {dst.stat().st_size} bajtow)')
