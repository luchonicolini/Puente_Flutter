import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/features/confirmation/confirmation_screen.dart';

void main() {
  Widget createConfirmationScreen({
    required String detectedValue,
    String category = 'Importe',
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: ConfirmationScreen(
        initialDetectedValue: detectedValue,
        category: category,
      ),
    );
  }

  testWidgets('ConfirmationScreen compares matching value and shows success', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createConfirmationScreen(detectedValue: r'$18.000'));
    await tester.pump();

    expect(find.text('Confirmar información'), findsOneWidget);
    expect(find.text(r'$18.000'), findsOneWidget);

    // Escribir el valor ingresado por la otra persona (ej. 18000)
    await tester.enterText(find.byType(TextField), '18000');
    await tester.pump();

    // Pulsar comparar
    await tester.tap(find.text('Comparar datos'));
    await tester.pump();

    expect(find.text('Los datos coinciden'), findsOneWidget);
    expect(find.text('Confirmar y regresar a la conversación'), findsOneWidget);
    expect(
      find.text('Aviso importante: Que los textos coincidan no certifica que el importe sea justo ni obligatorio.'),
      findsOneWidget,
    );
  });

  testWidgets('ConfirmationScreen compares mismatching value and shows warning', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createConfirmationScreen(detectedValue: r'$18.000'));
    await tester.pump();

    // Escribir un valor erróneo
    await tester.enterText(find.byType(TextField), '15000');
    await tester.pump();

    // Pulsar comparar
    await tester.tap(find.text('Comparar datos'));
    await tester.pump();

    expect(find.text('Los datos son diferentes'), findsOneWidget);
    expect(find.text('Confirmar y regresar a la conversación'), findsNothing);
  });
}
