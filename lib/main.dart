import 'package:flutter/material.dart';
import 'core/storage/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PreferencesService.getInstance();
  final showOnboarding = !prefs.hasSeenOnboarding;

  runApp(PuenteApp(
    preferencesService: prefs,
    showOnboarding: showOnboarding,
  ));
}

class PuenteApp extends StatelessWidget {
  const PuenteApp({
    super.key,
    this.preferencesService,
    this.showOnboarding = false,
  });

  final PreferencesService? preferencesService;

  /// Si es verdadero, muestra el flujo de bienvenida (primera apertura).
  /// Si es falso, inicia directamente en la pantalla principal.
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    final prefs = preferencesService;

    if (prefs == null) {
      return MaterialApp(
        title: 'Puente',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
      );
    }

    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        return MaterialApp(
          title: 'Puente',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: prefs.themeMode,
          home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
        );
      },
    );
  }
}
