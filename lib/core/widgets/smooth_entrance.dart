import 'package:flutter/material.dart';

/// Envuelve un widget para darle una entrada suave (fade-in + leve
/// desplazamiento vertical). Soporta un `delay` opcional sin usar `Timer`
/// mediante `Interval`, por lo que se integra sin problemas con pruebas.
/// Respeta la opción del sistema de reducir movimiento (`disableAnimations`).
class SmoothEntrance extends StatefulWidget {
  const SmoothEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0.0, 0.12),
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;

  @override
  State<SmoothEntrance> createState() => _SmoothEntranceState();
}

class _SmoothEntranceState extends State<SmoothEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final totalMs =
        widget.duration.inMilliseconds + widget.delay.inMilliseconds;
    final startFraction = totalMs > 0
        ? (widget.delay.inMilliseconds / totalMs).clamp(0.0, 0.9)
        : 0.0;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs > 0 ? totalMs : 1),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(startFraction, 1.0, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(startFraction, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (disableAnimations) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
