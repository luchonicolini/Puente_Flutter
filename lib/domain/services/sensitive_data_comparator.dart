import '../models/sensitive_data_item.dart';

/// Servicio de dominio para cotejar datos detectados contra datos escritos.
/// Aplica normalizaciones deterministas para monedas (ARS/USD, puntos, comas),
/// horarios (formato 24h, 12h, minutos) y fechas, aislando toda la lógica fuera de la UI.
///
/// Principio rector:
/// La coincidencia de texto no es verdad absoluta; solo indica coincidencia tipográfica.
class SensitiveDataComparator {
  const SensitiveDataComparator();

  ComparisonResult compare({
    required String detected,
    required String written,
    SensitiveDataCategory category = SensitiveDataCategory.other,
  }) {
    final cleanWritten = written.trim();
    if (cleanWritten.isEmpty) {
      return const ComparisonResult(
        status: ComparisonStatus.uncompared,
        normalizedDetected: '',
        normalizedWritten: '',
        note: 'Entrada escrita vacía.',
      );
    }

    final normDetected = _normalize(detected, category);
    final normWritten = _normalize(cleanWritten, category);

    final isMatch = normDetected.isNotEmpty && normDetected == normWritten;

    return ComparisonResult(
      status: isMatch ? ComparisonStatus.match : ComparisonStatus.mismatch,
      normalizedDetected: normDetected,
      normalizedWritten: normWritten,
      note: isMatch
          ? 'Coincidencia textual detectada. La persona usuaria debe confirmar la validez.'
          : 'Discrepancia entre el dato detectado y el escrito.',
    );
  }

  String _normalize(String input, SensitiveDataCategory category) {
    var text = input.trim().toLowerCase();

    switch (category) {
      case SensitiveDataCategory.price:
        // Quitar símbolos de moneda y términos comunes
        text = text.replaceAll(RegExp(r'[\$\s]|pesos|ars|usd'), '');
        // Si termina en decimales ceros redundantes (.00 o ,00), removerlos
        text = text.replaceAll(RegExp(r'([,\.]00)$'), '');
        // Quitar separadores de miles y puntos/comas
        text = text.replaceAll(RegExp(r'[\.,]'), '');
        return text;

      case SensitiveDataCategory.schedule:
        // Quitar sufijos horarios
        text = text.replaceAll(RegExp(r'\s*(hs|hrs|horas|h)\b'), '');
        text = text.replaceAll('.', ':');
        // Normalizar H:MM a HH:MM (ej: 9:00 a 09:00)
        final timeMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text.trim());
        if (timeMatch != null) {
          final hour = timeMatch.group(1)!.padLeft(2, '0');
          final min = timeMatch.group(2)!;
          return '$hour:$min';
        }
        return text.trim();

      case SensitiveDataCategory.date:
        // Normalizar separadores y conectores
        text = text.replaceAll('/', '-');
        text = text.replaceAll(RegExp(r'\s+de\s+'), '-');
        text = text.replaceAll(RegExp(r'\s+'), '');
        return text;

      case SensitiveDataCategory.quantity:
      case SensitiveDataCategory.address:
      case SensitiveDataCategory.other:
        // Normalización estándar sin puntuación excesiva
        return text.replaceAll(RegExp(r'[^\w\sáéíóúñ]'), '').replaceAll(RegExp(r'\s+'), ' ');
    }
  }
}
