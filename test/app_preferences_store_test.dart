import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/storage/app_preferences_store.dart';

void main() {
  group('AppPreferences & InMemoryAppPreferencesStore', () {
    test('effectivePresentationText vuelve al predeterminado si está vacío', () {
      const custom = AppPreferences(
        presentationText: 'Hola, prefiero leer mensajes escritos.',
      );
      expect(
        custom.effectivePresentationText,
        'Hola, prefiero leer mensajes escritos.',
      );

      const blank = AppPreferences(presentationText: '   ');
      expect(
        blank.effectivePresentationText,
        AppPreferences.defaultPresentationText,
      );
    });

    test('InMemoryAppPreferencesStore guarda y limpia preferencias locales', () async {
      final store = InMemoryAppPreferencesStore();
      final initial = await store.load();
      expect(
        initial.effectivePresentationText,
        AppPreferences.defaultPresentationText,
      );

      const updated = AppPreferences(
        themeMode: ThemeMode.dark,
        textScale: 1.15,
        readMessages: false,
        speechRate: 0.65,
        vibrateAtEnd: false,
        useExpressionAi: true,
        presentationText: 'Hola, tengo hipoacusia. Podemos escribir aquí.',
      );
      await store.save(updated);

      final loaded = await store.load();
      expect(loaded, updated);
      expect(
        loaded.effectivePresentationText,
        'Hola, tengo hipoacusia. Podemos escribir aquí.',
      );

      await store.clear();
      expect(await store.load(), const AppPreferences());
    });
  });
}
