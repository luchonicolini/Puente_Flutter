import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/puente_brand_logo.dart';
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
    final backgroundColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra superior: Logo Puente a la izquierda + Botón de Preferencias circular
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PuenteBrandLogo(
                      fontSize: 24,
                      iconSize: 34,
                      isDark: isDark,
                    ),
                    Semantics(
                      button: true,
                      label: 'Abrir Preferencias y Ajustes',
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceMutedDark : const Color(0xFFF1F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF2C3E50),
                            size: 22,
                          ),
                          tooltip: 'Preferencias',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Titular principal y descripción
              Text(
                'Comunicarnos\nhace todo más fácil.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontFamilyFallback: AppTypography.fontFallback,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Escribí, hablá o usá frases rápidas\npara comunicarte en tu vida cotidiana.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontFamilyFallback: AppTypography.fontFallback,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Tarjeta destacada principal: Iniciar conversación
              Semantics(
                button: true,
                label: 'Iniciar conversación cara a cara',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const ConversationScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Ink(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0D7E88),
                            Color(0xFF096870),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0D7E88).withValues(alpha: 0.25),
                            offset: const Offset(0, 8),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.chat_bubble_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Iniciar\nconversación',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontFamilyFallback: AppTypography.fontFallback,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Escribí, hablá y escuchá',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontFamilyFallback: AppTypography.fontFallback,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lista vertical de accesos directos secundarios (Full width)
              _SecondaryActionTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Frases rápidas',
                subtitle: 'Mensajes útiles para el día a día',
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
              const SizedBox(height: 12),

              _SecondaryActionTile(
                icon: Icons.edit_outlined,
                title: 'Expresar',
                subtitle: 'Te ayudamos a redactar tu mensaje',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const ExpressionScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _SecondaryActionTile(
                icon: Icons.shopping_cart_outlined,
                title: 'Comprar',
                subtitle: 'Precios y confirmaciones',
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
              const SizedBox(height: 20),

              // Banner inferior: Presentación personal con ilustración
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132D33) : const Color(0xFFE5F4F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.fromLTRB(12, 14, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ilustración recortada de la persona con teléfono
                    SizedBox(
                      width: 105,
                      height: 110,
                      child: Image.asset(
                        'assets/images/home_presentation_banner.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.person_pin_rounded,
                              size: 54,
                              color: AppColors.primaryTeal.withValues(alpha: 0.8),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Textos y botón de ver ejemplo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Podés mostrar un mensaje de presentación',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontFamilyFallback: AppTypography.fontFallback,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'en cualquier momento durante la conversación.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontFamilyFallback: AppTypography.fontFallback,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF5A6F7B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Botón píldora "Ver ejemplo"
                          Semantics(
                            button: true,
                            label: 'Ver ejemplo de mensaje de presentación',
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => const ShowMessageScreen(
                                      initialText: defaultPresentation,
                                      isPresentation: true,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E444B) : const Color(0xFFCEECEE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.visibility_outlined,
                                      size: 16,
                                      color: AppColors.primaryTeal,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ver ejemplo',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontFamilyFallback: AppTypography.fontFallback,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionTile extends StatelessWidget {
  const _SecondaryActionTile({
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
    final textSecondary = isDark ? AppColors.textSecondaryDark : const Color(0xFF70818B);

    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: Material(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF9FBFC),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE8EEF1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryTeal,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontFamilyFallback: AppTypography.fontFallback,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontFamilyFallback: AppTypography.fontFallback,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textMutedDark : const Color(0xFFA0AFB7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
