import '../models/sensitive_data_item.dart';

/// Servicio de dominio para extraer datos sensibles (precios, horarios, fechas)
/// a partir de texto transcripto o mensajes en conversación.
/// Utiliza expresiones regulares atómicas y seguras contra ReDoS (Catastrophic Backtracking).
class SensitiveDataDetector {
  const SensitiveDataDetector();

  /// Detecta entidades sensibles en un texto dado de manera determinista y rápida.
  List<SensitiveDataItem> extract(String text) {
    if (text.trim().isEmpty) return const [];

    final results = <SensitiveDataItem>[];

    // 1. Detección de importes con símbolo $ (ej: $5.000, $ 18.000)
    final prefixPriceRegex = RegExp(r'\$\s*(\d+(?:[\.,]\d+)*)');
    for (final match in prefixPriceRegex.allMatches(text)) {
      final val = match.group(0)!.trim();
      results.add(
        SensitiveDataItem(
          id: 'price_${match.start}',
          category: SensitiveDataCategory.price,
          detectedValue: val,
          label: 'Importe',
        ),
      );
    }

    // 2. Detección de importes con sufijo monetario (ej: 2500 pesos, 100 usd, 500 ars)
    final suffixPriceRegex = RegExp(
      r'\b(\d+(?:[\.,]\d+)*)\s*(?:pesos|ars|usd)\b',
      caseSensitive: false,
    );
    for (final match in suffixPriceRegex.allMatches(text)) {
      final val = match.group(0)!.trim();
      results.add(
        SensitiveDataItem(
          id: 'price_${match.start}',
          category: SensitiveDataCategory.price,
          detectedValue: val,
          label: 'Importe',
        ),
      );
    }

    // 3. Detección de horarios (ej: 18:30 hs, 9:00, 10.30 hs)
    final scheduleRegex = RegExp(
      r'\b([01]?\d|2[0-3])[:.]([0-5]\d)(?:\s*(?:hs|hrs|horas))?\b',
      caseSensitive: false,
    );
    for (final match in scheduleRegex.allMatches(text)) {
      final val = match.group(0)!.trim();
      results.add(
        SensitiveDataItem(
          id: 'schedule_${match.start}',
          category: SensitiveDataCategory.schedule,
          detectedValue: val,
          label: 'Horario',
        ),
      );
    }

    // 4. Detección de fechas (ej: 15 de noviembre, 20/11/2026, 05/11)
    final dateRegex = RegExp(
      r'\b(\d{1,2}\s+de\s+[a-záéíóúñ]+|\d{1,2}[/-]\d{1,2}(?:[/-]\d{2,4})?)\b',
      caseSensitive: false,
    );
    for (final match in dateRegex.allMatches(text)) {
      final val = match.group(0)!.trim();
      results.add(
        SensitiveDataItem(
          id: 'date_${match.start}',
          category: SensitiveDataCategory.date,
          detectedValue: val,
          label: 'Fecha',
        ),
      );
    }

    return results;
  }
}
