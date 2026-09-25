import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/lista_item.dart';

class BackupService {
  static const String appMarker = 'lista_urodzin';
  static const int backupVersion = 1;

  /// Buduje JSON string z listy urodzin
  static String buildBackupJson(List<ListaItem> lista) {
    final data = {
      'app': appMarker,
      'version': backupVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'items': lista
          .map((item) => {
                'tekst': item.tekst,
                'datazapisz': item.datazapisz?.toIso8601String(),
                'czyRokWidoczny': item.czyRokWidoczny,
                'czyPowiadamiac': item.czyPowiadamiac,
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Buduje domyślną nazwę pliku backupu
  static String buildBackupFileName() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year;
    return 'lista_urodzin_backup_$y-$m-$d.json';
  }

  /// Zapisuje backup do pliku tymczasowego i otwiera systemowe "udostępnij"
  static Future<void> saveBackupViaShare(List<ListaItem> lista) async {
    final jsonStr = buildBackupJson(lista);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${buildBackupFileName()}');
    await file.writeAsString(jsonStr, encoding: utf8);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Lista Urodzin - kopia zapasowa',
    );
  }

  /// Otwiera systemowy wybór pliku i zwraca zawartość jako string
  static Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.bytes != null) {
      return utf8.decode(file.bytes!, allowMalformed: true);
    }
    if (file.path != null) {
      return await File(file.path!).readAsString(encoding: utf8);
    }
    return null;
  }

  /// Parsuje dane z JSON LUB zwykłego tekstu.
  /// Format tekstowy (linia po linii):
  ///   Włodzimierz : 11.01.1984
  ///   Ewelina-Sofia: 13.01.2009
  ///   Tatiana Warszawa : 25.01
  static ImportResult parseAndImport(
    String rawContent,
    List<ListaItem> istniejacaLista,
  ) {
    final content = rawContent.trim();
    if (content.isEmpty) {
      return ImportResult(error: 'empty');
    }

    // Jeśli zaczyna się od { lub [ – traktujemy jako JSON
    if (content.startsWith('{') || content.startsWith('[')) {
      return _parseJson(content, istniejacaLista);
    }

    // W przeciwnym razie – traktujemy jako zwykły tekst
    return _parsePlainText(content, istniejacaLista);
  }

  // ───────────────────────────────────────
  //  PARSOWANIE JSON
  // ───────────────────────────────────────
  static ImportResult _parseJson(
    String jsonStr,
    List<ListaItem> istniejacaLista,
  ) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        return ImportResult(error: 'invalid_format');
      }
      final items = decoded['items'];
      if (items is! List) {
        return ImportResult(error: 'no_items');
      }

      final nowe = <ListaItem>[];
      for (final raw in items) {
        if (raw is! Map) continue;
        final m = Map<String, dynamic>.from(raw);
        final tekst = (m['tekst'] as String?)?.trim() ?? '';
        if (tekst.isEmpty) continue;

        final dataStr = m['datazapisz'] as String?;
        final data = dataStr != null ? DateTime.tryParse(dataStr) : null;

        _dodajJesliBrakDuplikatu(
          nowe,
          istniejacaLista,
          tekst: tekst,
          data: data,
          czyRokWidoczny: m['czyRokWidoczny'] as bool? ?? false,
          czyPowiadamiac: m['czyPowiadamiac'] as bool? ?? true,
        );
      }

      return ImportResult(newItems: nowe, totalInFile: items.length);
    } catch (_) {
      return ImportResult(error: 'parse_error');
    }
  }

  // ───────────────────────────────────────
  //  PARSOWANIE ZWYKŁEGO TEKSTU
  //  Format: "imię : DD.MM" lub "imię : DD.MM.RRRR"
  // ───────────────────────────────────────
  static ImportResult _parsePlainText(
    String content,
    List<ListaItem> istniejacaLista,
  ) {
    final nowe = <ListaItem>[];
    final lines = content.split(RegExp(r'\r?\n'));
    int totalLines = 0;

    // Regex:  imię  :  DD . MM [ . RRRR ]
    // Grupy:  1=imię  2=dzień  3=miesiąc  4=rok (opcjonalny)
    final regex = RegExp(
      r'^\s*(.+?)\s*[:\-]\s*(\d{1,2})\s*\.\s*(\d{1,2})(?:\s*\.\s*(\d{4}))?\s*$',
    );

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Pomijamy typowe nagłówki
      final lower = line.toLowerCase();
      if (lower.startsWith('lista urodzin') ||
          lower.startsWith('birthday list') ||
          lower.startsWith('geburtstagsliste') ||
          lower.startsWith('список дней')) {
        continue;
      }

      final match = regex.firstMatch(line);
      if (match == null) continue;

      totalLines++;

      final tekst = match.group(1)!.trim();
      final day = int.tryParse(match.group(2)!);
      final month = int.tryParse(match.group(3)!);
      final yearStr = match.group(4);
      final year = yearStr != null ? int.tryParse(yearStr) : null;

      if (tekst.isEmpty || day == null || month == null) continue;
      if (day < 1 || day > 31 || month < 1 || month > 12) continue;

      DateTime data;
      bool czyRokWidoczny;
      if (year != null && year > 1900) {
        data = DateTime(year, month, day);
        czyRokWidoczny = true;
      } else {
        // Rok nieznany – używamy 1900 (jak w oryginalnej logice)
        data = DateTime(1900, month, day);
        czyRokWidoczny = false;
      }

      _dodajJesliBrakDuplikatu(
        nowe,
        istniejacaLista,
        tekst: tekst,
        data: data,
        czyRokWidoczny: czyRokWidoczny,
        czyPowiadamiac: true,
      );
    }

    if (totalLines == 0) {
      return ImportResult(error: 'no_matches');
    }

    return ImportResult(newItems: nowe, totalInFile: totalLines);
  }

  // ───────────────────────────────────────
  //  POMOCNICZE
  // ───────────────────────────────────────
  static void _dodajJesliBrakDuplikatu(
    List<ListaItem> nowe,
    List<ListaItem> istniejacaLista, {
    required String tekst,
    required DateTime? data,
    required bool czyRokWidoczny,
    required bool czyPowiadamiac,
  }) {
    bool duplikat(List<ListaItem> src) => src.any((e) =>
        e.tekst.trim().toLowerCase() == tekst.toLowerCase() &&
        e.datazapisz?.day == data?.day &&
        e.datazapisz?.month == data?.month);

    if (duplikat(istniejacaLista)) return;
    if (duplikat(nowe)) return;

    nowe.add(ListaItem(
      id: DateTime.now().millisecondsSinceEpoch + nowe.length,
      tekst: tekst,
      datazapisz: data,
      czyRokWidoczny: czyRokWidoczny,
      czyPowiadamiac: czyPowiadamiac,
    ));
  }
}

class ImportResult {
  final List<ListaItem>? newItems;
  final int totalInFile;
  final String? error;

  ImportResult({this.newItems, this.totalInFile = 0, this.error});
}
