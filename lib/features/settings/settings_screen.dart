import 'package:flutter/material.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  double _speechRate = 1.0;
  bool _hapticFeedback = true;
  bool _speakResponsesAutomatically = false;
  bool _optInStorage = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await PreferencesService.getInstance();
    if (!mounted) return;
    setState(() {
      _themeMode = prefs.themeMode;
      _speechRate = prefs.speechRate;
      _hapticFeedback = prefs.hapticFeedback;
      _speakResponsesAutomatically = prefs.speakResponsesAutomatically;
      _optInStorage = prefs.optInStorage;
    });
  }

  Future<void> _updateThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await PreferencesService.getInstance();
    await prefs.setThemeMode(mode);
  }

  Future<void> _updateHapticFeedback(bool value) async {
    setState(() => _hapticFeedback = value);
    final prefs = await PreferencesService.getInstance();
    await prefs.setHapticFeedback(value);
  }

  Future<void> _updateSpeakResponsesAutomatically(bool value) async {
    setState(() => _speakResponsesAutomatically = value);
    final prefs = await PreferencesService.getInstance();
    await prefs.setSpeakResponsesAutomatically(value);
  }

  Future<void> _updateSpeechRate(double value) async {
    setState(() => _speechRate = value);
    final prefs = await PreferencesService.getInstance();
    await prefs.setSpeechRate(value);
  }

  Future<void> _updateOptInStorage(bool value) async {
    setState(() => _optInStorage = value);
    final prefs = await PreferencesService.getInstance();
    await prefs.setOptInStorage(value);
  }

  void _showClearDataDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            'Borrar todos los datos locales',
            style: AppTypography.screenTitle(
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          content: Text(
            'Se restablecerán las frases rápidas y las preferencias guardadas en este dispositivo.',
            style: AppTypography.body(
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final prefs = await PreferencesService.getInstance();
                await prefs.clearAll();
                if (!context.mounted) return;
                setState(() {
                  _themeMode = ThemeMode.system;
                  _speechRate = 1.0;
                  _hapticFeedback = true;
                  _speakResponsesAutomatically = false;
                  _optInStorage = false;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos locales eliminados y preferencias restablecidas.'),
                  ),
                );
              },
              child: const Text('Borrar datos'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text('Preferencias', style: AppTypography.screenTitle(textPrimary)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Sección: Apariencia
            Text('Apariencia', style: AppTypography.sectionTitle(AppColors.primaryTeal)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Tema visual', style: AppTypography.body(textPrimary)),
                    subtitle: Text(
                      _themeMode == ThemeMode.system
                          ? 'Siguiendo el sistema'
                          : (_themeMode == ThemeMode.dark ? 'Modo oscuro' : 'Modo claro'),
                      style: AppTypography.metadata(textSecondary),
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: _themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Sistema'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Claro'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Oscuro'),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          _updateThemeMode(mode);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sección: Comunicación
            Text('Comunicación y voz', style: AppTypography.sectionTitle(AppColors.primaryTeal)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Vibración táctil', style: AppTypography.body(textPrimary)),
                    subtitle: Text('Confirmaciones al interactuar', style: AppTypography.metadata(textSecondary)),
                    value: _hapticFeedback,
                    activeThumbColor: AppColors.primaryTeal,
                    onChanged: _updateHapticFeedback,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text('Reproducir voz automáticamente', style: AppTypography.body(textPrimary)),
                    subtitle: Text('Leer mensajes nuevos en voz alta', style: AppTypography.metadata(textSecondary)),
                    value: _speakResponsesAutomatically,
                    activeThumbColor: AppColors.primaryTeal,
                    onChanged: _updateSpeakResponsesAutomatically,
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Velocidad de síntesis (TTS)', style: AppTypography.body(textPrimary)),
                            ),
                            const SizedBox(width: 8),
                            Text('${_speechRate.toStringAsFixed(1)}x', style: AppTypography.metadata(textSecondary)),
                          ],
                        ),
                        Slider(
                          value: _speechRate,
                          min: 0.5,
                          max: 1.5,
                          divisions: 10,
                          activeColor: AppColors.primaryTeal,
                          onChanged: (val) => setState(() => _speechRate = val),
                          onChangeEnd: _updateSpeechRate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sección: Guía y Ayuda
            Text('Guía y tutorial', style: AppTypography.sectionTitle(AppColors.primaryTeal)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_rounded, color: AppColors.primaryTeal),
                title: Text('Cómo usar Puente', style: AppTypography.body(textPrimary)),
                subtitle: Text('Volver a ver las pantallas de bienvenida', style: AppTypography.metadata(textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (context) => const OnboardingScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Sección: Privacidad
            Text('Privacidad y datos', style: AppTypography.sectionTitle(AppColors.primaryTeal)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Guardar datos confirmados', style: AppTypography.body(textPrimary)),
                    subtitle: Text(
                      'Solo guarda en este teléfono datos que confirmes explícitamente.',
                      style: AppTypography.metadata(textSecondary),
                    ),
                    value: _optInStorage,
                    activeThumbColor: AppColors.primaryTeal,
                    onChanged: _updateOptInStorage,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    title: Text(
                      'Borrar datos locales',
                      style: AppTypography.body(AppColors.error),
                    ),
                    subtitle: Text('Elimina el historial y preferencias', style: AppTypography.metadata(textSecondary)),
                    onTap: _showClearDataDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metadatos de versión y principios
            Center(
              child: Column(
                children: [
                  Text('Puente v1.0.0', style: AppTypography.metadata(textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    'Tu independencia, tu manera de comunicarte.',
                    style: AppTypography.metadata(textSecondary),
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
