import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/providers/theme_context_provider.dart';

/// 🖼️ Fantasy Frame Variants based on Theme Schema
enum AppFrameVariant {
  /// Standard frame with surface colors
  standard,
  /// Fantasy magic frame with glow effects
  magic,
  /// Portal frame with aqua effects
  portal,
  /// Artifact frame with golden effects
  artifact,
  /// Rune frame with mystical corners
  rune,
  /// Crystal frame with shimmer effects
  crystal,
  /// Ancient frame for scrolls and artifacts
  ancient,
  /// Minimal frame with subtle borders
  minimal,
}

/// 🎭 Frame Styles
enum AppFrameStyle {
  /// Filled background
  filled,
  /// Border only
  outlined,
  /// Glass morphism effect
  glass,
  /// Gradient background
  gradient,
}

/// 🖼️ Weltenwind Schema-Based Fantasy Frame
/// 
/// Layout container for grouping UI elements with fantasy theming
class AppFrame extends StatefulWidget {
  final Widget child;
  final AppFrameVariant variant;
  final AppFrameStyle style;
  final String? title;
  final Widget? titleWidget;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isInteractive;

  const AppFrame({
    super.key,
    required this.child,
    this.variant = AppFrameVariant.standard,
    this.style = AppFrameStyle.filled,
    this.title,
    this.titleWidget,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isInteractive = false,
  });

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start continuous glow animation for fantasy variants  
    if (_shouldAnimateGlow()) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _shouldAnimateGlow() {
    return widget.variant == AppFrameVariant.magic ||
           widget.variant == AppFrameVariant.portal ||
           widget.variant == AppFrameVariant.crystal ||
           widget.variant == AppFrameVariant.rune;
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (widget.isInteractive) {
      setState(() => _isHovered = true);
    }
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (widget.isInteractive) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'AppFrame',
      contextOverrides: {
        'variant': widget.variant.name,
        'state': _isHovered ? 'hovered' : 'normal',
        'interactive': widget.isInteractive.toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildFrame(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildFrame(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        margin: widget.margin ?? _getDefaultMargin(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null || widget.titleWidget != null)
              _buildTitle(theme, extensions),
            Flexible(
              child: Container(
                decoration: _getDecoration(theme, extensions),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_getBorderRadius()),
                  child: Padding(
                    padding: widget.padding ?? _getDefaultPadding(),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build title section
  Widget _buildTitle(ThemeData theme, Map<String, dynamic>? extensions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
      child: widget.titleWidget ?? Text(
        widget.title!,
        style: _getTitleStyle(theme),
      ),
    );
  }

  /// Get decoration based on schema and fantasy extensions
  BoxDecoration _getDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme, extensions),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: _getBorder(theme, extensions),
      gradient: _getGradient(theme, extensions),
      boxShadow: _getShadows(theme, extensions),
    );
  }

  /// Background color based on variant and style
  Color? _getBackgroundColor(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.style) {
      case AppFrameStyle.outlined:
        return Colors.transparent;
      case AppFrameStyle.glass:
        return theme.colorScheme.surface.withValues(alpha: 0.1);
      case AppFrameStyle.filled:
      case AppFrameStyle.gradient:
        switch (widget.variant) {
          case AppFrameVariant.standard:
          case AppFrameVariant.minimal:
            return theme.colorScheme.surface;
          case AppFrameVariant.magic:
            return theme.colorScheme.primaryContainer.withValues(alpha: 0.2);
          case AppFrameVariant.portal:
            return theme.colorScheme.tertiaryContainer.withValues(alpha: 0.2);
          case AppFrameVariant.artifact:
            return theme.colorScheme.secondaryContainer.withValues(alpha: 0.2);
          case AppFrameVariant.ancient:
            return theme.colorScheme.surfaceContainerHighest;
          case AppFrameVariant.rune:
          case AppFrameVariant.crystal:
            return theme.colorScheme.surface.withValues(alpha: 0.9);
        }
    }
  }

  /// Border based on variant and style
  Border? _getBorder(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.style == AppFrameStyle.outlined || widget.variant == AppFrameVariant.minimal) {
      final borderColor = _getBorderColor(theme, extensions);
      return Border.all(
        color: borderColor,
        width: _getBorderWidth(),
      );
    }
    return null;
  }

  /// Border color based on variant
  Color _getBorderColor(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppFrameVariant.magic:
        return theme.colorScheme.primary.withValues(alpha: _isHovered ? 0.8 : 0.6);
      case AppFrameVariant.portal:
        return theme.colorScheme.tertiary.withValues(alpha: _isHovered ? 0.8 : 0.6);
      case AppFrameVariant.artifact:
        return theme.colorScheme.secondary.withValues(alpha: _isHovered ? 0.8 : 0.6);
      case AppFrameVariant.rune:
        return theme.colorScheme.primary.withValues(alpha: 0.7);
      case AppFrameVariant.crystal:
        return theme.colorScheme.onSurface.withValues(alpha: 0.3);
      case AppFrameVariant.ancient:
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.outline;
    }
  }

  /// Fantasy gradients from extensions
  Gradient? _getGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.style != AppFrameStyle.gradient) return null;

    switch (widget.variant) {
      case AppFrameVariant.magic:
        if (extensions != null && extensions.containsKey('magicGradient')) {
          final colors = (extensions['magicGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString())?.withValues(alpha: 0.3) ?? 
                   theme.colorScheme.primary.withValues(alpha: 0.3))
              .toList();
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          );
        }
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.2),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        );
      case AppFrameVariant.portal:
        if (extensions != null && extensions.containsKey('portalGradient')) {
          final colors = (extensions['portalGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString())?.withValues(alpha: 0.3) ?? 
                   theme.colorScheme.tertiary.withValues(alpha: 0.3))
              .toList();
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          );
        }
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiary.withValues(alpha: 0.2),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
          ],
        );
      case AppFrameVariant.crystal:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.2),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
            theme.colorScheme.surface.withValues(alpha: 0.05),
            theme.colorScheme.surfaceContainer.withValues(alpha: 0.1),
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainer,
          ],
        );
    }
  }

  /// Fantasy shadows and glow effects
  List<BoxShadow> _getShadows(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppFrameVariant.magic:
        final glowOpacity = 0.3 + (0.2 * _glowAnimation.value);
        return [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: glowOpacity),
            blurRadius: 12 + (8 * _glowAnimation.value),
            spreadRadius: 1 + (2 * _glowAnimation.value),
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ];
      case AppFrameVariant.portal:
        final glowOpacity = 0.3 + (0.2 * _glowAnimation.value);
        return [
          BoxShadow(
            color: theme.colorScheme.tertiary.withValues(alpha: glowOpacity),
            blurRadius: 12 + (6 * _glowAnimation.value),
            spreadRadius: 1 + (1 * _glowAnimation.value),
            offset: const Offset(0, 2),
          ),
        ];
      case AppFrameVariant.artifact:
        return [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: _isHovered ? 0.4 : 0.2),
            blurRadius: _isHovered ? 16 : 12,
            spreadRadius: _isHovered ? 2 : 1,
            offset: const Offset(0, 2),
          ),
        ];
      case AppFrameVariant.crystal:
        final shimmerOpacity = 0.1 + (0.1 * _glowAnimation.value);
        return [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: shimmerOpacity),
            blurRadius: 20 + (10 * _glowAnimation.value),
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ];
      case AppFrameVariant.rune:
        final glowOpacity = 0.2 + (0.3 * _glowAnimation.value);
        return [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: glowOpacity),
            blurRadius: 8 + (12 * _glowAnimation.value),
            spreadRadius: 0 + (2 * _glowAnimation.value),
            offset: const Offset(0, 2),
          ),
        ];
      case AppFrameVariant.ancient:
        return [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ];
    }
  }

  /// Title text style
  TextStyle _getTitleStyle(ThemeData theme) {
    return theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    ) ?? TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Border radius
  double _getBorderRadius() {
    switch (widget.variant) {
      case AppFrameVariant.minimal:
        return 4.0;
      case AppFrameVariant.ancient:
        return 2.0;
      case AppFrameVariant.crystal:
        return 20.0;
      default:
        return 12.0;
    }
  }

  /// Border width
  double _getBorderWidth() {
    switch (widget.variant) {
      case AppFrameVariant.magic:
      case AppFrameVariant.portal:
      case AppFrameVariant.rune:
        return 2.0;
      case AppFrameVariant.ancient:
        return 1.5;
      default:
        return 1.0;
    }
  }

  /// Default margin
  EdgeInsetsGeometry _getDefaultMargin() {
    return const EdgeInsets.all(4.0);
  }

  /// Default padding
  EdgeInsetsGeometry _getDefaultPadding() {
    switch (widget.variant) {
      case AppFrameVariant.minimal:
        return const EdgeInsets.all(8.0);
      case AppFrameVariant.ancient:
        return const EdgeInsets.all(20.0);
      default:
        return const EdgeInsets.all(16.0);
    }
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