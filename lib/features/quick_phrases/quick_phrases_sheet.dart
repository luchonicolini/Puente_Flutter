import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/services_providers.dart';
import '../../core/storage/quick_phrases_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/text_edit_dialog.dart';

class QuickPhrasesSheet extends ConsumerStatefulWidget {
  const QuickPhrasesSheet({
    super.key,
    this.onPhraseSelected,
    this.store,
    this.showResetOption = false,
  });

  final ValueChanged<String>? onPhraseSelected;
  final QuickPhrasesStore? store;
  final bool showResetOption;

  static const List<String> defaultPhrases =
      SharedPreferencesQuickPhrasesStore.defaultPhrases;

  static Future<void> show(
    BuildContext context, {
    ValueChanged<String>? onPhraseSelected,
    QuickPhrasesStore? store,
    bool showResetOption = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickPhrasesSheet(
        onPhraseSelected: onPhraseSelected,
        store: store,
        showResetOption: showResetOption,
      ),
    );
  }

  @override
  ConsumerState<QuickPhrasesSheet> createState() => _QuickPhrasesSheetState();
}

class _QuickPhrasesSheetState extends ConsumerState<QuickPhrasesSheet> {
  late QuickPhrasesStore _store;
  List<String> _phrases = <String>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    try {
      _store = widget.store ?? ref.read(quickPhrasesStoreProvider);
    } catch (_) {
      _store = widget.store ?? MockQuickPhrasesStore();
    }
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    final list = await _store.loadPhrases();
    if (mounted) {
      setState(() {
        _phrases = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddPhraseDialog() async {
    final newPhrase = await TextEditDialog.show(
      context,
      title: 'Nueva frase rápida',
      confirmLabel: 'Guardar',
      hintText: 'Ej: ¿Tenés factura A?',
      minLines: 1,
      maxLines: 3,
      requireNonEmpty: true,
    );

    if (newPhrase != null && newPhrase.isNotEmpty && mounted) {
      await _store.addPhrase(newPhrase);
      try {
        ref.read(hapticServiceProvider).vibrateSuccess();
      } catch (_) {}
      await _loadPhrases();
    }
  }

  Future<void> _deletePhrase(String phrase) async {
    await _store.removePhrase(phrase);
    try {
      ref.read(hapticServiceProvider).vibrateSuccess();
    } catch (_) {}
    await _loadPhrases();
  }

  Future<void> _resetToDefaults() async {
    await _store.resetToDefaults();
    try {
      ref.read(hapticServiceProvider).vibrateSuccess();
    } catch (_) {}
    await _loadPhrases();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTeal;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.flash_on_rounded,
                    color: accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Frases rápidas',
                      style: AppTypography.screenTitle(textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    tooltip: 'Agregar nueva frase',
                    color: accentColor,
                    onPressed: _showAddPhraseDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.onPhraseSelected != null
                    ? 'Tocá una frase para mostrarla en pantalla grande o agregá las tuyas:'
                    : 'Agregá, eliminá o restaurá tus frases rápidas guardadas en este dispositivo:',
                style: AppTypography.secondary(textSecondary),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _phrases.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final phrase = _phrases[index];
                      return Material(
                        color: isDark
                            ? AppColors.surfaceMutedDark
                            : AppColors.surfaceMutedLight,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: widget.onPhraseSelected == null
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  widget.onPhraseSelected!(phrase);
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    phrase,
                                    style: AppTypography.body(textPrimary),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                  ),
                                  tooltip: 'Eliminar frase',
                                  color: textSecondary,
                                  onPressed: () => _deletePhrase(phrase),
                                ),
                                if (widget.onPhraseSelected != null) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.fullscreen_rounded,
                                    size: 20,
                                    color: accentColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            if (widget.showResetOption && !_isLoading) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Restaurar predeterminadas'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}
