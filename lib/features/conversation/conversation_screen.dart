import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/not_understood_sheet.dart';
import '../confirmation/confirmation_screen.dart';
import '../expression/expression_screen.dart';
import '../show_message/show_message_screen.dart';
import 'models/chat_message.dart';
import 'widgets/detected_info_card.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    this.initialContext,
  });

  final String? initialContext;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;
  bool _isMuted = false;

  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = <ChatMessage>[
      ChatMessage(
        id: '1',
        text: 'Hola, quiero saber cuánto cuesta la inscripción del gimnasio.',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 10, 29, 9, 41),
        timeFormatted: '9:41',
      ),
      ChatMessage(
        id: '2',
        text: 'La inscripción es de \$20.000 y la cuota mensual cuesta \$35.000.',
        sender: MessageSender.interlocutor,
        timestamp: DateTime(2026, 10, 29, 9, 42),
        timeFormatted: '9:42',
        detectedInfo: const DetectedInfo(
          title: 'Información detectada',
          items: {
            'Inscripción': '\$20.000',
            'Cuota mensual': '\$35.000',
          },
          isConfirmed: false,
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? textOverride}) {
    final text = textOverride ?? _textController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final formattedTime = '${now.hour}:$minuteStr';

    setState(() {
      _messages.add(
        ChatMessage(
          id: now.millisecondsSinceEpoch.toString(),
          text: text,
          sender: MessageSender.user,
          timestamp: now,
          timeFormatted: formattedTime,
        ),
      );
      if (textOverride == null) {
        _textController.clear();
      }
    });

    _scrollToBottom();
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
    setState(() {
      _isListening = !_isListening;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isListening
              ? 'Micrófono activado: escuchando al interlocutor...'
              : 'Micrófono detenido.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isMuted ? 'Entrada de audio silenciada.' : 'Entrada de audio activa.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _playLastMessageTts() {
    if (_messages.isEmpty) return;
    final last = _messages.last;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reproduciendo en voz alta: "${last.text}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleConfirmInfo(ChatMessage message) async {
    final detected = message.detectedInfo;
    final firstValue = detected?.items.values.first ?? '\$35.000';

    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ConfirmationScreen(
          initialDetectedValue: firstValue,
          category: 'Importe',
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1 && _messages[index].detectedInfo != null) {
          _messages[index] = _messages[index].copyWith(
            detectedInfo: _messages[index].detectedInfo!.copyWith(isConfirmed: true),
          );
        }
      });
    }
  }

  Future<void> _handleExpression() async {
    final approvedText = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => ExpressionScreen(
          initialText: _textController.text,
        ),
      ),
    );

    if (approvedText != null && approvedText.isNotEmpty && mounted) {
      _textController.text = approvedText;
    }
  }

  void _handleShowMessage() {
    final text = _textController.text.trim();
    final textToShow = text.isNotEmpty ? text : 'Hola, nos comunicamos por escrito.';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ShowMessageScreen(
          initialText: textToShow,
          isPresentation: false,
        ),
      ),
    );
  }

  void _handlePresentation() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ShowMessageScreen(
          initialText:
              'Hola, soy sordo. Podemos comunicarnos por escrito o podés hablar y mi teléfono mostrará lo que decís.',
          isPresentation: true,
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
            'Por privacidad, la transcripción completa se descartará de este dispositivo.',
            style: AppTypography.body(
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continuar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Finalizar y borrar'),
            ),
          ],
        );
      },
    );

    if (shouldDiscard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : const Color(0xFF70818B);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmDiscard();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: 'Volver',
            onPressed: _confirmDiscard,
          ),
          title: Text(
            'Conversación',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontFamilyFallback: AppTypography.fontFallback,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
              tooltip: 'Finalizar y descartar conversación',
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF5A6F7B),
              onPressed: _confirmDiscard,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Indicador si el micrófono está escuchando activamente
              if (_isListening)
                Container(
                  color: AppColors.primaryTealLight,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mic_rounded,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Escuchando audio del interlocutor...',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontFamilyFallback: AppTypography.fontFallback,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTealDark,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _toggleMic,
                        child: const Text('Detener'),
                      ),
                    ],
                  ),
                ),

              // Lista de mensajes de conversación
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message.sender == MessageSender.user;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // Burbuja de mensaje
                            Semantics(
                              label: '${isUser ? "Vos" : "Interlocutor"}: ${message.text}',
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? (isDark ? const Color(0xFF103F45) : const Color(0xFFE2F3F4))
                                      : (isDark ? const Color(0xFF1F2B33) : const Color(0xFFEFF2F4)),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                                    bottomRight: Radius.circular(isUser ? 4 : 18),
                                  ),
                                  border: Border.all(
                                    color: isUser
                                        ? (isDark ? const Color(0xFF1B5961) : const Color(0xFFCEE5E7))
                                        : (isDark ? AppColors.borderDark : const Color(0xFFE2E7EA)),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontFamilyFallback: AppTypography.fontFallback,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.35,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message.timeFormatted,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontFamilyFallback: AppTypography.fontFallback,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Tarjeta de información detectada si corresponde
                            if (message.detectedInfo != null)
                              DetectedInfoCard(
                                detectedInfo: message.detectedInfo!,
                                onTap: () => _handleConfirmInfo(message),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Panel inferior de interacción (Accesos de 1 toque + Compositor + Control de micrófono)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : const Color(0xFFEEF2F4),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fila 1: Tres accesos rápidos circulares (Presentarme, No entendí, Confirmar)
                    Row(
                      children: [
                        Expanded(
                          child: _QuickCircleAction(
                            icon: Icons.person_outline_rounded,
                            label: 'Presentarme',
                            isDark: isDark,
                            onTap: _handlePresentation,
                          ),
                        ),
                        Expanded(
                          child: _QuickCircleAction(
                            icon: Icons.help_outline_rounded,
                            label: 'No entendí',
                            isDark: isDark,
                            onTap: () {
                              NotUnderstoodSheet.show(
                                context,
                                onOptionSelected: (phrase) {
                                  _sendMessage(textOverride: phrase);
                                },
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _QuickCircleAction(
                            icon: Icons.check_circle_outline_rounded,
                            label: 'Confirmar',
                            isDark: isDark,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => const ConfirmationScreen(
                                    initialDetectedValue: '\$35.000',
                                    category: 'Importe',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Fila 2: Compositor de texto (Teclado/Expresar + TextField + Enviar)
                    Row(
                      children: [
                        // Botón de opciones de entrada / Expresar
                        IconButton(
                          icon: const Icon(Icons.keyboard_outlined),
                          tooltip: 'Asistencia y sugerencias (Expresar)',
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF5A6F7B),
                          onPressed: _handleExpression,
                        ),
                        // Campo de texto
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontFamilyFallback: AppTypography.fontFallback,
                              fontSize: 15,
                              color: textPrimary,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Escribí tu mensaje…',
                              hintStyle: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontFamilyFallback: AppTypography.fontFallback,
                                fontSize: 15,
                                color: textSecondary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.surfaceMutedDark
                                  : const Color(0xFFF3F6F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botón enviar
                        Semantics(
                          button: true,
                          label: 'Enviar mensaje',
                          child: InkWell(
                            onTap: () => _sendMessage(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fila 3: Control de micrófono y reproducción (Silenciar + Botón grande Mic + TTS)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isMuted ? Icons.mic_off : Icons.mic_off_outlined,
                            color: _isMuted ? AppColors.error : (isDark ? AppColors.textMutedDark : const Color(0xFF7A8D99)),
                          ),
                          tooltip: _isMuted ? 'Audio silenciado' : 'Silenciar entrada',
                          onPressed: _toggleMute,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Semantics(
                              button: true,
                              label: _isListening ? 'Detener micrófono' : 'Tocar para hablar',
                              child: InkWell(
                                onTap: _toggleMic,
                                borderRadius: BorderRadius.circular(33),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: _isListening ? Colors.red : AppColors.primaryTeal,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isListening ? Colors.red : AppColors.primaryTeal).withValues(alpha: 0.35),
                                        offset: const Offset(0, 4),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isListening ? 'Escuchando...' : 'Tocá para hablar',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontFamilyFallback: AppTypography.fontFallback,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _isListening ? Colors.red : textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.volume_up_outlined,
                            color: isDark ? AppColors.textMutedDark : const Color(0xFF7A8D99),
                          ),
                          tooltip: 'Reproducir último mensaje en voz alta',
                          onPressed: _playLastMessageTts,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCircleAction extends StatelessWidget {
  const _QuickCircleAction({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceMutedDark : const Color(0xFFF1F4F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: AppColors.primaryTeal,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontFamilyFallback: AppTypography.fontFallback,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF536773),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
