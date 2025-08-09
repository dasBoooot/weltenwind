/// 🎯 App Button Component
/// 
/// Professional button component with theme integration
library;

import 'package:flutter/material.dart';
import '../base/base_component.dart';

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

    // Determine button style based on type
    final buttonStyle = _getButtonStyle(context, colorScheme, isDark);
    final textStyle = _getTextStyle(textTheme);
    // padding computed within style methods as needed

    Widget buttonChild = _buildButtonContent(context, textStyle);

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

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          elevation: elevation,
          padding: _getPadding(context),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onSecondary,
          backgroundColor: colorScheme.secondary,
          elevation: elevation,
          padding: _getPadding(context),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onError,
          backgroundColor: colorScheme.error,
          elevation: elevation,
          padding: _getPadding(context),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.success:
        final successColor = isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: successColor,
          elevation: elevation,
          padding: _getPadding(context),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: _getPadding(context),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: _getPadding(context),
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
  EdgeInsets _getPadding(BuildContext context) {
    final baseMultiplier = getScreenSize(context) == ScreenSize.mobile ? 0.8 : 1.0;

    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: 12 * baseMultiplier,
          vertical: 8 * baseMultiplier,
        );
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: 16 * baseMultiplier,
          vertical: 12 * baseMultiplier,
        );
      case AppButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: 24 * baseMultiplier,
          vertical: 16 * baseMultiplier,
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