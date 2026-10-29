import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../conversation/conversation_screen.dart';
import '../expression/expression_screen.dart';
import '../quick_phrases/quick_phrases_sheet.dart';
import '../settings/settings_screen.dart';
import '../show_message/show_message_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String defaultPresentation =
      'Hola, soy una persona sorda. Nos comunicamos por escrito o podés hablar despacio y mi teléfono mostrará lo que decís.';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.hearing_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text('Puente', style: AppTypography.screenTitle(textPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Preferencias',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bienvenida y propósito
              Text(
                'Tu independencia,\ntu manera de comunicarte.',
                style: AppTypography.display(textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Iniciá una interacción cara a cara o escribí lo que necesitás decir.',
                style: AppTypography.body(textSecondary),
              ),
              const SizedBox(height: 24),

              // CTA Principal: Iniciar conversación
              Semantics(
                button: true,
                label: 'Iniciar conversación interactiva',
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const ConversationScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.forum_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Iniciar conversación',
                                style: AppTypography.sectionTitle(Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hablamos o escribimos de forma accesible',
                                style: AppTypography.secondary(Colors.white.withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Accesos directos secundarios (Fila)
              Row(
                children: [
                  Expanded(
                    child: _SecondaryActionCard(
                      icon: Icons.flash_on_rounded,
                      title: 'Frases rápidas',
                      subtitle: 'Respuestas frecuentes',
                      onTap: () {
                        QuickPhrasesSheet.show(
                          context,
                          onPhraseSelected: (phrase) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => ShowMessageScreen(
                                  initialText: phrase,
                                  isPresentation: false,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SecondaryActionCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Expresar',
                      subtitle: 'Borrador y claridad',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const ExpressionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Atajo para compras (abre conversación con contexto de precio)
              _SecondaryActionCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Comprar o consultar precios',
                subtitle: 'Acceso directo con verificación de importes',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const ConversationScreen(
                        initialContext: 'Consulta de precio o compra',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Bloque inferior de presentación personal accesible en 1 toque
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.contact_mail_outlined,
                            color: AppColors.primaryTeal,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Presentación personal',
                            style: AppTypography.sectionTitle(textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mostrá rápidamente quién sos y cómo preferís comunicarte sin depender de explicaciones largas.',
                        style: AppTypography.secondary(textSecondary),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.fullscreen_rounded),
                        label: const Text('Presentarme con un toque'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const ShowMessageScreen(
                                initialText: defaultPresentation,
                                isPresentation: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryTeal, size: 24),
              const SizedBox(height: 10),
              Text(
                title,
                style: AppTypography.sectionTitle(textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.metadata(textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
