import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/core/widgets/not_understood_sheet.dart';
import 'package:puente/features/conversation/conversation_screen.dart';

void main() {
  Widget createConversationScreen() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: const ConversationScreen(),
    );
  }

  testWidgets('ConversationScreen renders all components matching the approved mockup',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    // 1. Cabecera
    expect(find.text('Conversación'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    // 2. Historial de mensajes y timestamps del mockup
    expect(
      find.textContaining('Hola, quiero saber cuánto cuesta la inscripción'),
      findsOneWidget,
    );
    expect(
      find.textContaining('La inscripción es de \$20.000 y la cuota mensual cuesta \$35.000.'),
      findsOneWidget,
    );
    expect(find.text('9:41'), findsOneWidget);
    expect(find.text('9:42'), findsWidgets);

    // 3. Tarjeta de información detectada con resumen
    expect(find.text('Información detectada'), findsOneWidget);
    expect(find.text('Inscripción'), findsOneWidget);
    expect(find.text('\$20.000'), findsOneWidget);
    expect(find.text('Cuota mensual'), findsOneWidget);
    expect(find.text('\$35.000'), findsOneWidget);

    // 4. Los tres accesos circulares rápidos
    expect(find.text('Presentarme'), findsOneWidget);
    expect(find.text('No entendí'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);

    // 5. Compositor de texto y botón de envío
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Escribí tu mensaje…'), findsOneWidget);

    // 6. Fila inferior de audio y micrófono
    expect(find.text('Tocá para hablar'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
  });

  testWidgets('Tapping No entendí opens NotUnderstoodSheet with 4 options',
      (WidgetTester tester) async {
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

  testWidgets('Tapping mic toggles listening state to Escuchando...',
      (WidgetTester tester) async {
    await tester.pumpWidget(createConversationScreen());
    await tester.pumpAndSettle();

    expect(find.text('Tocá para hablar'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Escuchando...'), findsOneWidget);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
  });
}
