/// 🎯 App Button Component
/// 
/// Professional button component with theme integration
library;

import 'package:flutter/material.dart';
import '../base/base_component.dart';
import '../../theme/extensions.dart';

enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
  danger,
  success,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends BaseComponent {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.icon,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final IconData? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final textTheme = getTextTheme(context);
    final isDark = isDarkMode(context);
    final effects = Theme.of(context).extension<AppEffectsTheme>();

    // Determine button style based on type
    final buttonStyle = _getButtonStyle(context, colorScheme, isDark);
    final textStyle = _getTextStyle(textTheme);
    // padding computed within style methods as needed

    Widget buttonChild = _buildButtonContent(context, textStyle);

    // For primary button: draw a stable gradient background inside the button
    if (type == AppButtonType.primary) {
      final borderRadius = getBorderRadius(context);
      final colorScheme = getColorScheme(context);
      final spacing = Theme.of(context).extension<AppSpacingTheme>();

      buttonChild = _GradientFilledButtonChild(
        borderRadius: borderRadius,
        padding: _getPadding(context, spacing),
        startColor: colorScheme.primary,
        endColor: colorScheme.tertiary,
        child: buttonChild,
      );
    }

    // Add loading indicator
    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getContentColor(colorScheme),
              ),
            ),
          ),
          const SizedBox(width: 8),
          buttonChild,
        ],
      );
    }

    Widget button;

    // Create appropriate button based on type
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.danger:
      case AppButtonType.success:
        button = ElevatedButton(
          onPressed: _getOnPressed(),
          style: buttonStyle,
          child: buttonChild,
        );
        break;

      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: _getOnPressed(),
          style: buttonStyle,
          child: buttonChild,
        );
        break;

      case AppButtonType.text:
        button = TextButton(
          onPressed: _getOnPressed(),
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }

    // Hover/Focus micro-interaction with safe scale
    final hoverScale = (effects?.scaleHover ?? 1.03).clamp(1.0, 1.08);
    final animDuration = effects?.durationFast ?? const Duration(milliseconds: 150);
    button = StatefulBuilder(
      builder: (ctx, setSt) {
        bool hovering = false;
        return MouseRegion(
          onEnter: (_) => setSt(() => hovering = true),
          onExit: (_) => setSt(() => hovering = false),
          child: AnimatedScale(
            scale: hovering ? hoverScale : 1.0,
            duration: animDuration,
            child: button,
          ),
        );
      },
    );

    // Apply full width if needed
    if (fullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  /// Build button content with optional icon
  Widget _buildButtonContent(BuildContext context, TextStyle? textStyle) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          DefaultTextStyle(
            style: textStyle ?? const TextStyle(),
            child: child,
          ),
        ],
      );
    }

    return DefaultTextStyle(
      style: textStyle ?? const TextStyle(),
      child: child,
    );
  }

  /// Get effective onPressed callback
  VoidCallback? _getOnPressed() {
    if (isDisabled || isLoading) return null;
    return onPressed;
  }

  /// Get button style based on type and theme
  ButtonStyle _getButtonStyle(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final elevation = getElevation(context);
    final borderRadius = getBorderRadius(context);
    final spacing = Theme.of(context).extension<AppSpacingTheme>();

    switch (type) {
      case AppButtonType.primary:
        // Transparent background; gradient is painted inside the child (stable on Web)
        return ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          // padding handled inside child to avoid double padding
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ).merge(
          ButtonStyle(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return colorScheme.onPrimary.withOpacity(0.08);
              }
              return null;
            }),
          ),
        );

      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onSecondary,
          backgroundColor: colorScheme.secondary,
          elevation: elevation,
          padding: _getPadding(context, spacing),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onError,
          backgroundColor: colorScheme.error,
          elevation: elevation,
          padding: _getPadding(context, spacing),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.success:
        final successColor = isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: successColor,
          elevation: elevation,
          padding: _getPadding(context, spacing),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: _getPadding(context, spacing),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: _getPadding(context, spacing),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
    }
  }

  /// Get text style based on size
  TextStyle? _getTextStyle(TextTheme textTheme) {
    switch (size) {
      case AppButtonSize.small:
        return textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600);
    }
  }

  /// Get button padding based on size
  EdgeInsets _getPadding(BuildContext context, AppSpacingTheme? spacing) {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: (spacing?.sm ?? 12),
          vertical: (spacing?.xs ?? 8),
        );
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: (spacing?.md ?? 16),
          vertical: (spacing?.sm ?? 12),
        );
      case AppButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: (spacing?.lg ?? 24),
          vertical: (spacing?.md ?? 16),
        );
    }
  }

  /// Get icon size based on button size
  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  /// Get content color for loading indicator
  Color _getContentColor(ColorScheme colorScheme) {
    switch (type) {
      case AppButtonType.primary:
        return colorScheme.onPrimary;
      case AppButtonType.secondary:
        return colorScheme.onSecondary;
      case AppButtonType.danger:
        return colorScheme.onError;
      case AppButtonType.success:
        return Colors.white;
      case AppButtonType.outlined:
      case AppButtonType.text:
        return colorScheme.primary;
    }
  }
}

class _GradientFilledButtonChild extends StatelessWidget {
  const _GradientFilledButtonChild({
    required this.borderRadius,
    required this.padding,
    required this.startColor,
    required this.endColor,
    required this.child,
  });

  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color startColor;
  final Color endColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RRectGradientPainter(
        borderRadius: borderRadius,
        startColor: startColor,
        endColor: endColor,
      ),
      child: Padding(
        padding: padding,
        child: Align(
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _RRectGradientPainter extends CustomPainter {
  _RRectGradientPainter({
    required this.borderRadius,
    required this.startColor,
    required this.endColor,
  });

  final BorderRadius borderRadius;
  final Color startColor;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _RRectGradientPainter oldDelegate) {
    return oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}