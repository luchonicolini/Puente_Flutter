import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

abstract interface class HapticService {
  Future<void> vibrateMicStart();
  Future<void> vibrateMicEnd();
  Future<void> vibrateMessageReceived();
  Future<void> vibrateSuccess();
}

/// Implementación real utilizando el motor de vibración del dispositivo.
class DeviceHapticService implements HapticService {
  DeviceHapticService();

  bool? _hasVibrator;
  bool? _hasCustomVibrationsSupport;

  Future<void> _checkCapabilities() async {
    if (_hasVibrator != null) return;
    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasCustomVibrationsSupport =
          await Vibration.hasCustomVibrationsSupport();
    } catch (_) {
      _hasVibrator = false;
      _hasCustomVibrationsSupport = false;
    }
  }

  @override
  Future<void> vibrateMicStart() async {
    try {
      await _checkCapabilities();
      if (_hasVibrator == true) {
        if (_hasCustomVibrationsSupport == true) {
          await Vibration.vibrate(duration: 50, amplitude: 128);
        } else {
          await Vibration.vibrate(duration: 50);
        }
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      debugPrint('Puente Haptics: error en vibrateMicStart: $e');
    }
  }

  @override
  Future<void> vibrateMicEnd() async {
    try {
      await _checkCapabilities();
      if (_hasVibrator == true) {
        if (_hasCustomVibrationsSupport == true) {
          // Doble pulso breve para indicar que terminó la escucha
          await Vibration.vibrate(
            pattern: <int>[0, 60, 60, 60],
            intensities: <int>[128, 200],
          );
        } else {
          await Vibration.vibrate(duration: 100);
        }
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      debugPrint('Puente Haptics: error en vibrateMicEnd: $e');
    }
  }

  @override
  Future<void> vibrateMessageReceived() async {
    try {
      await _checkCapabilities();
      if (_hasVibrator == true) {
        if (_hasCustomVibrationsSupport == true) {
          await Vibration.vibrate(
            pattern: <int>[0, 70, 80, 120],
            intensities: <int>[100, 220],
          );
        } else {
          await Vibration.vibrate(duration: 150);
        }
      } else {
        await HapticFeedback.selectionClick();
      }
    } catch (e) {
      debugPrint('Puente Haptics: error en vibrateMessageReceived: $e');
    }
  }

  @override
  Future<void> vibrateSuccess() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}

/// Implementación para pruebas automatizadas y entornos CI.
class MockHapticService implements HapticService {
  int micStartCount = 0;
  int micEndCount = 0;
  int messageReceivedCount = 0;
  int successCount = 0;

  @override
  Future<void> vibrateMicStart() async {
    micStartCount++;
  }

  @override
  Future<void> vibrateMicEnd() async {
    micEndCount++;
  }

  @override
  Future<void> vibrateMessageReceived() async {
    messageReceivedCount++;
  }

  @override
  Future<void> vibrateSuccess() async {
    successCount++;
  }
}
