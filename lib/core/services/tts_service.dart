import 'package:flutter_tts/flutter_tts.dart';

/// Contrato abstracto para el servicio de síntesis de voz (TTS).
abstract class TtsService {
  bool get isSpeaking;
  Future<void> initialize({String? languageCode, double? speechRate});
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setSpeechRate(double rate);
  void dispose();
}

/// Implementación real basada en `flutter_tts` para síntesis local en iOS y Android.
class TtsServiceImpl implements TtsService {
  TtsServiceImpl({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String? languageCode, double? speechRate}) async {
    try {
      await _tts.setLanguage(languageCode ?? 'es-AR');
      await _tts.setSpeechRate(speechRate ?? 0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((_) {
        _isSpeaking = false;
      });
    } catch (_) {
      // Manejo seguro en entornos donde el motor no esté disponible
    }
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      _isSpeaking = true;
      await _tts.speak(text);
    } catch (_) {
      _isSpeaking = false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isSpeaking = false;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    final normalized = (rate * 0.5).clamp(0.1, 1.0);
    try {
      await _tts.setSpeechRate(normalized);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
  }
}
