import 'package:shared_preferences/shared_preferences.dart';

/// Contrato abstracto para el almacenamiento clave-valor local de Puente.
/// Inspirado en el patrón de puertos de persistencia local (Clean Architecture).
/// Permite desacoplar el acceso a SharedPreferences en producción de implementaciones en memoria para pruebas.
abstract interface class PreferencesStore {
  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);

  String? getString(String key);
  Future<bool> setString(String key, String value);

  double? getDouble(String key);
  Future<bool> setDouble(String key, double value);

  Future<bool> clear();
}

/// Implementación de producción respaldada por [SharedPreferences].
class SharedPreferencesStore implements PreferencesStore {
  const SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  @override
  Future<bool> clear() => _prefs.clear();
}

/// Implementación en memoria para pruebas unitarias y de widgets,
/// idéntica al patrón usado en Gastos Compartidos (_MemoryStatusStore / MemoryDatabase).
/// Evita depender de bindings nativos de plataforma o SharedPreferences.setMockInitialValues.
class InMemoryPreferencesStore implements PreferencesStore {
  InMemoryPreferencesStore([Map<String, Object>? initialData])
      : _storage = Map<String, Object>.from(initialData ?? {});

  final Map<String, Object> _storage;

  @override
  bool? getBool(String key) {
    final val = _storage[key];
    return val is bool ? val : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  @override
  String? getString(String key) {
    final val = _storage[key];
    return val is String ? val : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) {
    final val = _storage[key];
    return val is double ? val : null;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }
}
