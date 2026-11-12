import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/haptic_service.dart';

void main() {
  group('HapticService Tests', () {
    test('MockHapticService tracks vibrator calls correctly', () async {
      final haptic = MockHapticService();

      expect(haptic.micStartCount, 0);
      expect(haptic.micEndCount, 0);
      expect(haptic.messageReceivedCount, 0);
      expect(haptic.successCount, 0);

      await haptic.vibrateMicStart();
      expect(haptic.micStartCount, 1);

      await haptic.vibrateMicEnd();
      expect(haptic.micEndCount, 1);

      await haptic.vibrateMessageReceived();
      expect(haptic.messageReceivedCount, 1);

      await haptic.vibrateSuccess();
      expect(haptic.successCount, 1);
    });
  });
}
