import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lista_item.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/custom_functions.dart';
import '../utils/translations.dart';
import 'custom_cupertino_picker.dart';
import 'pionowy_przelacznik.dart';

class EdytorwierszaWidget extends StatefulWidget {
  const EdytorwierszaWidget({
    super.key,
    this.initialItem,
    this.editIndex = -1,
  });

  final ListaItem? initialItem;
  final int editIndex;

  @override
  State<EdytorwierszaWidget> createState() => _EdytorwierszaWidgetState();
}

class _EdytorwierszaWidgetState extends State<EdytorwierszaWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _selectedDate;
  late bool _czyPokazacRok;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;

    if (item != null) {
      _nameController = TextEditingController(text: item.tekst);
      _czyPokazacRok = item.czyRokWidoczny;
      _selectedDate = item.datazapisz ?? DateTime.now();
    } else {
      _nameController = TextEditingController(text: '');
      _czyPokazacRok = false;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.wybranyJezyk;
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: topPadding,
      ),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: size.width * 0.95,
            height: size.height * 0.58,
            decoration: BoxDecoration(
              color: Colors.white,
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _CloseButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.88,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppTheme.primary, width: 2),
                  ),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _nameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText:
                                AppTranslations.tr('enter_name', lang),
                            hintStyle: const TextStyle(
                              color: Color(0xFF8B97A2),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF25D2C0),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF25D2C0),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppTranslations.tr(
                                  'enter_name', lang);
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF25D2C0),
                              width: 2),
                        ),
                        child: Row(
                          children: [
                            Text(
                              DateFormat("d MMMM", lang)
                                  .format(_selectedDate),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF15766E)),
                            ),
                            if (_czyPokazacRok) ...[
                              const SizedBox(width: 8),
                              Text(
                                "${_selectedDate.year}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF15766E)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: size.width * 0.84,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.70,
                        child: CustomCupertinoPicker(
                          initialDate: _selectedDate,
                          showYear: _czyPokazacRok,
                          languageCode: lang,
                          textColor: const Color(0xFF2C3E50),
                          onDateChanged: (newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppTranslations.tr('year_label', lang),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF138378)),
                          ),
                          const SizedBox(height: 6),
                          PionowyPrzelacznik(
                            width: 44,
                            height: 84,
                            initialValue: _czyPokazacRok,
                            activeColor: AppTheme.primary,
                            inactiveColor: const Color(0xFFB3BAC6),
                            onChanged: () {
                              setState(() {
                                _czyPokazacRok = !_czyPokazacRok;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SizedBox(
                    width: size.width * 0.28,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        final name = _nameController.text.trim();

                        final isDuplicate =
                            CustomFunctions.czyIstniejeDuplikatV3(
                          state.urodzinyList,
                          name,
                          _selectedDate,
                          widget.editIndex,
                        );

                        if (isDuplicate) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              content: Text(AppTranslations.tr(
                                  'duplicate_entry', lang)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(
                                      AppTranslations.tr('ok', lang)),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        final finalDate = _czyPokazacRok
                            ? _selectedDate
                            : CustomFunctions.ustawRok1900(
                                _selectedDate);

                        try {
                          if (widget.editIndex >= 0 &&
                              widget.initialItem != null) {
                            final updated =
                                widget.initialItem!.copyWith(
                              tekst: name,
                              datazapisz: finalDate,
                              czyRokWidoczny: _czyPokazacRok,
                            );
                            await state.updateUrodziny(
                                widget.editIndex, updated);
                          } else {
                            final newItem = ListaItem(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch,
                              tekst: name,
                              datazapisz: finalDate,
                              czyRokWidoczny: _czyPokazacRok,
                              czyPowiadamiac: true,
                            );
                            await state.addUrodziny(newItem);
                          }
                        } catch (_) {}

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppTranslations.tr('ok', lang),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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
//  Ujednolicony przycisk zamykania (X)
// ─────────────────────────────────────────────
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 26),
      ),
    );
  }
}
