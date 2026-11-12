import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/services_providers.dart';
import '../../core/storage/app_preferences_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../onboarding/onboarding_screen.dart';
import '../quick_phrases/quick_phrases_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    this.preferences = const AppPreferences(),
    this.onPreferencesChanged,
    this.onClearLocalData,
  });

  final AppPreferences preferences;
  final ValueChanged<AppPreferences>? onPreferencesChanged;
  final Future<void> Function()? onClearLocalData;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const List<({double rate, String label, String description})>
  _speechRates = [
    (rate: 0.35, label: 'Lenta', description: 'Más pausada para lugares ruidosos'),
    (rate: 0.5, label: 'Normal', description: 'Ritmo natural recomendado'),
    (rate: 0.65, label: 'Rápida', description: 'Lectura ágil para frases cortas'),
  ];

  late ThemeMode _themeMode;
  late int _textSize;
  late bool _readMessages;
  late double _speechRate;
  late bool _vibrateAtEnd;
  late bool _useExpressionAi;
  late String _presentationText;

  @override
  void initState() {
    super.initState();
    _applyPreferences(widget.preferences);
  }

  void _applyPreferences(AppPreferences preferences) {
    _themeMode = preferences.themeMode;
    _textSize = const <double>[0.9, 1.0, 1.15].indexOf(preferences.textScale);
    if (_textSize == -1) _textSize = 1;
    _readMessages = preferences.readMessages;
    _speechRate = preferences.speechRate;
    _vibrateAtEnd = preferences.vibrateAtEnd;
    _useExpressionAi = preferences.useExpressionAi;
    _presentationText = preferences.effectivePresentationText;
  }

  String get _speechRateLabel {
    return _speechRates
            .where((option) => (option.rate - _speechRate).abs() < 0.05)
            .map((option) => option.label)
            .firstOrNull ??
        'Normal';
  }

  bool get _isDefaultPresentation =>
      _presentationText.trim() == AppPreferences.defaultPresentationText;

  void _savePreferences() {
    final updated = AppPreferences(
      themeMode: _themeMode,
      textScale: const <double>[0.9, 1.0, 1.15][_textSize],
      readMessages: _readMessages,
      speechRate: _speechRate,
      vibrateAtEnd: _vibrateAtEnd,
      doNotSaveConversations: true,
      useExpressionAi: _useExpressionAi,
      presentationText: _presentationText,
    );
    ref.read(appPreferencesProvider.notifier).state = updated;
    unawaited(ref.read(ttsServiceProvider).setSpeechRate(updated.speechRate));
    widget.onPreferencesChanged?.call(updated);
  }

  void _update(VoidCallback update) {
    setState(update);
    _savePreferences();
  }

  Future<void> _showEditPresentationSheet() async {
    final updatedText = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _PresentationEditorSheet(initialText: _presentationText),
    );

    if (updatedText != null && updatedText.trim().isNotEmpty && mounted) {
      _update(() => _presentationText = updatedText.trim());
    }
  }

  Future<void> _showSpeechRateSheet() async {
    final selectedRate = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textPrimary = isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;
        final textSecondary = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Velocidad de voz',
                  style: AppTypography.screenTitle(textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ajustá qué tan rápido se reproducen los mensajes en voz alta.',
                  style: AppTypography.secondary(textSecondary),
                ),
                const SizedBox(height: 12),
                for (final option in _speechRates)
                  ListTile(
                    title: Text(
                      option.label,
                      style: AppTypography.body(textPrimary),
                    ),
                    subtitle: Text(
                      option.description,
                      style: AppTypography.metadata(textSecondary),
                    ),
                    trailing: (option.rate - _speechRate).abs() < 0.05
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: isDark
                                ? AppColors.primaryTealOnDark
                                : AppColors.primaryTeal,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option.rate),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedRate != null && mounted) {
      _update(() => _speechRate = selectedRate);
    }
  }

  void _showClearDataDialog() {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar datos guardados'),
        content: const Text(
          'Se eliminarán los datos que hayas elegido guardar en este dispositivo. Las conversaciones no se guardan por defecto.',
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await widget.onClearLocalData?.call();
              if (!mounted) return;
              const defaults = AppPreferences();
              setState(() => _applyPreferences(defaults));
              ref.read(appPreferencesProvider.notifier).state = defaults;
              unawaited(
                ref.read(ttsServiceProvider).setSpeechRate(defaults.speechRate),
              );
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Se eliminaron los datos guardados en este dispositivo.',
                  ),
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preferencias',
          style: AppTypography.sectionTitle(textPrimary),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            _SectionLabel('Apariencia', color: textPrimary),
            const SizedBox(height: 8),
            Text(
              'Tamaño del texto',
              style: AppTypography.metadata(textSecondary),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                    child: _TextSizeChoice(
                      index: index,
                      selected: _textSize == index,
                      onTap: () => _update(() => _textSize = index),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Tema', style: AppTypography.metadata(textSecondary)),
            const SizedBox(height: 6),
            Row(
              children: [
                _ThemeChoice(
                  icon: Icons.light_mode_outlined,
                  label: 'Claro',
                  selected: _themeMode == ThemeMode.light,
                  onTap: () => _update(() => _themeMode = ThemeMode.light),
                ),
                const SizedBox(width: 8),
                _ThemeChoice(
                  icon: Icons.dark_mode_outlined,
                  label: 'Oscuro',
                  selected: _themeMode == ThemeMode.dark,
                  onTap: () => _update(() => _themeMode = ThemeMode.dark),
                ),
                const SizedBox(width: 8),
                _ThemeChoice(
                  icon: Icons.phone_android_outlined,
                  label: 'Sistema',
                  selected: _themeMode == ThemeMode.system,
                  onTap: () => _update(() => _themeMode = ThemeMode.system),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Comunicación', color: textPrimary),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SwitchRow(
                  label: 'Reproducir mensajes',
                  subtitle: 'Habilita la reproducción de mensajes en voz alta',
                  value: _readMessages,
                  onChanged: (value) => _update(() => _readMessages = value),
                ),
                _Divider(isDark: isDark),
                _ArrowRow(
                  label: 'Velocidad de voz',
                  value: _speechRateLabel,
                  onTap: _showSpeechRateSheet,
                ),
                _Divider(isDark: isDark),
                _SwitchRow(
                  label: 'Vibrar al terminar de transcribir',
                  value: _vibrateAtEnd,
                  onChanged: (value) => _update(() => _vibrateAtEnd = value),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Idioma', color: textPrimary),
            const SizedBox(height: 8),
            _SettingsCard(
              children: const [
                _InfoRow(
                  icon: Icons.language_rounded,
                  label: 'Idioma principal',
                  subtitle: 'Español (Argentina) · Único idioma disponible en esta versión',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Frases rápidas', color: textPrimary),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _ArrowRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Editar frases',
                  onTap: () => QuickPhrasesSheet.show(
                    context,
                    showResetOption: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Presentación personal', color: textPrimary),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _ArrowRow(
                  icon: Icons.badge_outlined,
                  label: 'Texto de presentación',
                  value: _isDefaultPresentation
                      ? 'Predeterminado'
                      : 'Personalizado',
                  onTap: _showEditPresentationSheet,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Privacidad', color: textPrimary),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                const _InfoRow(
                  icon: Icons.shield_outlined,
                  label: 'No se guardan conversaciones',
                  subtitle: 'Solo viven en memoria y se descartan al finalizar.',
                ),
                _Divider(isDark: isDark),
                _SwitchRow(
                  label: 'Asistencia con IA en Expresar',
                  subtitle:
                      'Envía solo tu borrador puntual a Gemini cuando pedís opciones. Podés desactivarla cuando quieras.',
                  value: _useExpressionAi,
                  onChanged: (value) => _update(() => _useExpressionAi = value),
                ),
                _Divider(isDark: isDark),
                _ArrowRow(
                  icon: Icons.delete_outline_rounded,
                  label: 'Eliminar datos guardados',
                  isDestructive: true,
                  onTap: _showClearDataDialog,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              children: [
                _ArrowRow(
                  icon: Icons.menu_book_outlined,
                  label: 'Cómo usar Puente',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          const OnboardingScreen(isReopenedFromSettings: true),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppTypography.secondary(color).copyWith(fontWeight: FontWeight.w700),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    color: isDark ? AppColors.borderDark : AppColors.borderLight,
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final accentColor = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTeal;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text(label, style: AppTypography.secondary(textPrimary)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: AppTypography.metadata(textSecondary)),
      value: value,
      activeThumbColor: accentColor,
      onChanged: onChanged,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final accentColor = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTealDark;
    return ListTile(
      dense: true,
      minVerticalPadding: 8,
      leading: Icon(icon, size: 19, color: accentColor),
      title: Text(label, style: AppTypography.secondary(textPrimary)),
      subtitle: Text(subtitle, style: AppTypography.metadata(textSecondary)),
    );
  }
}

class _ArrowRow extends StatelessWidget {
  const _ArrowRow({
    required this.label,
    required this.onTap,
    this.value,
    this.icon,
    this.isDestructive = false,
  });
  final String label;
  final String? value;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final color = isDestructive ? errorColor : textPrimary;
    return ListTile(
      dense: true,
      minVerticalPadding: 7,
      leading: icon == null
          ? null
          : Icon(
              icon,
              size: 19,
              color: isDestructive ? errorColor : accentColor,
            ),
      title: Text(label, style: AppTypography.secondary(color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                value!,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.metadata(textSecondary),
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _TextSizeChoice extends StatelessWidget {
  const _TextSizeChoice({
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final selectedBorder = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTeal;
    final size = [14.0, 17.0, 20.0][index];
    return Semantics(
      button: true,
      selected: selected,
      label: 'Tamaño de texto ${index + 1}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? (isDark
                      ? AppColors.primaryTealDark
                      : AppColors.primaryTealLight)
                : (isDark
                      ? AppColors.surfaceMutedDark
                      : const Color(0xFFF3F5F6)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? selectedBorder : Colors.transparent,
            ),
          ),
          child: Text(
            'A',
            style: TextStyle(fontSize: size, color: textPrimary),
          ),
        ),
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final selectedAccent = isDark
        ? AppColors.primaryTealLight
        : AppColors.primaryTealDark;
    final selectedBorder = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTeal;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Tema $label',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark
                        ? AppColors.primaryTealDark
                        : AppColors.primaryTealLight)
                  : (isDark
                        ? AppColors.surfaceMutedDark
                        : const Color(0xFFF3F5F6)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? selectedBorder : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? selectedAccent : textPrimary,
                ),
                const SizedBox(height: 2),
                Text(label, style: AppTypography.metadata(textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresentationEditorSheet extends StatefulWidget {
  const _PresentationEditorSheet({required this.initialText});

  final String initialText;

  @override
  State<_PresentationEditorSheet> createState() =>
      _PresentationEditorSheetState();
}

class _PresentationEditorSheetState extends State<_PresentationEditorSheet> {
  late final TextEditingController _controller;
  String? _errorMessage;

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

  void _save() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _errorMessage = 'Escribí un mensaje antes de guardar.';
      });
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  void _restoreDefault() {
    setState(() {
      _controller.text = AppPreferences.defaultPresentationText;
      _errorMessage = null;
    });
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
    final accentColor = isDark
        ? AppColors.primaryTealOnDark
        : AppColors.primaryTealDark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.badge_outlined, color: accentColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Texto de presentación',
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
                'Se muestra solo cuando tocás «Presentarme». Podés adaptarlo a tu preferencia de comunicación.',
                style: AppTypography.secondary(textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.body(textPrimary),
                decoration: InputDecoration(
                  hintText: 'Escribí tu mensaje de presentación…',
                  errorText: _errorMessage,
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceMutedDark
                      : AppColors.surfaceMutedLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _restoreDefault,
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Restaurar predeterminado'),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _save,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
