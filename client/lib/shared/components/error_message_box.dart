import 'package:flutter/material.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED

/// 🚨 Error Message Types
enum ErrorMessageType {
  error,
  warning,
  info,
  success,
}

/// 🚨 Error Message Box based on Schema Configuration
/// 
/// Schema-based error display with glow effects, icons, and animations
class ErrorMessageBox extends StatefulWidget {
  final String message;
  final ErrorMessageType type;
  final IconData? icon;
  final bool showIcon;
  final bool showClose;
  final bool glowEffect;
  final bool animateIn;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? iconSize;

  const ErrorMessageBox({
    super.key,
    required this.message,
    this.type = ErrorMessageType.error,
    this.icon,
    this.showIcon = true,
    this.showClose = true,
    this.glowEffect = true,
    this.animateIn = true,
    this.onClose,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 500),
    this.padding,
    this.borderRadius,
    this.iconSize,
  });

  /// Error message box
  const ErrorMessageBox.error({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.showIcon = true,
    this.showClose = true,
    this.glowEffect = true,
    this.animateIn = true,
    this.onClose,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 500),
    this.padding,
    this.borderRadius,
    this.iconSize,
  }) : type = ErrorMessageType.error;

  /// Warning message box
  const ErrorMessageBox.warning({
    super.key,
    required this.message,
    this.icon = Icons.warning_outlined,
    this.showIcon = true,
    this.showClose = true,
    this.glowEffect = true,
    this.animateIn = true,
    this.onClose,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 500),
    this.padding,
    this.borderRadius,
    this.iconSize,
  }) : type = ErrorMessageType.warning;

  /// Info message box
  const ErrorMessageBox.info({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.showIcon = true,
    this.showClose = true,
    this.glowEffect = false,
    this.animateIn = true,
    this.onClose,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 500),
    this.padding,
    this.borderRadius,
    this.iconSize,
  }) : type = ErrorMessageType.info;

  /// Success message box
  const ErrorMessageBox.success({
    super.key,
    required this.message,
    this.icon = Icons.check_circle_outline,
    this.showIcon = true,
    this.showClose = true,
    this.glowEffect = false,
    this.animateIn = true,
    this.onClose,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 500),
    this.padding,
    this.borderRadius,
    this.iconSize,
  }) : type = ErrorMessageType.success;

  @override
  State<ErrorMessageBox> createState() => _ErrorMessageBoxState();
}

class _ErrorMessageBoxState extends State<ErrorMessageBox> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slide in animation
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
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
      
      _glowController.repeat(reverse: true);
    }

    // Start animation
    if (widget.animateIn) {
      _slideController.forward();
    } else {
      _slideController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    if (widget.glowEffect) {
      _glowController.dispose();
    }
    super.dispose();
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return _buildErrorBox(context, Theme.of(context), null);
  }

  Widget _buildErrorBox(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    
    Widget errorBox = Container(
      padding: _getPadding(),
      decoration: _getDecoration(theme, extensions),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            if (widget.showIcon && _getIcon() != null) ...[
              Icon(
                _getIcon(),
                color: _getIconColor(theme),
                size: _getIconSize(),
              ),
              const SizedBox(width: 12),
            ],
            
            // Message
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap,
                child: Text(
                  widget.message,
                  style: _getTextStyle(theme),
                ),
              ),
            ),
            
            // Close button
            if (widget.showClose) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _handleClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: _getIconColor(theme).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Wrap with glow effect
    if (widget.glowEffect) {
      errorBox = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              boxShadow: [
                BoxShadow(
                  color: _getGlowColor(theme, extensions).withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 8 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: _getGlowColor(theme, extensions).withValues(alpha: 0.1 * _glowAnimation.value),
                  blurRadius: 16 * _glowAnimation.value,
                  spreadRadius: 4 * _glowAnimation.value,
                ),
              ],
            ),
            child: errorBox,
          );
        },
      );
    }

    // Wrap with slide animation
    if (widget.animateIn) {
      return AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: errorBox,
            ),
          );
        },
      );
    }

    return errorBox;
  }

  /// Get container decoration
  BoxDecoration _getDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme),
      border: Border.all(
        color: _getBorderColor(theme),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
    );
  }

  /// Get icon for message type
  IconData? _getIcon() {
    if (widget.icon != null) return widget.icon;
    
    switch (widget.type) {
      case ErrorMessageType.error:
        return Icons.error_outline;
      case ErrorMessageType.warning:
        return Icons.warning_outlined; 
      case ErrorMessageType.info:
        return Icons.info_outline;
      case ErrorMessageType.success:
        return Icons.check_circle_outline;
    }
  }

  /// Get background color based on type
  Color _getBackgroundColor(ThemeData theme) {
    switch (widget.type) {
      case ErrorMessageType.error:
        return theme.colorScheme.errorContainer;
      case ErrorMessageType.warning:
        return theme.colorScheme.tertiaryContainer;
      case ErrorMessageType.info:
        return theme.colorScheme.primaryContainer;
      case ErrorMessageType.success:
        return theme.colorScheme.primaryContainer;
    }
  }

  /// Get border color based on type
  Color _getBorderColor(ThemeData theme) {
    switch (widget.type) {
      case ErrorMessageType.error:
        return theme.colorScheme.error;
      case ErrorMessageType.warning:
        return theme.colorScheme.tertiary;
      case ErrorMessageType.info:
        return theme.colorScheme.primary;
      case ErrorMessageType.success:
        return theme.colorScheme.primary;
    }
  }

  /// Get icon color based on type
  Color _getIconColor(ThemeData theme) {
    switch (widget.type) {
      case ErrorMessageType.error:
        return theme.colorScheme.onErrorContainer;
      case ErrorMessageType.warning:
        return theme.colorScheme.onTertiaryContainer;
      case ErrorMessageType.info:
        return theme.colorScheme.onPrimaryContainer;
      case ErrorMessageType.success:
        return theme.colorScheme.onPrimaryContainer;
    }
  }

  /// Get glow color for animation
  Color _getGlowColor(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.type) {
      case ErrorMessageType.error:
        return theme.colorScheme.error;
      case ErrorMessageType.warning:
        return theme.colorScheme.tertiary;
      case ErrorMessageType.info:
        return theme.colorScheme.primary;
      case ErrorMessageType.success:
        return theme.colorScheme.primary;
    }
  }

  /// Get text style
  TextStyle _getTextStyle(ThemeData theme) {
    Color textColor;
    switch (widget.type) {
      case ErrorMessageType.error:
        textColor = theme.colorScheme.onErrorContainer;
        break;
      case ErrorMessageType.warning:
        textColor = theme.colorScheme.onTertiaryContainer;
        break;
      case ErrorMessageType.info:
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
      case ErrorMessageType.success:
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
    }

    return theme.textTheme.bodyMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w500,
    ) ?? TextStyle(
      color: textColor,
      fontWeight: FontWeight.w500,
    );
  }

  /// Get padding from schema
  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;
    
    // Schema default: 16
    return const EdgeInsets.all(16.0);
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    if (widget.borderRadius != null) return widget.borderRadius!;
    
    // Schema default: 12
    return 12.0;
  }

  /// Get icon size from schema
  double _getIconSize() {
    if (widget.iconSize != null) return widget.iconSize!;
    
    // Schema default: 20
    return 20.0;
  }
}

/// 🚨 Error Message Box Helpers
class ErrorHelpers {
  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorMessageBox.error(
          message: message,
          showClose: false,
          animateIn: false,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorMessageBox.warning(
          message: message,
          showClose: false,
          animateIn: false,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorMessageBox.success(
          message: message,
          showClose: false,
          animateIn: false,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorMessageBox.info(
          message: message,
          showClose: false,
          animateIn: false,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}