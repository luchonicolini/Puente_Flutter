import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_store.dart';

/// Servicio de almacenamiento local clave-valor y gestión reactiva de preferencias.
/// Respeta los principios de privacidad de Puente: almacenamiento 100% en el dispositivo sin red.
/// Sigue el patrón de repositorio / puertos de persistencia (Clean Architecture) similar a Gastos Compartidos.
class PreferencesService extends ChangeNotifier {
  PreferencesService(this._store);

  /// Constructor de conveniencia en memoria para pruebas unitarias y de widgets.
  factory PreferencesService.inMemory([Map<String, Object>? initialData]) {
    return PreferencesService(InMemoryPreferencesStore(initialData));
  }

  final PreferencesStore _store;

  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyHapticFeedback = 'haptic_feedback';
  static const String _keySpeakResponsesAutomatically = 'speak_responses_automatically';
  static const String _keySpeechRate = 'speech_rate';
  static const String _keyOptInStorage = 'opt_in_storage';

  static PreferencesService? _instance;

  /// Obtiene o inicializa la instancia singleton de [PreferencesService].
  static Future<PreferencesService> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = PreferencesService(SharedPreferencesStore(prefs));
    return _instance!;
  }

  /// Permite establecer una instancia de prueba o reiniciar el singleton en tests.
  @visibleForTesting
  static void setMockInstance(PreferencesService instance) {
    _instance = instance;
  }

  // --- Onboarding ---
  bool get hasSeenOnboarding => _store.getBool(_keyHasSeenOnboarding) ?? false;

  Future<bool> setOnboardingCompleted(bool value) async {
    final result = await _store.setBool(_keyHasSeenOnboarding, value);
    notifyListeners();
    return result;
  }

  // --- Tema visual ---
  ThemeMode get themeMode {
    final val = _store.getString(_keyThemeMode);
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    final result = await _store.setString(_keyThemeMode, mode.name);
    notifyListeners();
    return result;
  }

  // --- Vibración táctil ---
  bool get hapticFeedback => _store.getBool(_keyHapticFeedback) ?? true;

  Future<bool> setHapticFeedback(bool value) async {
    final result = await _store.setBool(_keyHapticFeedback, value);
    notifyListeners();
    return result;
  }

  // --- Reproducir voz automáticamente ---
  bool get speakResponsesAutomatically =>
      _store.getBool(_keySpeakResponsesAutomatically) ?? false;

  Future<bool> setSpeakResponsesAutomatically(bool value) async {
    final result = await _store.setBool(_keySpeakResponsesAutomatically, value);
    notifyListeners();
    return result;
  }

  // --- Velocidad TTS ---
  double get speechRate => _store.getDouble(_keySpeechRate) ?? 1.0;

  Future<bool> setSpeechRate(double value) async {
    final result = await _store.setDouble(_keySpeechRate, value);
    notifyListeners();
    return result;
  }

  // --- Almacenamiento opt-in de confirmaciones ---
  bool get optInStorage => _store.getBool(_keyOptInStorage) ?? false;

  Future<bool> setOptInStorage(bool value) async {
    final result = await _store.setBool(_keyOptInStorage, value);
    notifyListeners();
    return result;
  }

  /// Restablece todas las preferencias y datos locales a los valores de fábrica.
  Future<bool> clearAll() async {
    final result = await _store.clear();
    notifyListeners();
    return result;
  }
}
