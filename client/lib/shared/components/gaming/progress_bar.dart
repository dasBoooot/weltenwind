import 'package:flutter/material.dart';
import '../../../core/providers/theme_context_provider.dart';

/// 🎮 RPG Progress Bar Types based on Gaming Schema
enum ProgressBarType {
  health,
  mana,
  experience,
  stamina,
  energy,
  custom,
}

/// 📊 Gaming Progress Bar Component based on Gaming Schema
/// 
/// RPG-style progress bar for health, mana, XP with animations and effects
class GameProgressBar extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double? maxValue;
  final double? currentValue;
  final ProgressBarType type;
  final String? label;
  final bool showValue;
  final bool showPercentage;
  final bool isAnimated;
  final Duration animationDuration;
  final Color? customColor;
  final double height;
  final double? width;

  const GameProgressBar({
    super.key,
    required this.value,
    this.maxValue,
    this.currentValue,
    this.type = ProgressBarType.health,
    this.label,
    this.showValue = false,
    this.showPercentage = false,
    this.isAnimated = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.customColor,
    this.height = 24.0,
    this.width,
  }) : assert(value >= 0.0 && value <= 1.0);

  @override
  State<GameProgressBar> createState() => _GameProgressBarState();
}

class _GameProgressBarState extends State<GameProgressBar> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  double _displayValue = 0.0;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _displayValue = widget.value;
    
    if (widget.isAnimated) {
      _progressController.forward();
    }
    
    // Start pulse animation for low health/mana
    if (_shouldPulse()) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GameProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.value != widget.value) {
      if (widget.isAnimated) {
        _progressAnimation = Tween<double>(
          begin: _displayValue,
          end: widget.value,
        ).animate(CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeInOut,
        ));
        _progressController.reset();
        _progressController.forward();
      } else {
        _displayValue = widget.value;
      }
    }
    
    // Handle pulse animation based on new value
    if (_shouldPulse()) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _shouldPulse() {
    return widget.value <= 0.25 && (widget.type == ProgressBarType.health || widget.type == ProgressBarType.mana);
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'GameProgressBar',
      contextOverrides: {
        'type': widget.type.name,
        'animated': widget.isAnimated.toString(),
        'progress': widget.value.toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildProgressBar(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _pulseController]),
      builder: (context, child) {
        _displayValue = widget.isAnimated ? _progressAnimation.value : widget.value;
        
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: _getBackgroundColor(theme),
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  border: Border.all(
                    color: _getBorderColor(theme),
                    width: 1.0,
                  ),
                ),
              ),
              
              // Progress fill
              ClipRRect(
                borderRadius: BorderRadius.circular(widget.height / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: (widget.width ?? double.infinity) * _displayValue,
                  decoration: BoxDecoration(
                    gradient: _getProgressGradient(theme, extensions),
                    boxShadow: _getProgressShadows(theme),
                  ),
                  transform: _shouldPulse() 
                      ? (Matrix4.identity()..scale(_pulseAnimation.value, 1.0))
                      : null,
                  transformAlignment: Alignment.centerLeft,
                ),
              ),
              
              // Shimmer effect for XP/special bars
              if (widget.type == ProgressBarType.experience)
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  child: _buildShimmerEffect(theme),
                ),
              
              // Text overlay
              if (widget.label != null || widget.showValue || widget.showPercentage)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      _getDisplayText(),
                      style: _getTextStyle(theme),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Background color
  Color _getBackgroundColor(ThemeData theme) {
    return theme.colorScheme.surfaceContainer.withValues(alpha: 0.8);
  }

  /// Border color
  Color _getBorderColor(ThemeData theme) {
    return theme.colorScheme.outline.withValues(alpha: 0.5);
  }

  /// Progress gradient based on type
  LinearGradient _getProgressGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.type) {
      case ProgressBarType.health:
        return LinearGradient(
          colors: [
            const Color(0xFFE53E3E), // Red
            const Color(0xFFFC8181), // Light red  
          ],
        );
      case ProgressBarType.mana:
        return LinearGradient(
          colors: [
            const Color(0xFF3182CE), // Blue
            const Color(0xFF63B3ED), // Light blue
          ],
        );
      case ProgressBarType.experience:
        return LinearGradient(
          colors: [
            const Color(0xFFD69E2E), // Gold
            const Color(0xFFF7D794), // Light gold
            const Color(0xFFD69E2E),
          ],
        );
      case ProgressBarType.stamina:
        return LinearGradient(
          colors: [
            const Color(0xFF38A169), // Green
            const Color(0xFF68D391), // Light green
          ],
        );
      case ProgressBarType.energy:
        return LinearGradient(
          colors: [
            const Color(0xFF805AD5), // Purple
            const Color(0xFFB794F6), // Light purple
          ],
        );
      case ProgressBarType.custom:
        final customColor = widget.customColor ?? theme.colorScheme.primary;
        return LinearGradient(
          colors: [
            customColor,
            customColor.withValues(alpha: 0.7),
          ],
        );
    }
  }

  /// Progress glow shadows
  List<BoxShadow> _getProgressShadows(ThemeData theme) {
    final progressColor = _getProgressGradient(theme, null).colors.first;
    
    return [
      BoxShadow(
        color: progressColor.withValues(alpha: 0.3),
        blurRadius: 4,
        spreadRadius: 1,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Shimmer effect for XP bars
  Widget _buildShimmerEffect(ThemeData theme) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          width: (widget.width ?? double.infinity) * _displayValue,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                0.3 + (0.4 * _progressController.value),
                0.6 + (0.4 * _progressController.value),
                1.0,
              ],
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Display text
  String _getDisplayText() {
    if (widget.label != null) {
      if (widget.showValue && widget.maxValue != null && widget.currentValue != null) {
        return '${widget.label}: ${widget.currentValue!.toInt()}/${widget.maxValue!.toInt()}';
      } else if (widget.showPercentage) {
        return '${widget.label}: ${(widget.value * 100).toInt()}%';
      }
      return widget.label!;
    }
    
    if (widget.showValue && widget.maxValue != null && widget.currentValue != null) {
      return '${widget.currentValue!.toInt()}/${widget.maxValue!.toInt()}';
    }
    
    if (widget.showPercentage) {
      return '${(widget.value * 100).toInt()}%';
    }
    
    return '';
  }

  /// Text style
  TextStyle _getTextStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      fontSize: widget.height * 0.5,
      shadows: [
        Shadow(
          color: theme.colorScheme.shadow.withValues(alpha: 0.8),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    ) ?? TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      fontSize: widget.height * 0.5,
    );
  }
}