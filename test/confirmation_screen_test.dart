import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/features/confirmation/confirmation_screen.dart';

void main() {
  Widget createConfirmationScreen({
    String initialDetectedValue = '',
    String category = 'Importe',
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ConfirmationScreen(
        initialDetectedValue: initialDetectedValue,
        category: category,
      ),
    );
  }

  testWidgets('permite editar el dato detectado y compara importes por valor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      createConfirmationScreen(initialDetectedValue: r'$35.000'),
    );
    await tester.pumpAndSettle();

    expect(find.text(r'$35.000'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    // El primer campo es el dato detectado; se puede corregir.
    await tester.enterText(find.byType(TextField).at(0), '35000');
    await tester.enterText(find.byType(TextField).at(1), '35.000');

    await tester.ensureVisible(find.text('Comparar datos'));
    await tester.tap(find.text('Comparar datos'));
    await tester.pumpAndSettle();

    expect(find.text('Los datos coinciden'), findsOneWidget);
  });

  testWidgets('no declara coincidencia entre 3,5 y 35', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      createConfirmationScreen(initialDetectedValue: '3,5'),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '35');
    await tester.ensureVisible(find.text('Comparar datos'));
    await tester.tap(find.text('Comparar datos'));
    await tester.pumpAndSettle();

    expect(find.text('Los datos son diferentes'), findsOneWidget);
    expect(find.text('Los datos coinciden'), findsNothing);
  });

  testWidgets('cambiar el tipo de dato reinicia la comparación', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      createConfirmationScreen(
        initialDetectedValue: '3/5/2026',
        category: 'Fecha',
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '03/05/2026');
    await tester.ensureVisible(find.text('Comparar datos'));
    await tester.tap(find.text('Comparar datos'));
    await tester.pumpAndSettle();

    expect(find.text('Los datos coinciden'), findsOneWidget);

    await tester.ensureVisible(find.text('Horario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Horario'));
    await tester.pumpAndSettle();

    expect(find.text('Los datos coinciden'), findsNothing);
  });

  testWidgets('modo oscuro en pantalla pequeña con texto grande sin desbordamientos', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaler: const TextScaler.linear(1.35)),
            child: child!,
          );
        },
        home: const ConfirmationScreen(initialDetectedValue: '15.000'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '15000');
    await tester.ensureVisible(find.text('Comparar datos'));
    await tester.tap(find.text('Comparar datos'));
    await tester.pumpAndSettle();

    expect(find.text('Los datos coinciden'), findsOneWidget);
  });
}
