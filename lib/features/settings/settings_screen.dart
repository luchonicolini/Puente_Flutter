import 'package:flutter/material.dart';
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
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Datos locales eliminados.')),
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
                          setState(() => _themeMode = mode);
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
                    activeColor: AppColors.primaryTeal,
                    onChanged: (val) => setState(() => _hapticFeedback = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text('Reproducir voz automáticamente', style: AppTypography.body(textPrimary)),
                    subtitle: Text('Leer mensajes nuevos en voz alta', style: AppTypography.metadata(textSecondary)),
                    value: _speakResponsesAutomatically,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (val) => setState(() => _speakResponsesAutomatically = val),
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
                            Text('Velocidad de síntesis (TTS)', style: AppTypography.body(textPrimary)),
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
                    activeColor: AppColors.primaryTeal,
                    onChanged: (val) => setState(() => _optInStorage = val),
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
