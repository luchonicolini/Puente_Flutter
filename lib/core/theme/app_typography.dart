import 'package:flutter/material.dart';

/// Sistema tipográfico aprobado para Puente según docs/TIPOGRAFIA.md
/// Fuente base: Figtree con fallback al sistema operativo.
abstract final class AppTypography {
  static const String fontFamily = 'Figtree';
  static const List<String> fontFallback = <String>[
    '-apple-system',
    'BlinkMacSystemFont',
    'Roboto',
    'Segoe UI',
    'Helvetica Neue',
    'sans-serif',
  ];

  /// Hero / titular principal (28, 700)
  static TextStyle display(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      );

  /// Título de pantalla (22, 600)
  static TextStyle screenTitle(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  /// Título de secciones (18, 600)
  static TextStyle sectionTitle(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  /// Mensajes de conversación (18, 400)
  static TextStyle conversation(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  /// Texto general y formularios (16, 400)
  static TextStyle body(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  /// Acciones principales y botones (16, 600)
  static TextStyle button(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: color,
      );

  /// Ayudas, explicaciones y avisos (14, 400)
  static TextStyle secondary(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  /// Hora y metadatos no esenciales (12, 500)
  static TextStyle metadata(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: color,
      );

  /// Mostrar texto grande al interlocutor (36-48, 600-700)
  static TextStyle showMessage(Color color, {double fontSize = 40}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      );
}
