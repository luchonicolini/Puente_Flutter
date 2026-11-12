import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// Tipo de alerta para definir colores, contrastes e ícono por defecto.
enum AlertType {
  info,
  success,
  warning,
  error,
}

/// Modelo de datos para las alertas visuales superiores.
class TopAlertData {
  const TopAlertData({
    required this.message,
    this.type = AlertType.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 3),
  });

  final String message;
  final AlertType type;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
}

/// Componente visual de alerta superior tipo banner/píldora flotante.
/// Reemplaza el SnackBar inferior para evitar tapar los controles críticos
/// de la parte baja de la pantalla (como el micrófono, silenciador y compositor).
class TopAlertBanner extends StatelessWidget {
  const TopAlertBanner({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  final TopAlertData data;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;
    final Color iconColor;
    final IconData defaultIcon;

    switch (data.type) {
      case AlertType.info:
        backgroundColor = isDark ? const Color(0xFF132D33) : const Color(0xFFE5F4F5);
        borderColor = isDark ? const Color(0xFF1B5961) : const Color(0xFFBCE3E6);
        textColor = isDark ? const Color(0xFFC7EFF2) : const Color(0xFF095860);
        iconColor = isDark ? const Color(0xFF4AC2CD) : const Color(0xFF0D7E88);
        defaultIcon = Icons.info_outline_rounded;
        break;
      case AlertType.success:
        backgroundColor = isDark ? const Color(0xFF143021) : const Color(0xFFE8F6ED);
        borderColor = isDark ? const Color(0xFF1D5C3B) : const Color(0xFFBEE5CD);
        textColor = isDark ? const Color(0xFFB8ECCB) : const Color(0xFF155C35);
        iconColor = isDark ? const Color(0xFF34C759) : const Color(0xFF1C7A45);
        defaultIcon = Icons.check_circle_outline_rounded;
        break;
      case AlertType.warning:
        backgroundColor = isDark ? const Color(0xFF332712) : const Color(0xFFFFF7E6);
        borderColor = isDark ? const Color(0xFF6B4E15) : const Color(0xFFFDE1A6);
        textColor = isDark ? const Color(0xFFFFE7B3) : const Color(0xFF805300);
        iconColor = isDark ? const Color(0xFFFFB834) : const Color(0xFFB27300);
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case AlertType.error:
        backgroundColor = isDark ? const Color(0xFF381A1A) : const Color(0xFFFDE8E8);
        borderColor = isDark ? const Color(0xFF7A2424) : const Color(0xFFF5B5B5);
        textColor = isDark ? const Color(0xFFFFBABA) : const Color(0xFF9E1C1C);
        iconColor = isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC92A2A);
        defaultIcon = Icons.error_outline_rounded;
        break;
    }

    final effectiveIcon = data.icon ?? defaultIcon;

    return Semantics(
      liveRegion: true,
      label: 'Aviso: ${data.message}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(effectiveIcon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.message,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontFamilyFallback: AppTypography.fontFallback,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: textColor,
                  ),
                ),
              ),
              if (data.actionLabel != null && data.onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                    textStyle: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontFamilyFallback: AppTypography.fontFallback,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    data.onAction!();
                    onDismiss();
                  },
                  child: Text(data.actionLabel!),
                ),
              ],
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: textColor.withValues(alpha: 0.7),
                tooltip: 'Cerrar aviso',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                visualDensity: VisualDensity.compact,
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
