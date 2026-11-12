import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.textScale = 1.0,
    this.readMessages = true,
    this.speechRate = 0.5,
    this.vibrateAtEnd = true,
    this.doNotSaveConversations = true,
    this.useExpressionAi = false,
    this.presentationText = defaultPresentationText,
  });

  static const String defaultPresentationText =
      'Hola, soy sordo.\n\nPodemos comunicarnos por escrito o podés hablar y mi teléfono mostrará lo que decís.\n\nGracias por tu paciencia.';

  final ThemeMode themeMode;
  final double textScale;
  final bool readMessages;
  final double speechRate;
  final bool vibrateAtEnd;
  final bool doNotSaveConversations;
  final bool useExpressionAi;
  final String presentationText;

  String get effectivePresentationText =>
      presentationText.trim().isEmpty ? defaultPresentationText : presentationText;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    double? textScale,
    bool? readMessages,
    double? speechRate,
    bool? vibrateAtEnd,
    bool? doNotSaveConversations,
    bool? useExpressionAi,
    String? presentationText,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    textScale: textScale ?? this.textScale,
    readMessages: readMessages ?? this.readMessages,
    speechRate: speechRate ?? this.speechRate,
    vibrateAtEnd: vibrateAtEnd ?? this.vibrateAtEnd,
    doNotSaveConversations:
        doNotSaveConversations ?? this.doNotSaveConversations,
    useExpressionAi: useExpressionAi ?? this.useExpressionAi,
    presentationText: presentationText ?? this.presentationText,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppPreferences &&
        other.themeMode == themeMode &&
        other.textScale == textScale &&
        other.readMessages == readMessages &&
        other.speechRate == speechRate &&
        other.vibrateAtEnd == vibrateAtEnd &&
        other.doNotSaveConversations == doNotSaveConversations &&
        other.useExpressionAi == useExpressionAi &&
        other.presentationText == presentationText;
  }

  @override
  int get hashCode => Object.hash(
    themeMode,
    textScale,
    readMessages,
    speechRate,
    vibrateAtEnd,
    doNotSaveConversations,
    useExpressionAi,
    presentationText,
  );
}

abstract interface class AppPreferencesStore {
  Future<AppPreferences> load();
  Future<void> save(AppPreferences preferences);
  Future<void> clear();
}

class SharedPreferencesAppPreferencesStore implements AppPreferencesStore {
  SharedPreferencesAppPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;

  static const _themeKey = 'preference_theme_mode';
  static const _textScaleKey = 'preference_text_scale';
  static const _readMessagesKey = 'preference_read_messages';
  static const _speechRateKey = 'preference_speech_rate';
  static const _vibrateKey = 'preference_vibrate_at_end';
  static const _privacyKey = 'preference_do_not_save_conversations';
  static const _useExpressionAiKey = 'preference_use_expression_ai';
  static const _presentationTextKey = 'preference_presentation_text';

  @override
  Future<AppPreferences> load() async {
    final storedTheme = await _preferences.getString(_themeKey);
    final storedPresentation = await _preferences.getString(
      _presentationTextKey,
    );
    final normalizedPresentation =
        storedPresentation == null || storedPresentation.trim().isEmpty
        ? AppPreferences.defaultPresentationText
        : storedPresentation;
    return AppPreferences(
      themeMode:
          ThemeMode.values
              .where((mode) => mode.name == storedTheme)
              .firstOrNull ??
          ThemeMode.system,
      textScale: await _preferences.getDouble(_textScaleKey) ?? 1.0,
      readMessages: await _preferences.getBool(_readMessagesKey) ?? true,
      speechRate: await _preferences.getDouble(_speechRateKey) ?? 0.5,
      vibrateAtEnd: await _preferences.getBool(_vibrateKey) ?? true,
      doNotSaveConversations: await _preferences.getBool(_privacyKey) ?? true,
      useExpressionAi: await _preferences.getBool(_useExpressionAiKey) ?? false,
      presentationText: normalizedPresentation,
    );
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    await _preferences.setString(_themeKey, preferences.themeMode.name);
    await _preferences.setDouble(_textScaleKey, preferences.textScale);
    await _preferences.setBool(_readMessagesKey, preferences.readMessages);
    await _preferences.setDouble(_speechRateKey, preferences.speechRate);
    await _preferences.setBool(_vibrateKey, preferences.vibrateAtEnd);
    await _preferences.setBool(_privacyKey, preferences.doNotSaveConversations);
    await _preferences.setBool(
      _useExpressionAiKey,
      preferences.useExpressionAi,
    );
    final presentation = preferences.effectivePresentationText;
    if (presentation == AppPreferences.defaultPresentationText) {
      await _preferences.remove(_presentationTextKey);
    } else {
      await _preferences.setString(_presentationTextKey, presentation);
    }
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_themeKey);
    await _preferences.remove(_textScaleKey);
    await _preferences.remove(_readMessagesKey);
    await _preferences.remove(_speechRateKey);
    await _preferences.remove(_vibrateKey);
    await _preferences.remove(_privacyKey);
    await _preferences.remove(_useExpressionAiKey);
    await _preferences.remove(_presentationTextKey);
  }
}

class InMemoryAppPreferencesStore implements AppPreferencesStore {
  InMemoryAppPreferencesStore({AppPreferences initial = const AppPreferences()})
    : _preferences = initial;

  AppPreferences _preferences;

  @override
  Future<AppPreferences> load() async => _preferences;

  @override
  Future<void> save(AppPreferences preferences) async {
    _preferences = preferences;
  }

  @override
  Future<void> clear() async {
    _preferences = const AppPreferences();
  }
}
