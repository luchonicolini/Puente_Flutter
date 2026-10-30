import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/features/home/home_screen.dart';
import 'package:puente/main.dart';

void main() {
  testWidgets('PuenteApp renders HomeScreen with title and CTA by default',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PuenteApp());
    await tester.pumpAndSettle();

    // Verifica que HomeScreen se haya montado
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verifica la marca y el titular
    expect(find.text('Puente'), findsOneWidget);
    expect(find.textContaining('Comunicarnos'), findsOneWidget);

    // Verifica el CTA principal
    expect(find.textContaining('Iniciar\nconversación'), findsOneWidget);

    // Verifica los accesos secundarios
    expect(find.text('Frases rápidas'), findsOneWidget);
    expect(find.text('Expresar'), findsOneWidget);

    // Verifica el banner de presentación
    expect(find.text('Ver ejemplo'), findsOneWidget);
  });
}
