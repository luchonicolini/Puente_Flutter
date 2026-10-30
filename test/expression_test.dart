import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/features/expression/expression_screen.dart';

void main() {
  Widget createExpressionScreen({String? initialText}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ExpressionScreen(initialText: initialText),
    );
  }

  testWidgets('ExpressionScreen displays demo banner, preserves original text and generates context-aware variants',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createExpressionScreen(initialText: 'donde queda la farmacia'));
    await tester.pumpAndSettle();

    // 1. Banner de demostración UI explícito
    expect(find.text('Modo demostración (UI)'), findsOneWidget);
    expect(
      find.textContaining('El servicio de IA está en evaluación de privacidad'),
      findsOneWidget,
    );

    // 2. Preservación del texto original
    expect(find.text('Tu mensaje original se conserva siempre.'), findsOneWidget);
    expect(find.text('donde queda la farmacia'), findsOneWidget);
    expect(find.text('Usar mi texto original'), findsWidgets);

    // 3. Botón de generación rotulado transparentemente como Demo
    expect(find.text('Generar propuestas (Demo)'), findsOneWidget);

    // 4. Las variantes generadas corresponden al texto del usuario y NO al gimnasio
    expect(find.textContaining('gimnasio'), findsNothing);
    expect(find.textContaining('cuota mensual'), findsNothing);
    expect(find.textContaining('donde queda la farmacia'), findsWidgets);

    // 5. Cada tarjeta contiene el badge de "Propuesta simulada" y botón "Editar"
    expect(find.text('Propuesta simulada'), findsNWidgets(3));
    expect(find.text('Editar'), findsNWidgets(3));
  });

  testWidgets('ExpressionScreen provides gym example when gym context is explicitly present',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createExpressionScreen(initialText: 'Hola, quiero consultar la inscripción del gimnasio'),
    );
    await tester.pumpAndSettle();

    // En contexto de gimnasio, ofrece las alternativas pertinentes con el badge de demostración
    expect(find.textContaining('costo mensual y qué actividades incluye'), findsOneWidget);
    expect(find.text('Propuesta simulada'), findsNWidgets(3));
  });
}
