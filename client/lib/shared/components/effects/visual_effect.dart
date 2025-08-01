import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/services/modular_theme_service.dart';

/// ✨ Visual Effect Types based on Effects Schema
enum VisualEffectType {
  magicGradient,
  portalGradient,
  glow,
  shimmer,
  particles,
  pulseGlow,
  breathingGlow,
}

/// 🎨 Gradient Direction Types from Schema
enum GradientDirection {
  horizontal,
  vertical,
  diagonal,
  radial,
  conic,
}

/// ✨ Visual Effect Component based on Effects Schema
/// 
/// Fantasy visual effects system with gradients, glow, shimmer, and particles
class VisualEffect extends StatefulWidget {
  final Widget child;
  final VisualEffectType effectType;
  final bool isEnabled;
  final double intensity;
  final Duration duration;
  final List<Color>? customColors;
  final GradientDirection? gradientDirection;
  final double? glowRadius;
  final bool continuousAnimation;

  const VisualEffect({
    super.key,
    required this.child,
    required this.effectType,
    this.isEnabled = true,
    this.intensity = 1.0,
    this.duration = const Duration(milliseconds: 2000),
    this.customColors,
    this.gradientDirection,
    this.glowRadius,
    this.continuousAnimation = true,
  });

  @override
  State<VisualEffect> createState() => _VisualEffectState();
}

class _VisualEffectState extends State<VisualEffect> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _animation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _getAnimationCurve(),
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    if (widget.isEnabled && widget.continuousAnimation) {
      _animationController.repeat(reverse: _shouldReverse());
      if (widget.effectType == VisualEffectType.particles) {
        _particleController.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(VisualEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled && widget.continuousAnimation) {
        _animationController.repeat(reverse: _shouldReverse());
        if (widget.effectType == VisualEffectType.particles) {
          _particleController.repeat();
        }
      } else {
        _animationController.stop();
        _particleController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  bool _shouldReverse() {
    switch (widget.effectType) {
      case VisualEffectType.pulseGlow:
      case VisualEffectType.breathingGlow:
      case VisualEffectType.shimmer:
        return true;
      default:
        return false;
    }
  }

  Curve _getAnimationCurve() {
    switch (widget.effectType) {
      case VisualEffectType.pulseGlow:
        return Curves.easeInOut;
      case VisualEffectType.breathingGlow:
        return Curves.slowMiddle;
      case VisualEffectType.shimmer:
        return Curves.linear;
      default:
        return Curves.easeInOut;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final extensions = ModularThemeService().getCurrentThemeExtensions();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _particleController]),
      builder: (context, child) {
        return _buildEffect(theme, extensions);
      },
    );
  }

  Widget _buildEffect(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.effectType) {
      case VisualEffectType.magicGradient:
        return _buildGradientEffect(theme, extensions, 'magic');
      case VisualEffectType.portalGradient:
        return _buildGradientEffect(theme, extensions, 'portal');
      case VisualEffectType.glow:
      case VisualEffectType.pulseGlow:
      case VisualEffectType.breathingGlow:
        return _buildGlowEffect(theme, extensions);
      case VisualEffectType.shimmer:
        return _buildShimmerEffect(theme, extensions);
      case VisualEffectType.particles:
        return _buildParticleEffect(theme, extensions);
    }
  }

  /// Build gradient effect from schema
  Widget _buildGradientEffect(ThemeData theme, Map<String, dynamic>? extensions, String gradientType) {
    final gradientColors = _getGradientColors(theme, extensions, gradientType);
    final gradient = _createGradient(gradientColors);
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: widget.child,
    );
  }

  /// Build glow effect
  Widget _buildGlowEffect(ThemeData theme, Map<String, dynamic>? extensions) {
    final glowIntensity = _getGlowIntensity();
    final glowColor = _getGlowColor(theme, extensions);
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3 * glowIntensity),
            blurRadius: _getGlowRadius() * glowIntensity,
            spreadRadius: 2 * glowIntensity,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.1 * glowIntensity),
            blurRadius: _getGlowRadius() * 2 * glowIntensity,
            spreadRadius: 4 * glowIntensity,
          ),
        ],
      ),
      child: widget.child,
    );
  }

  /// Build shimmer effect
  Widget _buildShimmerEffect(ThemeData theme, Map<String, dynamic>? extensions) {
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
            Colors.white.withValues(alpha: 0.3 * widget.intensity),
            Colors.white.withValues(alpha: 0.6 * widget.intensity),
            Colors.transparent,
          ],
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }

  /// Build particle effect
  Widget _buildParticleEffect(ThemeData theme, Map<String, dynamic>? extensions) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: CustomPaint(
            painter: ParticleEffectPainter(
              animation: _particleAnimation.value,
              color: _getParticleColor(theme, extensions),
              intensity: widget.intensity,
            ),
          ),
        ),
      ],
    );
  }

  /// Get gradient colors from schema or defaults
  List<Color> _getGradientColors(ThemeData theme, Map<String, dynamic>? extensions, String gradientType) {
    if (widget.customColors != null) {
      return widget.customColors!;
    }

    if (extensions != null && extensions.containsKey('gradients')) {
      final gradients = extensions['gradients'] as Map<String, dynamic>?;
      if (gradients != null && gradients.containsKey(gradientType)) {
        final gradient = gradients[gradientType] as Map<String, dynamic>?;
        if (gradient != null && gradient.containsKey('colors')) {
          final colors = gradient['colors'] as List<dynamic>?;
          if (colors != null) {
            return colors
                .map((color) => _parseColor(color.toString()) ?? theme.colorScheme.primary)
                .toList();
          }
        }
      }
    }

    // Schema defaults
    switch (gradientType) {
      case 'magic':
        return [const Color(0xFF7C6BAF), const Color(0xFFA594D1)]; // Schema default
      case 'portal':
        return [const Color(0xFF4A90E2), const Color(0xFF7C6BAF)]; // Schema default
      default:
        return [theme.colorScheme.primary, theme.colorScheme.primaryContainer];
    }
  }

  /// Create gradient based on direction
  Gradient _createGradient(List<Color> colors) {
    final direction = widget.gradientDirection ?? GradientDirection.diagonal;
    
    switch (direction) {
      case GradientDirection.horizontal:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        );
      case GradientDirection.vertical:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        );
      case GradientDirection.diagonal:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        );
      case GradientDirection.radial:
        return RadialGradient(
          colors: colors,
          radius: 1.0,
        );
      case GradientDirection.conic:
        return SweepGradient(
          colors: colors,
          startAngle: 0.0,
          endAngle: 2 * math.pi,
        );
    }
  }

  /// Get glow intensity based on animation and effect type
  double _getGlowIntensity() {
    switch (widget.effectType) {
      case VisualEffectType.pulseGlow:
        return 0.3 + (0.7 * _animation.value * widget.intensity);
      case VisualEffectType.breathingGlow:
        return 0.5 + (0.5 * _animation.value * widget.intensity);
      case VisualEffectType.glow:
      default:
        return widget.intensity;
    }
  }

  /// Get glow color
  Color _getGlowColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.customColors != null && widget.customColors!.isNotEmpty) {
      return widget.customColors!.first;
    }
    
    // Try to get from extensions
    if (extensions != null && extensions.containsKey('hoverAuraColor')) {
      final color = _parseColor(extensions['hoverAuraColor'].toString());
      if (color != null) return color;
    }
    
    return theme.colorScheme.primary;
  }

  /// Get glow radius
  double _getGlowRadius() {
    return widget.glowRadius ?? 12.0; // Schema default
  }

  /// Get particle color
  Color _getParticleColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (extensions != null && extensions.containsKey('particles')) {
      final particles = extensions['particles'] as Map<String, dynamic>?;
      if (particles != null && particles.containsKey('color')) {
        final color = _parseColor(particles['color'].toString());
        if (color != null) return color;
      }
    }
    
    return theme.colorScheme.primary.withValues(alpha: 0.6);
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

/// 🌟 Particle Effect Painter
class ParticleEffectPainter extends CustomPainter {
  final double animation;
  final Color color;
  final double intensity;

  ParticleEffectPainter({
    required this.animation,
    required this.color,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final particleCount = (20 * intensity).round();
    final random = math.Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < particleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.5 + random.nextDouble() * 1.5;
      
      // Calculate animated position
      final animatedOffset = (animation * speed) % 1.0;
      final x = baseX;
      final y = (baseY + (animatedOffset * size.height * 0.3)) % size.height;
      
      // Particle size and opacity
      final particleSize = 1.0 + random.nextDouble() * 2.0;
      final opacity = (0.3 + 0.7 * (1.0 - animatedOffset)) * intensity;
      
      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleEffectPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.color != color ||
           oldDelegate.intensity != intensity;
  }
}