import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/haptic_service.dart';
import 'package:puente/core/services/permission_service.dart';
import 'package:puente/core/services/stt_service.dart';
import 'package:puente/core/services/tts_service.dart';
import 'package:puente/domain/confirmation/data_comparison.dart';
import 'package:puente/features/conversation/controllers/conversation_controller.dart';
import 'package:puente/features/conversation/models/chat_message.dart';

void main() {
  group('ConversationController Tests', () {
    late MockTtsService mockTts;
    late MockSttService mockStt;
    late MockHapticService mockHaptics;
    late MockPermissionService mockPermissions;
    late ConversationController controller;

    setUp(() {
      mockTts = MockTtsService();
      mockStt = MockSttService();
      mockHaptics = MockHapticService();
      mockPermissions = MockPermissionService(granted: true);

      controller = ConversationController(
        ttsService: mockTts,
        sttService: mockStt,
        hapticService: mockHaptics,
        permissionService: mockPermissions,
        initialMessages: const [],
      );
    });

    test('Initial state contains empty messages and idle states', () {
      expect(controller.state.messages, isEmpty);
      expect(controller.state.isListening, isFalse);
      expect(controller.state.isMuted, isFalse);
    });

    test('sendMessage adds a user message', () {
      controller.sendMessage(text: 'Hola, ¿dónde están ubicados?');

      expect(controller.state.messages.length, 1);
      final last = controller.state.messages.last;
      expect(last.text, 'Hola, ¿dónde están ubicados?');
      expect(last.sender, MessageSender.user);
      expect(mockHaptics.messageReceivedCount, 0);
    });

    test('sendMessage from interlocutor triggers haptic feedback', () {
      controller.sendMessage(
        text: 'La cuota mensual cuesta \$45.000',
        sender: MessageSender.interlocutor,
      );

      final last = controller.state.messages.last;
      expect(last.detectedInfo, isNotNull);
      expect(last.detectedInfo!.items['Cuota mensual'], '\$45.000');
      expect(mockHaptics.messageReceivedCount, 1);
    });

    test('interlocutor message with two amounts keeps each label', () {
      controller.sendMessage(
        text:
            r'La inscripción es de $20.000 y la cuota mensual cuesta $35.000.',
        sender: MessageSender.interlocutor,
      );

      final items = controller.state.messages.last.detectedInfo!.items;
      expect(items['Inscripción'], r'$20.000');
      expect(items['Cuota mensual'], r'$35.000');
    });

    test('user message does not create detected data', () {
      controller.sendMessage(text: r'El total es $12.345');

      expect(controller.state.messages.last.detectedInfo, isNull);
    });

    test(
      'startListening triggers haptic mic start and sets listening true',
      () async {
        await controller.startListening();

        expect(controller.state.isListening, isTrue);
        expect(mockHaptics.micStartCount, 1);
      },
    );

    test('toggleMute stops the microphone and blocks new listening', () async {
      await controller.startListening();
      expect(controller.state.isListening, isTrue);

      await controller.toggleMute();

      expect(controller.state.isMuted, isTrue);
      expect(controller.state.isListening, isFalse);
      expect(mockStt.cancelCount, 1);

      await controller.startListening();

      expect(controller.state.isListening, isFalse);
      expect(controller.state.errorMessage, contains('silenciado'));
      expect(mockStt.startCount, 1);
    });

    test(
      'pauseAudio cancels STT, stops TTS and discards partial text',
      () async {
        await controller.startListening();
        mockStt.emitTranscription('texto parcial sin confirmar');
        expect(
          controller.state.partialTranscription,
          'texto parcial sin confirmar',
        );

        await controller.pauseAudio();

        expect(controller.state.isListening, isFalse);
        expect(controller.state.partialTranscription, isEmpty);
        expect(mockStt.cancelCount, 1);
        expect(mockTts.stopCount, greaterThanOrEqualTo(1));
      },
    );

    test('speakMessage stops listening before reproducing audio', () async {
      await controller.startListening();

      await controller.speakMessage('Hola, ¿cómo estás?');

      expect(controller.state.isListening, isFalse);
      expect(mockStt.cancelCount, 1);
      expect(mockTts.speakCount, 1);
    });

    test('clearConversation removes messages and stops audio', () async {
      controller.sendMessage(text: 'Mensaje de prueba');
      await controller.startListening();

      await controller.clearConversation();

      expect(controller.state.messages, isEmpty);
      expect(controller.state.isListening, isFalse);
      expect(mockStt.cancelCount, 1);
    });

    test('dispose stops microphone and TTS', () async {
      await controller.startListening();

      controller.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(mockStt.cancelCount, greaterThanOrEqualTo(1));
      expect(mockTts.stopCount, greaterThanOrEqualTo(1));
    });

    test(
      'stopListening triggers haptic mic end and resets listening',
      () async {
        await controller.startListening();
        await controller.stopListening();

        expect(controller.state.isListening, isFalse);
        expect(mockHaptics.micEndCount, 1);
      },
    );

    test('Handles permanently denied mic permission gracefully', () async {
      final deniedPermissions = MockPermissionService(
        granted: false,
        permanentlyDenied: true,
      );

      final c = ConversationController(
        ttsService: mockTts,
        sttService: mockStt,
        hapticService: mockHaptics,
        permissionService: deniedPermissions,
      );

      await c.startListening();

      expect(c.state.isListening, isFalse);
      expect(c.state.errorMessage, contains('Ajustes'));
      expect(mockHaptics.micStartCount, 0);

      await c.openAppSettings();
      expect(deniedPermissions.openSettingsCount, 1);
    });

    test('speakMessage respects disabled readMessages preference', () async {
      final c = ConversationController(
        ttsService: mockTts,
        sttService: mockStt,
        hapticService: mockHaptics,
        permissionService: mockPermissions,
        isReadMessagesEnabled: () => false,
      );

      final spoken = await c.speakMessage('Hola');

      expect(spoken, isFalse);
      expect(mockTts.speakCount, 0);
      expect(c.state.errorMessage, contains('Preferencias'));
    });

    test('stopListening skips vibrateMicEnd when vibrateAtEnd is false', () async {
      final c = ConversationController(
        ttsService: mockTts,
        sttService: mockStt,
        hapticService: mockHaptics,
        permissionService: mockPermissions,
        isVibrateAtEndEnabled: () => false,
      );

      await c.startListening();
      await c.stopListening();

      expect(mockHaptics.micStartCount, 1);
      expect(mockHaptics.micEndCount, 0);
    });

    test('confirmDetectedInfo por clave solo marca confirmado al completar todos los ítems', () {
      controller.sendMessage(
        text: r'La inscripción es de $20.000 y la cuota mensual cuesta $35.000.',
        sender: MessageSender.interlocutor,
      );

      final message = controller.state.messages.last;
      controller.confirmDetectedInfo(message.id, itemKey: 'Inscripción');

      var info = controller.state.messages.last.detectedInfo!;
      expect(info.isKeyConfirmed('Inscripción'), isTrue);
      expect(info.isKeyConfirmed('Cuota mensual'), isFalse);
      expect(info.isConfirmed, isFalse);

      controller.confirmDetectedInfo(message.id, itemKey: 'Cuota mensual');

      info = controller.state.messages.last.detectedInfo!;
      expect(info.isConfirmed, isTrue);
    });

    test('addWrittenConfirmation agrega dato confirmado del interlocutor', () {
      controller.addWrittenConfirmation(
        label: 'Horario',
        value: '14:30',
        kind: DataKind.time,
      );

      expect(controller.state.messages.length, 1);
      final msg = controller.state.messages.last;
      expect(msg.sender, MessageSender.interlocutor);
      expect(msg.detectedInfo, isNotNull);
      expect(msg.detectedInfo!.isConfirmed, isTrue);
      expect(msg.detectedInfo!.items['Horario'], '14:30');
      expect(msg.detectedInfo!.kindFor('Horario'), DataKind.time);
    });
  });
}
