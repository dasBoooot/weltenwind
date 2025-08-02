import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/providers/theme_context_provider.dart';

/// 🪄 Magic Animation Types based on Animations Schema
enum MagicAnimationType {
  // Entrance animations
  fadeIn,
  scaleIn,
  slideIn,
  magicAppear,
  portalEntry,
  
  // Exit animations
  fadeOut,
  scaleOut,
  slideOut,
  magicDisappear,
  portalExit,
  
  // Continuous animations
  float,
  pulse,
  rotate,
  shimmer,
  breathe,
  glow,
  
  // Interactive animations
  hover,
  press,
  focus,
  shake,
}

/// 🎭 Animation Direction
enum AnimationDirection {
  up,
  down,
  left,
  right,
  center,
}

/// 🎮 Magic Animation Component based on Animations Schema
/// 
/// Fantasy animation system with magical entrance/exit effects and continuous animations
class MagicAnimation extends StatefulWidget {
  final Widget child;
  final MagicAnimationType animationType;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final bool autoStart;
  final bool repeat;
  final bool reverse;
  final AnimationDirection? direction;
  final double intensity;
  final VoidCallback? onComplete;

  const MagicAnimation({
    super.key,
    required this.child,
    required this.animationType,
    this.duration = const Duration(milliseconds: 800),
    this.delay,
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.repeat = false,
    this.reverse = false,
    this.direction,
    this.intensity = 1.0,
    this.onComplete,
  });

  @override
  State<MagicAnimation> createState() => _MagicAnimationState();
}

class _MagicAnimationState extends State<MagicAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _setupAnimations();
    
    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    // Basic animation
    _animation = Tween<double>(
      begin: _getBeginValue(),
      end: _getEndValue(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: _getSlideBegin(),
      end: _getSlideEnd(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: _getScaleBegin(),
      end: _getScaleEnd(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: _getRotationEnd(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Glow animation
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: widget.intensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        
        if (widget.repeat) {
          if (widget.reverse) {
            _controller.reverse();
          } else {
            _controller.reset();
            _controller.forward();
          }
        }
      } else if (status == AnimationStatus.dismissed && widget.repeat && widget.reverse) {
        _controller.forward();
      }
    });
  }

  void _startAnimation() {
    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'MagicAnimation',
      contextOverrides: {
        'type': widget.animationType.name,
        'duration': widget.duration.inMilliseconds.toString(),
        'autoStart': widget.autoStart.toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildMagicAnimation(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildMagicAnimation(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildAnimatedWidget(theme, extensions);
      },
    );
  }

  Widget _buildAnimatedWidget(ThemeData theme, Map<String, dynamic>? extensions) {
    Widget animatedChild = widget.child;

    switch (widget.animationType) {
      case MagicAnimationType.fadeIn:
      case MagicAnimationType.fadeOut:
        animatedChild = Opacity(
          opacity: _animation.value,
          child: animatedChild,
        );
        break;

      case MagicAnimationType.scaleIn:
      case MagicAnimationType.scaleOut:
        animatedChild = Transform.scale(
          scale: _scaleAnimation.value,
          child: animatedChild,
        );
        break;

      case MagicAnimationType.slideIn:
      case MagicAnimationType.slideOut:
        animatedChild = SlideTransition(
          position: _slideAnimation,
          child: animatedChild,
        );
        break;

      case MagicAnimationType.magicAppear:
      case MagicAnimationType.magicDisappear:
        animatedChild = _buildMagicTransition(theme, extensions, animatedChild);
        break;

      case MagicAnimationType.portalEntry:
      case MagicAnimationType.portalExit:
        animatedChild = _buildPortalTransition(theme, extensions, animatedChild);
        break;

      case MagicAnimationType.float:
        animatedChild = Transform.translate(
          offset: Offset(0, math.sin(_animation.value * 2 * math.pi) * 10 * widget.intensity),
          child: animatedChild,
        );
        break;

      case MagicAnimationType.pulse:
        animatedChild = Transform.scale(
          scale: 1.0 + (math.sin(_animation.value * 2 * math.pi) * 0.1 * widget.intensity),
          child: animatedChild,
        );
        break;

      case MagicAnimationType.rotate:
        animatedChild = Transform.rotate(
          angle: _rotationAnimation.value,
          child: animatedChild,
        );
        break;

      case MagicAnimationType.shimmer:
        animatedChild = _buildShimmerTransition(animatedChild);
        break;

      case MagicAnimationType.breathe:
        animatedChild = Transform.scale(
          scale: 1.0 + (math.sin(_animation.value * math.pi) * 0.05 * widget.intensity),
          child: Opacity(
            opacity: 0.7 + (math.sin(_animation.value * math.pi) * 0.3),
            child: animatedChild,
          ),
        );
        break;

      case MagicAnimationType.glow:
        animatedChild = _buildGlowTransition(theme, extensions, animatedChild);
        break;

      case MagicAnimationType.hover:
      case MagicAnimationType.press:
      case MagicAnimationType.focus:
        animatedChild = Transform.scale(
          scale: _scaleAnimation.value,
          child: animatedChild,
        );
        break;

      case MagicAnimationType.shake:
        animatedChild = Transform.translate(
          offset: Offset(
            math.sin(_animation.value * 20 * math.pi) * 5 * widget.intensity,
            0,
          ),
          child: animatedChild,
        );
        break;
    }

    return animatedChild;
  }

  /// Build magic appearance/disappearance transition
  Widget _buildMagicTransition(ThemeData theme, Map<String, dynamic>? extensions, Widget child) {
    final magicColor = _getMagicColor(theme, extensions);
    
    return Stack(
      children: [
        // Magic sparkles effect
        Positioned.fill(
          child: CustomPaint(
            painter: MagicSparklesPainter(
              progress: _animation.value,
              color: magicColor,
              intensity: widget.intensity,
            ),
          ),
        ),
        // Main widget with fade and scale
        Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: 0.5 + (_animation.value * 0.5),
            child: child,
          ),
        ),
      ],
    );
  }

  /// Build portal entry/exit transition
  Widget _buildPortalTransition(ThemeData theme, Map<String, dynamic>? extensions, Widget child) {
    final portalColor = _getPortalColor(theme, extensions);
    
    return Stack(
      children: [
        // Portal swirl effect
        Positioned.fill(
          child: CustomPaint(
            painter: PortalSwirlPainter(
              progress: _animation.value,
              color: portalColor,
              intensity: widget.intensity,
            ),
          ),
        ),
        // Main widget with rotation and scale
        Transform.rotate(
          angle: _animation.value * 2 * math.pi,
          child: Transform.scale(
            scale: _animation.value,
            child: Opacity(
              opacity: _animation.value,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  /// Build shimmer transition
  Widget _buildShimmerTransition(Widget child) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [
            0.0,
            0.3 + (0.4 * _animation.value),
            0.6 + (0.4 * _animation.value),  
            1.0,
          ],
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.5 * widget.intensity),
            Colors.white.withValues(alpha: 0.8 * widget.intensity),
            Colors.transparent,
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }

  /// Build glow transition
  Widget _buildGlowTransition(ThemeData theme, Map<String, dynamic>? extensions, Widget child) {
    final glowColor = _getGlowColor(theme, extensions);
    final glowIntensity = _glowAnimation.value;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3 * glowIntensity),
            blurRadius: 20 * glowIntensity,
            spreadRadius: 5 * glowIntensity,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.1 * glowIntensity),
            blurRadius: 40 * glowIntensity,
            spreadRadius: 10 * glowIntensity,
          ),
        ],
      ),
      child: child,
    );
  }

  // Animation value getters
  double _getBeginValue() {
    switch (widget.animationType) {
      case MagicAnimationType.fadeIn:
      case MagicAnimationType.magicAppear:
      case MagicAnimationType.portalEntry:
        return 0.0;
      case MagicAnimationType.fadeOut:
      case MagicAnimationType.magicDisappear:
      case MagicAnimationType.portalExit:
        return 1.0;
      default:
        return 0.0;
    }
  }

  double _getEndValue() {
    switch (widget.animationType) {
      case MagicAnimationType.fadeIn:
      case MagicAnimationType.magicAppear:
      case MagicAnimationType.portalEntry:
        return 1.0;
      case MagicAnimationType.fadeOut:
      case MagicAnimationType.magicDisappear:
      case MagicAnimationType.portalExit:
        return 0.0;
      default:
        return 1.0;
    }
  }

  Offset _getSlideBegin() {
    final direction = widget.direction ?? AnimationDirection.up;
    switch (direction) {
      case AnimationDirection.up:
        return const Offset(0, 1);
      case AnimationDirection.down:
        return const Offset(0, -1);
      case AnimationDirection.left:
        return const Offset(1, 0);
      case AnimationDirection.right:
        return const Offset(-1, 0);
      case AnimationDirection.center:
        return const Offset(0, 0);
    }
  }

  Offset _getSlideEnd() {
    return Offset.zero;
  }

  double _getScaleBegin() {
    switch (widget.animationType) {
      case MagicAnimationType.scaleIn:
        return 0.0;
      case MagicAnimationType.scaleOut:
        return 1.0;
      case MagicAnimationType.hover:
        return 1.0;
      case MagicAnimationType.press:
        return 1.0;
      case MagicAnimationType.focus:
        return 1.0;
      default:
        return 1.0;
    }
  }

  double _getScaleEnd() {
    switch (widget.animationType) {
      case MagicAnimationType.scaleIn:
        return 1.0;
      case MagicAnimationType.scaleOut:
        return 0.0;
      case MagicAnimationType.hover:
        return 1.05;
      case MagicAnimationType.press:
        return 0.95;
      case MagicAnimationType.focus:
        return 1.02;
      default:
        return 1.0;
    }
  }

  double _getRotationEnd() {
    switch (widget.animationType) {
      case MagicAnimationType.rotate:
        return 2 * math.pi;
      default:
        return 0.0;
    }
  }

  // Color getters from extensions
  Color _getMagicColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (extensions != null && extensions.containsKey('magicGradient')) {
      final colors = extensions['magicGradient'] as List<dynamic>?;
      if (colors != null && colors.isNotEmpty) {
        return _parseColor(colors.first.toString()) ?? theme.colorScheme.primary;
      }
    }
    return theme.colorScheme.primary;
  }

  Color _getPortalColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (extensions != null && extensions.containsKey('portalGradient')) {
      final colors = extensions['portalGradient'] as List<dynamic>?;
      if (colors != null && colors.isNotEmpty) {
        return _parseColor(colors.first.toString()) ?? theme.colorScheme.tertiary;
      }
    }
    return theme.colorScheme.tertiary;
  }

  Color _getGlowColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (extensions != null && extensions.containsKey('hoverAuraColor')) {
      return _parseColor(extensions['hoverAuraColor'].toString()) ?? theme.colorScheme.primary;
    }
    return theme.colorScheme.primary;
  }

  /// Helper: Parse color from hex string
  Color? _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    return null;
  }
}

/// ✨ Magic Sparkles Painter
class MagicSparklesPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double intensity;

  MagicSparklesPainter({
    required this.progress,
    required this.color,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8 * intensity)
      ..style = PaintingStyle.fill;

    final sparkleCount = (15 * intensity).round();
    final random = math.Random(42);

    for (int i = 0; i < sparkleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sparkleProgress = (progress * 2 + (i / sparkleCount)) % 1.0;
      
      if (sparkleProgress > 0.1 && sparkleProgress < 0.9) {
        final sparkleSize = (2 + random.nextDouble() * 3) * sparkleProgress * (1 - sparkleProgress) * 4;
        final sparkleOpacity = sparkleProgress * (1 - sparkleProgress) * 4;
        
        paint.color = color.withValues(alpha: sparkleOpacity * intensity);
        canvas.drawCircle(Offset(x, y), sparkleSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MagicSparklesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.intensity != intensity;
  }
}

/// 🌀 Portal Swirl Painter
class PortalSwirlPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double intensity;

  PortalSwirlPainter({
    required this.progress,
    required this.color,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw spiral swirls
    for (int i = 0; i < 5; i++) {
      final spiralProgress = (progress + (i * 0.2)) % 1.0;
      final radius = maxRadius * spiralProgress;
      final opacity = (1.0 - spiralProgress) * intensity;
      
      paint.color = color.withValues(alpha: opacity);
      
      final path = Path();
      const steps = 20;
      for (int step = 0; step < steps; step++) {
        final angle = (step / steps) * 2 * math.pi * 3; // 3 full rotations
        final r = radius * (step / steps);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        
        if (step == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PortalSwirlPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.intensity != intensity;
  }
}