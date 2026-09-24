import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/backup_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/custom_functions.dart';
import '../utils/translations.dart';
import 'wierszprzekaz_widget.dart';

class OknoprzekazuWidget extends StatefulWidget {
  const OknoprzekazuWidget({super.key});

  @override
  State<OknoprzekazuWidget> createState() => _OknoprzekazuWidgetState();
}

class _OknoprzekazuWidgetState extends State<OknoprzekazuWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.wybranyJezyk;
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.92,
          height: size.height * 0.82,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppTheme.primary, width: 1.5),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.primaryDark,
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: AppTranslations.tr('tab_share', lang)),
                      Tab(text: AppTranslations.tr('tab_backup', lang)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildShareTab(context, state, lang),
                    _buildBackupTab(context, state, lang),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────
  //  ZAKŁADKA 1: PRZEKAŻ WYBRANE
  // ───────────────────────────────────────
  Widget _buildShareTab(BuildContext context, AppState state, String lang) {
    final shareList = state.tymczasowaListaShare;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Text(
            AppTranslations.tr('share_select_prompt', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF248C80)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: shareList.isEmpty
                ? Center(
                    child: Text(
                      AppTranslations.tr('empty_list', lang),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: shareList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      return WierszprzekazWidget(
                        itemIndex: index,
                        itemOsoba: shareList[index],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (alertDialogContext) {
                  return AlertDialog(
                    content: Text(AppTranslations.tr('share_ask', lang)),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, false),
                        child: Text(AppTranslations.tr('no', lang)),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, true),
                        child: Text(AppTranslations.tr('yes', lang)),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true && context.mounted) {
                final textToSend = CustomFunctions.budujTekstDoWysylki(
                  state.tymczasowaListaShare,
                  lang,
                );
                await Share.share(textToSend);
              }
            },
            icon: const Icon(Icons.email_outlined,
                color: Colors.white, size: 22),
            label: Text(
              AppTranslations.tr('send', lang),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  //  ZAKŁADKA 2: KOPIA ZAPASOWA
  // ───────────────────────────────────────
  Widget _buildBackupTab(BuildContext context, AppState state, String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _karta(
            icon: Icons.save_alt,
            title: AppTranslations.tr('backup_card_title', lang),
            desc: AppTranslations.tr('backup_card_desc', lang),
            buttons: [
              ElevatedButton.icon(
                onPressed: () => _zapiszBackup(context, state, lang),
                icon:
                    const Icon(Icons.save, color: Colors.white, size: 20),
                label: Text(AppTranslations.tr('backup_save_btn', lang)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _karta(
            icon: Icons.upload_file,
            title: AppTranslations.tr('restore_card_title', lang),
            desc: AppTranslations.tr('restore_card_desc', lang),
            buttons: [
              ElevatedButton.icon(
                onPressed: () => _wczytajZPliku(context, state, lang),
                icon: const Icon(Icons.folder_open,
                    color: Colors.white, size: 20),
                label: Text(AppTranslations.tr('restore_pick_btn', lang)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _wklejZeSchowka(context, state, lang),
                icon: const Icon(Icons.content_paste, size: 20),
                label: Text(AppTranslations.tr('restore_paste_btn', lang)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryDark,
                  side: const BorderSide(
                      color: AppTheme.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _karta({
    required IconData icon,
    required String title,
    required String desc,
    required List<Widget> buttons,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D7C70)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF556068), height: 1.4),
          ),
          const SizedBox(height: 12),
          ...buttons,
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  //  AKCJE
  // ───────────────────────────────────────

  Future<void> _zapiszBackup(
      BuildContext context, AppState state, String lang) async {
    try {
      await BackupService.saveBackupViaShare(state.urodzinyList);
      if (context.mounted) {
        _toast(context, AppTranslations.tr('backup_success', lang));
      }
    } catch (e) {
      if (context.mounted) {
        _toast(context, AppTranslations.tr('import_error', lang));
      }
    }
  }

  Future<void> _wczytajZPliku(
      BuildContext context, AppState state, String lang) async {
    try {
      final content = await BackupService.pickBackupFile();
      if (content == null) return;
      if (!context.mounted) return;
      await _importuj(context, state, lang, content);
    } catch (e) {
      if (context.mounted) {
        _toast(context, AppTranslations.tr('import_error', lang));
      }
    }
  }

  Future<void> _wklejZeSchowka(
      BuildContext context, AppState state, String lang) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null || data.text!.isEmpty) {
      if (context.mounted) {
        _toast(context, AppTranslations.tr('import_error', lang));
      }
      return;
    }
    if (context.mounted) {
      await _importuj(context, state, lang, data.text!);
    }
  }

  Future<void> _importuj(BuildContext context, AppState state, String lang,
      String content) async {
    final result =
        BackupService.parseAndImport(content, state.urodzinyList);

    if (result.error != null) {
      if (context.mounted) {
        _toast(context, AppTranslations.tr('import_error', lang));
      }
      return;
    }

    final nowe = result.newItems ?? [];
    if (nowe.isEmpty) {
      if (context.mounted) {
        _toast(context, AppTranslations.tr('import_no_new', lang));
      }
      return;
    }

    for (final item in nowe) {
      await state.addUrodziny(item);
    }

    if (context.mounted) {
      final msg = AppTranslations.tr('import_success', lang)
          .replaceAll('{n}', '${nowe.length}');
      _toast(context, msg);
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
