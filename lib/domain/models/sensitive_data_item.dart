import 'package:flutter/foundation.dart';

/// Categorías de datos críticos o sensibles que requieren confirmación explícita según docs/PRODUCTO.md y AGENTS.md.
enum SensitiveDataCategory {
  price('Importe'),
  schedule('Horario'),
  date('Fecha'),
  quantity('Cantidad'),
  address('Dirección'),
  other('Otro');

  const SensitiveDataCategory(this.displayName);
  final String displayName;

  static SensitiveDataCategory fromString(String value) {
    final lower = value.trim().toLowerCase();
    switch (lower) {
      case 'importe':
      case 'precio':
      case 'price':
        return SensitiveDataCategory.price;
      case 'horario':
      case 'hora':
      case 'schedule':
        return SensitiveDataCategory.schedule;
      case 'fecha':
      case 'date':
        return SensitiveDataCategory.date;
      case 'cantidad':
      case 'quantity':
        return SensitiveDataCategory.quantity;
      case 'dirección':
      case 'direccion':
      case 'address':
        return SensitiveDataCategory.address;
      default:
        return SensitiveDataCategory.other;
    }
  }
}

/// Estado del cotejo entre transcripción y entrada escrita.
enum ComparisonStatus {
  uncompared,
  match,
  mismatch,
}

/// Resultado inmutable del cotejo entre transcripción y entrada escrita.
/// Regla innegociable de Puente:
/// Un `match` verifica equivalencia textual, pero jamás garantiza veracidad
/// ni validez legal/comercial sin confirmación explícita de la persona usuaria.
@immutable
class ComparisonResult {
  const ComparisonResult({
    required this.status,
    required this.normalizedDetected,
    required this.normalizedWritten,
    this.note,
  });

  final ComparisonStatus status;
  final String normalizedDetected;
  final String normalizedWritten;
  final String? note;

  bool get isMatch => status == ComparisonStatus.match;
  bool get isMismatch => status == ComparisonStatus.mismatch;
  bool get isUncompared => status == ComparisonStatus.uncompared;
}

/// Entidad pura de dominio que representa un dato detectado sujeto a confirmación.
@immutable
class SensitiveDataItem {
  const SensitiveDataItem({
    required this.id,
    required this.category,
    required this.detectedValue,
    this.label,
    this.writtenConfirmation,
    this.isConfirmed = false,
    this.comparisonResult,
  });

  final String id;
  final SensitiveDataCategory category;
  final String detectedValue;
  final String? label;
  final String? writtenConfirmation;
  final bool isConfirmed;
  final ComparisonResult? comparisonResult;

  SensitiveDataItem copyWith({
    String? id,
    SensitiveDataCategory? category,
    String? detectedValue,
    String? label,
    String? writtenConfirmation,
    bool? isConfirmed,
    ComparisonResult? comparisonResult,
  }) {
    return SensitiveDataItem(
      id: id ?? this.id,
      category: category ?? this.category,
      detectedValue: detectedValue ?? this.detectedValue,
      label: label ?? this.label,
      writtenConfirmation: writtenConfirmation ?? this.writtenConfirmation,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      comparisonResult: comparisonResult ?? this.comparisonResult,
    );
  }
}
