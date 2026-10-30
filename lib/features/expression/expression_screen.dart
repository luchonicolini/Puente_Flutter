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

    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      final lower = input.toLowerCase();
      final isGymCase = lower.contains('gimnasio') ||
          lower.contains('inscripción') ||
          lower.contains('cuota');

      final List<String> generated;
      if (isGymCase) {
        generated = <String>[
          '¿Podría indicarme el costo mensual y qué actividades incluye?',
          'Hola, quisiera consultar el precio mensual y los horarios disponibles, por favor.',
          'Quisiera confirmar si la cuota mensual cubre todas las clases.',
        ];
      } else {
        // Generar variantes basadas en el propio texto ingresado por la persona usuaria
        final clean = input.replaceAll(RegExp(r'^[¿¡]+|[?!.]+$'), '').trim();
        final startsWithGreeting = lower.startsWith('hola') || lower.startsWith('buen');
        final greeting = startsWithGreeting ? '' : 'Hola, ';

        generated = <String>[
          // 1. Consulta formal y amable
          '$greeting quisiera consultar por favor: $clean.',
          // 2. Directa y concisa
          '¿Podría indicarme información sobre $clean?',
          // 3. Confirmación / verificación
          '¿Me podría confirmar los detalles sobre $clean, por favor?',
        ];
      }

      setState(() {
        _isLoadingSuggestions = false;
        _suggestions = generated;
        _selectedText = generated.first;
      });
    });
  }

  void _useSelected(String text) {
    Navigator.of(context).pop(text);
  }

  Future<void> _editSuggestion(String original) async {
    final controller = TextEditingController(text: original);
    final edited = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar sugerencia'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ajustá el mensaje a tu manera...',
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

    if (edited != null && edited.isNotEmpty && mounted) {
      setState(() {
        final index = _suggestions.indexOf(original);
        if (index != -1) {
          _suggestions[index] = edited;
          _selectedText = edited;
        }
      });
    }
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
              // Banner informativo sobre el modo demostración
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16252F) : const Color(0xFFE8F3F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF224251) : const Color(0xFFC3DEE3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo demostración (UI)',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontFamilyFallback: AppTypography.fontFallback,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.primaryTealDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'El servicio de IA está en evaluación de privacidad y arquitectura. Las propuestas son ejemplos ilustrativos basados en tu texto. Tu texto original se conserva siempre y nunca se envía sin tu confirmación.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontFamilyFallback: AppTypography.fontFallback,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF2E4B59),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
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
                        child: Tooltip(
                          message: 'Genera propuestas ilustrativas de reformulación (Demostración)',
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
                            label: const Text('Generar propuestas (Demo)'),
                            onPressed: _isLoadingSuggestions ||
                                    _originalController.text.trim().isEmpty
                                ? null
                                : _generateSimulatedSuggestions,
                          ),
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
                          ? (isDark
                              ? AppColors.primaryTealDark.withValues(alpha: 0.3)
                              : AppColors.primaryTealLight)
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
                            // Badge superior de demostración + botón editar
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Propuesta simulada',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontFamilyFallback: AppTypography.fontFallback,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryTeal,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.edit_outlined, size: 15),
                                  label: const Text('Editar'),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onPressed: () => _editSuggestion(suggestion),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              suggestion,
                              style: AppTypography.body(textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: const Text('Copiar'),
                                  onPressed: () => _copyToClipboard(suggestion),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.fullscreen_rounded, size: 16),
                                  label: const Text('Mostrar'),
                                  onPressed: () => _showFullscreen(suggestion),
                                ),
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
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: const Text('Usar mi texto original'),
                  onPressed: () => _useSelected(_originalController.text),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
