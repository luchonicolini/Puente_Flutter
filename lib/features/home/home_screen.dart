import 'package:flutter/material.dart';
import '../../core/storage/app_preferences_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/puente_brand_logo.dart';
import '../../core/widgets/smooth_entrance.dart';
import '../../core/widgets/tap_scale.dart';
import '../conversation/conversation_screen.dart';
import '../expression/expression_screen.dart';
import '../quick_phrases/quick_phrases_sheet.dart';
import '../settings/settings_screen.dart';
import '../show_message/show_message_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.preferences = const AppPreferences(),
    this.onPreferencesChanged,
    this.onClearLocalData,
  });

  final AppPreferences preferences;
  final ValueChanged<AppPreferences>? onPreferencesChanged;
  final Future<void> Function()? onClearLocalData;

  static const String defaultPresentation =
      AppPreferences.defaultPresentationText;

  Future<void> _openExpressionFlow(BuildContext context) async {
    final selectedText = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => ExpressionScreen(
          onUseExpressionAiChanged: (enabled) => onPreferencesChanged?.call(
            preferences.copyWith(useExpressionAi: enabled),
          ),
        ),
      ),
    );

    if (selectedText == null || selectedText.trim().isEmpty || !context.mounted) {
      return;
    }

    final preparedText = selectedText.trim();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final textPrimary = isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;
        final textSecondary = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¿Cómo querés usar tu mensaje?',
                  style: AppTypography.screenTitle(textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  preparedText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.secondary(textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => ConversationScreen(
                          initialContext: preparedText,
                          onPresentationSaved: (text) =>
                              onPreferencesChanged?.call(
                                preferences.copyWith(presentationText: text),
                              ),
                          onUseExpressionAiChanged: (enabled) =>
                              onPreferencesChanged?.call(
                                preferences.copyWith(useExpressionAi: enabled),
                              ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Llevar a conversación'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            ShowMessageScreen(initialText: preparedText),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen_rounded),
                  label: const Text('Mostrar en pantalla grande'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

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
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: PuenteBrandLogo(
                          fontSize: 24,
                          iconSize: 34,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Abrir Preferencias y Ajustes',
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceMutedDark
                              : const Color(0xFFF1F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : const Color(0xFF2C3E50),
                            size: 22,
                          ),
                          tooltip: 'Preferencias',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => SettingsScreen(
                                  preferences: preferences,
                                  onPreferencesChanged: onPreferencesChanged,
                                  onClearLocalData: onClearLocalData,
                                ),
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
              SmoothEntrance(
                beginOffset: const Offset(0.0, 0.06),
                child: TapScale(
                  pressedScale: 0.98,
                  child: Semantics(
                    button: true,
                    label: 'Iniciar conversación cara a cara',
                    child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => ConversationScreen(
                            onPresentationSaved: (text) =>
                                onPreferencesChanged?.call(
                                  preferences.copyWith(presentationText: text),
                                ),
                            onUseExpressionAiChanged: (enabled) =>
                                onPreferencesChanged?.call(
                                  preferences.copyWith(
                                    useExpressionAi: enabled,
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Ink(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D7E88), Color(0xFF096870)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0D7E88,
                            ).withValues(alpha: 0.25),
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
                                    fontFamilyFallback:
                                        AppTypography.fontFallback,
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
                                    fontFamilyFallback:
                                        AppTypography.fontFallback,
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
                icon: Icons.fullscreen_rounded,
                title: 'Mostrar mensaje',
                subtitle: 'Escribí un texto grande para mostrar al instante',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const ShowMessageScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _SecondaryActionTile(
                icon: Icons.edit_outlined,
                title: 'Expresar',
                subtitle: 'Te ayudamos a redactar tu mensaje',
                onTap: () => _openExpressionFlow(context),
              ),
              const SizedBox(height: 20),

              // Banner inferior: Presentación personal con ilustración
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF132D33)
                      : const Color(0xFFE5F4F5),
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
                              color:
                                  (isDark
                                          ? AppColors.primaryTealOnDark
                                          : AppColors.primaryTeal)
                                      .withValues(alpha: 0.8),
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
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : const Color(0xFF5A6F7B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Botón píldora "Ver ejemplo"
                          TapScale(
                            pressedScale: 0.96,
                            child: Semantics(
                              button: true,
                              label: 'Ver ejemplo de mensaje de presentación',
                              child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => ShowMessageScreen(
                                      initialText: preferences
                                          .effectivePresentationText,
                                      isPresentation: true,
                                      onSavePresentation: (text) =>
                                          onPreferencesChanged?.call(
                                            preferences.copyWith(
                                              presentationText: text,
                                            ),
                                          ),
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E444B)
                                      : const Color(0xFFCEECEE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility_outlined,
                                      size: 16,
                                      color: isDark
                                          ? AppColors.primaryTealLight
                                          : AppColors.primaryTealDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Ver ejemplo',
                                        style: TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontFamilyFallback:
                                              AppTypography.fontFallback,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.primaryTealLight
                                              : AppColors.primaryTealDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return TapScale(
      pressedScale: 0.98,
      child: Semantics(
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
                  color: isDark
                      ? AppColors.primaryTealOnDark
                      : AppColors.primaryTeal,
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
                  color: isDark
                      ? AppColors.textMutedDark
                      : const Color(0xFFA0AFB7),
                  size: 16,
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
