import 'expression_alternatives.dart';

/// Origen de las alternativas mostradas en Expresar.
enum ExpressionAssistSource { local, ai }

/// Interpretación concreta cuando la IA detecta ambigüedad de intención,
/// artículos, pronombres o número/género.
class ExpressionInterpretationOption {
  const ExpressionInterpretationOption({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

/// Contrato estructurado de sugerencias de redacción para Expresar.
class ExpressionAssistResult {
  const ExpressionAssistResult({
    required this.originalText,
    required this.source,
    required this.suggestions,
    this.hasAmbiguity = false,
    this.ambiguityReason = '',
    this.uncertaintyNote = '',
    this.interpretations = const [],
  });

  final String originalText;
  final ExpressionAssistSource source;
  final List<ExpressionSuggestion> suggestions;
  final bool hasAmbiguity;
  final String ambiguityReason;
  final String uncertaintyNote;
  final List<ExpressionInterpretationOption> interpretations;

  /// Genera el resultado local determinista sin salir del dispositivo.
  factory ExpressionAssistResult.local({
    required String input,
    ExpressionIntent? intent,
  }) {
    final trimmed = input.trim();
    return ExpressionAssistResult(
      originalText: trimmed,
      source: ExpressionAssistSource.local,
      suggestions: ExpressionAlternatives.generate(trimmed, intent: intent),
      hasAmbiguity: ExpressionAlternatives.looksAmbiguous(trimmed),
    );
  }

  /// Parsea y valida la respuesta JSON estructurada devuelta por el proxy IA.
  factory ExpressionAssistResult.fromAiJson({
    required String originalText,
    required Map<String, dynamic> json,
  }) {
    final rawSuggestions = json['suggestions'];
    if (rawSuggestions is! List) {
      throw const FormatException('La respuesta de IA no incluye propuestas.');
    }

    final suggestions = <ExpressionSuggestion>[];
    for (final item in rawSuggestions) {
      if (item is! Map) continue;
      final text = (item['text'] as String?)?.trim() ?? '';
      if (text.isEmpty) continue;
      final label = (item['label'] as String?)?.trim();
      final description = (item['description'] as String?)?.trim();
      suggestions.add(
        ExpressionSuggestion(
          label: (label != null && label.isNotEmpty)
              ? label
              : 'Propuesta clara',
          description: (description != null && description.isNotEmpty)
              ? description
              : 'Sugerencia generada con Gemini',
          text: text,
        ),
      );
    }

    if (suggestions.isEmpty) {
      throw const FormatException('La respuesta de IA vino sin propuestas.');
    }

    final rawInterpretations = json['interpretations'];
    final interpretations = <ExpressionInterpretationOption>[];
    if (rawInterpretations is List) {
      for (var i = 0; i < rawInterpretations.length; i++) {
        final item = rawInterpretations[i];
        if (item is! Map) continue;
        final label = (item['label'] as String?)?.trim() ?? '';
        if (label.isEmpty) continue;
        final id = (item['id'] as String?)?.trim();
        final description = (item['description'] as String?)?.trim() ?? '';
        interpretations.add(
          ExpressionInterpretationOption(
            id: (id != null && id.isNotEmpty) ? id : 'opt_${i + 1}',
            label: label,
            description: description,
          ),
        );
      }
    }

    final hasAmbiguity =
        json['has_ambiguity'] == true && interpretations.isNotEmpty;
    final ambiguityReason =
        (json['ambiguity_reason'] as String?)?.trim() ?? '';
    final uncertaintyNote =
        (json['uncertainty_note'] as String?)?.trim() ?? '';

    return ExpressionAssistResult(
      originalText: originalText.trim(),
      source: ExpressionAssistSource.ai,
      suggestions: suggestions,
      hasAmbiguity: hasAmbiguity,
      ambiguityReason: ambiguityReason,
      uncertaintyNote: uncertaintyNote,
      interpretations: interpretations,
    );
  }
}

/// Excepción controlada cuando falla la asistencia externa de Expresar.
class ExpressionAssistException implements Exception {
  const ExpressionAssistException(
    this.message, {
    this.isNotConfigured = false,
  });

  final String message;
  final bool isNotConfigured;

  @override
  String toString() => message;
}

/// Contrato desacoplado de red para sugerencias asistidas por IA.
abstract interface class ExpressionAssistService {
  Future<ExpressionAssistResult> assist({
    required String text,
    ExpressionIntent? intent,
    String? clarificationChoice,
  });
}
