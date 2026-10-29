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

  final List<ChatMessage> _messages = <ChatMessage>[
    ChatMessage(
      id: '1',
      text: '¡Hola! ¿En qué puedo ayudarte hoy?',
      sender: MessageSender.interlocutor,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      id: '2',
      text: 'Hola, quería consultar el valor de la cuota mensual.',
      sender: MessageSender.user,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    ChatMessage(
      id: '3',
      text: 'La cuota mensual es de \$15.000 e incluye todas las clases.',
      sender: MessageSender.interlocutor,
      timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      detectedValue: '\$15.000',
      isConfirmed: false,
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? textOverride}) {
    final text = textOverride ?? _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          sender: MessageSender.user,
          timestamp: DateTime.now(),
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

    if (_isListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Micrófono activado: escuchando a la otra persona...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleConfirmInfo(ChatMessage message) async {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ConfirmationScreen(
          initialDetectedValue: message.detectedValue ?? '',
          category: 'Importe',
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(isConfirmed: true);
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
              'Hola, soy una persona sorda. Nos comunicamos por escrito o podés hablar despacio y mi teléfono mostrará lo que decís.',
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
            'Por privacidad, los mensajes se descartarán a menos que hayas confirmado un dato puntual.',
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
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmDiscard();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conversación', style: AppTypography.screenTitle(textPrimary)),
              if (widget.initialContext != null)
                Text(
                  widget.initialContext!,
                  style: AppTypography.metadata(AppColors.primaryTeal),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Finalizar conversación',
              onPressed: _confirmDiscard,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Fila persistente de acciones rápidas superiores
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          side: const BorderSide(color: AppColors.primaryTeal),
                        ),
                        icon: const Icon(Icons.contact_mail_outlined, size: 18),
                        label: const Text('Presentarme', overflow: TextOverflow.ellipsis),
                        onPressed: _handlePresentation,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: AppColors.warning,
                        ),
                        icon: const Icon(Icons.help_outline_rounded, size: 18),
                        label: const Text('No entendí', overflow: TextOverflow.ellipsis),
                        onPressed: () {
                          NotUnderstoodSheet.show(
                            context,
                            onOptionSelected: (phrase) {
                              _sendMessage(textOverride: phrase);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Indicador de micrófono si está escuchando
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
                          style: AppTypography.metadata(AppColors.primaryTealDark),
                        ),
                      ),
                      TextButton(
                        onPressed: _toggleMic,
                        child: const Text('Detener'),
                      ),
                    ],
                  ),
                ),

              // Lista de mensajes (Burbujas)
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message.sender == MessageSender.user;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // Etiqueta semántica de participante (accesibilidad)
                            Text(
                              isUser ? 'Vos' : 'Otra persona',
                              style: AppTypography.metadata(textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? (isDark ? AppColors.bubbleUserDark : AppColors.bubbleUserLight)
                                    : (isDark ? AppColors.bubbleOtherDark : AppColors.bubbleOtherLight),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 16),
                                ),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: Text(
                                message.text,
                                style: AppTypography.conversation(textPrimary),
                              ),
                            ),
                            // Tarjeta de información detectada si corresponde
                            if (message.detectedValue != null)
                              DetectedInfoCard(
                                detectedValue: message.detectedValue!,
                                isConfirmed: message.isConfirmed,
                                onConfirmTap: () => _handleConfirmInfo(message),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Área inferior de composición y entrada
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Botón Expresar (asistencia de claridad)
                        IconButton(
                          icon: const Icon(Icons.auto_awesome_rounded),
                          tooltip: 'Expresar (claridad y sugerencias)',
                          color: AppColors.primaryTeal,
                          onPressed: _handleExpression,
                        ),
                        // Botón Mostrar mensaje en pantalla grande
                        IconButton(
                          icon: const Icon(Icons.fullscreen_rounded),
                          tooltip: 'Mostrar en grande al interlocutor',
                          color: AppColors.primaryTeal,
                          onPressed: _handleShowMessage,
                        ),
                        // Campo de texto
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: AppTypography.body(textPrimary),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Escribí tu mensaje…',
                              hintStyle: AppTypography.body(textSecondary),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.surfaceMutedDark
                                  : AppColors.surfaceMutedLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Micrófono explícito
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: _isListening ? Colors.red : AppColors.primaryTeal,
                          ),
                          tooltip: _isListening ? 'Detener escucha' : 'Escuchar respuesta',
                          onPressed: _toggleMic,
                        ),
                        // Enviar
                        IconButton(
                          icon: const Icon(Icons.send_rounded),
                          tooltip: 'Enviar mensaje',
                          color: AppColors.primaryTeal,
                          onPressed: () => _sendMessage(),
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
