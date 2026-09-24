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

  /// Zapisuje backup do pliku tymczasowego i otwiera systemowe menu "udostępnij"
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
      return utf8.decode(file.bytes!);
    }
    if (file.path != null) {
      return await File(file.path!).readAsString(encoding: utf8);
    }
    return null;
  }

  /// Parsuje JSON i zwraca listę nowych osób (bez duplikatów)
  static ImportResult parseAndImport(
    String jsonStr,
    List<ListaItem> istniejacaLista,
  ) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        return ImportResult(error: 'invalid_format');
      }
      if (decoded['app'] != appMarker) {
        return ImportResult(error: 'invalid_app');
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

        bool duplikat(List<ListaItem> src) => src.any((e) =>
            e.tekst.trim().toLowerCase() == tekst.toLowerCase() &&
            e.datazapisz?.day == data?.day &&
            e.datazapisz?.month == data?.month);

        if (duplikat(istniejacaLista)) continue;
        if (duplikat(nowe)) continue;

        nowe.add(ListaItem(
          id: DateTime.now().millisecondsSinceEpoch + nowe.length,
          tekst: tekst,
          datazapisz: data,
          czyRokWidoczny: m['czyRokWidoczny'] as bool? ?? false,
          czyPowiadamiac: m['czyPowiadamiac'] as bool? ?? true,
        ));
      }

      return ImportResult(newItems: nowe, totalInFile: items.length);
    } catch (_) {
      return ImportResult(error: 'parse_error');
    }
  }
}

class ImportResult {
  final List<ListaItem>? newItems;
  final int totalInFile;
  final String? error;

  ImportResult({this.newItems, this.totalInFile = 0, this.error});
}
