import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Diálogo reutilizable para editar o ingresar texto breve administrando el ciclo
/// de vida de [TextEditingController] dentro de su propio estado hasta finalizar
/// la animación de cierre de la ruta.
class TextEditDialog extends StatefulWidget {
  const TextEditDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    this.initialText = '',
    this.labelText,
    this.hintText,
    this.helperText,
    this.minLines = 1,
    this.maxLines = 5,
    this.requireNonEmpty = false,
  });

  final String title;
  final String confirmLabel;
  final String initialText;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final int minLines;
  final int maxLines;
  final bool requireNonEmpty;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String initialText = '',
    String? labelText,
    String? hintText,
    String? helperText,
    int minLines = 1,
    int maxLines = 5,
    bool requireNonEmpty = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => TextEditDialog(
        title: title,
        confirmLabel: confirmLabel,
        initialText: initialText,
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        minLines: minLines,
        maxLines: maxLines,
        requireNonEmpty: requireNonEmpty,
      ),
    );
  }

  @override
  State<TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<TextEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = widget.requireNonEmpty
        ? _controller.text.trim()
        : _controller.text;
    if (widget.requireNonEmpty && value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return AlertDialog(
      title: Text(widget.title, style: AppTypography.screenTitle(textPrimary)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: AppTypography.body(textPrimary),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
        ),
        onSubmitted: (_) => _confirm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: _confirm,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
