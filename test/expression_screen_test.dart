import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/gemini_expression_assist_service.dart';
import 'package:puente/core/services/services_providers.dart';
import 'package:puente/core/storage/app_preferences_store.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/domain/expression/expression_alternatives.dart';
import 'package:puente/domain/expression/expression_assist.dart';
import 'package:puente/features/expression/expression_screen.dart';

import 'helpers/test_overrides.dart';

void main() {
  Widget createExpressionScreen({
    String? initialText,
    ThemeData? theme,
    double textScale = 1.0,
    bool useExpressionAi = false,
    ExpressionAssistService? assistService,
    ValueChanged<bool>? onUseExpressionAiChanged,
    ValueChanged<String?>? onResult,
  }) {
    return ProviderScope(
      overrides: [
        ...createTestOverrides(expressionAssistService: assistService),
        appPreferencesProvider.overrideWith(
          (ref) => AppPreferences(useExpressionAi: useExpressionAi),
        ),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute<String>(
                      builder: (_) => ExpressionScreen(
                        initialText: initialText,
                        onUseExpressionAiChanged: onUseExpressionAiChanged,
                      ),
                    ),
                  );
                  onResult?.call(result);
                },
                child: const Text('Abrir Expresar'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Preserva el texto original y permite usarlo sin cambios', (
    WidgetTester tester,
  ) async {
    String? returned;
    await tester.pumpWidget(
      createExpressionScreen(onResult: (v) => returned = v),
    );

    await tester.tap(find.text('Abrir Expresar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Necesito mi recibo');
    await tester.pump();

    await tester.tap(find.text('Usar mi texto original'));
    await tester.pumpAndSettle();

    expect(returned, 'Necesito mi recibo');
  });

  testWidgets(
    'Muestra aviso de ambigüedad, genera opciones locales y permite editar',
    (WidgetTester tester) async {
      String? returned;
      await tester.pumpWidget(
        createExpressionScreen(onResult: (v) => returned = v),
      );

      await tester.tap(find.text('Abrir Expresar'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'cuanto sale la cuota');
      await tester.pump();

      expect(
        find.text('Tu mensaje puede entenderse de más de una forma'),
        findsOneWidget,
      );
      await tester.tap(find.text('Hacer una consulta'));
      await tester.pump();

      await tester.tap(find.text('Ver opciones de redacción'));
      await tester.pumpAndSettle();

      expect(find.text('Alternativas'), findsOneWidget);
      expect(find.text('Como pregunta cordial'), findsOneWidget);

      await tester.ensureVisible(find.text('Editar').first);
      await tester.tap(find.text('Editar').first);
      await tester.pumpAndSettle();

      expect(find.text('Editar propuesta'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).last,
        'Buenos días, ¿cuál es el valor de la cuota?',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Usar propuesta seleccionada'));
      await tester.tap(find.text('Usar propuesta seleccionada'));
      await tester.pumpAndSettle();

      expect(returned, 'Buenos días, ¿cuál es el valor de la cuota?');
    },
  );

  testWidgets(
    'Modo oscuro en pantalla pequeña con ambigüedad y texto grande sin desbordamientos',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            builder: (context, child) {
              final data = MediaQuery.of(context);
              return MediaQuery(
                data: data.copyWith(textScaler: const TextScaler.linear(1.35)),
                child: child!,
              );
            },
            home: const ExpressionScreen(initialText: 'cuanto sale el horario'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Tu mensaje puede entenderse de más de una forma'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Ver opciones de redacción'));
      await tester.tap(find.text('Ver opciones de redacción'));
      await tester.pumpAndSettle();

      expect(find.text('Alternativas'), findsOneWidget);
    },
  );

  testWidgets('Pide consentimiento antes de llamar a la IA y guarda elección', (
    WidgetTester tester,
  ) async {
    final mockAi = MockExpressionAssistService();
    bool? persistedConsent;

    await tester.pumpWidget(
      createExpressionScreen(
        initialText: 'yo querer retirar el bolsa',
        assistService: mockAi,
        onUseExpressionAiChanged: (enabled) => persistedConsent = enabled,
      ),
    );
    await tester.tap(find.text('Abrir Expresar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pedir sugerencias a la IA'));
    await tester.pumpAndSettle();

    expect(find.text('Pedir ayuda a la IA'), findsOneWidget);
    expect(
      find.textContaining('servicio externo de inteligencia artificial'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(mockAi.callCount, 0);
    expect(persistedConsent, isNull);

    await tester.tap(find.text('Pedir sugerencias a la IA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Permitir y continuar'));
    await tester.pumpAndSettle();

    expect(persistedConsent, isTrue);
    expect(mockAi.callCount, 1);
    expect(find.text('Propuestas de la IA'), findsOneWidget);
    expect(
      find.text('Revisá los artículos sugeridos antes de usar.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Muestra interpretaciones ambiguas de la IA y aplica aclaración elegida',
    (WidgetTester tester) async {
      final mockAi = MockExpressionAssistService(
        onAssist: (text, intent, clarificationChoice) {
          if (clarificationChoice == null) {
            return const ExpressionAssistResult(
              originalText: 'yo necesitar el entrada 2',
              source: ExpressionAssistSource.ai,
              hasAmbiguity: true,
              ambiguityReason:
                  'No queda claro si te referís a "la entrada" o "las 2 entradas".',
              interpretations: [
                ExpressionInterpretationOption(
                  id: 'plural',
                  label: 'Dos entradas (las 2 entradas)',
                  description: 'Usa plural femenino',
                ),
                ExpressionInterpretationOption(
                  id: 'singular',
                  label: 'Una entrada (sector 2)',
                  description: 'Usa singular femenino',
                ),
              ],
              suggestions: [
                ExpressionSuggestion(
                  label: 'Redacción clara',
                  description: 'Opción tentativa',
                  text: 'Necesito las 2 entradas, por favor.',
                ),
              ],
            );
          }
          return const ExpressionAssistResult(
            originalText: 'yo necesitar el entrada 2',
            source: ExpressionAssistSource.ai,
            hasAmbiguity: false,
            suggestions: [
              ExpressionSuggestion(
                label: 'Redacción clara',
                description: 'Con aclaración aplicada',
                text: 'Hola, necesito las 2 entradas, por favor.',
              ),
            ],
          );
        },
      );

      await tester.pumpWidget(
        createExpressionScreen(
          initialText: 'yo necesitar el entrada 2',
          useExpressionAi: true,
          assistService: mockAi,
        ),
      );
      await tester.tap(find.text('Abrir Expresar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pedir sugerencias a la IA'));
      await tester.pumpAndSettle();

      expect(
        find.text('Tu mensaje admite más de una interpretación'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Dos entradas (las 2 entradas)'));
      await tester.tap(find.text('Dos entradas (las 2 entradas)'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Aplicar aclaración con IA'));
      await tester.tap(find.text('Aplicar aclaración con IA'));
      await tester.pumpAndSettle();

      expect(mockAi.callCount, 2);
      expect(mockAi.lastClarificationChoice, contains('Dos entradas'));
      expect(
        find.text('Hola, necesito las 2 entradas, por favor.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Ante error de red usa respaldo local sin bloquear a la persona',
    (WidgetTester tester) async {
      final mockAi = MockExpressionAssistService(
        errorToThrow: const ExpressionAssistException(
          'Sin conexión. Podés usar las opciones locales o tu texto original.',
        ),
      );

      await tester.pumpWidget(
        createExpressionScreen(
          initialText: 'necesito recibo',
          useExpressionAi: true,
          assistService: mockAi,
        ),
      );
      await tester.tap(find.text('Abrir Expresar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pedir sugerencias a la IA'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin conexión'), findsOneWidget);
      expect(find.text('Alternativas'), findsOneWidget);
      expect(find.text('Directa'), findsOneWidget);
    },
  );
}
