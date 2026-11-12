import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_service.dart';

class FlutterTtsService implements TtsService {
  FlutterTtsService({FlutterTts? ttsClient})
      : _tts = ttsClient ?? FlutterTts();

  final FlutterTts _tts;
  final ValueNotifier<TtsStatus> _statusNotifier =
      ValueNotifier<TtsStatus>(TtsStatus.idle);
  bool _isInitialized = false;
  double _speechRate = 0.5;

  @override
  ValueNotifier<TtsStatus> get statusNotifier => _statusNotifier;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _tts.setStartHandler(() {
        _statusNotifier.value = TtsStatus.speaking;
      });

      _tts.setCompletionHandler(() {
        _statusNotifier.value = TtsStatus.idle;
      });

      _tts.setCancelHandler(() {
        _statusNotifier.value = TtsStatus.stopped;
      });

      _tts.setErrorHandler((dynamic message) {
        _statusNotifier.value = TtsStatus.error;
      });

      // Configuración de idioma preferente: es-AR (Rioplatense) con fallback a español general
      final dynamic isArAvailable = await _tts.isLanguageAvailable('es-AR');
      if (isArAvailable == true || isArAvailable == 1) {
        await _tts.setLanguage('es-AR');
      } else {
        await _tts.setLanguage('es-ES');
      }

      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);

      _isInitialized = true;
      _statusNotifier.value = TtsStatus.idle;
    } catch (e) {
      debugPrint('Puente TTS: Error al inicializar síntesis de voz: $e');
      _statusNotifier.value = TtsStatus.error;
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.2, 1.0);
    if (!_isInitialized) return;
    try {
      await _tts.setSpeechRate(_speechRate);
    } catch (e) {
      debugPrint('Puente TTS: Error al ajustar velocidad de voz: $e');
    }
  }

  @override
  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (!_isInitialized) {
      await init();
    }

    try {
      _statusNotifier.value = TtsStatus.speaking;
      await _tts.speak(trimmed);
      _statusNotifier.value = TtsStatus.idle;
    } catch (e) {
      debugPrint('Puente TTS: Error al reproducir audio: $e');
      _statusNotifier.value = TtsStatus.error;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
      _statusNotifier.value = TtsStatus.stopped;
    } catch (e) {
      debugPrint('Puente TTS: Error al detener síntesis de voz: $e');
    }
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
  }
}
