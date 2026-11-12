import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/core/widgets/smooth_entrance.dart';
import 'package:puente/core/widgets/tap_scale.dart';
import 'package:puente/features/confirmation/confirmation_screen.dart';
import 'package:puente/features/conversation/conversation_screen.dart';
import 'package:puente/features/conversation/widgets/conversation_bottom_panel.dart';
import 'package:puente/features/show_message/show_message_screen.dart';

import 'helpers/test_overrides.dart';

void main() {
  group('UI animations & accessibility tests', () {
    testWidgets(
      'TapScale scales down on pointer press and restores on release',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: TapScale(
                  pressedScale: 0.95,
                  child: const SizedBox(
                    width: 120,
                    height: 50,
                    child: Text('Presionar'),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          1.0,
        );

        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Presionar')),
          kind: PointerDeviceKind.touch,
        );
        await tester.pump();

        expect(
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          0.95,
        );

        await gesture.up();
        await tester.pumpAndSettle();

        expect(
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          1.0,
        );
      },
    );

    testWidgets(
      'TapScale and SmoothEntrance skip animation when disableAnimations is true',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: const [
                  SmoothEntrance(
                    delay: Duration(milliseconds: 80),
                    child: Text('Entrada accesible'),
                  ),
                  TapScale(child: Text('Botón accesible')),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Entrada accesible'), findsOneWidget);
        expect(find.text('Botón accesible'), findsOneWidget);
        expect(find.byType(AnimatedScale), findsNothing);
      },
    );

    testWidgets('ShowMessageScreen animates 180° flip via AnimatedRotation', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ShowMessageScreen(initialText: 'Hola, ¿cómo estás?'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialRotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );
      expect(initialRotation.turns, 0.0);

      await tester.tap(find.text('Girar 180°'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final flippedRotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );
      expect(flippedRotation.turns, 0.5);
    });

    testWidgets('ConfirmationScreen animates comparison result cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ConfirmationScreen(
            initialDetectedValue: '20.000',
            category: 'Importe',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '20000');
      await tester.tap(find.text('Comparar datos'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Los datos coinciden'), findsOneWidget);
      expect(find.byType(AnimatedSize), findsOneWidget);
    });

    testWidgets('Listening indicator animates only when motion is allowed', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: ProviderScope(
            overrides: createTestOverrides(),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ConversationScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.mic_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final indicatorFinder = find.byType(ListeningWaveIndicator).first;
      final animation =
          tester
                  .widget<AnimatedBuilder>(
                    find.descendant(
                      of: indicatorFinder,
                      matching: find.byType(AnimatedBuilder),
                    ),
                  )
                  .animation
              as Animation<double>;
      final activeValue = animation.value;
      await tester.pump(const Duration(milliseconds: 250));
      expect(animation.value, isNot(activeValue));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ProviderScope(
            overrides: createTestOverrides(),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ConversationScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      final staticValue = animation.value;
      await tester.pump(const Duration(milliseconds: 500));
      expect(animation.value, staticValue);
    });
  });
}
