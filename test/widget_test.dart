import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/features/home/home_screen.dart';
import 'package:puente/main.dart';

void main() {
  testWidgets('PuenteApp renders HomeScreen with title and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const PuenteApp());

    // Verifica que el título "Puente" y el slogan estén presentes
    expect(find.text('Puente'), findsOneWidget);
    expect(find.textContaining('Tu independencia'), findsOneWidget);

    // Verifica que el botón de Iniciar conversación esté disponible
    expect(find.text('Iniciar conversación'), findsOneWidget);

    // Verifica que los accesos secundarios estén disponibles
    expect(find.text('Frases rápidas'), findsOneWidget);
    expect(find.text('Expresar'), findsOneWidget);

    // Verifica el acceso de un toque a Presentarme
    expect(find.text('Presentarme con un toque'), findsOneWidget);
  });
}
