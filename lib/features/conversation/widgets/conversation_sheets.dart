import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/confirmation/data_comparison.dart';
import '../models/chat_message.dart';

typedef WrittenDataResult = ({String label, String value, DataKind kind});

/// Modal amplio pensado para pasarle el teléfono a la otra persona y que
/// escriba su respuesta sin tener que entender controles internos del chat.
class InterlocutorWriteSheet extends StatefulWidget {
  const InterlocutorWriteSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InterlocutorWriteSheet(),
    );
  }

  @override
  State<InterlocutorWriteSheet> createState() => _InterlocutorWriteSheetState();
}

class _InterlocutorWriteSheetState extends State<InterlocutorWriteSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isFlipped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Transform.rotate(
            angle: _isFlipped ? math.pi : 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      color: isDark
                          ? AppColors.primaryTealOnDark
                          : AppColors.primaryTeal,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Escribí tu respuesta',
                        style: AppTypography.screenTitle(textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.screen_rotation_outlined),
                      tooltip: _isFlipped ? 'Volver a mí' : 'Girar 180°',
                      onPressed: () => setState(() => _isFlipped = !_isFlipped),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Se agregará a la conversación como respuesta de la otra persona.',
                  style: AppTypography.secondary(textSecondary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTypography.conversation(textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Escribí acá tu respuesta…',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceMutedDark
                        : AppColors.surfaceMutedLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Enviar respuesta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja de selección cuando un mensaje contiene más de un dato sensible.
class DetectedItemPickerSheet extends StatelessWidget {
  const DetectedItemPickerSheet({super.key, required this.detectedInfo});

  final DetectedInfo detectedInfo;

  static Future<String?> show(
    BuildContext context, {
    required DetectedInfo detectedInfo,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetectedItemPickerSheet(detectedInfo: detectedInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '¿Qué dato querés confirmar?',
                      style: AppTypography.screenTitle(textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Se detectaron varios datos en este mensaje. Elegí uno para contrastarlo por escrito:',
                style: AppTypography.secondary(textSecondary),
              ),
              const SizedBox(height: 14),
              for (final entry in detectedInfo.items.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isDark
                        ? AppColors.surfaceMutedDark
                        : AppColors.surfaceMutedLight,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).pop(entry.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppTypography.metadata(
                                      textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.value,
                                    style: AppTypography.sectionTitle(
                                      textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (detectedInfo.isKeyConfirmed(entry.key))
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark
                                    ? AppColors.successTextDark
                                    : AppColors.success,
                              )
                            else
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: isDark
                                    ? AppColors.primaryTealOnDark
                                    : AppColors.primaryTeal,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum QuickConfirmOption { askToWrite, compareManually }

/// Opciones al pulsar el botón rápido «Confirmar» sin datos pendientes.
class ConfirmQuickChoiceSheet extends StatelessWidget {
  const ConfirmQuickChoiceSheet({super.key});

  static Future<QuickConfirmOption?> show(BuildContext context) {
    return showModalBottomSheet<QuickConfirmOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ConfirmQuickChoiceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Confirmar un dato',
                      style: AppTypography.screenTitle(textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Elegí cómo querés verificar precios, fechas u horarios con la otra persona:',
                style: AppTypography.secondary(textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop(QuickConfirmOption.askToWrite),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Pedirle que escriba el dato'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).pop(QuickConfirmOption.compareManually),
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text('Comparar un dato que escuché'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal directo para que la otra persona escriba un dato sensible (monto,
/// fecha, horario u otro) en formato grande y quede confirmado en el chat.
class InterlocutorDataRequestSheet extends StatefulWidget {
  const InterlocutorDataRequestSheet({super.key});

  static Future<WrittenDataResult?> show(BuildContext context) {
    return showModalBottomSheet<WrittenDataResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InterlocutorDataRequestSheet(),
    );
  }

  @override
  State<InterlocutorDataRequestSheet> createState() =>
      _InterlocutorDataRequestSheetState();
}

class _InterlocutorDataRequestSheetState
    extends State<InterlocutorDataRequestSheet> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'Importe';
  bool _isFlipped = false;

  static const List<String> _categories = ['Importe', 'Fecha', 'Horario', 'Otro'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DataKind get _kind => switch (_selectedCategory) {
    'Importe' => DataKind.amount,
    'Fecha' => DataKind.date,
    'Horario' => DataKind.time,
    _ => DataKind.text,
  };

  TextInputType get _keyboard => switch (_selectedCategory) {
    'Importe' => const TextInputType.numberWithOptions(decimal: true),
    'Fecha' || 'Horario' => TextInputType.datetime,
    _ => TextInputType.text,
  };

  String get _hint => switch (_selectedCategory) {
    'Importe' => 'Ej. 35.000',
    'Fecha' => 'Ej. 15/11/2026',
    'Horario' => 'Ej. 14:30',
    _ => 'Escribí el dato exacto',
  };

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop((
      label: _selectedCategory == 'Otro' ? 'Dato' : _selectedCategory,
      value: value,
      kind: _kind,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Transform.rotate(
            angle: _isFlipped ? math.pi : 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      color: isDark
                          ? AppColors.primaryTealOnDark
                          : AppColors.primaryTeal,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¿Podés escribir el dato acá?',
                        style: AppTypography.screenTitle(textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.screen_rotation_outlined),
                      tooltip: _isFlipped ? 'Volver a mí' : 'Girar 180°',
                      onPressed: () => setState(() => _isFlipped = !_isFlipped),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _categories.map((category) {
                    final selected = category == _selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      selectedColor: AppColors.primaryTeal,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : textPrimary,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: _keyboard,
                  style: AppTypography.display(
                    textPrimary,
                  ).copyWith(fontSize: 26),
                  decoration: InputDecoration(
                    hintText: _hint,
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceMutedDark
                        : AppColors.surfaceMutedLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se agregará como dato escrito en la conversación. Recordá revisar si corresponde a lo acordado.',
                  style: AppTypography.metadata(textSecondary),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Confirmar y agregar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
