import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/features/conversation/conversation_screen.dart';
import 'package:puente/features/expression/expression_screen.dart';
import 'package:puente/features/home/home_screen.dart';
import 'package:puente/features/settings/settings_screen.dart';
import 'package:puente/features/show_message/show_message_screen.dart';

void main() {
  Widget createHomeScreen() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }

  testWidgets('HomeScreen renders all elements matching the visual mockup',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // 1. Marca y ajustes en cabecera
    expect(find.text('Puente'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // 2. Titular y subtítulo
    expect(find.textContaining('Comunicarnos\nhace todo más fácil.'), findsOneWidget);
    expect(find.textContaining('Escribí, hablá o usá frases rápidas'), findsOneWidget);

    // 3. Tarjeta destacada Iniciar conversación
    expect(find.textContaining('Iniciar\nconversación'), findsOneWidget);
    expect(find.text('Escribí, hablá y escuchá'), findsOneWidget);

    // 4. Tres tarjetas secundarias verticales
    expect(find.text('Frases rápidas'), findsOneWidget);
    expect(find.text('Mensajes útiles para el día a día'), findsOneWidget);

    expect(find.text('Expresar'), findsOneWidget);
    expect(find.text('Te ayudamos a redactar tu mensaje'), findsOneWidget);

    expect(find.text('Comprar'), findsOneWidget);
    expect(find.text('Precios y confirmaciones'), findsOneWidget);

    // 5. Banner de presentación personal
    expect(
      find.textContaining('Podés mostrar un mensaje de presentación'),
      findsOneWidget,
    );
    expect(find.text('Ver ejemplo'), findsOneWidget);
  });

  testWidgets('Tapping Iniciar conversación opens ConversationScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Iniciar\nconversación'));
    await tester.pumpAndSettle();

    expect(find.byType(ConversationScreen), findsOneWidget);
  });

  testWidgets('Tapping Expresar opens ExpressionScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Expresar'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpressionScreen), findsOneWidget);
  });

  testWidgets('Tapping Ver ejemplo opens ShowMessageScreen with presentation',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver ejemplo'));
    await tester.pumpAndSettle();

    expect(find.byType(ShowMessageScreen), findsOneWidget);
    expect(find.textContaining('persona sorda'), findsOneWidget);
  });

  testWidgets('Tapping Settings icon opens SettingsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
