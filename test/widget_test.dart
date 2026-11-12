import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/storage/app_preferences_store.dart';
import 'package:puente/core/storage/onboarding_store.dart';
import 'package:puente/main.dart';

import 'helpers/test_overrides.dart';

void main() {
  testWidgets('PuenteApp renders HomeScreen with title and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      PuenteApp(
        onboardingStore: InMemoryOnboardingStore(initialCompleted: true),
        preferencesStore: InMemoryAppPreferencesStore(),
        overrides: createTestOverrides(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifica que el título "Puente" y el titular estén presentes
    expect(find.text('Puente'), findsWidgets);
    expect(
      find.textContaining('Comunicarnos'),
      findsOneWidget,
    );

    // Verifica que el botón de Iniciar conversación esté disponible
    expect(find.textContaining('Iniciar\nconversación'), findsOneWidget);

    // Verifica que los accesos secundarios estén disponibles
    expect(find.text('Frases rápidas'), findsOneWidget);
    expect(find.text('Mostrar mensaje'), findsOneWidget);
    expect(find.text('Expresar'), findsOneWidget);

    // Verifica el bloque de presentación personal
    expect(
      find.textContaining('Podés mostrar un mensaje de presentación'),
      findsOneWidget,
    );
    expect(find.text('Ver ejemplo'), findsOneWidget);
  });
}
