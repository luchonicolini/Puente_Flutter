import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/sensitive_data_item.dart';
import '../../domain/services/sensitive_data_comparator.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.initialDetectedValue,
    this.category = 'Importe',
  });

  final String initialDetectedValue;
  final String category;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  late final TextEditingController _writtenController;
  late String _selectedCategory;
  bool _hasCompared = false;
  bool _isMatch = false;

  static const List<String> categories = <String>[
    'Importe',
    'Fecha',
    'Horario',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _writtenController = TextEditingController();
  }

  @override
  void dispose() {
    _writtenController.dispose();
    super.dispose();
  }

  void _compareValues() {
    final written = _writtenController.text.trim();
    if (written.isEmpty) return;

    final category = SensitiveDataCategory.fromString(_selectedCategory);
    final result = const SensitiveDataComparator().compare(
      detected: widget.initialDetectedValue,
      written: written,
      category: category,
    );

    setState(() {
      _hasCompared = true;
      _isMatch = result.isMatch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar información', style: AppTypography.screenTitle(textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de tipo de dato
              Text('Tipo de información:', style: AppTypography.secondary(textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryTeal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Tarjeta del dato detectado (audio)
              Card(
                color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mic_none_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Valor detectado en conversación:',
                              style: AppTypography.metadata(AppColors.warning)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.initialDetectedValue,
                        style: AppTypography.display(textPrimary).copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Estado: Sin confirmar por escrito.',
                        style: AppTypography.metadata(textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo para que el interlocutor escriba el dato
              Text(
                'Pedile a la otra persona que escriba el dato exacto:',
                style: AppTypography.sectionTitle(textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _writtenController,
                style: AppTypography.display(textPrimary).copyWith(fontSize: 26),
                decoration: InputDecoration(
                  hintText: 'Ej. 15000',
                  hintStyle: AppTypography.display(textSecondary).copyWith(fontSize: 26),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                keyboardType: _selectedCategory == 'Importe' ? TextInputType.number : TextInputType.text,
                onChanged: (_) {
                  if (_hasCompared) {
                    setState(() => _hasCompared = false);
                  }
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text('Comparar datos'),
                onPressed: _compareValues,
              ),
              const SizedBox(height: 20),

              // Resultado de comparación
              if (_hasCompared) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isMatch
                        ? (isDark ? AppColors.success.withValues(alpha: 0.15) : AppColors.successLight)
                        : (isDark ? AppColors.error.withValues(alpha: 0.15) : AppColors.errorLight),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isMatch ? AppColors.success : AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isMatch ? Icons.check_circle_rounded : Icons.warning_rounded,
                            color: _isMatch ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isMatch ? 'Los datos coinciden' : 'Los datos son diferentes',
                              style: AppTypography.sectionTitle(
                                _isMatch ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isMatch
                            ? 'Ambos registros coinciden con "${_writtenController.text.trim()}".'
                            : 'El valor detectado ("${widget.initialDetectedValue}") no coincide con lo escrito ("${_writtenController.text.trim()}"). Aclará la diferencia antes de continuar.',
                        style: AppTypography.body(textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Aviso importante: Que los textos coincidan no certifica que el importe sea justo ni obligatorio.',
                        style: AppTypography.metadata(textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isMatch)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Confirmar y regresar a la conversación'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
