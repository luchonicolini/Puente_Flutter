import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/tap_scale.dart';
import '../models/chat_message.dart';

/// Panel inferior de interacción en Conversación: acciones esenciales,
/// compositor unificado y controles secundarios de audio.
class ConversationBottomPanel extends StatelessWidget {
  const ConversationBottomPanel({
    super.key,
    required this.textController,
    required this.composerSender,
    required this.isListening,
    required this.isMuted,
    required this.isKeyboardOpen,
    required this.onSelectSender,
    required this.onSend,
    required this.onPresentation,
    required this.onNotUnderstood,
    required this.onQuickConfirm,
    required this.onPassPhoneToWrite,
    required this.onOpenExpression,
    required this.onShowMessage,
    required this.onToggleMic,
    required this.onToggleMute,
    required this.onPlayLastTts,
  });

  final TextEditingController textController;
  final MessageSender composerSender;
  final bool isListening;
  final bool isMuted;
  final bool isKeyboardOpen;
  final ValueChanged<MessageSender> onSelectSender;
  final VoidCallback onSend;
  final VoidCallback onPresentation;
  final VoidCallback onNotUnderstood;
  final VoidCallback onQuickConfirm;
  final VoidCallback onPassPhoneToWrite;
  final VoidCallback onOpenExpression;
  final VoidCallback onShowMessage;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleMute;
  final VoidCallback onPlayLastTts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final mutedSurface = isDark
        ? AppColors.surfaceMutedDark
        : AppColors.surfaceMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final accentColor = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTealDark;
    final errorColor = isDark ? AppColors.errorTextDark : AppColors.error;

    final keyboardOpen = isKeyboardOpen;
    final isCompactScreen = MediaQuery.sizeOf(context).height < 640;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        isCompactScreen ? 8 : 10,
        12,
        keyboardOpen || isCompactScreen ? 8 : 14,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Acciones esenciales. «No entendí» queda visible incluso con teclado.
          Row(
            children: [
              Expanded(
                child: _QuickActionPill(
                  icon: Icons.person_outline_rounded,
                  label: 'Presentarme',
                  isDark: isDark,
                  isHighlighted: false,
                  onTap: onPresentation,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickActionPill(
                  icon: Icons.help_outline_rounded,
                  label: 'No entendí',
                  isDark: isDark,
                  isHighlighted: true,
                  onTap: onNotUnderstood,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickActionPill(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Confirmar',
                  isDark: isDark,
                  isHighlighted: false,
                  onTap: onQuickConfirm,
                ),
              ),
            ],
          ),
          // El turno y el pase del teléfono comparten una línea compacta.
          SizedBox(height: isCompactScreen ? 10 : 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final useCompactRow =
                  constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(1.0) > 1.15;
              if (useCompactRow) {
                return Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: _SenderSegmentedControl(
                        selected: composerSender,
                        isDark: isDark,
                        useFlexRow: true,
                        onSelected: onSelectSender,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 9,
                      child: _PassPhoneButton(
                        isDark: isDark,
                        accentColor: accentColor,
                        textPrimary: textPrimary,
                        borderColor: borderColor,
                        onTap: onPassPhoneToWrite,
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _SenderSegmentedControl(
                      selected: composerSender,
                      isDark: isDark,
                      useFlexRow: true,
                      onSelected: onSelectSender,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _PassPhoneButton(
                    isDark: isDark,
                    accentColor: accentColor,
                    textPrimary: textPrimary,
                    borderColor: borderColor,
                    onTap: onPassPhoneToWrite,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: isCompactScreen ? 4 : 8),

          // Compositor unificado.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_outlined),
                tooltip: 'Asistencia y sugerencias (Expresar)',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                color: textSecondary,
                onPressed: onOpenExpression,
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  minLines: 1,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontFamilyFallback: AppTypography.fontFallback,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: composerSender == MessageSender.user
                        ? 'Escribí tu mensaje…'
                        : 'Escribí lo que dice la otra persona…',
                    hintStyle: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontFamilyFallback: AppTypography.fontFallback,
                      fontSize: 15,
                      color: textSecondary,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: isCompactScreen ? 8 : 11,
                    ),
                    filled: true,
                    fillColor: mutedSurface,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.fullscreen_rounded),
                      tooltip: 'Mostrar texto en grande',
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      color: textSecondary,
                      onPressed: onShowMessage,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              if (keyboardOpen) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isMuted
                        ? Icons.mic_off_rounded
                        : isListening
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                  ),
                  tooltip: isMuted
                      ? 'Micrófono silenciado; activalo para escuchar'
                      : isListening
                      ? 'Detener micrófono'
                      : 'Tocar para transcribir',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  color: isMuted || isListening ? errorColor : accentColor,
                  onPressed: onToggleMic,
                ),
              ],
              const SizedBox(width: 6),
              TapScale(
                pressedScale: 0.93,
                child: Semantics(
                  button: true,
                  label: composerSender == MessageSender.user
                      ? 'Enviar mensaje como yo'
                      : 'Enviar mensaje como la otra persona',
                  child: Material(
                    color: AppColors.primaryTeal,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onSend,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Controles secundarios en una sola fila; se pliegan al escribir.
          if (!keyboardOpen) ...[
            SizedBox(height: isCompactScreen ? 8 : 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  color: isMuted
                      ? (isDark
                            ? AppColors.surfaceMutedDark
                            : AppColors.errorLight)
                      : mutedSurface,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(
                      isMuted ? Icons.mic_off : Icons.mic_off_outlined,
                    ),
                    color: isMuted ? errorColor : textSecondary,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    tooltip: isMuted
                        ? 'Activar micrófono'
                        : 'Silenciar micrófono',
                    onPressed: onToggleMute,
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _PrimaryMicButton(
                    isCompact: isCompactScreen,
                    isListening: isListening,
                    isMuted: isMuted,
                    isDark: isDark,
                    mutedSurface: mutedSurface,
                    borderColor: borderColor,
                    errorColor: errorColor,
                    textSecondary: textSecondary,
                    disableAnimations: disableAnimations,
                    onTap: onToggleMic,
                  ),
                ),
                const SizedBox(width: 20),
                Material(
                  color: mutedSurface,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.volume_up_outlined),
                    color: textSecondary,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    tooltip: 'Reproducir último mensaje en voz alta',
                    onPressed: onPlayLastTts,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryMicButton extends StatelessWidget {
  const _PrimaryMicButton({
    required this.isCompact,
    required this.isListening,
    required this.isMuted,
    required this.isDark,
    required this.mutedSurface,
    required this.borderColor,
    required this.errorColor,
    required this.textSecondary,
    required this.disableAnimations,
    required this.onTap,
  });

  final bool isCompact;
  final bool isListening;
  final bool isMuted;
  final bool isDark;
  final Color mutedSurface;
  final Color borderColor;
  final Color errorColor;
  final Color textSecondary;
  final bool disableAnimations;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = isMuted
        ? 'Micrófono silenciado; activalo para escuchar'
        : isListening
        ? 'Detener micrófono'
        : 'Tocar para transcribir; el texto se revisa antes de agregarlo';
    final statusLabel = isMuted
        ? 'Micrófono silenciado'
        : isListening
        ? 'Escuchando...'
        : 'Tocá para hablar';

    final fillColor = isMuted
        ? mutedSurface
        : isListening
        ? AppColors.error
        : AppColors.primaryTeal;

    final foregroundOnFill = isMuted ? errorColor : Colors.white;

    final activeBorder = isListening
        ? Border.all(
            color: isDark ? AppColors.errorTextDark : AppColors.errorLight,
            width: 3,
          )
        : isMuted
        ? Border.all(color: borderColor, width: 1)
        : null;

    if (isCompact) {
      return TapScale(
        pressedScale: 0.96,
        child: Semantics(
          button: true,
          label: semanticLabel,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(26),
              child: AnimatedContainer(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minHeight: 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(26),
                  border: activeBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isListening)
                      ListeningWaveIndicator(
                        color: foregroundOnFill,
                        width: 22,
                        height: 22,
                        barWidth: 4,
                      )
                    else
                      Icon(
                        isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: foregroundOnFill,
                        size: 22,
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        statusLabel,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: AppTypography.secondary(
                          foregroundOnFill,
                        ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TapScale(
          pressedScale: 0.94,
          child: Semantics(
            button: true,
            label: semanticLabel,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onTap,
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: fillColor,
                        shape: BoxShape.circle,
                        border: activeBorder,
                      ),
                      child: Center(
                        child: isListening
                            ? ListeningWaveIndicator(
                                color: foregroundOnFill,
                                width: 30,
                                height: 30,
                                barWidth: 5,
                              )
                            : Icon(
                                isMuted
                                    ? Icons.mic_off_rounded
                                    : Icons.mic_rounded,
                                color: foregroundOnFill,
                                size: 30,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          statusLabel,
          textAlign: TextAlign.center,
          style: AppTypography.secondary(
            isMuted || isListening ? errorColor : textSecondary,
          ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.isHighlighted,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isHighlighted
        ? (isDark
              ? AppColors.primaryTealDark.withValues(alpha: 0.45)
              : AppColors.primaryTealLight)
        : (isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight);

    final borderColor = isHighlighted
        ? (isDark
              ? AppColors.primaryTealOnDark.withValues(alpha: 0.55)
              : AppColors.primaryTealMuted)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final iconColor = isHighlighted
        ? (isDark ? AppColors.primaryTealLight : AppColors.primaryTealDark)
        : (isDark ? AppColors.primaryTealOnDark : AppColors.primaryTealDark);

    final labelColor = isHighlighted
        ? (isDark ? AppColors.primaryTealLight : AppColors.primaryTealDark)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return TapScale(
      pressedScale: 0.96,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 15, color: iconColor),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontFamilyFallback: AppTypography.fontFallback,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SenderSegmentedControl extends StatelessWidget {
  const _SenderSegmentedControl({
    required this.selected,
    required this.isDark,
    required this.useFlexRow,
    required this.onSelected,
  });

  final MessageSender selected;
  final bool isDark;
  final bool useFlexRow;
  final ValueChanged<MessageSender> onSelected;

  @override
  Widget build(BuildContext context) {
    final containerBg = isDark
        ? AppColors.surfaceMutedDark
        : AppColors.surfaceMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final yoOption = _SegmentOption(
      label: 'Yo',
      semanticLabel: '¿Quién escribe? Yo',
      isSelected: selected == MessageSender.user,
      isDark: isDark,
      compactPadding: useFlexRow,
      onTap: () => onSelected(MessageSender.user),
    );

    final otherOption = _SegmentOption(
      label: 'La otra persona',
      semanticLabel: '¿Quién escribe? La otra persona',
      isSelected: selected == MessageSender.interlocutor,
      isDark: isDark,
      compactPadding: useFlexRow,
      onTap: () => onSelected(MessageSender.interlocutor),
    );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: useFlexRow
          ? Row(
              children: [
                Flexible(flex: 3, child: yoOption),
                const SizedBox(width: 2),
                Expanded(flex: 7, child: otherOption),
              ],
            )
          : Wrap(
              spacing: 2,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [yoOption, otherOption],
            ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.isDark,
    this.compactPadding = false,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool isSelected;
  final bool isDark;
  final bool compactPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final activeBorder = isDark
        ? AppColors.primaryTealOnDark.withValues(alpha: 0.45)
        : AppColors.primaryTealMuted;
    final activeText = isDark
        ? AppColors.primaryTealLight
        : AppColors.primaryTealDark;
    final inactiveText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compactPadding ? 6 : 10,
                vertical: compactPadding ? 5 : 6,
              ),
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: activeBorder),
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontFamilyFallback: AppTypography.fontFallback,
                  fontSize: 13,
                  height: 1.15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeText : inactiveText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PassPhoneButton extends StatelessWidget {
  const _PassPhoneButton({
    required this.isDark,
    required this.accentColor,
    required this.textPrimary,
    required this.borderColor,
    required this.onTap,
  });

  final bool isDark;
  final Color accentColor;
  final Color textPrimary;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.screen_rotation_outlined,
                  size: 16,
                  color: accentColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Pasar para escribir',
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontFamilyFallback: AppTypography.fontFallback,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Movimiento visual que indica que el micrófono está activo.
/// No representa el volumen ni confirma que haya voz detectada.
class ListeningWaveIndicator extends StatefulWidget {
  const ListeningWaveIndicator({
    super.key,
    this.color = AppColors.primaryTeal,
    this.width = 27,
    this.height = 28,
    this.barWidth = 5,
  });

  final Color color;
  final double width;
  final double height;
  final double barWidth;

  @override
  State<ListeningWaveIndicator> createState() => _ListeningWaveIndicatorState();
}

class _ListeningWaveIndicatorState extends State<ListeningWaveIndicator>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _disableAnimations = false;
  bool _appVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _syncAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appVisible = state == AppLifecycleState.resumed;
    _syncAnimation();
  }

  void _syncAnimation() {
    if (!_controller.isAnimating && !_disableAnimations && _appVisible) {
      _controller.repeat();
    } else if (_controller.isAnimating &&
        (_disableAnimations || !_appVisible)) {
      _controller.stop(canceled: false);
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (disableAnimations != _disableAnimations) {
      _disableAnimations = disableAnimations;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncAnimation();
      });
    }

    if (disableAnimations) {
      const staticScales = [0.65, 1.0, 0.65];
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(3, (index) {
            return Container(
              width: widget.barWidth,
              height: widget.height * 0.86 * staticScales[index],
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(3, (index) {
            final phase = _controller.value * math.pi * 2 + index * 1.2;
            final scale = 0.4 + ((math.sin(phase) + 1) / 2) * 0.6;
            return Transform.scale(
              scaleY: scale,
              alignment: Alignment.center,
              child: Container(
                width: widget.barWidth,
                height: widget.height * 0.86,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
