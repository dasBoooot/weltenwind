import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/providers/theme_context_provider.dart';

/// ☑️ Checkbox Variants
enum AppCheckboxVariant {
  standard,
  magic,
  minimal,
  outlined,
}

/// ☑️ Checkmark Styles
enum CheckmarkStyle {
  check,
  tick,
  cross,
}

/// ☑️ App Checkbox based on Schema Configuration
/// 
/// Schema-based checkbox with animations, glow effects, and fantasy styling
class AppCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final AppCheckboxVariant variant;
  final CheckmarkStyle checkmarkStyle;
  final Color? activeColor;
  final Color? checkColor;
  final Color? borderColor;
  final double? size;
  final bool showRipple;
  final bool glowEffect;
  final Duration animationDuration;
  final String? tooltip;
  final bool tristate;
  final MaterialTapTargetSize? materialTapTargetSize;
  
  // 🦾 Accessibility Parameters
  final String? semanticLabel;
  final String? semanticHint;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = AppCheckboxVariant.standard,
    this.checkmarkStyle = CheckmarkStyle.check,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.size,
    this.showRipple = true,
    this.glowEffect = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tooltip,
    this.tristate = false,
    this.materialTapTargetSize,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  });

  /// Standard checkbox
  const AppCheckbox.standard({
    super.key,
    required this.value,
    required this.onChanged,
    this.checkmarkStyle = CheckmarkStyle.check,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.size,
    this.showRipple = true,
    this.glowEffect = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tooltip,
    this.tristate = false,
    this.materialTapTargetSize,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppCheckboxVariant.standard;

  /// Magic checkbox with glow effects
  const AppCheckbox.magic({
    super.key,
    required this.value,
    required this.onChanged,
    this.checkmarkStyle = CheckmarkStyle.check,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.size,
    this.showRipple = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tooltip,
    this.tristate = false,
    this.materialTapTargetSize,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppCheckboxVariant.magic,
       glowEffect = true;

  /// Minimal checkbox without decorations
  const AppCheckbox.minimal({
    super.key,
    required this.value,
    required this.onChanged,
    this.checkmarkStyle = CheckmarkStyle.tick,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.size,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tooltip,
    this.tristate = false,
    this.materialTapTargetSize,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppCheckboxVariant.minimal,
       showRipple = false,
       glowEffect = false;

  /// Outlined checkbox
  const AppCheckbox.outlined({
    super.key,
    required this.value,
    required this.onChanged,
    this.checkmarkStyle = CheckmarkStyle.check,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.size,
    this.showRipple = true,
    this.glowEffect = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tooltip,
    this.tristate = false,
    this.materialTapTargetSize,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppCheckboxVariant.outlined;

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  
  late Animation<double> _checkAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Check animation
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    if (widget.glowEffect) {
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 1500),
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

    // Set initial state
    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
        if (widget.glowEffect) {
          _glowController.repeat(reverse: true);
        }
      } else {
        _animationController.reverse();
        if (widget.glowEffect) {
          _glowController.stop();
          _glowController.reset();
        }
      }
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

  void _onEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
  }

  void _onExit(PointerExitEvent event) {
    setState(() => _isHovered = false);
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      widget.onChanged!(!widget.value);
      
      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'AppCheckbox',
      contextOverrides: {
        'variant': widget.variant.name,
        'checked': widget.value.toString(),
        'enabled': (widget.onChanged != null).toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildCheckboxWidget(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildCheckboxWidget(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    Widget checkbox = MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _buildCheckbox(theme, extensions);
          },
        ),
      ),
    );

    // Add glow effect
    if (widget.glowEffect && widget.value) {
      checkbox = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_getBorderRadius() + 4),
              boxShadow: [
                BoxShadow(
                  color: _getActiveColor(theme, extensions).withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 8 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: checkbox,
          );
        },
      );
    }

    // Add tooltip
    if (widget.tooltip != null) {
      checkbox = Tooltip(
        message: widget.tooltip!,
        child: checkbox,
      );
    }

    return Semantics(
      label: _getSemanticLabel(),
      hint: _getSemanticHint(),
      checked: widget.value,
      enabled: widget.onChanged != null,
      onTap: widget.onChanged != null ? _handleTap : null,
      child: checkbox,
    );
  }

  Widget _buildCheckbox(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppCheckboxVariant.standard:
        return _buildStandardCheckbox(theme, extensions);
      case AppCheckboxVariant.magic:
        return _buildMagicCheckbox(theme, extensions);
      case AppCheckboxVariant.minimal:
        return _buildMinimalCheckbox(theme, extensions);
      case AppCheckboxVariant.outlined:
        return _buildOutlinedCheckbox(theme, extensions);
    }
  }

  Widget _buildStandardCheckbox(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      width: _getSize(),
      height: _getSize(),
      decoration: BoxDecoration(
        color: widget.value 
            ? _getActiveColor(theme, extensions)
            : Colors.transparent,
        border: Border.all(
          color: widget.value 
              ? _getActiveColor(theme, extensions)
              : _getBorderColor(theme),
          width: _getBorderWidth(),
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: widget.value
          ? _buildCheckmark(theme, extensions)
          : null,
    );
  }

  Widget _buildMagicCheckbox(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      width: _getSize(),
      height: _getSize(),
      decoration: BoxDecoration(
        gradient: widget.value 
            ? _getMagicGradient(theme, extensions)
            : null,
        color: !widget.value 
            ? Colors.transparent 
            : null,
        border: Border.all(
          color: widget.value 
              ? Colors.transparent
              : _getBorderColor(theme),
          width: _getBorderWidth(),
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: widget.value ? [
          BoxShadow(
            color: _getActiveColor(theme, extensions).withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: widget.value
          ? _buildCheckmark(theme, extensions)
          : null,
    );
  }

  Widget _buildMinimalCheckbox(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      width: _getSize(),
      height: _getSize(),
      decoration: BoxDecoration(
        color: widget.value 
            ? _getActiveColor(theme, extensions).withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: widget.value 
              ? _getActiveColor(theme, extensions)
              : _getBorderColor(theme).withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: widget.value
          ? _buildCheckmark(theme, extensions)
          : null,
    );
  }

  Widget _buildOutlinedCheckbox(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      width: _getSize(),
      height: _getSize(),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: widget.value 
              ? _getActiveColor(theme, extensions)
              : _getBorderColor(theme),
          width: _getBorderWidth() + 0.5,
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: widget.value
          ? Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getActiveColor(theme, extensions),
                borderRadius: BorderRadius.circular(_getBorderRadius() - 2),
              ),
              child: _buildCheckmark(theme, extensions),
            )
          : null,
    );
  }

  Widget _buildCheckmark(ThemeData theme, Map<String, dynamic>? extensions) {
    return AnimatedBuilder(
      animation: _checkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkAnimation.value,
          child: Icon(
            _getCheckmarkIcon(),
            size: _getSize() * 0.6,
            color: _getCheckColor(theme, extensions),
          ),
        );
      },
    );
  }

  /// Get checkmark icon based on style
  IconData _getCheckmarkIcon() {
    switch (widget.checkmarkStyle) {
      case CheckmarkStyle.check:
        return Icons.check;
      case CheckmarkStyle.tick:
        return Icons.done;
      case CheckmarkStyle.cross:
        return Icons.close;
    }
  }

  /// Get magic gradient for magic variant
  LinearGradient _getMagicGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    final activeColor = _getActiveColor(theme, extensions);
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        activeColor,
        activeColor.withValues(alpha: 0.7),
        activeColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Get active color from schema and theme
  Color _getActiveColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.activeColor != null) return widget.activeColor!;
    
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

  /// Get border color
  Color _getBorderColor(ThemeData theme) {
    if (widget.borderColor != null) return widget.borderColor!;
    
    return _isHovered 
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;
  }

  /// Get check color
  Color _getCheckColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.checkColor != null) return widget.checkColor!;
    
    return widget.variant == AppCheckboxVariant.minimal
        ? _getActiveColor(theme, extensions)
        : theme.colorScheme.onPrimary;
  }

  /// Get size from schema
  double _getSize() {
    if (widget.size != null) return widget.size!;
    
    // Schema default: 20
    return 20.0;
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    // Schema default: 4
    return 4.0;
  }

  /// Get border width from schema
  double _getBorderWidth() {
    // Schema default: 2
    return 2.0;
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

  /// 🦾 ACCESSIBILITY FIX: Generate semantic label
  String _getSemanticLabel() {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    
    if (widget.tristate) {
      if (widget.value == true) {
        return 'Checked checkbox';
      } else if (widget.value == false) {
        return 'Unchecked checkbox';
      } else {
        return 'Indeterminate checkbox';
      }
    } else {
      return widget.value ? 'Checked checkbox' : 'Unchecked checkbox';
    }
  }

  /// 🦾 ACCESSIBILITY FIX: Generate semantic hint
  String? _getSemanticHint() {
    if (widget.semanticHint != null) return widget.semanticHint!;
    
    List<String> hints = [];
    
    if (widget.onChanged == null) {
      hints.add('Disabled');
    }
    
    // Variant context
    switch (widget.variant) {
      case AppCheckboxVariant.magic:
        hints.add('Fantasy checkbox with glow effects');
        break;
      case AppCheckboxVariant.minimal:
        hints.add('Minimal checkbox');
        break;
      case AppCheckboxVariant.outlined:
        hints.add('Outlined checkbox');
        break;
      default:
        break;
    }
    
    if (widget.tristate) {
      hints.add('Three-state checkbox');
    }
    
    return hints.isNotEmpty ? hints.join(', ') : null;
  }
}

/// ☑️ Checkbox List Tile
class AppCheckboxListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool isThreeLine;
  final bool? dense;
  final EdgeInsetsGeometry? contentPadding;
  final AppCheckboxVariant variant;
  final CheckmarkStyle checkmarkStyle;
  final Color? activeColor;
  final Color? checkColor;

  const AppCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.secondary,
    this.isThreeLine = false,
    this.dense,
    this.contentPadding,
    this.variant = AppCheckboxVariant.standard,
    this.checkmarkStyle = CheckmarkStyle.check,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      isThreeLine: isThreeLine,
      dense: dense,
      contentPadding: contentPadding,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

/// ☑️ Checkbox Helpers
class CheckboxHelpers {
  /// Terms and conditions checkbox
  static Widget termsAndConditions({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    VoidCallback? onTermsTap,
  }) {
    return Builder(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCheckbox.standard(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTermsTap,
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  decoration: onTermsTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Remember me checkbox
  static Widget rememberMe({
    required bool value,
    required ValueChanged<bool?> onChanged,
    String text = 'Remember me',
  }) {
    return Builder(
      builder: (context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppCheckbox.minimal(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Settings toggle checkbox
  static Widget settingsToggle({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return Builder(
      builder: (context) => ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: AppCheckbox.magic(
          value: value,
          onChanged: onChanged,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }
}