#!/usr/bin/env python3
"""Przygotowuje pliki przed buildem: fix pubspec.yaml, tworzy logo.jpg."""
import base64
import re
from pathlib import Path

# ─── 1. FIX PUBSPEC.YAML ───
pubspec_path = Path('pubspec.yaml')
if pubspec_path.exists():
    content = pubspec_path.read_text(encoding='utf-8')
    original = content

    # Zamien intl ^0.20.x na ^0.19.0 (kompatybilne z Flutter 3.24.5 / Dart 3.5.4)
    content = re.sub(r'intl:\s*\^0\.20(\.\d+)?', 'intl: ^0.19.0', content)

    if content != original:
        pubspec_path.write_text(content, encoding='utf-8')
        print('pubspec.yaml: poprawiono wersje intl na ^0.19.0')
    else:
        print('pubspec.yaml: intl juz OK lub nie znaleziono')

    # Pokaz linie z intl
    for line in content.splitlines():
        if 'intl' in line.lower():
            print(f'  {line}')
else:
    print('BLAD: brak pubspec.yaml!')

# ─── 2. PLACEHOLDER LOGO ───
Path('assets/images').mkdir(parents=True, exist_ok=True)

logo_path = Path('assets/images/logo.jpg')
if logo_path.exists():
    print(f'logo.jpg juz istnieje ({logo_path.stat().st_size} bajtow)')
else:
    print('Tworzenie placeholdera logo.jpg (1x1 piksel)...')
    b64 = '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AKp//2Q=='
    logo_path.write_bytes(base64.b64decode(b64))
    print('Utworzono placeholder')

print('Zawartosc assets/images/:')
for f in Path('assets/images').iterdir():
    print(f'  {f.name} ({f.stat().st_size} bajtow)')

print('Gotowe.')
