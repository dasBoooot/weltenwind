import 'package:flutter/material.dart';
import '../../core/providers/theme_context_provider.dart';

/// ⏳ Loading Overlay based on Schema Configuration
/// 
/// Full-screen loading overlay with blur, pulse animations, and schema-based styling
class LoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String? message;
  final Widget? customSpinner;
  final Color? backgroundColor;
  final Color? textColor;
  final double? spinnerSize;
  final bool showText;
  final bool glowEffect;
  final bool pulseAnimation;
  final bool backdropBlur;
  final Duration animationDuration;
  final VoidCallback? onCancel;
  final bool canCancel;

  const LoadingOverlay({
    super.key,
    required this.isVisible,
    this.message,
    this.customSpinner,
    this.backgroundColor,
    this.textColor,
    this.spinnerSize,
    this.showText = true,
    this.glowEffect = true,
    this.pulseAnimation = true,
    this.backdropBlur = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onCancel,
    this.canCancel = false,
  });

  /// Magic loading overlay with glow effects
  const LoadingOverlay.magic({
    super.key,
    required this.isVisible,
    this.message,
    this.customSpinner,
    this.backgroundColor,
    this.textColor,
    this.spinnerSize,
    this.showText = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onCancel,
    this.canCancel = false,
  }) : glowEffect = true,
       pulseAnimation = true,
       backdropBlur = true;

  /// Simple loading overlay without effects
  const LoadingOverlay.simple({
    super.key,
    required this.isVisible,
    this.message,
    this.customSpinner,
    this.backgroundColor,
    this.textColor,
    this.spinnerSize,
    this.showText = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onCancel,
    this.canCancel = false,
  }) : glowEffect = false,
       pulseAnimation = false,
       backdropBlur = false;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade animation
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    if (widget.pulseAnimation) {
      _pulseController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );
      
      _pulseAnimation = Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ));
      
      _pulseController.repeat(reverse: true);
    }

    // Rotation animation for spinner
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _rotationController.repeat();

    if (widget.isVisible) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    if (widget.pulseAnimation) {
      _pulseController.dispose();
    }
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'LoadingOverlay',
      contextOverrides: {
        'showText': widget.showText.toString(),
        'hasBlur': widget.backdropBlur.toString(),
        'pulsing': widget.pulseAnimation.toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildOverlay(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildOverlay(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildOverlayContent(theme, extensions),
        );
      },
    );
  }

  Widget _buildOverlayContent(ThemeData theme, Map<String, dynamic>? extensions) {
    Widget overlay = Container(
      color: _getBackgroundColor(theme, extensions),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spinner
            _buildSpinner(theme, extensions),
            
            // Text
            if (widget.showText && widget.message != null) ...[
              const SizedBox(height: 24),
              _buildText(theme, extensions),
            ],
            
            // Cancel button
            if (widget.canCancel && widget.onCancel != null) ...[
              const SizedBox(height: 32),
              _buildCancelButton(theme),
            ],
          ],
        ),
      ),
    );

    // Add backdrop blur if enabled
    if (widget.backdropBlur) {
      overlay = Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(theme, extensions),
              ),
            ),
          ),
          // Content
          overlay,
        ],
      );
    }

    return overlay;
  }

  Widget _buildSpinner(ThemeData theme, Map<String, dynamic>? extensions) {
    Widget spinner = widget.customSpinner ?? _buildDefaultSpinner(theme, extensions);
    
    // Add pulse animation
    if (widget.pulseAnimation) {
      spinner = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: spinner,
          );
        },
      );
    }

    // Add glow effect
    if (widget.glowEffect) {
      spinner = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getGlowColor(theme, extensions).withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: _getGlowColor(theme, extensions).withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: spinner,
      );
    }

    return spinner;
  }

  Widget _buildDefaultSpinner(ThemeData theme, Map<String, dynamic>? extensions) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: _getSpinnerSize(),
            height: _getSpinnerSize(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getSpinnerGradient(theme, extensions),
              border: Border.all(
                color: _getSpinnerColor(theme, extensions),
                width: 3,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withValues(alpha: 0.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildText(ThemeData theme, Map<String, dynamic>? extensions) {
    return Text(
      widget.message!,
      style: _getTextStyle(theme, extensions),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCancelButton(ThemeData theme) {
    return OutlinedButton(
      onPressed: widget.onCancel,
      style: OutlinedButton.styleFrom(
        foregroundColor: _getTextColor(theme),
        side: BorderSide(color: _getTextColor(theme).withValues(alpha: 0.5)),
      ),
      child: const Text('Cancel'),
    );
  }

  /// Get background color from schema
  Color _getBackgroundColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    return theme.colorScheme.surface.withValues(alpha: 0.8);
  }

  /// Get text color from schema
  Color _getTextColor(ThemeData theme) {
    if (widget.textColor != null) return widget.textColor!;
    
    return theme.colorScheme.onSurface;
  }

  /// Get spinner size from schema
  double _getSpinnerSize() {
    if (widget.spinnerSize != null) return widget.spinnerSize!;
    
    // Schema default: 40
    return 40.0;
  }

  /// Get spinner color
  Color _getSpinnerColor(ThemeData theme, Map<String, dynamic>? extensions) {
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

  /// Get spinner gradient
  LinearGradient _getSpinnerGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    final spinnerColor = _getSpinnerColor(theme, extensions);
    
    return LinearGradient(
      colors: [
        spinnerColor,
        spinnerColor.withValues(alpha: 0.3),
        theme.colorScheme.surface.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }

  /// Get glow color for effect
  Color _getGlowColor(ThemeData theme, Map<String, dynamic>? extensions) {
    return _getSpinnerColor(theme, extensions);
  }

  /// Get text style
  TextStyle _getTextStyle(ThemeData theme, Map<String, dynamic>? extensions) {
    return theme.textTheme.bodyLarge?.copyWith(
      color: _getTextColor(theme),
      fontWeight: FontWeight.w500,
    ) ?? TextStyle(
      color: _getTextColor(theme),
      fontWeight: FontWeight.w500,
      fontSize: 16,
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

/// ⏳ Loading Overlay Manager
class LoadingManager {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Show loading overlay
  static void show(
    BuildContext context, {
    String? message,
    bool magic = false,
    bool canCancel = false,
    VoidCallback? onCancel,
  }) {
    if (_isShowing) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => magic
          ? LoadingOverlay.magic(
              isVisible: true,
              message: message,
              canCancel: canCancel,
              onCancel: onCancel ?? hide,
            )
          : LoadingOverlay(
              isVisible: true,
              message: message,
              canCancel: canCancel,
              onCancel: onCancel ?? hide,
            ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;
  }

  /// Hide loading overlay
  static void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  /// Check if loading is showing
  static bool get isShowing => _isShowing;
}