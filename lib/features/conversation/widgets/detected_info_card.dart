import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/confirmation/data_comparison.dart';
import '../models/chat_message.dart';

/// Tarjeta contextual que resume importes, fechas u horarios detectados
/// en un mensaje del interlocutor para confirmar por escrito.
class DetectedInfoCard extends StatelessWidget {
  const DetectedInfoCard({
    super.key,
    required this.detectedInfo,
    required this.onTap,
  });

  final DetectedInfo detectedInfo;
  final VoidCallback onTap;

  IconData _leadingIcon() {
    if (detectedInfo.isConfirmed) return Icons.check_circle_rounded;
    final kinds = detectedInfo.itemKinds.values.toSet();
    if (kinds.contains(DataKind.amount)) return Icons.attach_money_rounded;
    if (kinds.contains(DataKind.date)) return Icons.event_outlined;
    if (kinds.contains(DataKind.time)) return Icons.schedule_rounded;
    return Icons.fact_check_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final isConfirmed = detectedInfo.isConfirmed;

    final warningColor = isDark
        ? AppColors.warningTextDark
        : AppColors.warningTextLight;
    final successColor = isDark ? AppColors.successTextDark : AppColors.success;
    final actionColor = isConfirmed
        ? successColor
        : (isDark ? AppColors.primaryTealOnDark : AppColors.primaryTealDark);

    final borderColor = isConfirmed
        ? successColor.withValues(alpha: 0.45)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final headerBackground = isConfirmed
        ? (isDark
              ? AppColors.surfaceMutedDark
              : AppColors.successLight.withValues(alpha: 0.55))
        : (isDark
              ? AppColors.surfaceMutedDark
              : AppColors.warningLight.withValues(alpha: 0.65));

    final cardBackground = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final sourceColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Semantics(
      button: true,
      label: isConfirmed
          ? '${detectedInfo.title}: dato escrito confirmado. Tocar para revisar.'
          : 'Información detectada en el mensaje de la otra persona, pendiente de confirmación escrita. Tocar para confirmar.',
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 2),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: headerBackground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            _leadingIcon(),
                            size: 18,
                            color: isConfirmed ? successColor : warningColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Text(
                                isConfirmed
                                    ? 'Información confirmada'
                                    : 'Información detectada',
                                style: AppTypography.secondary(
                                  isConfirmed ? successColor : textPrimary,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (!isConfirmed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.warningTextDark.withValues(
                                            alpha: 0.16,
                                          )
                                        : AppColors.surfaceLight.withValues(
                                            alpha: 0.9,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Sin confirmar',
                                    style: AppTypography.metadata(
                                      warningColor,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: borderColor.withValues(alpha: 0.7),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...detectedInfo.items.entries.map((entry) {
                          final itemConfirmed = detectedInfo.isKeyConfirmed(
                            entry.key,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: AppTypography.secondary(
                                      textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  flex: 3,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          entry.value,
                                          textAlign: TextAlign.end,
                                          style: AppTypography.body(textPrimary)
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      if (itemConfirmed && !isConfirmed) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 16,
                                          color: successColor,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 7),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5,
                            runSpacing: 2,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 16,
                                color: sourceColor,
                              ),
                              Text(
                                'Escrito por la otra persona',
                                style: AppTypography.metadata(sourceColor),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: borderColor.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isConfirmed
                                      ? 'Tocar para revisar'
                                      : 'Tocar para confirmar por escrito',
                                  style: AppTypography.secondary(
                                    actionColor,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: actionColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
