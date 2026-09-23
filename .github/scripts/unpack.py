#!/usr/bin/env python3
"""Rozpakowuje packed.txt na prawdziwe pliki projektu.
NADPISUJE pliki utworzone przez flutter create."""
import re
import shutil
from pathlib import Path

packed_path = Path('packed.txt')
if not packed_path.exists():
    print('BLAD: brak pliku packed.txt!')
    raise SystemExit(1)

content = packed_path.read_text(encoding='utf-8').lstrip('\ufeff')
lines = content.count('\n')
print(f'Plik packed.txt: {len(content)} bajtow, {lines} linii')

# USUN domyslne pliki flutter create, ktore moga kolidowac
lib_path = Path('lib')
if lib_path.exists():
    print('Usuwam istniejacy folder lib/ (utworzony przez flutter create)')
    shutil.rmtree(lib_path)

# USUN domyslny pubspec.yaml
pubspec = Path('pubspec.yaml')
if pubspec.exists():
    print('Usuwam istniejacy pubspec.yaml (utworzony przez flutter create)')
    pubspec.unlink()

markers = list(re.finditer(r'^===FILE:(.+?)===\s*$', content, re.MULTILINE))
print(f'Znaleziono {len(markers)} markerow ===FILE:')

if not markers:
    print('BLAD: nie znaleziono markerow w packed.txt')
    print('Pierwsze 500 znakow:', repr(content[:500]))
    raise SystemExit(1)

created = 0
for i, m in enumerate(markers):
    file_path = m.group(1).strip()
    start = m.end()
    if start < len(content) and content[start] == '\n':
        start += 1
    elif start + 1 < len(content) and content[start:start+2] == '\r\n':
        start += 2

    end = markers[i + 1].start() if i + 1 < len(markers) else len(content)
    file_content = content[start:end]
    if file_content.endswith('\n'):
        file_content = file_content[:-1]
    if file_content.endswith('\r'):
        file_content = file_content[:-1]

    p = Path(file_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(file_content, encoding='utf-8')
    created += 1
    print(f'  -> {file_path} ({len(file_content)} bajtow)')

print(f'Rozpakowano: {created} plikow.')

# Weryfikacja - sprawdz czy nasz main.dart istnieje
main_file = Path('lib/main.dart')
if not main_file.exists():
    print('BLAD: lib/main.dart NIE istnieje!')
    raise SystemExit(1)

# Sprawdz czy to NASZ main.dart (nie domyslny flutterowy)
main_content = main_file.read_text(encoding='utf-8')
if 'listaurodzin' not in main_content and 'ListaUrodzinApp' not in main_content:
    print('BLAD: lib/main.dart to domyslny plik Fluttera, nie nasz!')
    print('Pierwsze 300 znakow:', repr(main_content[:300]))
    raise SystemExit(1)

print('OK: lib/main.dart to nasz plik')
