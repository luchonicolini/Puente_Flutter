import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DetectedInfoCard extends StatelessWidget {
  const DetectedInfoCard({
    super.key,
    required this.detectedValue,
    required this.isConfirmed,
    required this.onConfirmTap,
  });

  final String detectedValue;
  final bool isConfirmed;
  final VoidCallback onConfirmTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConfirmed
            ? (isDark ? AppColors.success.withValues(alpha: 0.15) : AppColors.successLight)
            : (isDark ? AppColors.warning.withValues(alpha: 0.15) : AppColors.warningLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed ? AppColors.success : AppColors.warning,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConfirmed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: 18,
                color: isConfirmed ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                isConfirmed ? 'Información confirmada' : 'Información detectada (Sin confirmar)',
                style: AppTypography.metadata(
                  isConfirmed ? AppColors.success : AppColors.warning,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Dato detectado: "$detectedValue"',
            style: AppTypography.sectionTitle(textPrimary).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Una transcripción no garantiza verdad. Verificalo por escrito.',
            style: AppTypography.metadata(textSecondary),
          ),
          if (!isConfirmed) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  backgroundColor: AppColors.primaryTeal,
                ),
                icon: const Icon(Icons.verified_outlined, size: 16),
                label: const Text('Confirmar dato'),
                onPressed: onConfirmTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
