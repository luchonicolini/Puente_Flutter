import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/confirmation/data_comparison.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    this.initialDetectedValue = '',
    this.category = 'Importe',
  });

  final String initialDetectedValue;
  final String category;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  late final TextEditingController _writtenController;
  late final TextEditingController _detectedController;
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
    _detectedController = TextEditingController(
      text: widget.initialDetectedValue,
    );
    _writtenController = TextEditingController();
  }

  @override
  void dispose() {
    _writtenController.dispose();
    _detectedController.dispose();
    super.dispose();
  }

  DataKind get _selectedKind => switch (_selectedCategory) {
    'Importe' => DataKind.amount,
    'Fecha' => DataKind.date,
    'Horario' => DataKind.time,
    _ => DataKind.text,
  };

  String get _hintForCategory => switch (_selectedCategory) {
    'Importe' => 'Ej. 35.000 o 35000',
    'Fecha' => 'Ej. 3/5/2026',
    'Horario' => 'Ej. 9:41',
    _ => 'Escribí el dato exacto',
  };

  TextInputType get _keyboardForCategory => switch (_selectedCategory) {
    'Importe' => const TextInputType.numberWithOptions(decimal: true),
    'Fecha' || 'Horario' => TextInputType.datetime,
    _ => TextInputType.text,
  };

  void _resetComparison() {
    if (!_hasCompared) return;
    setState(() => _hasCompared = false);
  }

  void _compareValues() {
    final written = _writtenController.text.trim();
    final dataToConfirm = _detectedController.text.trim();
    if (written.isEmpty || dataToConfirm.isEmpty) return;

    final result = DataComparator.compare(
      firstValue: dataToConfirm,
      secondValue: written,
      kind: _selectedKind,
    );

    setState(() {
      _hasCompared = true;
      _isMatch = result.matches;
    });
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
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        title: Text(
          'Confirmar información',
          style: AppTypography.sectionTitle(textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de tipo de dato
              Text(
                '¿Qué querés confirmar?',
                style: AppTypography.secondary(
                  textPrimary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                          _hasCompared = false;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Tarjeta del dato detectado (audio)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceMutedDark
                      : const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.mic_none_rounded,
                            color: isDark
                                ? AppColors.warningTextDark
                                : AppColors.warningTextLight,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Text(
                                widget.initialDetectedValue.isEmpty
                                    ? 'Dato a confirmar'
                                    : 'Dato detectado',
                                style: AppTypography.secondary(
                                  textPrimary,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Sin confirmar',
                                  style: AppTypography.metadata(
                                    isDark
                                        ? AppColors.warningTextDark
                                        : AppColors.warningTextLight,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _detectedController,
                      keyboardType: _keyboardForCategory,
                      style: AppTypography.display(
                        textPrimary,
                      ).copyWith(fontSize: 26),
                      decoration: InputDecoration(
                        hintText: _hintForCategory,
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => _resetComparison(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.initialDetectedValue.isEmpty
                          ? 'Escribí el dato y pedile a la otra persona que lo confirme por escrito.'
                          : 'Este valor proviene de la conversación. Podés corregirlo si la transcripción no fue exacta.',
                      style: AppTypography.secondary(textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Campo para que el interlocutor escriba el dato
              Text(
                'Dato escrito por la otra persona',
                style: AppTypography.secondary(
                  textPrimary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _writtenController,
                style: AppTypography.display(
                  textPrimary,
                ).copyWith(fontSize: 26),
                decoration: InputDecoration(
                  hintText: _hintForCategory,
                  hintStyle: AppTypography.display(
                    textSecondary,
                  ).copyWith(fontSize: 26),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
                keyboardType: _keyboardForCategory,
                onChanged: (_) => _resetComparison(),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text('Comparar datos'),
                onPressed: _compareValues,
              ),
              const SizedBox(height: 18),

              // Resultado de comparación
              AnimatedSize(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    if (disableAnimations) return child;
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: _hasCompared
                      ? Column(
                          key: ValueKey(
                            'cmp_${_isMatch}_${_detectedController.text.trim()}_${_writtenController.text.trim()}',
                          ),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _isMatch
                                    ? (isDark
                                          ? AppColors.success.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.successLight)
                                    : (isDark
                                          ? AppColors.error.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.errorLight),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _isMatch
                                      ? (isDark
                                            ? AppColors.successTextDark
                                            : AppColors.success)
                                      : (isDark
                                            ? AppColors.errorTextDark
                                            : AppColors.error),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _isMatch
                                            ? Icons.check_circle_rounded
                                            : Icons.warning_rounded,
                                        color: _isMatch
                                            ? (isDark
                                                  ? AppColors.successTextDark
                                                  : AppColors.success)
                                            : (isDark
                                                  ? AppColors.errorTextDark
                                                  : AppColors.error),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _isMatch
                                              ? 'Los datos coinciden'
                                              : 'Los datos son diferentes',
                                          style: AppTypography.sectionTitle(
                                            _isMatch
                                                ? (isDark
                                                      ? AppColors.successTextDark
                                                      : AppColors.success)
                                                : (isDark
                                                      ? AppColors.errorTextDark
                                                      : AppColors.error),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isMatch
                                        ? 'El valor detectado y el valor escrito coinciden: "${_writtenController.text.trim()}".'
                                        : 'El valor a confirmar ("${_detectedController.text.trim()}") no coincide con lo escrito ("${_writtenController.text.trim()}"). Aclará la diferencia antes de continuar.',
                                    style: AppTypography.body(textPrimary),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Importante: que los datos coincidan no garantiza que sean verdaderos, justos ni definitivos.',
                                    style: AppTypography.metadata(
                                      textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isMatch)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text(
                                  'Confirmar y regresar a la conversación',
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
