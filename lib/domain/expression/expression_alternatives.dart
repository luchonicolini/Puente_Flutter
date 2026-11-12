enum ExpressionIntent { consultation, clarification }

class ExpressionSuggestion {
  const ExpressionSuggestion({
    required this.label,
    required this.description,
    required this.text,
  });

  final String label;
  final String description;
  final String text;

  ExpressionSuggestion copyWith({String? text}) => ExpressionSuggestion(
    label: label,
    description: description,
    text: text ?? this.text,
  );
}

/// Alternativas locales y previsibles: no envían contenido ni deciden la
/// intención de la persona. El texto original permanece siempre disponible.
class ExpressionAlternatives {
  const ExpressionAlternatives._();

  static final RegExp _questionCue = RegExp(
    r'\b(?:cu[áa]nto|qu[ée]|c[óo]mo|d[óo]nde|cu[áa]ndo|cu[áa]l|tienen|hay|aceptan|puedo|se\s+puede|atienden|abren|cierran)\b',
    caseSensitive: false,
  );

  static final RegExp _uncertaintyCue = RegExp(
    r'\b(?:no\s+s[ée]|creo|capaz|tal\s+vez|depende|quiz[áa]s?)\b',
    caseSensitive: false,
  );

  static bool looksAmbiguous(String input) {
    final text = input.trim();
    if (text.isEmpty) return false;

    final hasQuestionMark = text.contains('?');
    if (!hasQuestionMark && _questionCue.hasMatch(text)) {
      return true;
    }

    return _uncertaintyCue.hasMatch(text);
  }

  static List<ExpressionSuggestion> generate(
    String input, {
    ExpressionIntent? intent,
  }) {
    final original = input.trim();
    if (original.isEmpty) return const [];

    final formatted = _formatByIntent(original, intent);
    final startsWithGreeting = RegExp(
      r'^(?:hola|buen\s+d[íi]a|buenas)\b',
      caseSensitive: false,
    ).hasMatch(formatted);

    final politeText = startsWithGreeting
        ? '$formatted\nMuchas gracias.'
        : 'Hola, ${_lowercaseFirst(formatted)}\nMuchas gracias.';

    final confirmationText =
        '$formatted\n\n¿Podés confirmarme por escrito si se entiende bien?';

    return [
      ExpressionSuggestion(
        label: intent == ExpressionIntent.consultation
            ? 'Como pregunta cordial'
            : 'Cordial para mostrador',
        description: 'Tono amable y claro para iniciar la atención',
        text: politeText,
      ),
      ExpressionSuggestion(
        label: 'Directa',
        description: 'Conserva tu texto claro y sin agregados',
        text: formatted,
      ),
      ExpressionSuggestion(
        label: 'Pedir confirmación',
        description: 'Invita a confirmar o responder por escrito',
        text: confirmationText,
      ),
    ];
  }

  static String _formatByIntent(String text, ExpressionIntent? intent) {
    if (intent == ExpressionIntent.consultation && !text.contains('?')) {
      final clean = text.replaceAll(RegExp(r'[.]+$'), '').trim();
      return '¿$clean?';
    }
    if (intent == ExpressionIntent.clarification && !text.contains('?')) {
      final clean = text.replaceAll(RegExp(r'[.]+$'), '').trim();
      return 'Quería aclarar esto: $clean.';
    }
    return text;
  }

  static String _lowercaseFirst(String text) {
    if (text.isEmpty) return text;
    if (text.startsWith('¿') && text.length > 1) {
      return '¿${text[1].toLowerCase()}${text.substring(2)}';
    }
    return '${text[0].toLowerCase()}${text.substring(1)}';
  }
}
