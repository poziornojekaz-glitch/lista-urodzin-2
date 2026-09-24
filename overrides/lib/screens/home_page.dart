import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lista_item.dart';
import '../services/notification_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/edytorwiersza_widget.dart';
import '../widgets/instrukcja_widget.dart';
import '../widgets/oknopowiadomien_widget.dart';
import '../widgets/oknoprzekazu_widget.dart';
import '../widgets/pusty_widget.dart';
import '../widgets/wiersz1_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.wybranyJezyk;
    final lista = state.urodzinyList;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ── GÓRNY PASEK: DZWONEK, LOGO, KOPERTA ──
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.topGradient,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x30000000),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ── Przycisk powiadomień (Dzwonek) jako BUTTON ──
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _TopIconButton(
                          icon: Icons.notifications_active_outlined,
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (dialogCtx) =>
                                  const OknopowiadomienWidget(),
                            );
                          },
                        ),
                      ),

                      // ── Logo aplikacji ──
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 32,
                            );
                          },
                        ),
                      ),

                      // ── Przycisk udostępniania (Koperta) jako BUTTON ──
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _TopIconButton(
                          icon: Icons.email_outlined,
                          onTap: () async {
                            context.read<AppState>().prepareShareList();
                            await showDialog(
                              context: context,
                              builder: (dialogCtx) =>
                                  const OknoprzekazuWidget(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // ── DRUGI PASEK: JĘZYK + INFO ──
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.languageGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6EE1D4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white70),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: lang,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF15766E),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15766E),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'pl',
                                  child: Text(
                                      'PL  \u{1F1F5}\u{1F1F1}')),
                              DropdownMenuItem(
                                  value: 'en',
                                  child: Text(
                                      'EN  \u{1F1EC}\u{1F1E7}')),
                              DropdownMenuItem(
                                  value: 'de',
                                  child: Text(
                                      'DE  \u{1F1E9}\u{1F1EA}')),
                              DropdownMenuItem(
                                  value: 'ru',
                                  child: Text(
                                      'RU  \u{1F1F7}\u{1F1FA}')),
                            ],
                            onChanged: (newLang) {
                              if (newLang != null) {
                                context
                                    .read<AppState>()
                                    .setLanguage(newLang);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (dialogCtx) =>
                                  const InstrukcjaWidget(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EE1D4),
                            foregroundColor: const Color(0xFF15766E),
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side:
                                  const BorderSide(color: Colors.white70),
                            ),
                          ),
                          child: Text(
                            AppTranslations.tr('info', lang),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tytuł ──
                Text(
                  AppTranslations.tr('calendar_title', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15998C),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Lista ──
                Expanded(
                  child: lista.isEmpty
                      ? const PustyWidget()
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: lista.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return Wiersz1Widget(
                              itemIndex: index,
                              itemData: lista[index],
                            );
                          },
                        ),
                ),

                // ── DOLNY PASEK: DODAJ DO LISTY ──
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 24.0, top: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.bottomGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (ctx) =>
                                const EdytorwierszaWidget(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF92F5ED),
                          foregroundColor: const Color(0xFF15766E),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          AppTranslations.tr('add_to_list', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15766E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Pomocniczy widget: ikonka w stylu przycisku
// ─────────────────────────────────────────────
class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF), // białe półprzezroczyste tło
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0x99FFFFFF), // białe obramowanie (60%)
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
