import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

abstract interface class PermissionService {
  Future<bool> requestMicrophonePermission();
  Future<bool> isMicrophoneGranted();
  Future<bool> isMicrophonePermanentlyDenied();
  Future<bool> openSettings();
}

class AppPermissionService implements PermissionService {
  const AppPermissionService();

  @override
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Puente Permissions: error al solicitar micrófono: $e');
      return false;
    }
  }

  @override
  Future<bool> isMicrophoneGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isMicrophonePermanentlyDenied() async {
    try {
      final status = await Permission.microphone.status;
      return status.isPermanentlyDenied;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Puente Permissions: error al abrir ajustes: $e');
      return false;
    }
  }
}

class MockPermissionService implements PermissionService {
  MockPermissionService({
    this.granted = true,
    this.permanentlyDenied = false,
  });

  bool granted;
  bool permanentlyDenied;
  int openSettingsCount = 0;

  @override
  Future<bool> requestMicrophonePermission() async => granted;

  @override
  Future<bool> isMicrophoneGranted() async => granted;

  @override
  Future<bool> isMicrophonePermanentlyDenied() async => permanentlyDenied;

  @override
  Future<bool> openSettings() async {
    openSettingsCount++;
    return true;
  }
}
