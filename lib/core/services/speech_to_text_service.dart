import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'stt_service.dart';

class SpeechToTextService implements SttService {
  SpeechToTextService({stt.SpeechToText? speechClient})
      : _speech = speechClient ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  final ValueNotifier<SttStatus> _statusNotifier =
      ValueNotifier<SttStatus>(SttStatus.idle);
  bool _isInitialized = false;

  @override
  ValueNotifier<SttStatus> get statusNotifier => _statusNotifier;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      final available = await _speech.initialize(
        onError: (val) {
          debugPrint('Puente STT Error: ${val.errorMsg}');
          _statusNotifier.value = SttStatus.error;
        },
        onStatus: (status) {
          switch (status) {
            case 'listening':
              _statusNotifier.value = SttStatus.listening;
              break;
            case 'notListening':
            case 'done':
              _statusNotifier.value = SttStatus.done;
              break;
            default:
              _statusNotifier.value = SttStatus.idle;
          }
        },
      );
      _isInitialized = available;
      return available;
    } catch (e) {
      debugPrint('Puente STT: Error al inicializar reconocimiento de voz: $e');
      _statusNotifier.value = SttStatus.error;
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return _speech.hasPermission;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> startListening({
    required ValueChanged<SttResult> onResult,
    ValueChanged<String>? onError,
  }) async {
    try {
      if (!_isInitialized) {
        final available = await initialize();
        if (!available) {
          onError?.call(
            'El reconocimiento de voz no está disponible en este dispositivo.',
          );
          _statusNotifier.value = SttStatus.error;
          return;
        }
      }

      final hasPerm = await hasPermission();
      if (!hasPerm) {
        onError?.call('Permiso de micrófono no otorgado.');
        _statusNotifier.value = SttStatus.error;
        return;
      }

      _statusNotifier.value = SttStatus.listening;

      // Buscar si es_AR está disponible en los locales del sistema
      String localeId = 'es_AR';
      try {
        final locales = await _speech.locales();
        final hasAr = locales.any((l) =>
            l.localeId.toLowerCase().startsWith('es_ar') ||
            l.localeId.toLowerCase().startsWith('es-ar'));
        if (!hasAr) {
          final anySpanish = locales.firstWhere(
            (l) => l.localeId.toLowerCase().startsWith('es'),
            orElse: () => locales.first,
          );
          localeId = anySpanish.localeId;
        }
      } catch (_) {}

      await _speech.listen(
        onResult: (result) {
          onResult(
            SttResult(
              text: result.recognizedWords,
              isFinal: result.finalResult,
              confidence:
                  result.hasConfidenceRating ? result.confidence : 1.0,
            ),
          );
          if (result.finalResult) {
            _statusNotifier.value = SttStatus.done;
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (e) {
      debugPrint('Puente STT: Error al iniciar escucha: $e');
      onError?.call('No se pudo iniciar la escucha de audio.');
      _statusNotifier.value = SttStatus.error;
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      _statusNotifier.value = SttStatus.idle;
    } catch (e) {
      debugPrint('Puente STT: Error al detener escucha: $e');
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _speech.cancel();
      _statusNotifier.value = SttStatus.idle;
    } catch (e) {
      debugPrint('Puente STT: Error al cancelar escucha: $e');
    }
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
  }
}
