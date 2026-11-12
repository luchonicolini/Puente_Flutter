import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/puente_brand_logo.dart';
import '../../core/widgets/tap_scale.dart';
import '../home/home_screen.dart';

class OnboardingStep {
  const OnboardingStep({
    required this.tag,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.semanticImageLabel,
  });

  final String tag;
  final String title;
  final String description;
  final String imageAsset;
  final String semanticImageLabel;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onFinished,
    this.isReopenedFromSettings = false,
  });

  /// El inicio de la app usa este callback para persistir que ya se vio.
  final Future<void> Function()? onFinished;

  /// Al reabrir desde Preferencias, volver a la pantalla anterior al terminar.
  final bool isReopenedFromSettings;

  static const List<OnboardingStep> steps = <OnboardingStep>[
    OnboardingStep(
      tag: '01 / 03',
      title: 'Comunicarnos\nnos acerca.',
      description:
          'Puente te ayuda a comunicarte con otras personas de forma sencilla, a tu manera.',
      imageAsset: 'assets/images/onboarding/onboarding_welcome.png',
      semanticImageLabel:
          'Ilustración de dos personas conversando de forma cercana con globos de diálogo.',
    ),
    OnboardingStep(
      tag: '02 / 03',
      title: 'Escribí, hablá\no mostrá.',
      description:
          'La otra persona puede hablar o escribir. Vos podés leer, responder o mostrar un mensaje grande.',
      imageAsset: 'assets/images/onboarding/onboarding_communication.png',
      semanticImageLabel:
          'Teléfono móvil mostrando opciones accesibles para escribir, hablar con micrófono o mostrar texto.',
    ),
    OnboardingStep(
      tag: '03 / 03',
      title: 'Entendé y decidí\ncon confianza.',
      description:
          'Pedí aclaraciones y confirmá información importante, como precios y horarios.',
      imageAsset: 'assets/images/onboarding/onboarding_independence.png',
      semanticImageLabel:
          'Teléfono mostrando un mensaje grande y una tarjeta de información detectada con confirmación.',
    ),
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _finish() async {
    if (widget.onFinished != null) {
      await widget.onFinished!();
      return;
    }

    if (!mounted) return;
    if (widget.isReopenedFromSettings) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
    );
  }

  void _next() {
    if (_currentPage < OnboardingScreen.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _previous() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final isLastPage = _currentPage == OnboardingScreen.steps.length - 1;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior: Logo Puente + Omitir
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PuenteBrandLogo(isDark: isDark),
                  Semantics(
                    label: 'Omitir introducción',
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: _finish,
                      child: Text(
                        'Omitir',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontFamilyFallback: AppTypography.fontFallback,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido central del onboarding (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingScreen.steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final step = OnboardingScreen.steps[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ilustración con fallback de ícono y efecto parallax/escala suave al deslizar
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    if (disableAnimations ||
                                        !_pageController.hasClients ||
                                        !_pageController
                                            .position
                                            .haveDimensions) {
                                      return child!;
                                    }
                                    final page =
                                        _pageController.page ??
                                        _currentPage.toDouble();
                                    final distance = (page - index).abs().clamp(
                                      0.0,
                                      1.0,
                                    );
                                    final scale = 1.0 - (distance * 0.12);
                                    final opacity = 1.0 - (distance * 0.45);
                                    return Transform.scale(
                                      scale: scale,
                                      child: Opacity(
                                        opacity: opacity,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Semantics(
                                    image: true,
                                    label: step.semanticImageLabel,
                                    child: Image.asset(
                                      step.imageAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.primaryTealDark
                                                          .withValues(
                                                            alpha: 0.3,
                                                          )
                                                    : AppColors
                                                          .primaryTealLight,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .chat_bubble_outline_rounded,
                                                size: 60,
                                                color: isDark
                                                    ? AppColors
                                                          .primaryTealOnDark
                                                    : AppColors.primaryTeal,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Tag numérico 01 / 03
                            Semantics(
                              label: 'Paso ${step.tag}',
                              child: Text(
                                step.tag,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontFamilyFallback:
                                      AppTypography.fontFallback,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.primaryTealOnDark
                                      : AppColors.primaryTealDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Título
                            Text(
                              step.title,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontFamilyFallback: AppTypography.fontFallback,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Descripción
                            Text(
                              step.description,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontFamilyFallback: AppTypography.fontFallback,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                color: textSecondary,
                              ),
                            ),
                            const Spacer(flex: 1),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Barra inferior con controles y paginación
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        child: _currentPage > 0
                            ? TapScale(
                                key: const ValueKey('onboarding_back_btn'),
                                pressedScale: 0.96,
                                child: Semantics(
                                  button: true,
                                  label: 'Paso anterior',
                                  child: InkWell(
                                    onTap: _previous,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.surfaceMutedDark
                                            : const Color(0xFFF1F4F6),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'Volver',
                                        style: AppTypography.button(
                                          isDark
                                              ? AppColors.textSecondaryDark
                                              : const Color(0xFF536773),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('onboarding_back_empty'),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DotsIndicator(
                      totalDots: OnboardingScreen.steps.length,
                      currentIndex: _currentPage,
                      isDark: isDark,
                      disableAnimations: disableAnimations,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TapScale(
                        pressedScale: 0.97,
                        child: Semantics(
                          button: true,
                          label: isLastPage
                              ? 'Empezar a usar Puente'
                              : 'Siguiente paso',
                          child: InkWell(
                            onTap: _next,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: disableAnimations
                                        ? Duration.zero
                                        : const Duration(milliseconds: 180),
                                    child: Text(
                                      isLastPage ? 'Empezar' : 'Siguiente',
                                      key: ValueKey(isLastPage),
                                      style: AppTypography.button(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.totalDots,
    required this.currentIndex,
    required this.isDark,
    required this.disableAnimations,
  });

  final int totalDots, currentIndex;
  final bool isDark;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? AppColors.primaryTeal
                : (isDark ? AppColors.borderDark : const Color(0xFFD6DFE3)),
          ),
        );
      }),
    );
  }
}
