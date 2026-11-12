import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/services_providers.dart';
import 'core/storage/app_preferences_store.dart';
import 'core/storage/onboarding_store.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const ProviderScope(child: PuenteApp()));
}

class PuenteApp extends StatefulWidget {
  const PuenteApp({
    super.key,
    this.onboardingStore,
    this.preferencesStore,
    this.overrides = const [],
  });

  final OnboardingStore? onboardingStore;
  final AppPreferencesStore? preferencesStore;
  final List<Override> overrides;

  @override
  State<PuenteApp> createState() => _PuenteAppState();
}

class _PuenteAppState extends State<PuenteApp> {
  late final OnboardingStore _onboardingStore;
  late final AppPreferencesStore _preferencesStore;
  late Future<bool> _hasCompletedOnboarding;
  AppPreferences _preferences = const AppPreferences();
  bool _completedDuringSession = false;

  @override
  void initState() {
    super.initState();
    _onboardingStore =
        widget.onboardingStore ?? SharedPreferencesOnboardingStore();
    _preferencesStore =
        widget.preferencesStore ?? SharedPreferencesAppPreferencesStore();
    _hasCompletedOnboarding = _onboardingStore.hasCompletedOnboarding();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final loaded = await _preferencesStore.load();
    if (mounted) setState(() => _preferences = loaded);
  }

  Future<void> _updatePreferences(AppPreferences updated) async {
    setState(() => _preferences = updated);
    await _preferencesStore.save(updated);
  }

  Future<void> _clearLocalData() async {
    await _preferencesStore.clear();
    await _onboardingStore.clearOnboardingCompleted();
    if (mounted) setState(() => _preferences = const AppPreferences());
  }

  Future<void> _completeOnboarding() async {
    await _onboardingStore.markOnboardingCompleted();
    if (mounted) setState(() => _completedDuringSession = true);
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Puente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _preferences.themeMode,
      builder: (context, child) {
        final systemFactor = MediaQuery.textScalerOf(context).scale(1.0);
        return _PreferencesSync(
          preferences: _preferences,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                systemFactor * _preferences.textScale,
              ),
            ),
            child: child!,
          ),
        );
      },
      home: FutureBuilder<bool>(
        future: _hasCompletedOnboarding,
        builder: (context, snapshot) {
          if (_completedDuringSession || snapshot.data == true) {
            return HomeScreen(
              preferences: _preferences,
              onPreferencesChanged: _updatePreferences,
              onClearLocalData: _clearLocalData,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return OnboardingScreen(onFinished: _completeOnboarding);
        },
      ),
    );

    try {
      ProviderScope.containerOf(context, listen: false);
      return app;
    } catch (_) {
      return ProviderScope(overrides: widget.overrides, child: app);
    }
  }
}

class _PreferencesSync extends ConsumerStatefulWidget {
  const _PreferencesSync({required this.preferences, required this.child});

  final AppPreferences preferences;
  final Widget child;

  @override
  ConsumerState<_PreferencesSync> createState() => _PreferencesSyncState();
}

class _PreferencesSyncState extends ConsumerState<_PreferencesSync> {
  @override
  void initState() {
    super.initState();
    _syncPreferences();
  }

  @override
  void didUpdateWidget(covariant _PreferencesSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preferences != widget.preferences) {
      _syncPreferences();
    }
  }

  void _syncPreferences() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appPreferencesProvider.notifier).state = widget.preferences;
      unawaited(
        ref.read(ttsServiceProvider).setSpeechRate(widget.preferences.speechRate),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
