import 'package:flutter/foundation.dart';

enum TtsStatus { idle, speaking, stopped, error }

abstract interface class TtsService {
  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setSpeechRate(double rate);
  ValueNotifier<TtsStatus> get statusNotifier;
  void dispose();
}

/// Implementación simulada / para pruebas y entornos sin hardware de audio.
class MockTtsService implements TtsService {
  MockTtsService({this.simulateLatency = false});

  final bool simulateLatency;
  final ValueNotifier<TtsStatus> _statusNotifier =
      ValueNotifier<TtsStatus>(TtsStatus.idle);

  String? lastSpokenText;
  int speakCount = 0;
  int stopCount = 0;
  double speechRate = 0.5;
  int setSpeechRateCount = 0;

  @override
  ValueNotifier<TtsStatus> get statusNotifier => _statusNotifier;

  @override
  Future<void> init() async {
    _statusNotifier.value = TtsStatus.idle;
  }

  @override
  Future<void> speak(String text) async {
    lastSpokenText = text;
    speakCount++;
    _statusNotifier.value = TtsStatus.speaking;

    if (simulateLatency) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    _statusNotifier.value = TtsStatus.idle;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    _statusNotifier.value = TtsStatus.stopped;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    speechRate = rate;
    setSpeechRateCount++;
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
  }
}
