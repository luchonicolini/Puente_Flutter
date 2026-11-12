import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/services_providers.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/top_alert_banner.dart';

class ShowMessageScreen extends StatelessWidget {
  const ShowMessageScreen({
    super.key,
    this.initialText = '',
    this.isPresentation = false,
    this.onSavePresentation,
  });

  final String initialText;
  final bool isPresentation;
  final ValueChanged<String>? onSavePresentation;

  @override
  Widget build(BuildContext context) {
    try {
      ProviderScope.containerOf(context, listen: false);
      return _ShowMessageScreenBody(
        initialText: initialText,
        isPresentation: isPresentation,
        onSavePresentation: onSavePresentation,
      );
    } catch (_) {
      return ProviderScope(
        child: _ShowMessageScreenBody(
          initialText: initialText,
          isPresentation: isPresentation,
          onSavePresentation: onSavePresentation,
        ),
      );
    }
  }
}

class _ShowMessageScreenBody extends ConsumerStatefulWidget {
  const _ShowMessageScreenBody({
    required this.initialText,
    this.isPresentation = false,
    this.onSavePresentation,
  });

  final String initialText;
  final bool isPresentation;
  final ValueChanged<String>? onSavePresentation;

  @override
  ConsumerState<_ShowMessageScreenBody> createState() =>
      _ShowMessageScreenBodyState();
}

class _ShowMessageScreenBodyState
    extends ConsumerState<_ShowMessageScreenBody> {
  late String _currentText;
  late bool _isEditing;
  late final TextEditingController _editController;
  late final TtsService _ttsService;
  bool _isFlipped = false;
  bool _savePresentationAsDefault = false;
  double _fontSize = 40.0;
  TopAlertData? _activeAlert;
  Timer? _alertTimer;

  @override
  void initState() {
    super.initState();
    _currentText = widget.initialText.trim();
    _isEditing = _currentText.isEmpty;
    _editController = TextEditingController(text: _currentText);
    _ttsService = ref.read(ttsServiceProvider);
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    _editController.dispose();
    unawaited(_ttsService.stop());
    super.dispose();
  }

  void _showAlert(TopAlertData alert) {
    _alertTimer?.cancel();
    if (mounted) {
      setState(() => _activeAlert = alert);
    }
    _alertTimer = Timer(alert.duration, () {
      if (mounted) {
        setState(() => _activeAlert = null);
      }
    });
  }

  void _dismissAlert() {
    _alertTimer?.cancel();
    if (mounted) {
      setState(() => _activeAlert = null);
    }
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _startEditing() {
    _editController.text = _currentText;
    setState(() {
      _isFlipped = false;
      _savePresentationAsDefault = false;
      _isEditing = true;
    });
  }

  void _submitEdit() {
    final trimmed = _editController.text.trim();
    if (trimmed.isEmpty) {
      _showAlert(
        const TopAlertData(
          message: 'Escribí un mensaje antes de mostrarlo en grande.',
          type: AlertType.warning,
        ),
      );
      return;
    }

    if (widget.isPresentation && _savePresentationAsDefault) {
      final updated = ref
          .read(appPreferencesProvider)
          .copyWith(presentationText: trimmed);
      ref.read(appPreferencesProvider.notifier).state = updated;
      widget.onSavePresentation?.call(trimmed);
    }

    setState(() {
      _currentText = trimmed;
      _isEditing = false;
    });
  }

  void _speakText() {
    if (_currentText.trim().isEmpty) return;

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

    unawaited(_ttsService.speak(_currentText));
    _showAlert(
      TopAlertData(
        message: 'Reproduciendo en voz alta: "$_currentText"',
        type: AlertType.info,
        icon: Icons.volume_up_rounded,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMessageContent(Color textPrimary, Color textSecondary) {
    if (!widget.isPresentation) {
      return Text(
        _currentText,
        textAlign: TextAlign.center,
        style: AppTypography.showMessage(textPrimary, fontSize: _fontSize),
      );
    }

    final paragraphs = _currentText
        .split(RegExp(r'\n\s*\n'))
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .toList();
    final heading = paragraphs.isEmpty ? _currentText : paragraphs.first;
    final body = paragraphs.length > 1
        ? paragraphs.sublist(1)
        : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: AppTypography.showMessage(textPrimary, fontSize: _fontSize),
        ),
        for (final paragraph in body) ...[
          const SizedBox(height: 22),
          Text(
            paragraph,
            style:
                AppTypography.body(
                  paragraph == body.last ? textSecondary : textPrimary,
                ).copyWith(
                  fontWeight: paragraph == body.last
                      ? FontWeight.w400
                      : FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildInlineEditor(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Escribí tu mensaje para mostrarlo en pantalla grande',
            style: AppTypography.secondary(textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editController,
            autofocus: true,
            minLines: 4,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.screenTitle(textPrimary),
            decoration: InputDecoration(
              hintText: 'Ej: Hola, ¿cuánto cuesta esto?',
              hintStyle: AppTypography.sectionTitle(textSecondary),
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceMutedDark
                  : AppColors.surfaceMutedLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(18),
            ),
            onSubmitted: (_) => _submitEdit(),
          ),
          if (widget.isPresentation) ...[
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primaryTeal,
              value: _savePresentationAsDefault,
              onChanged: (checked) {
                setState(() => _savePresentationAsDefault = checked ?? false);
              },
              title: Text(
                'Guardar como mi presentación habitual',
                style: AppTypography.secondary(textPrimary),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _submitEdit,
            icon: const Icon(Icons.fullscreen_rounded),
            label: const Text('Mostrar en grande'),
          ),
          if (_currentText.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isPresentation ? 'Presentarme' : 'Mostrar mensaje',
          style: AppTypography.sectionTitle(textPrimary),
        ),
        actions: _isEditing
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.text_fields_rounded),
                  tooltip: 'Cambiar tamaño de texto',
                  onPressed: () {
                    setState(() {
                      _fontSize = _fontSize == 40.0 ? 52.0 : 40.0;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar texto',
                  onPressed: _startEditing,
                ),
              ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _isEditing
                        ? KeyedSubtree(
                            key: const ValueKey('show_message_editor'),
                            child: _buildInlineEditor(
                              isDark,
                              textPrimary,
                              textSecondary,
                            ),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('show_message_viewer'),
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: AnimatedRotation(
                                  turns: _isFlipped ? 0.5 : 0.0,
                                  duration: disableAnimations
                                      ? Duration.zero
                                      : const Duration(milliseconds: 320),
                                  curve: Curves.easeOutCubic,
                                  child: _buildMessageContent(
                                    textPrimary,
                                    textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                if (!_isEditing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _speakText,
                            icon: const Icon(Icons.volume_up_outlined, size: 20),
                            label: const Text('Reproducir'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _toggleFlip,
                            icon: const Icon(
                              Icons.screen_rotation_outlined,
                              size: 20,
                            ),
                            label: Text(
                              _isFlipped ? 'Volver a mí' : 'Girar 180°',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: AnimatedSwitcher(
                duration:
                    (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
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
