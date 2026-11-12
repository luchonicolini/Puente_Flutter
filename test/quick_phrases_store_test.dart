import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/storage/quick_phrases_store.dart';

void main() {
  group('QuickPhrasesStore Tests', () {
    late MockQuickPhrasesStore store;

    setUp(() {
      store = MockQuickPhrasesStore();
    });

    test('Loads default phrases on start', () async {
      final phrases = await store.loadPhrases();
      expect(phrases.isNotEmpty, isTrue);
      expect(phrases, contains('Hola, ¿cuánto cuesta esto?'));
    });

    test('Adds custom phrase successfully', () async {
      await store.addPhrase('¿Tenés factura A?');

      final updated = await store.loadPhrases();
      expect(updated, contains('¿Tenés factura A?'));
    });

    test('Does not add empty or duplicate phrase', () async {
      final initialCount = (await store.loadPhrases()).length;

      await store.addPhrase('   ');
      expect((await store.loadPhrases()).length, initialCount);

      await store.addPhrase('Hola, ¿cuánto cuesta esto?');
      expect((await store.loadPhrases()).length, initialCount);
    });

    test('Removes phrase correctly', () async {
      await store.addPhrase('Frase para borrar');
      expect(await store.loadPhrases(), contains('Frase para borrar'));

      await store.removePhrase('Frase para borrar');
      expect(await store.loadPhrases(), isNot(contains('Frase para borrar')));
    });

    test('Resets phrases to default list', () async {
      await store.addPhrase('Frase extra');
      await store.removePhrase('Hola, ¿cuánto cuesta esto?');

      await store.resetToDefaults();
      final resetList = await store.loadPhrases();
      expect(resetList, contains('Hola, ¿cuánto cuesta esto?'));
      expect(resetList, isNot(contains('Frase extra')));
    });
  });
}
