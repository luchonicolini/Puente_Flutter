/// Tipo de dato que se compara. La comparación de importes, fechas y horas
/// no se basa en igualdad de texto: interpreta el formato antes de decidir.
enum DataKind { amount, date, time, text }

/// Resultado de contrastar dos valores aportados por personas distintas.
/// Una coincidencia expresa equivalencia según el tipo elegido, no veracidad.
class DataComparisonResult {
  const DataComparisonResult({required this.matches, required this.kind});

  final bool matches;
  final DataKind kind;
}

class DataComparator {
  const DataComparator._();

  static DataComparisonResult compare({
    required String firstValue,
    required String secondValue,
    DataKind kind = DataKind.text,
  }) {
    final first = firstValue.trim();
    final second = secondValue.trim();

    if (first.isEmpty || second.isEmpty) {
      return DataComparisonResult(matches: false, kind: kind);
    }

    final matches = switch (kind) {
      DataKind.amount => _compareAmounts(first, second),
      DataKind.date => _compareDates(first, second),
      DataKind.time => _compareTimes(first, second),
      DataKind.text => _normalizeText(first) == _normalizeText(second),
    };

    return DataComparisonResult(matches: matches, kind: kind);
  }

  /// Compara importes en formato rioplatense e internacional.
  ///
  /// Casos que resuelve:
  /// - `$35.000` y `35.000` son el mismo importe.
  /// - `1.500` y `1500` son el mismo importe.
  /// - `3,5` y `35` **no** son el mismo importe.
  /// - `1.234,56` y `1234,56` son el mismo importe.
  static bool _compareAmounts(String first, String second) {
    final firstAmount = _parseAmount(first);
    final secondAmount = _parseAmount(second);

    if (firstAmount == null || secondAmount == null) {
      // Si alguno no es un importe reconocible, no arriesgamos una
      // coincidencia numérica: comparamos el texto de forma conservadora.
      return _normalizeText(first) == _normalizeText(second);
    }

    return (firstAmount - secondAmount).abs() < 0.005;
  }

  static double? _parseAmount(String input) {
    var text = input
        .toLowerCase()
        .replaceAll(RegExp(r'ars|pesos?|\$|\s'), '')
        .trim();

    if (text.isEmpty) return null;

    // Signo negativo opcional.
    final isNegative = text.startsWith('-');
    if (isNegative) text = text.substring(1);

    // Quedarse solo con dígitos y separadores.
    if (!RegExp(r'^[\d.,]+$').hasMatch(text)) return null;

    // Un punto final de oración no forma parte del importe.
    text = text.replaceAll(RegExp(r'[.,;:]+$'), '');
    if (text.isEmpty) return null;

    final hasComma = text.contains(',');
    final hasDot = text.contains('.');

    String normalized;
    if (hasComma && hasDot) {
      // El último separador es el decimal; el otro es de miles.
      final lastComma = text.lastIndexOf(',');
      final lastDot = text.lastIndexOf('.');
      normalized = lastComma > lastDot
          ? text.replaceAll('.', '').replaceAll(',', '.')
          : text.replaceAll(',', '');
    } else if (hasComma) {
      // En es-AR la coma es decimal. "1,500" se interpreta como 1,5.
      normalized = text.replaceAll(',', '.');
    } else if (hasDot) {
      final lastDot = text.lastIndexOf('.');
      final decimals = text.length - lastDot - 1;
      final dots = '.'.allMatches(text).length;

      if (dots > 1 || decimals == 3) {
        // "1.500" y "1.500.000" usan punto como separador de miles.
        normalized = text.replaceAll('.', '');
      } else {
        normalized = text;
      }
    } else {
      normalized = text;
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null) return null;
    return isNegative ? -parsed : parsed;
  }

  static bool _compareDates(String first, String second) {
    final firstDate = _parseDate(first);
    final secondDate = _parseDate(second);

    if (firstDate == null || secondDate == null) {
      return _normalizeText(first) == _normalizeText(second);
    }

    if (firstDate.day != secondDate.day ||
        firstDate.month != secondDate.month) {
      return false;
    }

    // Si ambas personas escribieron el año, debe coincidir. Si ninguna lo
    // escribió, alcanza con día y mes. Si solo una lo escribió, no asumimos.
    if (firstDate.year != null && secondDate.year != null) {
      return firstDate.year == secondDate.year;
    }
    return firstDate.year == null && secondDate.year == null;
  }

  static const Map<String, int> _months = {
    'enero': 1,
    'febrero': 2,
    'marzo': 3,
    'abril': 4,
    'mayo': 5,
    'junio': 6,
    'julio': 7,
    'agosto': 8,
    'septiembre': 9,
    'setiembre': 9,
    'octubre': 10,
    'noviembre': 11,
    'diciembre': 12,
  };

  static ({int day, int month, int? year})? _parseDate(String input) {
    final numericMatch = RegExp(
      r'(\d{1,2})[/\-.](\d{1,2})(?:[/\-.](\d{2,4}))?',
    ).firstMatch(input);
    if (numericMatch != null) {
      final day = int.tryParse(numericMatch.group(1)!);
      final month = int.tryParse(numericMatch.group(2)!);
      if (day == null || month == null || day < 1 || day > 31) return null;
      if (month < 1 || month > 12) return null;

      var year = numericMatch.group(3) == null
          ? null
          : int.tryParse(numericMatch.group(3)!);
      if (year != null && year < 100) year += 2000;

      return (day: day, month: month, year: year);
    }

    final textMatch = RegExp(
      r'\b(\d{1,2})\s+de\s+([a-záéíóú]+)(?:\s+(?:de|del)\s+(\d{2,4}))?\b',
      caseSensitive: false,
    ).firstMatch(input);
    if (textMatch == null) return null;

    final day = int.tryParse(textMatch.group(1)!);
    final monthName = textMatch.group(2)!.toLowerCase();
    final month = _months[monthName];
    if (day == null || month == null || day < 1 || day > 31) return null;

    var year = textMatch.group(3) == null
        ? null
        : int.tryParse(textMatch.group(3)!);
    if (year != null && year < 100) year += 2000;

    return (day: day, month: month, year: year);
  }

  static bool _compareTimes(String first, String second) {
    final firstTime = _parseTime(first);
    final secondTime = _parseTime(second);

    if (firstTime == null || secondTime == null) {
      return _normalizeText(first) == _normalizeText(second);
    }

    return firstTime.hour == secondTime.hour &&
        firstTime.minute == secondTime.minute;
  }

  static ({int hour, int minute})? _parseTime(String input) {
    final colonMatch = RegExp(r'(\d{1,2})[:.](\d{2})').firstMatch(input);
    if (colonMatch != null) {
      final hour = int.tryParse(colonMatch.group(1)!);
      final minute = int.tryParse(colonMatch.group(2)!);
      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      return (hour: hour, minute: minute);
    }

    final hsMatch = RegExp(
      r'\b(\d{1,2})\s*hs?\.?(?!\w)',
      caseSensitive: false,
    ).firstMatch(input);
    if (hsMatch == null) return null;

    final hour = int.tryParse(hsMatch.group(1)!);
    if (hour == null || hour < 0 || hour > 23) return null;
    return (hour: hour, minute: 0);
  }

  /// Normalización conservadora para texto: no elimina separadores ni
  /// símbolos, para no convertir valores distintos en una falsa coincidencia.
  static String _normalizeText(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
