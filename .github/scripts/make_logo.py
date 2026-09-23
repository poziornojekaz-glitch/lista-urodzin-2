#!/usr/bin/env python3
"""Tworzy placeholder logo.jpg jesli nie istnieje."""
import base64
from pathlib import Path

Path('assets/images').mkdir(parents=True, exist_ok=True)

logo_path = Path('assets/images/logo.jpg')

if logo_path.exists():
    print('logo.jpg juz istnieje - uzywam go')
    print(f'  rozmiar: {logo_path.stat().st_size} bajtow')
else:
    print('Tworzenie placeholdera logo.jpg (1x1 piksel)...')
    b64 = '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AKp//2Q=='
    logo_path.write_bytes(base64.b64decode(b64))
    print('Utworzono placeholder')

print('Zawartosc assets/images/:')
for f in Path('assets/images').iterdir():
    print(f'  {f.name} ({f.stat().st_size} bajtow)')
