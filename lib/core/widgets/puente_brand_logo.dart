import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PuenteBrandLogo extends StatelessWidget {
  const PuenteBrandLogo({
    super.key,
    this.fontSize = 22,
    this.iconSize = 30,
    this.isDark,
  });

  final double fontSize;
  final double iconSize;
  final bool? isDark;

  @override
  Widget build(BuildContext context) {
    final effectiveIsDark = isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final dotSize = iconSize * (10 / 30);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícono característico de Puente: globo de diálogo con corte circular
        Container(
          width: iconSize,
          height: iconSize,
          decoration: const BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Center(
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: effectiveIsDark ? AppColors.backgroundDark : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Puente',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontFamilyFallback: AppTypography.fontFallback,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTeal,
          ),
        ),
      ],
    );
  }
}
