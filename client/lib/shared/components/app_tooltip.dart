import 'package:flutter/material.dart';
import '../../core/providers/theme_context_provider.dart';

/// 💬 App Tooltip based on Schema Configuration
/// 
/// Enhanced tooltip with schema-based styling, delays, and fantasy effects
class AppTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final InlineSpan? richMessage;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? verticalOffset;
  final bool preferBelow;
  final bool waitDuration;
  final Duration? showDuration;
  final Duration? showDelay;
  final Duration? hideDelay;
  final TooltipTriggerMode? triggerMode;
  final bool enableFeedback;
  final double? maxWidth;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final bool showGlow;

  const AppTooltip({
    super.key,
    required this.child,
    required this.message,
    this.richMessage,
    this.padding,
    this.margin,
    this.verticalOffset,
    this.preferBelow = true,
    this.waitDuration = true,
    this.showDuration,
    this.showDelay,
    this.hideDelay,
    this.triggerMode,
    this.enableFeedback = true,
    this.maxWidth,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.showGlow = false,
  });

  /// Magic tooltip with glow effect
  const AppTooltip.magic({
    super.key,
    required this.child,
    required this.message,
    this.richMessage,
    this.padding,
    this.margin,
    this.verticalOffset,
    this.preferBelow = true,
    this.showDuration,
    this.triggerMode,
    this.enableFeedback = true,
    this.maxWidth,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : waitDuration = true,
       showDelay = const Duration(milliseconds: 300),
       hideDelay = const Duration(milliseconds: 100),
       showGlow = true;

  /// Quick tooltip with no delay
  const AppTooltip.quick({
    super.key,
    required this.child,
    required this.message,
    this.richMessage,
    this.padding,
    this.margin,
    this.verticalOffset,
    this.preferBelow = true,
    this.showDuration,
    this.triggerMode,
    this.enableFeedback = true,
    this.maxWidth,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : waitDuration = false,
       showDelay = Duration.zero,
       hideDelay = Duration.zero,
       showGlow = false;

  /// Help tooltip for UI explanations
  const AppTooltip.help({
    super.key,
    required this.child,
    required this.message,
    this.richMessage,
    this.padding,
    this.margin,
    this.verticalOffset,
    this.preferBelow = false,
    this.showDuration = const Duration(seconds: 5),
    this.triggerMode = TooltipTriggerMode.tap,
    this.enableFeedback = true,
    this.maxWidth = 250,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : waitDuration = true,
       showDelay = const Duration(milliseconds: 500),
       hideDelay = const Duration(milliseconds: 200),
       showGlow = false;

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

class _AppTooltipState extends State<AppTooltip> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.showGlow) {
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );
      
      _glowAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.showGlow) {
      _glowController.dispose();
    }
    super.dispose();
  }

  void _startGlowAnimation() {
    if (widget.showGlow && _glowController.status != AnimationStatus.forward) {
      _glowController.repeat(reverse: true);
    }
  }

  void _stopGlowAnimation() {
    if (widget.showGlow) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'AppTooltip',
      contextOverrides: {
        'visible': 'normal',
        'hasMessage': (widget.message.isNotEmpty).toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildTooltip(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildTooltip(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    
    Widget tooltip = Tooltip(
      message: widget.message,
      richMessage: widget.richMessage,
      padding: _getPadding(),
      margin: _getMargin(),
      verticalOffset: widget.verticalOffset,
      preferBelow: widget.preferBelow,
      waitDuration: _getShowDelay(),
      showDuration: _getShowDuration(),
      exitDuration: _getHideDelay(),
      triggerMode: _getTriggerMode(),
      enableFeedback: widget.enableFeedback,
      decoration: _getDecoration(theme, extensions),
      textStyle: _getTextStyle(theme, extensions),
      child: widget.child,
    );

    // Wrap with glow effect if enabled
    if (widget.showGlow) {
      return MouseRegion(
        onEnter: (_) => _startGlowAnimation(),
        onExit: (_) => _stopGlowAnimation(),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _getGlowColor(theme, extensions).withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 8 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                ],
              ),
              child: tooltip,
            );
          },
        ),
      );
    }

    return tooltip;
  }

  /// Get padding from schema
  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;
    
    // Schema default: 8
    return const EdgeInsets.all(8.0);
  }

  /// Get margin from schema
  EdgeInsetsGeometry _getMargin() {
    if (widget.margin != null) return widget.margin!;
    
    // Schema default: 12
    return const EdgeInsets.all(12.0);
  }

  /// Get show delay from schema
  Duration _getShowDelay() {
    if (widget.showDelay != null) return widget.showDelay!;
    if (!widget.waitDuration) return Duration.zero;
    
    // Schema default: 500ms
    return const Duration(milliseconds: 500);
  }

  /// Get show duration from schema
  Duration? _getShowDuration() {
    return widget.showDuration;
  }

  /// Get hide delay from schema
  Duration _getHideDelay() {
    if (widget.hideDelay != null) return widget.hideDelay!;
    
    // Schema default: 0ms
    return Duration.zero;
  }

  /// Get trigger mode
  TooltipTriggerMode _getTriggerMode() {
    return widget.triggerMode ?? TooltipTriggerMode.longPress;
  }

  /// Get tooltip decoration from schema
  BoxDecoration _getDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme, extensions),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get text style from schema
  TextStyle _getTextStyle(ThemeData theme, Map<String, dynamic>? extensions) {
    return TextStyle(
      color: _getTextColor(theme, extensions),
      fontSize: _getFontSize(),
      fontWeight: FontWeight.w500,
    );
  }

  /// Get background color from schema
  Color _getBackgroundColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    // Schema default: #000000CC (black with alpha)
    return const Color(0xCC000000);
  }

  /// Get text color from schema
  Color _getTextColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.textColor != null) return widget.textColor!;
    
    // Schema default: #FFFFFF (white)
    return const Color(0xFFFFFFFF);
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    if (widget.borderRadius != null) return widget.borderRadius!;
    
    // Schema default: 8
    return 8.0;
  }

  /// Get font size from schema
  double _getFontSize() {
    if (widget.fontSize != null) return widget.fontSize!;
    
    // Schema default: 12
    return 12.0;
  }

  /// Get glow color for magic tooltips
  Color _getGlowColor(ThemeData theme, Map<String, dynamic>? extensions) {
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

/// 🎯 Tooltip Wrapper Widgets for common use cases
class TooltipHelpers {
  /// Help icon with tooltip
  static Widget helpIcon({
    required String message,
    IconData icon = Icons.help_outline,
    double size = 16,
    Color? color,
  }) {
    return Builder(
      builder: (context) => AppTooltip.help(
        message: message,
        child: Icon(
          icon,
          size: size,
          color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// Info icon with tooltip
  static Widget infoIcon({
    required String message,
    IconData icon = Icons.info_outline,
    double size = 16,
    Color? color,
  }) {
    return Builder(
      builder: (context) => AppTooltip.quick(
        message: message,
        child: Icon(
          icon,
          size: size,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Warning icon with tooltip
  static Widget warningIcon({
    required String message,
    IconData icon = Icons.warning_outlined,
    double size = 16,
    Color? color,
  }) {
    return Builder(
      builder: (context) => AppTooltip.quick(
        message: message,
        child: Icon(
          icon,
          size: size,
          color: color ?? Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  /// Text with tooltip
  static Widget text({
    required String text,
    required String tooltip,
    TextStyle? style,
  }) {
    return AppTooltip(
      message: tooltip,
      child: Text(text, style: style),
    );
  }

  /// Button with tooltip
  static Widget button({
    required Widget child,
    required String tooltip,
    required VoidCallback? onPressed,
    ButtonStyle? style,
  }) {
    return AppTooltip.quick(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}