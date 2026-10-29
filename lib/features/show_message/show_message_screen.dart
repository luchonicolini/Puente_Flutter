import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ShowMessageScreen extends StatefulWidget {
  const ShowMessageScreen({
    super.key,
    required this.initialText,
    this.isPresentation = false,
  });

  final String initialText;
  final bool isPresentation;

  @override
  State<ShowMessageScreen> createState() => _ShowMessageScreenState();
}

class _ShowMessageScreenState extends State<ShowMessageScreen> {
  late String _currentText;
  bool _isFlipped = false;
  double _fontSize = 40.0;

  @override
  void initState() {
    super.initState();
    _currentText = widget.initialText;
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _editText() async {
    final controller = TextEditingController(text: _currentText);
    final updatedText = await showDialog<String>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            'Editar mensaje',
            style: AppTypography.screenTitle(
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            autofocus: true,
            style: AppTypography.body(
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: const InputDecoration(
              hintText: 'Escribí el texto para mostrar...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (updatedText != null && updatedText.isNotEmpty && mounted) {
      setState(() {
        _currentText = updatedText;
      });
    }
  }

  void _speakText() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reproduciendo en voz alta: "$_currentText"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.isPresentation ? 'Presentación personal' : 'Mostrar mensaje',
          style: AppTypography.screenTitle(textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase_rounded),
            tooltip: 'Aumentar tamaño',
            onPressed: () {
              if (_fontSize < 56) {
                setState(() => _fontSize += 4);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded),
            tooltip: 'Reducir tamaño',
            onPressed: () {
              if (_fontSize > 28) {
                setState(() => _fontSize -= 4);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenido en texto grande con opción de rotación 180°
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Transform.rotate(
                    angle: _isFlipped ? math.pi : 0,
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _currentText,
                        textAlign: TextAlign.center,
                        style: AppTypography.showMessage(textPrimary, fontSize: _fontSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Barra de controles inferiores
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Reproducir'),
                      onPressed: _speakText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(_isFlipped ? Icons.screen_rotation_rounded : Icons.flip_camera_android_rounded),
                      label: Text(_isFlipped ? 'Normal' : 'Girar 180°'),
                      onPressed: _toggleFlip,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar'),
                      onPressed: _editText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
