import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/providers/theme_context_provider.dart';

/// 📊 Progress Indicator Variants
enum AppProgressVariant {
  linear,
  circular,
  magic,
  segmented,
}

/// 📊 App Progress Indicator based on Schema Configuration
/// 
/// Schema-based progress indicators with glow effects, gradients, and animations
class AppProgressIndicator extends StatefulWidget {
  final double? value; // 0.0 to 1.0, null for indeterminate
  final AppProgressVariant variant;
  final double? height;
  final double? width;
  final double? strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Color? secondaryColor;
  final bool showPercentage;
  final bool glowEffect;
  final bool gradient;
  final Duration animationDuration;
  final String? label;
  final TextStyle? labelStyle;
  final int segments;

  const AppProgressIndicator({
    super.key,
    this.value,
    this.variant = AppProgressVariant.linear,
    this.height,
    this.width,
    this.strokeWidth,
    this.backgroundColor,
    this.valueColor,
    this.secondaryColor,
    this.showPercentage = false,
    this.glowEffect = false,
    this.gradient = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.label,
    this.labelStyle,
    this.segments = 10,
  });

  /// Linear progress bar
  const AppProgressIndicator.linear({
    super.key,
    this.value,
    this.height,
    this.width,
    this.backgroundColor,
    this.valueColor,
    this.secondaryColor,
    this.showPercentage = false,
    this.glowEffect = false,
    this.gradient = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.label,
    this.labelStyle,
  }) : variant = AppProgressVariant.linear,
       strokeWidth = null,
       segments = 10;

  /// Circular progress indicator
  const AppProgressIndicator.circular({
    super.key,
    this.value,
    this.width = 40.0,
    this.strokeWidth,
    this.backgroundColor,
    this.valueColor,
    this.secondaryColor,
    this.showPercentage = false,
    this.glowEffect = false,
    this.gradient = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.label,
    this.labelStyle,
  }) : variant = AppProgressVariant.circular,
       height = null,
       segments = 10;

  /// Magic progress with glow effects
  const AppProgressIndicator.magic({
    super.key,
    this.value,
    this.variant = AppProgressVariant.linear,
    this.height,
    this.width,
    this.strokeWidth,
    this.backgroundColor,
    this.valueColor,
    this.secondaryColor,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.label,
    this.labelStyle,
    this.segments = 10,
  }) : glowEffect = true,
       gradient = true;

  /// Segmented progress bar
  const AppProgressIndicator.segmented({
    super.key,
    this.value,
    this.height,
    this.width,
    this.backgroundColor,
    this.valueColor,
    this.secondaryColor,
    this.showPercentage = false,
    this.glowEffect = false,
    this.gradient = false,
    this.animationDuration = const Duration(milliseconds: 500),
    this.label,
    this.labelStyle,
    this.segments = 10,
  }) : variant = AppProgressVariant.segmented,
       strokeWidth = null;

  @override
  State<AppProgressIndicator> createState() => _AppProgressIndicatorState();
}

class _AppProgressIndicatorState extends State<AppProgressIndicator> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  double _displayValue = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Progress animation
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value ?? 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    if (widget.glowEffect) {
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      
      _glowAnimation = Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));
      
      _glowController.repeat(reverse: true);
    }

    _displayValue = widget.value ?? 0.0;
    
    if (widget.value != null) {
      _animationController.forward();
    } else {
      // Indeterminate animation
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AppProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.value != oldWidget.value) {
      _progressAnimation = Tween<double>(
        begin: _displayValue,
        end: widget.value ?? 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      
      _displayValue = widget.value ?? 0.0;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.glowEffect) {
      _glowController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'AppProgressIndicator',
      contextOverrides: {
        'variant': widget.variant.name,
        'animated': 'true',
        'progress': widget.value.toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildProgress(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildProgress(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ?? _getLabelStyle(theme),
          ),
          const SizedBox(height: 8),
        ],
        
        // Progress indicator
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _buildProgressIndicator(theme, extensions);
          },
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppProgressVariant.linear:
        return _buildLinearProgress(theme, extensions);
      case AppProgressVariant.circular:
        return _buildCircularProgress(theme, extensions);
      case AppProgressVariant.magic:
        return _buildMagicProgress(theme, extensions);
      case AppProgressVariant.segmented:
        return _buildSegmentedProgress(theme, extensions);
    }
  }

  Widget _buildLinearProgress(ThemeData theme, Map<String, dynamic>? extensions) {
    final progress = widget.value != null ? _progressAnimation.value : null;
    
    Widget progressBar = Container(
      width: widget.width,
      height: _getHeight(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Stack(
          children: [
            // Progress fill
            if (progress != null)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: _getHeight(),
                    decoration: BoxDecoration(
                      color: widget.gradient ? null : _getValueColor(theme, extensions),
                      gradient: widget.gradient ? _getProgressGradient(theme, extensions) : null,
                      borderRadius: BorderRadius.circular(_getBorderRadius()),
                    ),
                  ),
                ),
              ),
            
            // Indeterminate animation
            if (progress == null)
              _buildIndeterminateBar(theme, extensions),
            
            // Percentage text
            if (widget.showPercentage && progress != null)
              Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: _getPercentageStyle(theme),
                ),
              ),
          ],
        ),
      ),
    );

    // Add glow effect
    if (widget.glowEffect && _glowController != null) {
      progressBar = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              boxShadow: [
                BoxShadow(
                  color: _getValueColor(theme, extensions).withValues(alpha: 0.4 * _glowAnimation.value),
                  blurRadius: 8 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: progressBar,
          );
        },
      );
    }

    return progressBar;
  }

  Widget _buildCircularProgress(ThemeData theme, Map<String, dynamic>? extensions) {
    final progress = widget.value != null ? _progressAnimation.value : null;
    final size = widget.width ?? 40.0;
    
    Widget progressIndicator = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircularProgressPainter(
          progress: progress,
          backgroundColor: _getBackgroundColor(theme),
          valueColor: _getValueColor(theme, extensions),
          strokeWidth: _getStrokeWidth(),
          gradient: widget.gradient ? _getProgressGradient(theme, extensions) : null,
        ),
        child: widget.showPercentage && progress != null
            ? Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: _getPercentageStyle(theme).copyWith(fontSize: size * 0.2),
                ),
              )
            : null,
      ),
    );

    // Add glow effect
    if (widget.glowEffect && _glowController != null) {
      progressIndicator = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getValueColor(theme, extensions).withValues(alpha: 0.4 * _glowAnimation.value),
                  blurRadius: 12 * _glowAnimation.value,
                  spreadRadius: 3 * _glowAnimation.value,
                ),
              ],
            ),
            child: progressIndicator,
          );
        },
      );
    }

    return progressIndicator;
  }

  Widget _buildMagicProgress(ThemeData theme, Map<String, dynamic>? extensions) {
    // Magic progress is enhanced linear progress
    return _buildLinearProgress(theme, extensions);
  }

  Widget _buildSegmentedProgress(ThemeData theme, Map<String, dynamic>? extensions) {
    final progress = widget.value != null ? _progressAnimation.value : 0.0;
    final filledSegments = (progress * widget.segments).round();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.segments, (index) {
        final isFilled = index < filledSegments;
        return Container(
          width: (widget.width ?? 200) / widget.segments - 2,
          height: _getHeight(),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isFilled 
                ? _getValueColor(theme, extensions)
                : _getBackgroundColor(theme),
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            border: Border.all(
              color: _getValueColor(theme, extensions).withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIndeterminateBar(ThemeData theme, Map<String, dynamic>? extensions) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = _animationController.value;
        final width = widget.width ?? 200.0;
        final barWidth = width * 0.3;
        final position = (width + barWidth) * animationValue - barWidth;
        
        return Positioned(
          left: position,
          child: Container(
            width: barWidth,
            height: _getHeight(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _getValueColor(theme, extensions),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
          ),
        );
      },
    );
  }

  /// Get height from schema
  double _getHeight() {
    if (widget.height != null) return widget.height!;
    
    // Schema default: 6
    return 6.0;
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    // Schema default: 3
    return 3.0;
  }

  /// Get stroke width for circular progress
  double _getStrokeWidth() {
    if (widget.strokeWidth != null) return widget.strokeWidth!;
    
    return 4.0;
  }

  /// Get background color
  Color _getBackgroundColor(ThemeData theme) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    return theme.colorScheme.surfaceContainer;
  }

  /// Get value color
  Color _getValueColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.valueColor != null) return widget.valueColor!;
    
    // Try to get magic gradient color from extensions
    if (extensions != null && extensions.containsKey('magicGradient')) {
      final colors = extensions['magicGradient'] as List<dynamic>?;
      if (colors != null && colors.isNotEmpty) {
        final color = _parseColor(colors.first.toString());
        if (color != null) return color;
      }
    }
    
    return theme.colorScheme.primary;
  }

  /// Get progress gradient
  LinearGradient _getProgressGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    final primaryColor = _getValueColor(theme, extensions);
    final secondaryColor = widget.secondaryColor ?? primaryColor.withValues(alpha: 0.7);
    
    return LinearGradient(
      colors: [primaryColor, secondaryColor, primaryColor],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Get label style
  TextStyle _getLabelStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    ) ?? TextStyle(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Get percentage text style
  TextStyle _getPercentageStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onPrimary,
    ) ?? TextStyle(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onPrimary,
      fontSize: 12,
    );
  }

  /// Helper: Parse color from hex string
  Color? _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }
}

/// 🎨 Circular Progress Painter
class CircularProgressPainter extends CustomPainter {
  final double? progress;
  final Color backgroundColor;
  final Color valueColor;
  final double strokeWidth;
  final Gradient? gradient;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.valueColor,
    required this.strokeWidth,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress != null) {
      final progressPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (gradient != null) {
        progressPaint.shader = gradient!.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      } else {
        progressPaint.color = valueColor;
      }

      final sweepAngle = 2 * math.pi * progress!.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    } else {
      // Indeterminate spinner
      final paint = Paint()
        ..color = valueColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0,
        math.pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.valueColor != valueColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}