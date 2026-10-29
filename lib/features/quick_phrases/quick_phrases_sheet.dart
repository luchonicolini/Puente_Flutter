import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class QuickPhrasesSheet extends StatelessWidget {
  const QuickPhrasesSheet({
    super.key,
    required this.onPhraseSelected,
  });

  final ValueChanged<String> onPhraseSelected;

  static const List<String> phrases = <String>[
    'Hola, ¿cuánto cuesta esto?',
    '¿Tienen descuento en efectivo o transferencia?',
    '¿A qué hora cierran hoy?',
    'Muchas gracias, que tengas buen día.',
    'Necesito ayuda para encontrar un producto, por favor.',
    '¿Aceptan tarjeta de débito o Mercado Pago?',
  ];

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onPhraseSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickPhrasesSheet(onPhraseSelected: onPhraseSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
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
                const Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.primaryTeal,
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
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tocá una frase para mostrarla en pantalla grande al interlocutor:',
              style: AppTypography.secondary(textSecondary),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: phrases.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final phrase = phrases[index];
                  return Material(
                    color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPhraseSelected(phrase);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                phrase,
                                style: AppTypography.body(textPrimary),
                              ),
                            ),
                            const Icon(
                              Icons.fullscreen_rounded,
                              size: 20,
                              color: AppColors.primaryTeal,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
