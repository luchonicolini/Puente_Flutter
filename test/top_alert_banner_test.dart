import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/core/widgets/top_alert_banner.dart';

void main() {
  Widget wrapAlert(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('TopAlertBanner Tests', () {
    testWidgets('Renders info alert message and default info icon', (
      tester,
    ) async {
      var dismissed = false;

      await tester.pumpWidget(
        wrapAlert(
          TopAlertBanner(
            data: const TopAlertData(
              message: 'Micrófono activado. Podés hablar.',
              type: AlertType.info,
            ),
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      expect(find.text('Micrófono activado. Podés hablar.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(dismissed, isTrue);
    });

    testWidgets('Renders error alert with action button and triggers onAction', (
      tester,
    ) async {
      var actionTriggered = false;
      var dismissed = false;

      await tester.pumpWidget(
        wrapAlert(
          TopAlertBanner(
            data: TopAlertData(
              message: 'El permiso del micrófono fue denegado permanentemente.',
              type: AlertType.error,
              actionLabel: 'Ajustes',
              onAction: () => actionTriggered = true,
            ),
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      expect(
        find.text('El permiso del micrófono fue denegado permanentemente.'),
        findsOneWidget,
      );
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      await tester.tap(find.text('Ajustes'));
      expect(actionTriggered, isTrue);
      expect(dismissed, isTrue);
    });

    testWidgets('Renders custom icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapAlert(
          TopAlertBanner(
            data: const TopAlertData(
              message: 'Reproduciendo en voz alta',
              type: AlertType.info,
              icon: Icons.volume_up_rounded,
            ),
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('Reproduciendo en voz alta'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });
  });
}
