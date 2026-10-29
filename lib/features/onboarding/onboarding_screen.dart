import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/puente_brand_logo.dart';
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
  const OnboardingScreen({super.key});

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

  void _finish() {
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
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final isLastPage = _currentPage == OnboardingScreen.steps.length - 1;

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
                    button: true,
                    label: 'Omitir introducción',
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _finish,
                      child: Text(
                        'Omitir',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontFamilyFallback: AppTypography.fontFallback,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
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
                            // Ilustración con fallback de ícono
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Semantics(
                                  image: true,
                                  label: step.semanticImageLabel,
                                  child: Image.asset(
                                    step.imageAsset,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.primaryTealDark.withValues(alpha: 0.3)
                                              : AppColors.primaryTealLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 60,
                                          color: AppColors.primaryTeal,
                                        ),
                                      );
                                    },
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
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontFamilyFallback: AppTypography.fontFallback,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryTeal,
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
                    // Botón Volver (en pantallas 2 y 3)
                    if (_currentPage > 0)
                      Semantics(
                        button: true,
                        label: 'Paso anterior',
                        child: InkWell(
                          onTap: _previous,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceMutedDark : const Color(0xFFF1F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Volver',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontFamilyFallback: AppTypography.fontFallback,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : const Color(0xFF536773),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      // Indicador de puntos a la izquierda en la pantalla 1
                      _DotsIndicator(
                        totalDots: OnboardingScreen.steps.length,
                        currentIndex: _currentPage,
                        isDark: isDark,
                      ),

                    // Espaciador o indicador en pantallas 2 y 3
                    if (_currentPage > 0) ...[
                      const Spacer(),
                      _DotsIndicator(
                        totalDots: OnboardingScreen.steps.length,
                        currentIndex: _currentPage,
                        isDark: isDark,
                      ),
                      const Spacer(),
                    ] else
                      const Spacer(),

                    // Botón Siguiente / Empezar
                    Semantics(
                      button: true,
                      label: isLastPage ? 'Empezar a usar Puente' : 'Siguiente paso',
                      child: InkWell(
                        onTap: _next,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLastPage ? 'Empezar' : 'Siguiente',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontFamilyFallback: AppTypography.fontFallback,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
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
  });

  final int totalDots, currentIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryTeal
                : (isDark ? AppColors.borderDark : const Color(0xFFD6DFE3)),
          ),
        );
      }),
    );
  }
}

