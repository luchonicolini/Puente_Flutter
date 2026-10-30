import 'dart:async';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Estados del motor de reconocimiento de voz.
enum SpeechState {
  uninitialized,
  initializing,
  ready,
  listening,
  denied,
  notAvailable,
  error,
}

/// Contrato abstracto para el servicio de reconocimiento de voz (STT).
abstract class SpeechService {
  SpeechState get state;
  bool get isListening;
  bool get isAvailable;
  Future<bool> get hasPermission;

  Future<bool> initialize({
    void Function(SpeechState state)? onStateChanged,
    void Function(String errorMessage)? onError,
  });

  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    String? localeId,
  });

  Future<void> stopListening();
  Future<void> cancelListening();
  void dispose();
}

/// Implementación real basada en `speech_to_text` para iOS y Android.
class SpeechServiceImpl implements SpeechService {
  SpeechServiceImpl({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  SpeechState _state = SpeechState.uninitialized;

  void Function(SpeechState state)? _onStateChanged;
  void Function(String errorMessage)? _onError;

  @override
  SpeechState get state => _state;

  @override
  bool get isListening => _speech.isListening;

  @override
  bool get isAvailable => _speech.isAvailable;

  @override
  Future<bool> get hasPermission => _speech.hasPermission;

  void _setState(SpeechState newState) {
    _state = newState;
    _onStateChanged?.call(newState);
  }

  @override
  Future<bool> initialize({
    void Function(SpeechState state)? onStateChanged,
    void Function(String errorMessage)? onError,
  }) async {
    _onStateChanged = onStateChanged;
    _onError = onError;
    _setState(SpeechState.initializing);

    try {
      final available = await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          _setState(SpeechState.error);
          _onError?.call(error.errorMsg);
        },
        onStatus: (String status) {
          if (status == 'listening') {
            _setState(SpeechState.listening);
          } else if (status == 'notListening' || status == 'done') {
            _setState(SpeechState.ready);
          }
        },
      );

      if (!available) {
        final hasPerm = await _speech.hasPermission;
        if (!hasPerm) {
          _setState(SpeechState.denied);
        } else {
          _setState(SpeechState.notAvailable);
        }
        return false;
      }

      _setState(SpeechState.ready);
      return true;
    } catch (e) {
      _setState(SpeechState.error);
      _onError?.call(e.toString());
      return false;
    }
  }

  @override
  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    String? localeId,
  }) async {
    if (!_speech.isAvailable) {
      final initialized = await initialize(
        onStateChanged: _onStateChanged,
        onError: _onError,
      );
      if (!initialized) return;
    }

    _setState(SpeechState.listening);

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult) {
          _setState(SpeechState.ready);
        }
      },
      localeId: localeId ?? 'es_AR',
      cancelOnError: false,
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    _setState(SpeechState.ready);
  }

  @override
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (_) {}
    _setState(SpeechState.ready);
  }

  @override
  void dispose() {
    _speech.stop();
  }
}
