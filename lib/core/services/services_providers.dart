import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/expression/expression_assist.dart';
import '../storage/app_preferences_store.dart';
import '../storage/quick_phrases_store.dart';
import 'flutter_tts_service.dart';
import 'gemini_expression_assist_service.dart';
import 'haptic_service.dart';
import 'permission_service.dart';
import 'speech_to_text_service.dart';
import 'stt_service.dart';
import 'tts_service.dart';

/// Preferencias activas de la aplicación disponibles para servicios y controladores.
final appPreferencesProvider = StateProvider<AppPreferences>(
  (ref) => const AppPreferences(),
);

/// Proveedor para Text-to-Speech nativo.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final TtsService service = FlutterTtsService();
  ref.onDispose(service.dispose);
  return service;
});

/// Proveedor para Speech-to-Text nativo.
final sttServiceProvider = Provider<SttService>((ref) {
  final SttService service = SpeechToTextService();
  ref.onDispose(service.dispose);
  return service;
});

/// Proveedor para Respuesta Háptica y Vibración.
final hapticServiceProvider = Provider<HapticService>((ref) {
  return DeviceHapticService();
});

/// Proveedor para Permisos del Sistema.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const AppPermissionService();
});

/// Proveedor para Almacenamiento local de Frases Rápidas.
final quickPhrasesStoreProvider = Provider<QuickPhrasesStore>((ref) {
  return SharedPreferencesQuickPhrasesStore();
});

/// Proveedor para sugerencias opcionales de Expresar vía proxy seguro de Gemini.
final expressionAssistServiceProvider = Provider<ExpressionAssistService>((ref) {
  return SupabaseGeminiExpressionAssistService();
});
