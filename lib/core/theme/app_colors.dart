import 'package:flutter/material.dart';

/// Paleta de colores aprobada para Puente según docs/DISENO_VISUAL.md
abstract final class AppColors {
  // Primario
  static const Color primaryTeal = Color(0xFF0D7E88);
  static const Color primaryTealDark = Color(0xFF095A62);
  static const Color primaryTealLight = Color(0xFFE6F4F5);
  static const Color primaryTealMuted = Color(0xFFCCE8EB);

  // Superficies e interfaces (Modo claro)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF7F9FA);
  static const Color surfaceMutedLight = Color(0xFFEFF3F5);

  // Superficies e interfaces (Modo oscuro)
  static const Color surfaceDark = Color(0xFF141E24);
  static const Color backgroundDark = Color(0xFF0D1418);
  static const Color surfaceMutedDark = Color(0xFF1B2830);

  // Textos modo claro
  static const Color textPrimaryLight = Color(0xFF102A38); // Azul marino muy oscuro
  static const Color textSecondaryLight = Color(0xFF536773); // Gris contrastado
  static const Color textMutedLight = Color(0xFF7A8D99);

  // Textos modo oscuro
  static const Color textPrimaryDark = Color(0xFFF0F5F8);
  static const Color textSecondaryDark = Color(0xFFA6BAC5);
  static const Color textMutedDark = Color(0xFF768B97);

  // Burbujas de conversación
  static const Color bubbleUserLight = Color(0xFFE2F3F5);
  static const Color bubbleUserDark = Color(0xFF104349);
  static const Color bubbleOtherLight = Color(0xFFF0F3F5);
  static const Color bubbleOtherDark = Color(0xFF202C33);

  // Estados semánticos
  static const Color warning = Color(0xFFD97706); // Ámbar / Pendiente de confirmar
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF0F766E); // Confirmado / Coincide
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFDC2626); // Discrepancia
  static const Color errorLight = Color(0xFFFEE2E2);

  // Bordes y divisores
  static const Color borderLight = Color(0xFFD9E2E7);
  static const Color borderDark = Color(0xFF263742);
}
