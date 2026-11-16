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
    final dotColor = effectiveIsDark
        ? AppColors.backgroundDark
        : const Color(0xFFF7F9FA);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: CustomPaint(
            size: Size.square(iconSize),
            painter: _PuenteBrandMarkPainter(dotColor: dotColor),
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
            color: effectiveIsDark
                ? AppColors.primaryTealOnDark
                : AppColors.primaryTealDark,
          ),
        ),
      ],
    );
  }
}

class _PuenteBrandMarkPainter extends CustomPainter {
  const _PuenteBrandMarkPainter({required this.dotColor});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    const markBounds = Rect.fromLTRB(150, 150, 874, 898);
    final scale = size.shortestSide / markBounds.height;
    final offset = Offset(
      (size.width - markBounds.width * scale) / 2,
      (size.height - markBounds.height * scale) / 2,
    );
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    canvas.translate(-markBounds.left, -markBounds.top);

    final bubble = Path()
      ..moveTo(512, 150)
      ..cubicTo(311, 150, 150, 297, 150, 478)
      ..cubicTo(150, 575, 197, 657, 273, 714)
      ..lineTo(240, 864)
      ..cubicTo(236, 884, 257, 898, 275, 888)
      ..lineTo(423, 806)
      ..cubicTo(452, 812, 482, 816, 512, 816)
      ..cubicTo(713, 816, 874, 669, 874, 488)
      ..cubicTo(874, 301, 713, 150, 512, 150)
      ..close();

    canvas.drawPath(
      bubble,
      Paint()
        ..color = AppColors.primaryTeal
        ..isAntiAlias = true,
    );
    final dotPaint = Paint()
      ..color = dotColor
      ..isAntiAlias = true;
    for (final x in const [414.0, 512.0, 610.0]) {
      canvas.drawCircle(Offset(x, 486), 38, dotPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PuenteBrandMarkPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor;
}
