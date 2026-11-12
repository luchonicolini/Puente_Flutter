import 'package:shared_preferences/shared_preferences.dart';

abstract interface class QuickPhrasesStore {
  Future<List<String>> loadPhrases();
  Future<void> addPhrase(String phrase);
  Future<void> removePhrase(String phrase);
  Future<void> resetToDefaults();
}

class SharedPreferencesQuickPhrasesStore implements QuickPhrasesStore {
  SharedPreferencesQuickPhrasesStore({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;
  static const String _key = 'puente_custom_quick_phrases';

  static const List<String> defaultPhrases = <String>[
    'Hola, ¿cuánto cuesta esto?',
    '¿Tienen descuento en efectivo o transferencia?',
    '¿A qué hora cierran hoy?',
    'Muchas gracias, que tengas buen día.',
    'Necesito ayuda para encontrar un producto, por favor.',
    '¿Aceptan tarjeta de débito o Mercado Pago?',
  ];

  @override
  Future<List<String>> loadPhrases() async {
    final list = await _preferences.getStringList(_key);
    if (list == null || list.isEmpty) {
      return List<String>.from(defaultPhrases);
    }
    return list;
  }

  @override
  Future<void> addPhrase(String phrase) async {
    final trimmed = phrase.trim();
    if (trimmed.isEmpty) return;

    final current = await loadPhrases();
    if (!current.contains(trimmed)) {
      current.add(trimmed);
      await _preferences.setStringList(_key, current);
    }
  }

  @override
  Future<void> removePhrase(String phrase) async {
    final current = await loadPhrases();
    current.remove(phrase);
    await _preferences.setStringList(_key, current);
  }

  @override
  Future<void> resetToDefaults() async {
    await _preferences.remove(_key);
  }
}

class MockQuickPhrasesStore implements QuickPhrasesStore {
  MockQuickPhrasesStore({List<String>? initial})
      : phrases = List<String>.from(
          initial ?? SharedPreferencesQuickPhrasesStore.defaultPhrases,
        );

  final List<String> phrases;

  @override
  Future<List<String>> loadPhrases() async => List<String>.from(phrases);

  @override
  Future<void> addPhrase(String phrase) async {
    final trimmed = phrase.trim();
    if (trimmed.isEmpty) return;
    if (!phrases.contains(trimmed)) {
      phrases.add(trimmed);
    }
  }

  @override
  Future<void> removePhrase(String phrase) async {
    phrases.remove(phrase);
  }

  @override
  Future<void> resetToDefaults() async {
    phrases.clear();
    phrases.addAll(SharedPreferencesQuickPhrasesStore.defaultPhrases);
  }
}
