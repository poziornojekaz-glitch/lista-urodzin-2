#!/usr/bin/env python3
"""Sprawdza czy logo istnieje w repo."""
from pathlib import Path

Path('assets/images').mkdir(parents=True, exist_ok=True)

png_path = Path('assets/images/logo.png')
jpg_path = Path('assets/images/logo.jpg')

if png_path.exists():
    print(f'logo.png istnieje ({png_path.stat().st_size} bajtow)')
elif jpg_path.exists():
    print(f'logo.jpg istnieje ({jpg_path.stat().st_size} bajtow)')
else:
    print('UWAGA: brak logo.png i logo.jpg - uzywam ikony kalendarza')

print('Zawartosc assets/images/:')
for f in Path('assets/images').iterdir():
    print(f'  {f.name} ({f.stat().st_size} bajtow)')
