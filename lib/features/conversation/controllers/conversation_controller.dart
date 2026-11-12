import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/services_providers.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../domain/confirmation/data_comparison.dart';
import '../../../domain/conversation/sensitive_data_detector.dart';
import '../models/chat_message.dart';

class ConversationState {
  const ConversationState({
    required this.messages,
    this.isListening = false,
    this.isMuted = false,
    this.partialTranscription = '',
    this.pendingTranscription,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isListening;

  /// El micrófono está silenciado. No impide reproducir mensajes con TTS.
  final bool isMuted;
  final String partialTranscription;

  /// Texto recibido por STT que todavía no forma parte de la conversación.
  final String? pendingTranscription;
  final String? errorMessage;

  ConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isListening,
    bool? isMuted,
    String? partialTranscription,
    String? pendingTranscription,
    String? errorMessage,
    bool clearPendingTranscription = false,
    bool clearError = false,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isMuted: isMuted ?? this.isMuted,
      partialTranscription: partialTranscription ?? this.partialTranscription,
      pendingTranscription: clearPendingTranscription
          ? null
          : (pendingTranscription ?? this.pendingTranscription),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ConversationController extends StateNotifier<ConversationState> {
  ConversationController({
    required this.ttsService,
    required this.sttService,
    HapticService? hapticService,
    PermissionService? permissionService,
    List<ChatMessage>? initialMessages,
    bool Function()? isReadMessagesEnabled,
    bool Function()? isVibrateAtEndEnabled,
  }) : hapticService = hapticService ?? MockHapticService(),
       permissionService = permissionService ?? const AppPermissionService(),
       _isReadMessagesEnabled = isReadMessagesEnabled ?? (() => true),
       _isVibrateAtEndEnabled = isVibrateAtEndEnabled ?? (() => true),
       super(ConversationState(messages: initialMessages ?? const []));

  final TtsService ttsService;
  final SttService sttService;
  final HapticService hapticService;
  final PermissionService permissionService;
  final bool Function() _isReadMessagesEnabled;
  final bool Function() _isVibrateAtEndEnabled;

  int _audioSession = 0;
  bool _isRequestingPermission = false;

  /// Permite que la pantalla ignore el ciclo «inactive» mientras el sistema
  /// muestra el diálogo de permiso de micrófono.
  bool get isRequestingPermission => _isRequestingPermission;

  void sendMessage({
    required String text,
    MessageSender sender = MessageSender.user,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final formattedTime = '${now.hour}:$minuteStr';

    final detectedInfo = sender == MessageSender.interlocutor
        ? _detectSensitiveInfo(trimmed)
        : null;

    final newMessage = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      text: trimmed,
      sender: sender,
      timestamp: now,
      timeFormatted: formattedTime,
      detectedInfo: detectedInfo,
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
      clearError: true,
    );

    if (sender == MessageSender.interlocutor) {
      hapticService.vibrateMessageReceived();
    }
  }

  Future<bool> speakMessage(String text) async {
    if (text.trim().isEmpty) return false;
    if (!_isReadMessagesEnabled()) {
      state = state.copyWith(
        errorMessage:
            'La reproducción de mensajes está desactivada en Preferencias.',
      );
      return false;
    }

    // Evitar que el micrófono siga escuchando o termine de iniciarse mientras
    // se reproduce audio.
    await pauseAudio();
    await ttsService.speak(text);
    return true;
  }

  /// Silencia el micrófono. Si estaba escuchando, detiene la escucha y
  /// descarta el texto parcial: no lo convierte en una transcripción.
  Future<void> toggleMute() async {
    final nextMuted = !state.isMuted;

    if (nextMuted) {
      _audioSession++;
      await sttService.cancel();
      if (!mounted) return;
      state = state.copyWith(
        isMuted: true,
        isListening: false,
        partialTranscription: '',
        clearError: true,
      );
    } else {
      state = state.copyWith(isMuted: false, clearError: true);
    }
  }

  Future<void> toggleMic() async {
    if (state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    if (state.isMuted) {
      state = state.copyWith(
        errorMessage:
            'El micrófono está silenciado. Activalo para escuchar al interlocutor.',
        isListening: false,
      );
      return;
    }

    if (state.isListening) return;

    final session = ++_audioSession;

    final isPermanentlyDenied = await permissionService
        .isMicrophonePermanentlyDenied();
    if (!mounted || session != _audioSession) return;
    if (isPermanentlyDenied) {
      state = state.copyWith(
        errorMessage:
            'El permiso de micrófono está bloqueado en el sistema. Abrí Ajustes para activarlo.',
        isListening: false,
      );
      return;
    }

    bool hasPerm;
    _isRequestingPermission = true;
    try {
      hasPerm = await permissionService.requestMicrophonePermission();
    } finally {
      _isRequestingPermission = false;
    }
    if (!mounted || session != _audioSession) return;
    if (!hasPerm) {
      state = state.copyWith(
        errorMessage: 'Permiso de micrófono no otorgado.',
        isListening: false,
      );
      return;
    }

    // No reproducir TTS mientras el micrófono está activo. La detención es
    // best-effort: no debe bloquear el inicio de la escucha.
    unawaited(ttsService.stop());
    if (!mounted || session != _audioSession) return;

    state = state.copyWith(
      isListening: true,
      partialTranscription: '',
      clearError: true,
    );

    await hapticService.vibrateMicStart();
    if (!mounted || session != _audioSession) return;

    await sttService.startListening(
      onResult: (result) {
        if (!mounted || session != _audioSession) return;
        if (result.isFinal) {
          state = state.copyWith(
            partialTranscription: '',
            pendingTranscription: result.text.trim(),
            isListening: false,
          );
          if (_isVibrateAtEndEnabled()) {
            unawaited(hapticService.vibrateMicEnd());
          }
        } else {
          state = state.copyWith(partialTranscription: result.text);
        }
      },
      onError: (err) {
        if (!mounted || session != _audioSession) return;
        state = state.copyWith(errorMessage: err, isListening: false);
      },
    );

    // Si la pantalla se cerró o se silenció mientras el servicio iniciaba,
    // cancelar para no dejar el micrófono activo en segundo plano.
    if (!mounted || session != _audioSession) {
      await sttService.cancel();
    }
  }

  /// Detiene la escucha de forma explícita y conserva el texto parcial para
  /// que la persona lo revise antes de agregarlo.
  Future<void> stopListening() async {
    _audioSession++;
    await sttService.stopListening();
    if (_isVibrateAtEndEnabled()) {
      await hapticService.vibrateMicEnd();
    }
    if (!mounted) return;

    if (state.partialTranscription.trim().isNotEmpty) {
      state = state.copyWith(
        pendingTranscription: state.partialTranscription.trim(),
      );
    }
    state = state.copyWith(isListening: false, partialTranscription: '');
  }

  /// Detiene micrófono y TTS sin convertir texto parcial en transcripción.
  /// Se usa al salir de la conversación, al pasar la app a segundo plano y
  /// antes de navegar a otra pantalla.
  Future<void> pauseAudio() async {
    _audioSession++;
    await sttService.cancel();
    unawaited(ttsService.stop());
    if (!mounted) return;

    state = state.copyWith(isListening: false, partialTranscription: '');
  }

  Future<bool> openAppSettings() async {
    return await permissionService.openSettings();
  }

  /// Agrega una transcripción solo luego de la revisión explícita de la persona.
  void acceptPendingTranscription(String text) {
    final reviewedText = text.trim();
    if (reviewedText.isEmpty) return;
    sendMessage(text: reviewedText, sender: MessageSender.interlocutor);
    state = state.copyWith(clearPendingTranscription: true);
  }

  void discardPendingTranscription() {
    state = state.copyWith(clearPendingTranscription: true);
  }

  void confirmDetectedInfo(String messageId, {String? itemKey}) {
    final updated = state.messages.map((m) {
      if (m.id == messageId && m.detectedInfo != null) {
        final info = m.detectedInfo!;
        final nextConfirmed = itemKey == null
            ? info.items.keys.toSet()
            : {...info.confirmedKeys, itemKey};
        final allConfirmed = info.items.keys.every(nextConfirmed.contains);
        return m.copyWith(
          detectedInfo: info.copyWith(
            confirmedKeys: nextConfirmed,
            isConfirmed: allConfirmed,
          ),
        );
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updated);
  }

  /// Registra un dato escrito directamente por el interlocutor como confirmado
  /// por escrito dentro de la conversación.
  void addWrittenConfirmation({
    required String label,
    required String value,
    required DataKind kind,
  }) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return;

    final now = DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final formattedTime = '${now.hour}:$minuteStr';

    final newMessage = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      text: '$label confirmado por escrito: $trimmedValue',
      sender: MessageSender.interlocutor,
      timestamp: now,
      timeFormatted: formattedTime,
      detectedInfo: DetectedInfo(
        title: 'Dato confirmado por escrito',
        items: {label: trimmedValue},
        itemKinds: {label: kind},
        confirmedKeys: {label},
        isConfirmed: true,
      ),
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
      clearError: true,
    );
    hapticService.vibrateMessageReceived();
  }

  Future<void> clearConversation() async {
    await pauseAudio();
    if (!mounted) return;

    state = state.copyWith(
      messages: <ChatMessage>[],
      partialTranscription: '',
      clearPendingTranscription: true,
      clearError: true,
    );
  }

  static DetectedInfo? _detectSensitiveInfo(String text) {
    final detection = SensitiveDataDetector.detect(text);
    if (detection == null) return null;
    return DetectedInfo(
      title: 'Información detectada',
      items: detection.items,
      itemKinds: detection.kinds,
      isConfirmed: false,
    );
  }

  @override
  void dispose() {
    // Si la pantalla o el scope desaparecen, no dejar micrófono ni voz activos.
    _audioSession++;
    unawaited(sttService.cancel());
    unawaited(ttsService.stop());
    super.dispose();
  }
}

final conversationControllerProvider =
    StateNotifierProvider<ConversationController, ConversationState>((ref) {
      final tts = ref.watch(ttsServiceProvider);
      final stt = ref.watch(sttServiceProvider);
      final haptics = ref.watch(hapticServiceProvider);
      final permissions = ref.watch(permissionServiceProvider);
      return ConversationController(
        ttsService: tts,
        sttService: stt,
        hapticService: haptics,
        permissionService: permissions,
        isReadMessagesEnabled: () =>
            ref.read(appPreferencesProvider).readMessages,
        isVibrateAtEndEnabled: () =>
            ref.read(appPreferencesProvider).vibrateAtEnd,
      );
    });
