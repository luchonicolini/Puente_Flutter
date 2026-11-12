import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/stt_service.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/core/widgets/not_understood_sheet.dart';
import 'package:puente/features/conversation/conversation_screen.dart';

import 'helpers/test_overrides.dart';

void main() {
  Widget createConversationScreen({
    List<Override> overrides = const [],
    ThemeData? theme,
    double textScale = 1.0,
  }) {
    return ProviderScope(
      overrides: [...createTestOverrides(), ...overrides],
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: const ConversationScreen(),
      ),
    );
  }

  testWidgets('ConversationScreen renders all components in initial empty state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    // 1. Cabecera
    expect(find.text('Conversación'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    // 2. Historial vacío sin datos demo precargados y accesos rápidos de inicio
    expect(
      find.textContaining('Hola, quiero saber cuánto cuesta la inscripción'),
      findsNothing,
    );
    expect(find.textContaining('La inscripción es de'), findsNothing);
    expect(find.text('Mostrar mi presentación'), findsOneWidget);
    expect(find.text('Elegir frase rápida'), findsOneWidget);
    expect(find.text('Escuchar al interlocutor'), findsOneWidget);

    // 3. Los tres accesos circulares rápidos
    expect(find.text('Presentarme'), findsOneWidget);
    expect(find.text('No entendí'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);

    // 4. Selector de turno y acceso para pasar el teléfono mientras no se escribe
    expect(find.text('Yo'), findsOneWidget);
    expect(find.text('La otra persona'), findsOneWidget);
    expect(find.text('Pasar para escribir'), findsOneWidget);

    // 5. Compositor de texto y botón de envío
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Escribí tu mensaje…'), findsOneWidget);

    // 6. Fila inferior de audio y micrófono
    expect(find.text('Tocá para hablar'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
  });

  testWidgets('Tapping No entendí opens NotUnderstoodSheet with 4 options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('No entendí'));
    await tester.pumpAndSettle();

    expect(find.byType(NotUnderstoodSheet), findsOneWidget);
    expect(find.text('¿Podés repetirlo?'), findsOneWidget);
    expect(find.text('¿Podés escribirlo?'), findsOneWidget);
    expect(find.text('¿Podés hablar más despacio?'), findsOneWidget);
    expect(find.text('¿Podés explicarlo de otra manera?'), findsOneWidget);
  });

  testWidgets('Tapping mic toggles listening state to Escuchando...', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    expect(find.text('Tocá para hablar'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Escuchando...'), findsOneWidget);
    expect(find.textContaining('Micrófono activo'), findsOneWidget);
  });

  testWidgets('El selector de turno permite escribir como la otra persona', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('La otra persona'));
    await tester.pump();

    expect(find.text('Escribí lo que dice la otra persona…'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'El total es \$12.345');
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('El total es \$12.345'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('Un mensaje propio no genera detección de datos', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'El total es \$12.345');
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Total'), findsNothing);
  });

  testWidgets('Silenciar el micrófono detiene la escucha', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Escuchando...'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.mic_off_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Micrófono silenciado'), findsOneWidget);
    expect(find.text('Escuchando...'), findsNothing);
  });

  testWidgets(
    'Sending a message animates new message bubble smoothly into view',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createConversationScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        '¿Tienen lockers disponibles?',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Desplazar la lista hacia abajo para asegurar visibilidad en pantalla
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('¿Tienen lockers disponibles?'), findsOneWidget);
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);
    },
  );

  testWidgets('Elegir frase rápida desde el estado vacío envía el mensaje', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Elegir frase rápida'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hola, ¿cuánto cuesta esto?'));
    await tester.pumpAndSettle();

    expect(find.text('Hola, ¿cuánto cuesta esto?'), findsOneWidget);
  });

  testWidgets(
    'Pasar para escribir registra mensaje del interlocutor y detecta horario',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createConversationScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pasar para escribir'));
      await tester.pumpAndSettle();

      expect(find.text('Escribí tu respuesta'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Abrimos a las 9:41');
      await tester.tap(find.text('Enviar respuesta'));
      await tester.pumpAndSettle();

      expect(find.text('Abrimos a las 9:41'), findsOneWidget);
      expect(find.text('Horario'), findsOneWidget);
      expect(find.text('9:41'), findsOneWidget);
    },
  );

  testWidgets(
    'Confirmar rápido permite pedir al interlocutor que escriba el dato',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createConversationScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar un dato'), findsOneWidget);
      await tester.tap(find.text('Pedirle que escriba el dato'));
      await tester.pumpAndSettle();

      expect(find.text('¿Podés escribir el dato acá?'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '35.000');
      await tester.tap(find.text('Confirmar y agregar'));
      await tester.pumpAndSettle();

      expect(find.text('Información confirmada'), findsOneWidget);
      expect(find.text('35.000'), findsOneWidget);
    },
  );

  testWidgets(
    'Las burbujas muestran participante visible y DetectedInfoCard indica acción',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createConversationScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        '¿Cuánto sale la consulta?',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.textContaining('Vos'), findsWidgets);

      await tester.tap(find.text('La otra persona'));
      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'La consulta sale \$15.000',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.textContaining('Otra persona'), findsWidgets);
      expect(find.text('Sin confirmar'), findsOneWidget);
      expect(find.text('Tocar para confirmar por escrito'), findsOneWidget);
    },
  );

  testWidgets(
    'Modo oscuro, pantalla pequeña y texto grande renderizan sin desbordamientos',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createConversationScreen(theme: AppTheme.darkTheme, textScale: 1.35),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.mic_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('La otra persona'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'El total es \$8.500');
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No entendí'), findsOneWidget);
      expect(find.text('Micrófono activo'), findsOneWidget);
    },
  );

  testWidgets(
    'Con teclado abierto se compacta el panel y No entendí sigue visible',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
      addTearDown(() {
        tester.view.resetViewInsets();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(createConversationScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tocá para hablar'), findsNothing);
      expect(find.byTooltip('Tocar para transcribir'), findsOneWidget);
      expect(find.text('Pasar para escribir'), findsOneWidget);

      await tester.tap(find.text('No entendí'));
      await tester.pumpAndSettle();
      expect(find.byType(NotUnderstoodSheet), findsOneWidget);
    },
  );

  testWidgets(
    'La tarjeta de transcripción pendiente permite revisar y agregar el mensaje',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockStt = MockSttService();
      await tester.pumpWidget(
        createConversationScreen(
          overrides: createTestOverrides(sttService: mockStt),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.mic_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      mockStt.emitTranscription('El total es \$2.000', isFinal: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Texto transcripto — sin confirmar'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
      expect(find.text('Agregar'), findsOneWidget);

      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      expect(find.text('El total es \$2.000'), findsOneWidget);
      expect(find.text('Sin confirmar'), findsOneWidget);
    },
  );
}
