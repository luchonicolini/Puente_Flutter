import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Modal accesible para el botón permanente «No entendí».
/// Ofrece las 4 opciones sin conexión requeridas por docs/FUNCIONALIDADES.md
class NotUnderstoodSheet extends StatelessWidget {
  const NotUnderstoodSheet({
    super.key,
    required this.onOptionSelected,
  });

  final ValueChanged<String> onOptionSelected;

  static const List<String> options = <String>[
    '¿Podés repetirlo?',
    '¿Podés escribirlo?',
    '¿Podés hablar más despacio?',
    '¿Podés explicarlo de otra manera?',
  ];

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onOptionSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotUnderstoodSheet(onOptionSelected: onOptionSelected),
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
                Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primaryTeal,
                  size: 26,
                  semanticLabel: 'Ayuda de comprensión',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No entendí',
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
              'Elegí qué pedirle a la otra persona:',
              style: AppTypography.secondary(textSecondary),
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Semantics(
                  button: true,
                  label: 'Pedir: $option',
                  child: Material(
                    color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).pop();
                        onOptionSelected(option);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: AppTypography.sectionTitle(textPrimary),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppColors.primaryTeal,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
