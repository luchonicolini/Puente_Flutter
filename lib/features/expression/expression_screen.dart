import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/services_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smooth_entrance.dart';
import '../../core/widgets/tap_scale.dart';
import '../../core/widgets/text_edit_dialog.dart';
import '../../domain/expression/expression_alternatives.dart';
import '../../domain/expression/expression_assist.dart';

class ExpressionScreen extends StatelessWidget {
  const ExpressionScreen({
    super.key,
    this.initialText,
    this.onUseExpressionAiChanged,
  });

  final String? initialText;
  final ValueChanged<bool>? onUseExpressionAiChanged;

  @override
  Widget build(BuildContext context) {
    try {
      ProviderScope.containerOf(context, listen: false);
      return _ExpressionScreenBody(
        initialText: initialText,
        onUseExpressionAiChanged: onUseExpressionAiChanged,
      );
    } catch (_) {
      return ProviderScope(
        child: _ExpressionScreenBody(
          initialText: initialText,
          onUseExpressionAiChanged: onUseExpressionAiChanged,
        ),
      );
    }
  }
}

class _ExpressionScreenBody extends ConsumerStatefulWidget {
  const _ExpressionScreenBody({
    this.initialText,
    this.onUseExpressionAiChanged,
  });

  final String? initialText;
  final ValueChanged<bool>? onUseExpressionAiChanged;

  @override
  ConsumerState<_ExpressionScreenBody> createState() =>
      _ExpressionScreenBodyState();
}

class _ExpressionScreenBodyState extends ConsumerState<_ExpressionScreenBody> {
  late final TextEditingController _originalController;
  List<ExpressionSuggestion> _suggestions = const [];
  ExpressionAssistSource _suggestionsSource = ExpressionAssistSource.local;
  int? _selectedSuggestionIndex;
  ExpressionIntent? _selectedInterpretation;

  bool _isLoadingAi = false;
  String? _aiStatusMessage;
  bool _aiHasAmbiguity = false;
  String _aiAmbiguityReason = '';
  String _aiUncertaintyNote = '';
  List<ExpressionInterpretationOption> _aiInterpretations = const [];
  String? _selectedAiInterpretationId;

  @override
  void initState() {
    super.initState();
    _originalController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _originalController.dispose();
    super.dispose();
  }

  bool get _looksAmbiguous =>
      ExpressionAlternatives.looksAmbiguous(_originalController.text);

  void _resetSuggestionsState() {
    _suggestions = const [];
    _selectedSuggestionIndex = null;
    _aiStatusMessage = null;
    _aiHasAmbiguity = false;
    _aiAmbiguityReason = '';
    _aiUncertaintyNote = '';
    _aiInterpretations = const [];
    _selectedAiInterpretationId = null;
  }

  void _createLocalAlternatives() {
    final original = _originalController.text.trim();
    if (original.isEmpty) return;

    final local = ExpressionAssistResult.local(
      input: original,
      intent: _selectedInterpretation,
    );

    setState(() {
      _suggestions = local.suggestions;
      _suggestionsSource = ExpressionAssistSource.local;
      _selectedSuggestionIndex = 0;
      _aiStatusMessage = null;
      _aiHasAmbiguity = false;
      _aiAmbiguityReason = '';
      _aiUncertaintyNote = '';
      _aiInterpretations = const [];
      _selectedAiInterpretationId = null;
    });
  }

  Future<bool> _ensureAiConsent() async {
    final prefs = ref.read(appPreferencesProvider);
    if (prefs.useExpressionAi) return true;

    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pedir ayuda a la IA'),
        content: const Text(
          'Para generar sugerencias, enviaremos únicamente este borrador al servidor de Puente y a un servicio externo de inteligencia artificial.\n\nNo se envía el resto de la conversación. Conservás tu texto original y podés desactivar esta ayuda desde Preferencias.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Permitir y continuar'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) return false;

    final updated = ref
        .read(appPreferencesProvider)
        .copyWith(useExpressionAi: true);
    ref.read(appPreferencesProvider.notifier).state = updated;
    widget.onUseExpressionAiChanged?.call(true);
    return true;
  }

  Future<void> _requestAiAlternatives({String? clarificationChoice}) async {
    final original = _originalController.text.trim();
    if (original.isEmpty || _isLoadingAi) return;

    final hasConsent = await _ensureAiConsent();
    if (!hasConsent || !mounted) return;

    setState(() {
      _isLoadingAi = true;
      _aiStatusMessage = null;
    });

    try {
      final result = await ref
          .read(expressionAssistServiceProvider)
          .assist(
            text: original,
            intent: _selectedInterpretation,
            clarificationChoice: clarificationChoice,
          );
      if (!mounted) return;

      setState(() {
        _isLoadingAi = false;
        _suggestions = result.suggestions;
        _suggestionsSource = ExpressionAssistSource.ai;
        _selectedSuggestionIndex = 0;
        _aiHasAmbiguity = result.hasAmbiguity;
        _aiAmbiguityReason = result.ambiguityReason;
        _aiUncertaintyNote = result.uncertaintyNote;
        _aiInterpretations = result.interpretations;
        _selectedAiInterpretationId = null;
      });
    } on ExpressionAssistException catch (error) {
      if (!mounted) return;
      _applyLocalFallback(error.message);
    } catch (_) {
      if (!mounted) return;
      _applyLocalFallback(
        'La ayuda de IA no está disponible ahora. Te mostramos opciones locales.',
      );
    }
  }

  void _applyLocalFallback(String reason) {
    final original = _originalController.text.trim();
    final fallback = ExpressionAssistResult.local(
      input: original,
      intent: _selectedInterpretation,
    );
    setState(() {
      _isLoadingAi = false;
      _aiStatusMessage = reason;
      _suggestions = fallback.suggestions;
      _suggestionsSource = ExpressionAssistSource.local;
      _selectedSuggestionIndex = fallback.suggestions.isNotEmpty ? 0 : null;
      _aiHasAmbiguity = false;
      _aiAmbiguityReason = '';
      _aiUncertaintyNote = '';
      _aiInterpretations = const [];
      _selectedAiInterpretationId = null;
    });
  }

  Future<void> _editSuggestion(int index) async {
    final edited = await TextEditDialog.show(
      context,
      title: 'Editar propuesta',
      confirmLabel: 'Guardar',
      initialText: _suggestions[index].text,
      labelText: 'Propuesta',
      minLines: 3,
      maxLines: 7,
    );

    if (edited == null || !mounted) return;
    setState(() {
      _suggestions = List<ExpressionSuggestion>.of(_suggestions)
        ..[index] = _suggestions[index].copyWith(text: edited.trim());
      _selectedSuggestionIndex = index;
    });
  }

  void _useText(String text) {
    final selected = text.trim();
    if (selected.isNotEmpty) Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useExpressionAi = ref.watch(
      appPreferencesProvider.select((prefs) => prefs.useExpressionAi),
    );
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final hasText = _originalController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expresar', style: AppTypography.sectionTitle(textPrimary)),
        actions: [
          IconButton(
            tooltip: 'Cómo funciona Expresar',
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cómo funciona Expresar'),
                content: const Text(
                  'Podés generar opciones locales en tu dispositivo sin conexión o pedir sugerencias a la asistencia de IA.\n\nTu texto original nunca se reemplaza automáticamente: elegís, editás o descartás lo que quieras.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tu mensaje',
                style: AppTypography.secondary(
                  textPrimary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _originalController,
                maxLines: 4,
                maxLength: 500,
                style: AppTypography.body(textPrimary),
                decoration: InputDecoration(
                  hintText: 'Escribí lo que querés comunicar...',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceMutedDark
                      : const Color(0xFFF2F5F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: AppTypography.metadata(textSecondary),
                ),
                onChanged: (_) => setState(_resetSuggestionsState),
              ),
              if (_looksAmbiguous && !_aiHasAmbiguity) ...[
                const SizedBox(height: 12),
                SmoothEntrance(
                  beginOffset: const Offset(0.0, 0.08),
                  child: _AmbiguityNotice(
                    selected: _selectedInterpretation,
                    onSelected: (value) => setState(() {
                      _selectedInterpretation = value;
                      _resetSuggestionsState();
                    }),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _AiAssistantCard(
                enabled: hasText && !_isLoadingAi,
                isLoading: _isLoadingAi,
                consentEnabled: useExpressionAi,
                onTap: () => _requestAiAlternatives(),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text('Ver opciones de redacción'),
                onPressed: (!hasText || _isLoadingAi)
                    ? null
                    : _createLocalAlternatives,
              ),
              const SizedBox(height: 6),
              Text(
                'Sugerencias locales en el dispositivo (sin IA externa).',
                style: AppTypography.metadata(textSecondary),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: hasText
                    ? () => _useText(_originalController.text)
                    : null,
                child: const Text('Usar mi texto original'),
              ),
              if (_aiStatusMessage != null) ...[
                const SizedBox(height: 14),
                SmoothEntrance(
                  key: ValueKey('status_${_aiStatusMessage!}'),
                  beginOffset: const Offset(0.0, 0.08),
                  child: _StatusNoticeCard(
                    message: _aiStatusMessage!,
                    isWarning: true,
                    isDark: isDark,
                  ),
                ),
              ],
              if (_aiHasAmbiguity && _aiInterpretations.isNotEmpty) ...[
                const SizedBox(height: 14),
                SmoothEntrance(
                  beginOffset: const Offset(0.0, 0.08),
                  child: _AiAmbiguityNotice(
                    reason: _aiAmbiguityReason,
                    interpretations: _aiInterpretations,
                    selectedId: _selectedAiInterpretationId,
                    isLoading: _isLoadingAi,
                    onSelected: (id) =>
                        setState(() => _selectedAiInterpretationId = id),
                    onApplyClarification: () {
                      final chosen = _aiInterpretations
                          .where(
                            (item) => item.id == _selectedAiInterpretationId,
                          )
                          .firstOrNull;
                      if (chosen == null) return;
                      final label = chosen.description.isEmpty
                          ? chosen.label
                          : '${chosen.label}: ${chosen.description}';
                      _requestAiAlternatives(clarificationChoice: label);
                    },
                  ),
                ),
              ],
              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  _suggestionsSource == ExpressionAssistSource.ai
                      ? 'Propuestas de la IA'
                      : 'Alternativas',
                  style: AppTypography.secondary(
                    textPrimary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _suggestionsSource == ExpressionAssistSource.ai
                      ? 'Revisá y editá las sugerencias. Vos decidís si querés usarlas.'
                      : 'Son propuestas locales. Elegí, editá o descartá la que prefieras.',
                  style: AppTypography.metadata(textSecondary),
                ),
                if (_aiUncertaintyNote.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SmoothEntrance(
                    beginOffset: const Offset(0.0, 0.08),
                    child: _StatusNoticeCard(
                      message: _aiUncertaintyNote,
                      isWarning: false,
                      isDark: isDark,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                for (var index = 0; index < _suggestions.length; index++) ...[
                  SmoothEntrance(
                    key: ValueKey(
                      '${_suggestionsSource.name}_${index}_${_suggestions[index].text}',
                    ),
                    delay: Duration(milliseconds: index * 45),
                    beginOffset: const Offset(0.0, 0.1),
                    child: _SuggestionCard(
                      suggestion: _suggestions[index],
                      selected: _selectedSuggestionIndex == index,
                      isDark: isDark,
                      onTap: () =>
                          setState(() => _selectedSuggestionIndex = index),
                      onEdit: () => _editSuggestion(index),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_selectedSuggestionIndex != null)
                  ElevatedButton(
                    onPressed: () =>
                        _useText(_suggestions[_selectedSuggestionIndex!].text),
                    child: const Text('Usar propuesta seleccionada'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard({
    required this.enabled,
    required this.isLoading,
    required this.consentEnabled,
    required this.onTap,
  });

  final bool enabled;
  final bool isLoading;
  final bool consentEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTealDark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final background = isDark
        ? AppColors.surfaceMutedDark
        : AppColors.primaryTealLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.smart_toy_outlined, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asistencia de IA',
                      style: AppTypography.sectionTitle(
                        textPrimary,
                      ).copyWith(fontSize: 16),
                    ),
                    Text(
                      'Sugerencias para expresar tu mensaje con claridad',
                      style: AppTypography.metadata(textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: enabled ? onTap : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome_outlined, size: 20),
            label: Text(
              isLoading
                  ? 'Preparando sugerencias…'
                  : 'Pedir sugerencias a la IA',
            ),
          ),
          const SizedBox(height: 7),
          Text(
            consentEnabled
                ? 'Activa: solo se envía este borrador cuando lo pedís.'
                : 'Opcional. Antes de usarla, te contamos qué texto se envía.',
            style: AppTypography.metadata(textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusNoticeCard extends StatelessWidget {
  const _StatusNoticeCard({
    required this.message,
    required this.isWarning,
    required this.isDark,
  });

  final String message;
  final bool isWarning;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final accent = isWarning
        ? (isDark ? AppColors.warningTextDark : AppColors.warningTextLight)
        : (isDark ? AppColors.primaryTealOnDark : AppColors.primaryTeal);

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceMutedDark
              : (isWarning
                    ? AppColors.warningLight
                    : AppColors.primaryTealLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.info_outline_rounded,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: AppTypography.secondary(textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiAmbiguityNotice extends StatelessWidget {
  const _AiAmbiguityNotice({
    required this.reason,
    required this.interpretations,
    required this.selectedId,
    required this.isLoading,
    required this.onSelected,
    required this.onApplyClarification,
  });

  final String reason;
  final List<ExpressionInterpretationOption> interpretations;
  final String? selectedId;
  final bool isLoading;
  final ValueChanged<String> onSelected;
  final VoidCallback onApplyClarification;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final warningAccent = isDark
        ? AppColors.warningTextDark
        : AppColors.warningTextLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceMutedDark : AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warningAccent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu mensaje admite más de una interpretación',
            style: AppTypography.secondary(
              warningAccent,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              reason,
              style: AppTypography.secondary(
                isDark ? textSecondary : textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final option in interpretations)
                ChoiceChip(
                  label: Text(option.label),
                  selected: selectedId == option.id,
                  onSelected: isLoading ? null : (_) => onSelected(option.id),
                ),
            ],
          ),
          if (selectedId != null) ...[
            for (final option in interpretations)
              if (option.id == selectedId && option.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  option.description,
                  style: AppTypography.metadata(textSecondary),
                ),
              ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : onApplyClarification,
              child: const Text('Aplicar aclaración con IA'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmbiguityNotice extends StatelessWidget {
  const _AmbiguityNotice({required this.selected, required this.onSelected});

  final ExpressionIntent? selected;
  final ValueChanged<ExpressionIntent> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final warningAccent = isDark
        ? AppColors.warningTextDark
        : AppColors.warningTextLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceMutedDark : AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.warningTextDark.withValues(alpha: 0.45)
              : AppColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu mensaje puede entenderse de más de una forma',
            style: AppTypography.secondary(
              warningAccent,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Elegí una intención solo si representa lo que querés decir.',
            style: AppTypography.secondary(
              isDark ? textSecondary : textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Hacer una consulta'),
                selected: selected == ExpressionIntent.consultation,
                onSelected: (_) => onSelected(ExpressionIntent.consultation),
              ),
              ChoiceChip(
                label: const Text('Pedir una aclaración'),
                selected: selected == ExpressionIntent.clarification,
                onSelected: (_) => onSelected(ExpressionIntent.clarification),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.selected,
    required this.isDark,
    required this.onTap,
    required this.onEdit,
  });

  final ExpressionSuggestion suggestion;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final accentColor = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTeal;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return TapScale(
      pressedScale: 0.98,
      child: Semantics(
        button: true,
        selected: selected,
        label: '${suggestion.label}. ${suggestion.description}',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? (isDark
                          ? AppColors.primaryTealDark
                          : AppColors.primaryTealLight)
                    : (isDark
                          ? AppColors.surfaceMutedDark
                          : AppColors.surfaceLight),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? accentColor
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          suggestion.label,
                          style: AppTypography.secondary(
                            textPrimary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: isDark
                              ? AppColors.primaryTealLight
                              : AppColors.primaryTeal,
                        ),
                    ],
                  ),
                  Text(
                    suggestion.description,
                    style: AppTypography.metadata(textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(suggestion.text, style: AppTypography.body(textPrimary)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
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
}
