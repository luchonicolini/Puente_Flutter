import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/permission_service.dart';

void main() {
  group('PermissionService Tests', () {
    test('MockPermissionService reports granted status and tracks openSettings', () async {
      final service = MockPermissionService(granted: true);

      final hasPermission = await service.requestMicrophonePermission();
      expect(hasPermission, isTrue);

      final isGranted = await service.isMicrophoneGranted();
      expect(isGranted, isTrue);

      final permanentlyDenied = await service.isMicrophonePermanentlyDenied();
      expect(permanentlyDenied, isFalse);

      expect(service.openSettingsCount, 0);
      await service.openSettings();
      expect(service.openSettingsCount, 1);
    });

    test('MockPermissionService handles denied/blocked state', () async {
      final service = MockPermissionService(granted: false, permanentlyDenied: true);

      final hasPermission = await service.requestMicrophonePermission();
      expect(hasPermission, isFalse);

      final permanentlyDenied = await service.isMicrophonePermanentlyDenied();
      expect(permanentlyDenied, isTrue);
    });
  });
}
