import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../show_message/show_message_screen.dart';

class ExpressionScreen extends StatefulWidget {
  const ExpressionScreen({
    super.key,
    this.initialText,
  });

  final String? initialText;

  @override
  State<ExpressionScreen> createState() => _ExpressionScreenState();
}

class _ExpressionScreenState extends State<ExpressionScreen> {
  late final TextEditingController _originalController;
  bool _isLoadingSuggestions = false;
  List<String> _suggestions = <String>[];
  String? _selectedText;

  @override
  void initState() {
    super.initState();
    _originalController = TextEditingController(text: widget.initialText ?? '');
    if (_originalController.text.isNotEmpty) {
      _generateSimulatedSuggestions();
    }
  }

  @override
  void dispose() {
    _originalController.dispose();
    super.dispose();
  }

  void _generateSimulatedSuggestions() {
    final input = _originalController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoadingSuggestions = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isLoadingSuggestions = false;
        // Demostración estructurada respetando el texto original
        _suggestions = <String>[
          '¿Podría indicarme el costo mensual y qué actividades incluye?',
          'Hola, quisiera consultar el precio mensual y los horarios disponibles, por favor.',
          'Quisiera confirmar si la cuota mensual cubre todas las clases.',
        ];
        _selectedText = _suggestions.first;
      });
    });
  }

  void _useSelected(String text) {
    Navigator.of(context).pop(text);
  }

  void _showFullscreen(String text) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ShowMessageScreen(
          initialText: text,
          isPresentation: false,
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje copiado al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expresar', style: AppTypography.screenTitle(textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tu mensaje original se conserva siempre.',
                style: AppTypography.secondary(textSecondary),
              ),
              const SizedBox(height: 12),

              // Área de texto original (editable)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tu mensaje', style: AppTypography.sectionTitle(textPrimary)),
                          if (_originalController.text.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Usar mi texto original'),
                              onPressed: () => _useSelected(_originalController.text),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _originalController,
                        maxLines: 4,
                        style: AppTypography.body(textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Escribí lo que querés comunicar...',
                          border: InputBorder.none,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: _isLoadingSuggestions
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome_rounded, size: 18),
                          label: const Text('Mejorar con IA'),
                          onPressed: _isLoadingSuggestions || _originalController.text.trim().isEmpty
                              ? null
                              : _generateSimulatedSuggestions,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sección de sugerencias y alternativas
              if (_suggestions.isNotEmpty) ...[
                Text(
                  'Sugerencias alternativas (elegí o editá):',
                  style: AppTypography.sectionTitle(textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Podés seleccionar una propuesta, editarla o seguir usando tu mensaje original.',
                  style: AppTypography.metadata(textSecondary),
                ),
                const SizedBox(height: 12),
                ..._suggestions.map((suggestion) {
                  final isSelected = _selectedText == suggestion;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: isSelected
                          ? (isDark ? AppColors.primaryTealDark.withValues(alpha: 0.3) : AppColors.primaryTealLight)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryTeal : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion,
                              style: AppTypography.body(textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: const Text('Copiar'),
                                  onPressed: () => _copyToClipboard(suggestion),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.fullscreen_rounded, size: 16),
                                  label: const Text('Mostrar'),
                                  onPressed: () => _showFullscreen(suggestion),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(90, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () => _useSelected(suggestion),
                                  child: const Text('Usar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
