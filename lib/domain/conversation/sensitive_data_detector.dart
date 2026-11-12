import 'dart:math' as math;

import '../confirmation/data_comparison.dart';

class SensitiveDataDetection {
  const SensitiveDataDetection({required this.items, this.kinds = const {}});

  final Map<String, String> items;
  final Map<String, DataKind> kinds;
}

/// Detección local y determinista de importes, fechas y horarios para sugerir
/// confirmación escrita; nunca afirma certeza ni veracidad.
class SensitiveDataDetector {
  const SensitiveDataDetector._();

  /// Importes con símbolo o moneda explícita: `$35.000`, `ARS 35.000`.
  static final RegExp _currencyAmount = RegExp(
    r'(?:\$|ars)\s*\d+(?:[.,]\d+)*',
    caseSensitive: false,
  );

  /// Importes sin símbolo, pero con separador de miles o decimal:
  /// `35.000`, `1.234,56`, `35,00`.
  static final RegExp _bareAmount = RegExp(
    r'\b(?:\d{1,3}(?:\.\d{3})+(?:,\d{1,2})?|\d+,\d{2})\b',
  );

  /// Fechas numéricas (`3/5`, `03/05/2026`, `15-11-2026`) o en español (`15 de noviembre`).
  static final RegExp _datePattern = RegExp(
    r'\b(?:(?:0?[1-9]|[12]\d|3[01])[/\-](?:0?[1-9]|1[0-2])(?:[/\-](?:\d{4}|\d{2}))?|(?:0?[1-9]|[12]\d|3[01])\s+de\s+(?:enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre)(?:\s+(?:de|del)\s+(?:\d{4}|\d{2}))?)\b',
    caseSensitive: false,
  );

  /// Horarios (`9:41`, `14:30 hs`, `18 hs`).
  static final RegExp _timeWithMinutesPattern = RegExp(
    r'\b(?:[01]?\d|2[0-3]):[0-5]\d(?:\s*hs?\.?)?\b',
    caseSensitive: false,
  );

  static final RegExp _timeHoursOnlyPattern = RegExp(
    r'\b(?:[01]?\d|2[0-3])\s*hs\.?(?!\w)',
    caseSensitive: false,
  );

  /// Separadores de cláusula para evitar que la etiqueta de una parte de la
  /// frase invada el valor de otra (p. ej. inscripción vs. cuota).
  static final RegExp _clauseBoundary = RegExp(
    r'(?:\s+y\s+|\s+pero\s+|;\s*|,\s+|\.\s+|\n)',
    caseSensitive: false,
  );

  static final List<({RegExp pattern, String label})> _amountLabels = [
    (
      pattern: RegExp(r'inscrip[a-záéíóúüñ]*', caseSensitive: false),
      label: 'Inscripción',
    ),
    (
      pattern: RegExp(r'cuota\s+mensual', caseSensitive: false),
      label: 'Cuota mensual',
    ),
    (pattern: RegExp(r'\bcuota\b', caseSensitive: false), label: 'Cuota'),
    (pattern: RegExp(r'\btotal\b', caseSensitive: false), label: 'Total'),
    (pattern: RegExp(r'\bprecio\b', caseSensitive: false), label: 'Precio'),
    (pattern: RegExp(r'\bse[ñn]a\b', caseSensitive: false), label: 'Seña'),
    (pattern: RegExp(r'\banticipo\b', caseSensitive: false), label: 'Anticipo'),
    (pattern: RegExp(r'\bdescuento\b', caseSensitive: false), label: 'Descuento'),
    (
      pattern: RegExp(r'\bmatr[íi]cula\b', caseSensitive: false),
      label: 'Matrícula',
    ),
  ];

  static final List<({RegExp pattern, String label})> _dateLabels = [
    (
      pattern: RegExp(r'\bturno\b', caseSensitive: false),
      label: 'Fecha de turno',
    ),
    (
      pattern: RegExp(r'\bvenc[a-záéíóúüñ]*', caseSensitive: false),
      label: 'Vencimiento',
    ),
    (pattern: RegExp(r'\bentrega\b', caseSensitive: false), label: 'Entrega'),
    (pattern: RegExp(r'\binicio\b', caseSensitive: false), label: 'Inicio'),
  ];

  static final List<({RegExp pattern, String label})> _timeLabels = [
    (
      pattern: RegExp(r'\bapertura\b|\babre[a-záéíóúüñ]*', caseSensitive: false),
      label: 'Apertura',
    ),
    (
      pattern: RegExp(r'\bcierre\b|\bcierr[a-záéíóúüñ]*', caseSensitive: false),
      label: 'Cierre',
    ),
    (
      pattern: RegExp(r'\bturno\b', caseSensitive: false),
      label: 'Hora de turno',
    ),
    (pattern: RegExp(r'\bsalida\b', caseSensitive: false), label: 'Salida'),
  ];

  static SensitiveDataDetection? detect(String text) {
    final matches = <({RegExpMatch match, DataKind kind})>[];
    final ranges = <({int start, int end})>[];

    void collect(RegExp pattern, DataKind kind) {
      for (final match in pattern.allMatches(text)) {
        final overlaps = ranges.any(
          (range) => match.start < range.end && match.end > range.start,
        );
        if (!overlaps) {
          matches.add((match: match, kind: kind));
          ranges.add((start: match.start, end: match.end));
        }
      }
    }

    collect(_currencyAmount, DataKind.amount);
    collect(_datePattern, DataKind.date);
    collect(_timeWithMinutesPattern, DataKind.time);
    collect(_timeHoursOnlyPattern, DataKind.time);
    collect(_bareAmount, DataKind.amount);

    if (matches.isEmpty) return null;

    matches.sort((a, b) => a.match.start.compareTo(b.match.start));

    final items = <String, String>{};
    final kinds = <String, DataKind>{};
    for (final entry in matches) {
      final label = _labelFor(
        text,
        entry.match.start,
        entry.match.end,
        entry.kind,
      );
      final key = _uniqueKey(items, label);
      items[key] = entry.match.group(0)!.trim();
      kinds[key] = entry.kind;
    }

    return items.isEmpty
        ? null
        : SensitiveDataDetection(items: items, kinds: kinds);
  }

  /// Elige la etiqueta más cercana dentro de la misma cláusula y tipo de dato.
  static String _labelFor(
    String text,
    int start,
    int end,
    DataKind kind,
  ) {
    final labels = switch (kind) {
      DataKind.amount => _amountLabels,
      DataKind.date => _dateLabels,
      DataKind.time => _timeLabels,
      DataKind.text => const <({RegExp pattern, String label})>[],
    };
    final fallback = switch (kind) {
      DataKind.amount => 'Importe',
      DataKind.date => 'Fecha',
      DataKind.time => 'Horario',
      DataKind.text => 'Dato',
    };

    var windowStart = math.max(0, start - 70);
    var windowEnd = math.min(text.length, end + 70);

    for (final separator in _clauseBoundary.allMatches(text)) {
      if (separator.end <= start && separator.end > windowStart) {
        windowStart = separator.end;
      }
      if (separator.start >= end && separator.start < windowEnd) {
        windowEnd = separator.start;
      }
    }

    final window = text.substring(windowStart, windowEnd);

    String? bestLabel;
    int? bestDistance;
    int? bestLength;

    for (final entry in labels) {
      for (final match in entry.pattern.allMatches(window)) {
        final keywordStart = windowStart + match.start;
        final keywordEnd = windowStart + match.end;

        final distance = keywordEnd <= start
            ? start - keywordEnd
            : keywordStart >= end
            ? keywordStart - end
            : 0;
        final length = match.end - match.start;

        final isCloser =
            bestDistance == null ||
            distance < bestDistance ||
            (distance == bestDistance && length > (bestLength ?? 0));

        if (isCloser) {
          bestDistance = distance;
          bestLength = length;
          bestLabel = entry.label;
        }
      }
    }

    return bestLabel ?? fallback;
  }

  static String _uniqueKey(Map<String, String> items, String label) {
    if (!items.containsKey(label)) return label;

    var suffix = 2;
    var key = '$label $suffix';
    while (items.containsKey(key)) {
      suffix++;
      key = '$label $suffix';
    }
    return key;
  }
}
