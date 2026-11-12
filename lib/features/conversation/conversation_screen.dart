import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/services_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/not_understood_sheet.dart';
import '../../core/widgets/text_edit_dialog.dart';
import '../../core/widgets/top_alert_banner.dart';
import '../../domain/confirmation/data_comparison.dart';
import '../confirmation/confirmation_screen.dart';
import '../expression/expression_screen.dart';
import '../quick_phrases/quick_phrases_sheet.dart';
import '../show_message/show_message_screen.dart';
import 'controllers/conversation_controller.dart';
import 'models/chat_message.dart';
import 'widgets/conversation_bottom_panel.dart';
import 'widgets/conversation_sheets.dart';
import 'widgets/message_bubble.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({
    super.key,
    this.initialContext,
    this.onPresentationSaved,
    this.onUseExpressionAiChanged,
  });

  final String? initialContext;
  final ValueChanged<String>? onPresentationSaved;
  final ValueChanged<bool>? onUseExpressionAiChanged;

  @override
  Widget build(BuildContext context) {
    try {
      ProviderScope.containerOf(context, listen: false);
      return _ConversationScreenBody(
        initialContext: initialContext,
        onPresentationSaved: onPresentationSaved,
        onUseExpressionAiChanged: onUseExpressionAiChanged,
      );
    } catch (_) {
      return ProviderScope(
        child: _ConversationScreenBody(
          initialContext: initialContext,
          onPresentationSaved: onPresentationSaved,
          onUseExpressionAiChanged: onUseExpressionAiChanged,
        ),
      );
    }
  }
}

class _ConversationScreenBody extends ConsumerStatefulWidget {
  const _ConversationScreenBody({
    this.initialContext,
    this.onPresentationSaved,
    this.onUseExpressionAiChanged,
  });

  final String? initialContext;
  final ValueChanged<String>? onPresentationSaved;
  final ValueChanged<bool>? onUseExpressionAiChanged;

  @override
  ConsumerState<_ConversationScreenBody> createState() =>
      _ConversationScreenBodyState();
}

class _ConversationScreenBodyState
    extends ConsumerState<_ConversationScreenBody>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ConversationController _controller;
  MessageSender _composerSender = MessageSender.user;

  TopAlertData? _activeAlert;
  Timer? _alertTimer;

  void _showAlert(TopAlertData alert) {
    _alertTimer?.cancel();
    if (mounted) {
      setState(() {
        _activeAlert = alert;
      });
    }
    _alertTimer = Timer(alert.duration, () {
      if (mounted) {
        setState(() {
          _activeAlert = null;
        });
      }
    });
  }

  void _dismissAlert() {
    _alertTimer?.cancel();
    if (mounted) {
      setState(() {
        _activeAlert = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ref.read(conversationControllerProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialContext != null && widget.initialContext!.isNotEmpty) {
      _textController.text = widget.initialContext!;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // El diálogo de permiso del sistema puede emitir «inactive»; no hay que
    // cancelar la solicitud en curso por ese motivo.
    if (state == AppLifecycleState.inactive &&
        _controller.isRequestingPermission) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_controller.pauseAudio());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.pauseAudio());
    _alertTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? textOverride}) {
    final text = textOverride ?? _textController.text.trim();
    if (text.isEmpty) return;

    // Los pedidos de «No entendí» siempre son de la persona usuaria. El
    // compositor respeta el turno elegido para que el interlocutor también
    // pueda escribir sin que su mensaje se atribuya a la persona usuaria.
    final sender = textOverride == null ? _composerSender : MessageSender.user;
    _controller.sendMessage(text: text, sender: sender);

    if (textOverride == null) {
      _textController.clear();
    }

    _scrollToBottom();
  }

  void _setComposerSender(MessageSender sender) {
    if (_composerSender == sender) return;
    setState(() => _composerSender = sender);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleMic() {
    ref.read(conversationControllerProvider.notifier).toggleMic();
  }

  Future<void> _editPendingTranscription(String transcription) async {
    final reviewedText = await TextEditDialog.show(
      context,
      title: 'Revisar transcripción',
      confirmLabel: 'Agregar',
      initialText: transcription,
      labelText: 'Texto detectado',
      helperText: 'Corregilo antes de agregarlo a la conversación.',
      minLines: 2,
      maxLines: 5,
    );

    if (reviewedText != null && mounted) {
      ref
          .read(conversationControllerProvider.notifier)
          .acceptPendingTranscription(reviewedText);
    }
  }

  void _toggleMute() {
    unawaited(_controller.toggleMute());
  }

  void _playLastMessageTts() {
    if (!ref.read(appPreferencesProvider).readMessages) {
      _showAlert(
        const TopAlertData(
          message: 'La reproducción de voz está desactivada en Preferencias.',
          type: AlertType.warning,
          icon: Icons.volume_off_rounded,
        ),
      );
      return;
    }

    final messages = ref.read(conversationControllerProvider).messages;
    if (messages.isEmpty) {
      _showAlert(
        const TopAlertData(
          message: 'Todavía no hay mensajes para reproducir en voz alta.',
          type: AlertType.info,
          icon: Icons.volume_up_outlined,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final last = messages.last;

    unawaited(_controller.speakMessage(last.text));

    _showAlert(
      TopAlertData(
        message: 'Reproduciendo en voz alta: "${last.text}"',
        type: AlertType.info,
        icon: Icons.volume_up_rounded,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _categoryForKind(DataKind kind) => switch (kind) {
    DataKind.amount => 'Importe',
    DataKind.date => 'Fecha',
    DataKind.time => 'Horario',
    DataKind.text => 'Otro',
  };

  Future<void> _handleConfirmInfo(ChatMessage message) async {
    final detected = message.detectedInfo;
    if (detected == null || detected.items.isEmpty) return;

    await _controller.pauseAudio();
    if (!mounted) return;

    String? targetKey;
    if (detected.items.length == 1) {
      targetKey = detected.items.keys.first;
    } else {
      targetKey = await DetectedItemPickerSheet.show(
        context,
        detectedInfo: detected,
      );
    }

    if (targetKey == null || !mounted) return;
    final targetValue = detected.items[targetKey] ?? '';
    final targetCategory = _categoryForKind(detected.kindFor(targetKey));

    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ConfirmationScreen(
          initialDetectedValue: targetValue,
          category: targetCategory,
        ),
      ),
    );

    if (confirmed == true && mounted) {
      _controller.confirmDetectedInfo(message.id, itemKey: targetKey);
    }
  }

  Future<void> _handleQuickConfirm() async {
    await _controller.pauseAudio();
    if (!mounted) return;

    final messages = ref.read(conversationControllerProvider).messages;
    ChatMessage? pendingMessage;
    for (final message in messages.reversed) {
      final info = message.detectedInfo;
      if (info != null && !info.isConfirmed) {
        pendingMessage = message;
        break;
      }
    }

    if (pendingMessage != null) {
      await _handleConfirmInfo(pendingMessage);
      return;
    }

    final option = await ConfirmQuickChoiceSheet.show(context);
    if (!mounted || option == null) return;

    switch (option) {
      case QuickConfirmOption.askToWrite:
        final written = await InterlocutorDataRequestSheet.show(context);
        if (written != null && mounted) {
          _controller.addWrittenConfirmation(
            label: written.label,
            value: written.value,
            kind: written.kind,
          );
          _scrollToBottom();
        }
      case QuickConfirmOption.compareManually:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => const ConfirmationScreen(),
          ),
        );
    }
  }

  Future<void> _handlePassPhoneToWrite() async {
    await _controller.pauseAudio();
    if (!mounted) return;

    final reply = await InterlocutorWriteSheet.show(context);
    if (reply != null && reply.trim().isNotEmpty && mounted) {
      _controller.sendMessage(text: reply, sender: MessageSender.interlocutor);
      _scrollToBottom();
    }
  }

  void _openQuickPhrasesInChat() {
    QuickPhrasesSheet.show(
      context,
      onPhraseSelected: (phrase) {
        _sendMessage(textOverride: phrase);
      },
    );
  }

  Future<void> _handleExpression() async {
    await _controller.pauseAudio();
    if (!mounted) return;

    final approvedText = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => ExpressionScreen(
          initialText: _textController.text,
          onUseExpressionAiChanged: widget.onUseExpressionAiChanged,
        ),
      ),
    );

    if (approvedText != null && approvedText.isNotEmpty && mounted) {
      _textController.text = approvedText;
    }
  }

  Future<void> _handleShowMessage([String? messageText]) async {
    final text = (messageText ?? _textController.text).trim();
    final textToShow = text.isNotEmpty
        ? text
        : 'Hola, nos comunicamos por escrito.';

    await _controller.pauseAudio();
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            ShowMessageScreen(initialText: textToShow, isPresentation: false),
      ),
    );
  }

  Future<void> _handlePresentation() async {
    await _controller.pauseAudio();
    if (!mounted) return;

    final presentationText = ref
        .read(appPreferencesProvider)
        .effectivePresentationText;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ShowMessageScreen(
          initialText: presentationText,
          isPresentation: true,
          onSavePresentation: widget.onPresentationSaved,
        ),
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            '¿Finalizar conversación?',
            style: AppTypography.screenTitle(
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          content: Text(
            'Los mensajes y datos detectados se descartarán. Puente no guarda conversaciones por defecto para proteger tu privacidad.',
            style: AppTypography.body(
              isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continuar hablando'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Finalizar y borrar'),
            ),
          ],
        );
      },
    );

    if (shouldDiscard == true && mounted) {
      await _controller.clearConversation();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.surfaceLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final conversationState = ref.watch(conversationControllerProvider);
    final messages = conversationState.messages;
    final isListening = conversationState.isListening;
    final isMuted = conversationState.isMuted;
    final pendingTranscription = conversationState.pendingTranscription;
    // Se lee antes del Scaffold para capturar el teclado antes de que lo consuma.
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    ref.listen<ConversationState>(conversationControllerProvider, (
      previous,
      next,
    ) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
      if (previous?.isMuted != next.isMuted) {
        _showAlert(
          TopAlertData(
            message: next.isMuted
                ? 'Micrófono silenciado. No se está escuchando.'
                : 'Micrófono habilitado. Tocá para hablar.',
            type: AlertType.info,
            icon: next.isMuted ? Icons.mic_off_outlined : Icons.mic_rounded,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        final isSettings = next.errorMessage!.contains('Ajustes');
        _showAlert(
          TopAlertData(
            message: next.errorMessage!,
            type: AlertType.error,
            icon: Icons.error_outline_rounded,
            duration: const Duration(seconds: 5),
            actionLabel: isSettings ? 'Ajustes' : null,
            onAction: isSettings
                ? () => ref
                      .read(conversationControllerProvider.notifier)
                      .openAppSettings()
                : null,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          tooltip: 'Volver al Inicio',
          color: textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Conversación',
          style: AppTypography.sectionTitle(textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            tooltip: 'Finalizar y descartar conversación',
            color: textSecondary,
            onPressed: _confirmDiscard,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    if (isListening)
                      _ListeningStatusBanner(
                        partialTranscription:
                            conversationState.partialTranscription,
                        onStop: _toggleMic,
                      ),

                    if (pendingTranscription != null &&
                        pendingTranscription.trim().isNotEmpty)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.28,
                        ),
                        child: SingleChildScrollView(
                          child: _PendingTranscriptionCard(
                            text: pendingTranscription,
                            onEdit: () =>
                                _editPendingTranscription(pendingTranscription),
                            onDiscard: () => ref
                                .read(conversationControllerProvider.notifier)
                                .discardPendingTranscription(),
                            onAdd: () => ref
                                .read(conversationControllerProvider.notifier)
                                .acceptPendingTranscription(
                                  pendingTranscription,
                                ),
                          ),
                        ),
                      ),

                    Expanded(
                      child: messages.isEmpty
                          ? _ConversationEmptyState(
                              scrollController: _scrollController,
                              onPresentation: _handlePresentation,
                              onQuickPhrases: _openQuickPhrasesInChat,
                              onStartListening: _toggleMic,
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                10,
                              ),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return ConversationMessageBubble(
                                  message: message,
                                  onTapDetectedInfo: () =>
                                      _handleConfirmInfo(message),
                                );
                              },
                            ),
                    ),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            constraints.maxHeight *
                            (isKeyboardOpen
                                ? 0.72
                                : isListening
                                ? 0.64
                                : 0.68),
                      ),
                      child: SingleChildScrollView(
                        child: ConversationBottomPanel(
                          textController: _textController,
                          composerSender: _composerSender,
                          isListening: isListening,
                          isMuted: isMuted,
                          isKeyboardOpen: isKeyboardOpen,
                          onSelectSender: _setComposerSender,
                          onSend: () => _sendMessage(),
                          onPresentation: _handlePresentation,
                          onNotUnderstood: () {
                            NotUnderstoodSheet.show(
                              context,
                              onOptionSelected: (phrase) {
                                _sendMessage(textOverride: phrase);
                              },
                            );
                          },
                          onQuickConfirm: _handleQuickConfirm,
                          onPassPhoneToWrite: _handlePassPhoneToWrite,
                          onOpenExpression: _handleExpression,
                          onShowMessage: () => _handleShowMessage(),
                          onToggleMic: _toggleMic,
                          onToggleMute: _toggleMute,
                          onPlayLastTts: _playLastMessageTts,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Alerta superior flotante (nunca obstruye el micrófono ni el compositor inferior)
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: AnimatedSwitcher(
                duration:
                    (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.0, -0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: _activeAlert != null
                    ? TopAlertBanner(
                        key: ValueKey(_activeAlert!.message),
                        data: _activeAlert!,
                        onDismiss: _dismissAlert,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningStatusBanner extends StatelessWidget {
  const _ListeningStatusBanner({
    required this.partialTranscription,
    required this.onStop,
  });

  final String partialTranscription;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.primaryTealDark
        : AppColors.primaryTealLight;
    final foreground = isDark
        ? AppColors.primaryTealLight
        : AppColors.primaryTealDark;
    final borderColor = isDark
        ? AppColors.borderDark
        : AppColors.primaryTealMuted;

    final subtitle = partialTranscription.isNotEmpty
        ? partialTranscription
        : 'Esperando texto del interlocutor…';

    return Semantics(
      liveRegion: true,
      label: 'Micrófono activo. $subtitle',
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 6, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: ListeningWaveIndicator(color: foreground),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Micrófono activo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.secondary(
                      foreground,
                    ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: foreground,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    textStyle: AppTypography.secondary(
                      foreground,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  onPressed: onStop,
                  child: const Text('Detener'),
                ),
              ],
            ),
            Text(
              subtitle,
              style: AppTypography.secondary(
                foreground,
              ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTranscriptionCard extends StatelessWidget {
  const _PendingTranscriptionCard({
    required this.text,
    required this.onEdit,
    required this.onDiscard,
    required this.onAdd,
  });

  final String text;
  final VoidCallback onEdit;
  final VoidCallback onDiscard;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final warningColor = isDark
        ? AppColors.warningTextDark
        : AppColors.warningTextLight;
    final background = isDark
        ? AppColors.surfaceMutedDark
        : AppColors.warningLight;
    final borderColor = isDark
        ? AppColors.warningTextDark.withValues(alpha: 0.45)
        : AppColors.warning;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: warningColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Texto transcripto — sin confirmar',
                  style: AppTypography.secondary(
                    warningColor,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: AppTypography.body(textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: onDiscard,
                child: const Text('Descartar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onPressed: onAdd,
                child: const Text('Agregar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConversationEmptyState extends StatelessWidget {
  const _ConversationEmptyState({
    required this.scrollController,
    required this.onPresentation,
    required this.onQuickPhrases,
    required this.onStartListening,
  });

  final ScrollController scrollController;
  final VoidCallback onPresentation;
  final VoidCallback onQuickPhrases;
  final VoidCallback onStartListening;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final accent = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTealDark;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceMutedDark
                        : AppColors.primaryTealLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 26,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Empezá la conversación',
                style: AppTypography.sectionTitle(textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Escribí un mensaje para empezar. También podés usar una de estas opciones:',
                style: AppTypography.secondary(textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onPresentation,
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Mostrar mi presentación'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: borderColor),
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onQuickPhrases,
                icon: const Icon(Icons.flash_on_rounded),
                label: const Text('Elegir frase rápida'),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: borderColor),
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onStartListening,
                icon: const Icon(Icons.record_voice_over_outlined),
                label: const Text('Escuchar al interlocutor'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
