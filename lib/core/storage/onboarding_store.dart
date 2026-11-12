import 'package:shared_preferences/shared_preferences.dart';

/// Guarda exclusivamente si la bienvenida ya fue completada u omitida.
/// No almacena conversaciones, transcripciones ni datos personales.
abstract interface class OnboardingStore {
  Future<bool> hasCompletedOnboarding();
  Future<void> markOnboardingCompleted();
  Future<void> clearOnboardingCompleted();
}

class SharedPreferencesOnboardingStore implements OnboardingStore {
  SharedPreferencesOnboardingStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _completedKey = 'onboarding_completed';
  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> hasCompletedOnboarding() async {
    return await _preferences.getBool(_completedKey) ?? false;
  }

  @override
  Future<void> markOnboardingCompleted() async {
    await _preferences.setBool(_completedKey, true);
  }

  @override
  Future<void> clearOnboardingCompleted() async {
    await _preferences.remove(_completedKey);
  }
}

class InMemoryOnboardingStore implements OnboardingStore {
  InMemoryOnboardingStore({bool initialCompleted = false})
      : _completed = initialCompleted;

  bool _completed;

  @override
  Future<bool> hasCompletedOnboarding() async => _completed;

  @override
  Future<void> markOnboardingCompleted() async {
    _completed = true;
  }

  @override
  Future<void> clearOnboardingCompleted() async {
    _completed = false;
  }
}
