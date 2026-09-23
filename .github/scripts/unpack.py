#!/usr/bin/env python3
"""Rozpakowuje packed.txt na pliki projektu.
NIE rusza pubspec.yaml. Naklada pliki z overrides/."""
import re
import shutil
from pathlib import Path

packed_path = Path('packed.txt')
if not packed_path.exists():
    print('BLAD: brak packed.txt!')
    raise SystemExit(1)

content = packed_path.read_text(encoding='utf-8').lstrip('\ufeff')
print(f'packed.txt: {len(content)} bajtow')

lib_path = Path('lib')
if lib_path.exists():
    shutil.rmtree(lib_path)
    print('Usunieto: lib/')

markers = list(re.finditer(r'^===FILE:(.+?)===\s*$', content, re.MULTILINE))
print(f'Znaleziono {len(markers)} plikow w packed.txt')

created = 0
for i, m in enumerate(markers):
    file_path = m.group(1).strip()

    if file_path == 'pubspec.yaml':
        print(f'  -> pubspec.yaml (POMINIETY - jest osobno w repo)')
        continue

    start = m.end()
    if start < len(content) and content[start] == '\n':
        start += 1
    elif start + 1 < len(content) and content[start:start+2] == '\r\n':
        start += 2

    end = markers[i + 1].start() if i + 1 < len(markers) else len(content)
    fc = content[start:end]
    if fc.endswith('\n'):
        fc = fc[:-1]
    if fc.endswith('\r'):
        fc = fc[:-1]

    p = Path(file_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(fc, encoding='utf-8')
    created += 1

print(f'Rozpakowano: {created} plikow.')

overrides_dir = Path('overrides')
if overrides_dir.exists():
    print('Nakladam pliki z overrides/...')
    count = 0
    for src in overrides_dir.rglob('*'):
        if src.is_file():
            rel = src.relative_to(overrides_dir)
            dst = Path(str(rel))
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            print(f'  OVERRIDE: {rel}')
            count += 1
    print(f'Nalożono {count} plikow.')

main_file = Path('lib/main.dart')
if not main_file.exists():
    print('BLAD: lib/main.dart NIE istnieje!')
    raise SystemExit(1)
if 'ListaUrodzinApp' not in main_file.read_text(encoding='utf-8'):
    print('BLAD: lib/main.dart to domyslny plik Fluttera!')
    raise SystemExit(1)
print('OK: lib/main.dart poprawny')

pubspec_file = Path('pubspec.yaml')
if not pubspec_file.exists():
    print('BLAD: pubspec.yaml nie istnieje!')
    raise SystemExit(1)
print('OK: pubspec.yaml istnieje')
