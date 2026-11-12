import 'package:flutter/foundation.dart';

enum SttStatus { idle, listening, done, error }

class SttResult {
  const SttResult({
    required this.text,
    required this.isFinal,
    this.confidence = 1.0,
  });

  final String text;
  final bool isFinal;
  final double confidence;
}

abstract interface class SttService {
  Future<bool> initialize();
  Future<bool> hasPermission();
  Future<void> startListening({
    required ValueChanged<SttResult> onResult,
    ValueChanged<String>? onError,
  });
  Future<void> stopListening();
  Future<void> cancel();
  ValueNotifier<SttStatus> get statusNotifier;
  void dispose();
}

/// Implementación simulada / para tests y demostración sin hardware de micrófono.
class MockSttService implements SttService {
  MockSttService({this.hasPermissionResult = true});

  final bool hasPermissionResult;
  final ValueNotifier<SttStatus> _statusNotifier = ValueNotifier<SttStatus>(
    SttStatus.idle,
  );

  bool isInitialized = false;
  int startCount = 0;
  int stopCount = 0;
  int cancelCount = 0;
  ValueChanged<SttResult>? activeOnResult;

  @override
  ValueNotifier<SttStatus> get statusNotifier => _statusNotifier;

  @override
  Future<bool> initialize() async {
    isInitialized = true;
    return true;
  }

  @override
  Future<bool> hasPermission() async => hasPermissionResult;

  @override
  Future<void> startListening({
    required ValueChanged<SttResult> onResult,
    ValueChanged<String>? onError,
  }) async {
    startCount++;
    activeOnResult = onResult;
    _statusNotifier.value = SttStatus.listening;
  }

  /// Permite a los tests simular una frase recibida por el micrófono.
  void emitTranscription(String text, {bool isFinal = false}) {
    activeOnResult?.call(SttResult(text: text, isFinal: isFinal));
    if (isFinal) {
      _statusNotifier.value = SttStatus.done;
    }
  }

  @override
  Future<void> stopListening() async {
    stopCount++;
    _statusNotifier.value = SttStatus.idle;
    activeOnResult = null;
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
    _statusNotifier.value = SttStatus.idle;
    activeOnResult = null;
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
  }
}
