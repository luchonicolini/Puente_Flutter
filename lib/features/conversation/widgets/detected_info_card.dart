import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/chat_message.dart';

class DetectedInfoCard extends StatelessWidget {
  const DetectedInfoCard({
    super.key,
    required this.detectedInfo,
    required this.onTap,
  });

  final DetectedInfo detectedInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : const Color(0xFF6B7D88);
    final isConfirmed = detectedInfo.isConfirmed;

    return Semantics(
      button: true,
      label: 'Información detectada: tocar para confirmar por escrito',
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceMutedDark : const Color(0xFFF9FBFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConfirmed
                ? AppColors.success
                : (isDark ? AppColors.borderDark : const Color(0xFFE2ECEE)),
            width: isConfirmed ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera: Ícono $ + "Información detectada" + flecha >
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isConfirmed ? AppColors.success : AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isConfirmed ? Icons.check_rounded : Icons.attach_money_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isConfirmed ? 'Información confirmada' : detectedInfo.title,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontFamilyFallback: AppTypography.fontFallback,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isConfirmed ? AppColors.success : textPrimary,
                          ),
                        ),
                      ),
                      if (!isConfirmed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sin confirmar',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontFamilyFallback: AppTypography.fontFallback,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isConfirmed ? AppColors.success : AppColors.primaryTeal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Lista de pares clave-valor
                  ...detectedInfo.items.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontFamilyFallback: AppTypography.fontFallback,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.value,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontFamilyFallback: AppTypography.fontFallback,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
