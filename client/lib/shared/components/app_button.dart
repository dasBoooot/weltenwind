import 'package:flutter/material.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)

/// 🎯 Fantasy Button Variants based on Theme Schema
enum AppButtonVariant {
  /// Primary action button
  primary,
  /// Secondary action with outline
  secondary, 
  /// Text-only button
  tertiary,
  /// Fantasy magic button with glow effects
  magic,
  /// Portal button with aqua effects
  portal,
  /// Artifact button with golden effects
  artifact,
  /// Success button
  success,
  /// Danger/error button
  danger,
  /// Ghost transparent button
  ghost,
}

/// 📏 Button Sizes based on Schema
enum AppButtonSize {
  small,
  medium, 
  large,
  extraLarge,
}

/// 🎨 Weltenwind Schema-Based Fantasy Button
/// 
/// Completely rebuilt based on JSON Theme Schema with ModularThemeService integration
class AppButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final IconData? suffixIcon;
  
  // 🦾 Accessibility Parameters
  final String? semanticLabel;
  final String? tooltip;
  final String? hint;

  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.suffixIcon,
    // 🦾 Accessibility 
    this.semanticLabel,
    this.tooltip,
    this.hint,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 SMART NAVIGATION THEME: Verwendet globales Theme
    return _buildButton(context, Theme.of(context), null);
  }

  Widget _buildButton(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    return Semantics(
      label: _getSemanticLabel(),
      hint: _getSemanticHint(),
      button: true,
      enabled: isEnabled,
      onTap: isEnabled ? widget.onPressed : null,
      child: widget.tooltip != null
        ? Tooltip(
            message: widget.tooltip!,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: widget.isExpanded ? double.infinity : null,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled ? widget.onPressed : null,
                    onTapDown: isEnabled ? _handleTapDown : null,
                    onTapUp: isEnabled ? _handleTapUp : null,
                    onTapCancel: _handleTapCancel,
                    borderRadius: BorderRadius.circular(_getBorderRadius(theme)),
                    splashColor: _getSplashColor(theme, extensions).withValues(alpha: 0.2),
                    highlightColor: _getSplashColor(theme, extensions).withValues(alpha: 0.1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: _getDecoration(theme, isEnabled, extensions),
                      padding: _getPadding(theme),
                      child: _buildContent(theme, isEnabled),
                    ),
                  ),
                ),
              ),
            ),
          )
        : ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: widget.isExpanded ? double.infinity : null,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  onTapDown: isEnabled ? _handleTapDown : null,
                  onTapUp: isEnabled ? _handleTapUp : null,
                  onTapCancel: _handleTapCancel,
                  borderRadius: BorderRadius.circular(_getBorderRadius(theme)),
                  splashColor: _getSplashColor(theme, extensions).withValues(alpha: 0.2),
                  highlightColor: _getSplashColor(theme, extensions).withValues(alpha: 0.1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: _getDecoration(theme, isEnabled, extensions),
                    padding: _getPadding(theme),
                    child: _buildContent(theme, isEnabled),
                  ),
                ),
              ),
            ),
          ),
      );
    }

  /// Get decoration based on schema and fantasy extensions
  BoxDecoration _getDecoration(ThemeData theme, bool isEnabled, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme, isEnabled),
      borderRadius: BorderRadius.circular(_getBorderRadius(theme)),
      border: _getBorder(theme, isEnabled),
      gradient: _getGradient(theme, isEnabled, extensions),
      boxShadow: _getShadows(theme, isEnabled, extensions),
    );
  }

  /// Background color based on variant and theme
  Color _getBackgroundColor(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return theme.colorScheme.onSurface.withValues(alpha: 0.12);
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return theme.colorScheme.primary;
      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.magic:
        return theme.colorScheme.primary;
      case AppButtonVariant.portal:
        return theme.colorScheme.tertiary;
      case AppButtonVariant.artifact:
        return theme.colorScheme.secondary;
      case AppButtonVariant.success:
        return theme.colorScheme.tertiary;
      case AppButtonVariant.danger:
        return theme.colorScheme.error;
    }
  }

  /// Border based on variant
  Border? _getBorder(ThemeData theme, bool isEnabled) {
    if (widget.variant == AppButtonVariant.secondary || 
        widget.variant == AppButtonVariant.tertiary || 
        widget.variant == AppButtonVariant.ghost) {
      return Border.all(
        color: isEnabled 
            ? theme.colorScheme.primary 
            : theme.colorScheme.onSurface.withValues(alpha: 0.12),
        width: 1.5,
      );
    }
    return null;
  }

  /// Fantasy gradients from extensions
  Gradient? _getGradient(ThemeData theme, bool isEnabled, Map<String, dynamic>? extensions) {
    if (!isEnabled) return null;

    switch (widget.variant) {
      case AppButtonVariant.magic:
        if (extensions != null && extensions.containsKey('magicGradient')) {
          final colors = (extensions['magicGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString()) ?? theme.colorScheme.primary)
              .toList();
          return LinearGradient(colors: colors);
        }
        return LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer]);
      case AppButtonVariant.portal:
        if (extensions != null && extensions.containsKey('portalGradient')) {
          final colors = (extensions['portalGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString()) ?? theme.colorScheme.tertiary)
              .toList();
          return LinearGradient(colors: colors);
        }
        return LinearGradient(colors: [theme.colorScheme.tertiary, theme.colorScheme.tertiaryContainer]);
      default:
        return null;
    }
  }

  /// Fantasy shadows and glow effects
  List<BoxShadow> _getShadows(ThemeData theme, bool isEnabled, Map<String, dynamic>? extensions) {
    if (!isEnabled) return [];

    switch (widget.variant) {
      case AppButtonVariant.magic:
        return [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: _isPressed ? 8 : 12,
            spreadRadius: _isPressed ? 1 : 2,
            offset: const Offset(0, 2),
          ),
        ];
      case AppButtonVariant.portal:
        return [
          BoxShadow(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
            blurRadius: _isPressed ? 8 : 12,
            spreadRadius: _isPressed ? 1 : 2,
            offset: const Offset(0, 2),
          ),
        ];
      case AppButtonVariant.artifact:
        return [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.4),
            blurRadius: _isPressed ? 6 : 10,
            spreadRadius: _isPressed ? 0 : 1,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return [];
    }
  }

  /// Splash color for interactions
  Color _getSplashColor(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppButtonVariant.magic:
        if (extensions != null && extensions.containsKey('hoverAuraColor')) {
          return _parseColor(extensions['hoverAuraColor'].toString()) ?? theme.colorScheme.primary;
        }
        return theme.colorScheme.primary;
      case AppButtonVariant.portal:
        return theme.colorScheme.tertiary;
      case AppButtonVariant.artifact:
        return theme.colorScheme.secondary;
      case AppButtonVariant.success:
        return theme.colorScheme.tertiary;
      case AppButtonVariant.danger:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Border radius from schema components.buttons configuration  
  double _getBorderRadius(ThemeData theme) {
    // TODO: Get from schema - for now use reasonable defaults
    switch (widget.size) {
      case AppButtonSize.small:
        return 8.0;
      case AppButtonSize.medium:
        return 12.0;
      case AppButtonSize.large:
        return 16.0;
      case AppButtonSize.extraLarge:
        return 20.0;
    }
  }

  /// Padding from schema components.buttons configuration
  EdgeInsetsGeometry _getPadding(ThemeData theme) {
    // TODO: Get from schema - for now use reasonable defaults
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
      case AppButtonSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0);
    }
  }

  /// Build button content
  Widget _buildContent(ThemeData theme, bool isEnabled) {
    final contentColor = _getContentColor(theme, isEnabled);
    
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: contentColor,
            size: _getIconSize(),
          ),
          if (widget.text != null || widget.child != null)
            SizedBox(width: _getIconSpacing()),
        ],
        if (widget.child != null)
          widget.child!
        else if (widget.text != null)
          Text(
            widget.text!,
            style: _getTextStyle(theme, isEnabled),
          ),
        if (widget.suffixIcon != null) ...[
          if (widget.text != null || widget.child != null)
            SizedBox(width: _getIconSpacing()),
          Icon(
            widget.suffixIcon,
            color: contentColor,
            size: _getIconSize(),
          ),
        ],
      ],
    );
  }

  /// Content color based on variant
  Color _getContentColor(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return theme.colorScheme.onSurface.withValues(alpha: 0.38);
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.magic:
      case AppButtonVariant.portal:
      case AppButtonVariant.artifact:
      case AppButtonVariant.success:
      case AppButtonVariant.danger:
        return theme.colorScheme.onPrimary;
      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
      case AppButtonVariant.ghost:
        return theme.colorScheme.primary;
    }
  }

  /// Text style based on size and schema typography
  TextStyle _getTextStyle(ThemeData theme, bool isEnabled) {
    final baseStyle = switch (widget.size) {
      AppButtonSize.small => theme.textTheme.bodyMedium,
      AppButtonSize.medium => theme.textTheme.bodyLarge,
      AppButtonSize.large => theme.textTheme.bodyLarge,
      AppButtonSize.extraLarge => theme.textTheme.headlineSmall,
    };

    return baseStyle?.copyWith(
      color: _getContentColor(theme, isEnabled),
      fontWeight: FontWeight.w600,
    ) ?? TextStyle(
      color: _getContentColor(theme, isEnabled),
      fontWeight: FontWeight.w600,
    );
  }

  /// Icon size based on button size
  double _getIconSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 18.0;
      case AppButtonSize.large:
        return 20.0;
      case AppButtonSize.extraLarge:
        return 24.0;
    }
  }

  /// Icon spacing based on button size
  double _getIconSpacing() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 6.0;
      case AppButtonSize.medium:
        return 8.0;
      case AppButtonSize.large:
        return 10.0;
      case AppButtonSize.extraLarge:
        return 12.0;
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

  /// 🦾 ACCESSIBILITY FIX: Generate semantic label
  String _getSemanticLabel() {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.text != null) return widget.text!;
    
    // Fallback based on variant
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return 'Primary button';
      case AppButtonVariant.secondary:
        return 'Secondary button';
      case AppButtonVariant.tertiary:
        return 'Text button';
      case AppButtonVariant.magic:
        return 'Magic button';
      case AppButtonVariant.portal:
        return 'Portal button';
      case AppButtonVariant.artifact:
        return 'Artifact button';
      case AppButtonVariant.success:
        return 'Success button';
      case AppButtonVariant.danger:
        return 'Danger button';
      case AppButtonVariant.ghost:
        return 'Ghost button';
    }
  }

  /// 🦾 ACCESSIBILITY FIX: Generate semantic hint
  String? _getSemanticHint() {
    if (widget.hint != null) return widget.hint!;
    
    List<String> hints = [];
    
    // Loading state
    if (widget.isLoading) {
      hints.add('Loading');
    }
    
    // Disabled state
    if (widget.onPressed == null && !widget.isLoading) {
      hints.add('Disabled');
    }
    
    // Variant context
    switch (widget.variant) {
      case AppButtonVariant.magic:
        hints.add('Magical action');
        break;
      case AppButtonVariant.portal:
        hints.add('Portal navigation');
        break;
      case AppButtonVariant.artifact:
        hints.add('Artifact interaction');
        break;
      case AppButtonVariant.danger:
        hints.add('Destructive action');
        break;
      default:
        break;
    }
    
    // Size context
    if (widget.size == AppButtonSize.extraLarge) {
      hints.add('Large button');
    }
    
    return hints.isNotEmpty ? hints.join(', ') : null;
  }
}