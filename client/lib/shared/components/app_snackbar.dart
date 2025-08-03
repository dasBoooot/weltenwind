import 'package:flutter/material.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED

/// 📢 Snackbar Types
enum AppSnackbarType {
  info,
  success,
  warning,
  error,
  custom,
}

/// 📢 Snackbar Position
enum AppSnackbarPosition {
  top,
  bottom,
}

/// 📢 App Snackbar based on Schema Configuration
/// 
/// Schema-based snackbar with animations, actions, and fantasy styling
class AppSnackbar extends StatefulWidget {
  final String message;
  final AppSnackbarType type;
  final AppSnackbarPosition position;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final bool showIcon;
  final bool showCloseButton;
  final bool slideAnimation;
  final bool backdrop;
  final double? maxWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const AppSnackbar({
    super.key,
    required this.message,
    this.type = AppSnackbarType.info,
    this.position = AppSnackbarPosition.bottom,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.icon,
    this.showIcon = true,
    this.showCloseButton = true,
    this.slideAnimation = true,
    this.backdrop = false,
    this.maxWidth,
    this.backgroundColor,
    this.textColor,
  });

  /// Info snackbar
  const AppSnackbar.info({
    super.key,
    required this.message,
    this.position = AppSnackbarPosition.bottom,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.icon = Icons.info_outline,
    this.showIcon = true,
    this.showCloseButton = true,
    this.slideAnimation = true,
    this.backdrop = false,
    this.maxWidth,
    this.backgroundColor,
    this.textColor,
  }) : type = AppSnackbarType.info;

  /// Success snackbar
  const AppSnackbar.success({
    super.key,
    required this.message,
    this.position = AppSnackbarPosition.bottom,
    this.duration = const Duration(seconds: 3),
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.icon = Icons.check_circle_outline,
    this.showIcon = true,
    this.showCloseButton = false,
    this.slideAnimation = true,
    this.backdrop = false,
    this.maxWidth,
    this.backgroundColor,
    this.textColor,
  }) : type = AppSnackbarType.success;

  /// Warning snackbar
  const AppSnackbar.warning({
    super.key,
    required this.message,
    this.position = AppSnackbarPosition.bottom,
    this.duration = const Duration(seconds: 5),
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.icon = Icons.warning_outlined,
    this.showIcon = true,
    this.showCloseButton = true,
    this.slideAnimation = true,
    this.backdrop = false,
    this.maxWidth,
    this.backgroundColor,
    this.textColor,
  }) : type = AppSnackbarType.warning;

  /// Error snackbar
  const AppSnackbar.error({
    super.key,
    required this.message,
    this.position = AppSnackbarPosition.bottom,
    this.duration = const Duration(seconds: 6),
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.icon = Icons.error_outline,
    this.showIcon = true,
    this.showCloseButton = true,
    this.slideAnimation = true,
    this.backdrop = false,
    this.maxWidth,
    this.backgroundColor,
    this.textColor,
  }) : type = AppSnackbarType.error;

  @override
  State<AppSnackbar> createState() => _AppSnackbarState();
}

class _AppSnackbarState extends State<AppSnackbar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slide animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    final slideDirection = widget.position == AppSnackbarPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);
    
    _slideAnimation = Tween<Offset>(
      begin: slideDirection,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();
    
    // Auto dismiss
    if (widget.duration != Duration.zero) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return _buildSnackbar(context, Theme.of(context), null);
  }

  Widget _buildSnackbar(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    Widget snackbar = Container(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth ?? _getMaxWidth(),
      ),
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(_getPadding()),
      decoration: _getSnackbarDecoration(theme, extensions),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (widget.showIcon && _getIcon() != null) ...[
              Icon(
                _getIcon(),
                color: _getIconColor(theme, extensions),
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            
            // Message
            Expanded(
              child: Text(
                widget.message,
                style: _getTextStyle(theme, extensions),
              ),
            ),
            
            // Action button
            if (widget.actionLabel != null && widget.onAction != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: widget.onAction,
                style: TextButton.styleFrom(
                  foregroundColor: _getActionColor(theme, extensions),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(widget.actionLabel!),
              ),
            ],
            
            // Close button
            if (widget.showCloseButton) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _dismiss,
                icon: const Icon(Icons.close),
                iconSize: 18,
                color: _getTextColor(theme, extensions).withValues(alpha: 0.7),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );

    // Add backdrop
    if (widget.backdrop) {
      snackbar = Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(child: snackbar),
      );
    }

    // Add animation
    if (widget.slideAnimation) {
      snackbar = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: snackbar,
            ),
          );
        },
      );
    }

    return snackbar;
  }

  /// Get snackbar decoration
  BoxDecoration _getSnackbarDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme, extensions),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get icon for snackbar type
  IconData? _getIcon() {
    if (widget.icon != null) return widget.icon;
    
    switch (widget.type) {
      case AppSnackbarType.info:
        return Icons.info_outline;
      case AppSnackbarType.success:
        return Icons.check_circle_outline;
      case AppSnackbarType.warning:
        return Icons.warning_outlined;
      case AppSnackbarType.error:
        return Icons.error_outline;
      case AppSnackbarType.custom:
        return null;
    }
  }

  /// Get background color based on type
  Color _getBackgroundColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    switch (widget.type) {
      case AppSnackbarType.info:
        return theme.colorScheme.primaryContainer;
      case AppSnackbarType.success:
        return const Color(0xFF4CAF50);
      case AppSnackbarType.warning:
        return const Color(0xFFF59E0B);
      case AppSnackbarType.error:
        return theme.colorScheme.errorContainer;
      case AppSnackbarType.custom:
        return theme.colorScheme.surface;
    }
  }

  /// Get text color based on type
  Color _getTextColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.textColor != null) return widget.textColor!;
    
    switch (widget.type) {
      case AppSnackbarType.info:
        return theme.colorScheme.onPrimaryContainer;
      case AppSnackbarType.success:
        return Colors.white;
      case AppSnackbarType.warning:
        return Colors.white;
      case AppSnackbarType.error:
        return theme.colorScheme.onErrorContainer;
      case AppSnackbarType.custom:
        return theme.colorScheme.onSurface;
    }
  }

  /// Get icon color based on type
  Color _getIconColor(ThemeData theme, Map<String, dynamic>? extensions) {
    return _getTextColor(theme, extensions);
  }

  /// Get action color based on type
  Color _getActionColor(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.type) {
      case AppSnackbarType.info:
        return theme.colorScheme.primary;
      case AppSnackbarType.success:
        return Colors.white;
      case AppSnackbarType.warning:
        return Colors.white;
      case AppSnackbarType.error:
        return theme.colorScheme.error;
      case AppSnackbarType.custom:
        return theme.colorScheme.primary;
    }
  }

  /// Get text style
  TextStyle _getTextStyle(ThemeData theme, Map<String, dynamic>? extensions) {
    return theme.textTheme.bodyMedium?.copyWith(
      color: _getTextColor(theme, extensions),
      fontWeight: FontWeight.w500,
    ) ?? TextStyle(
      color: _getTextColor(theme, extensions),
      fontWeight: FontWeight.w500,
    );
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    return 8.0; // Schema default
  }

  /// Get padding from schema
  double _getPadding() {
    return 16.0;
  }

  /// Get max width from schema
  double _getMaxWidth() {
    return 400.0; // Schema default
  }
}

/// 📢 Snackbar Manager
class SnackbarManager {
  static OverlayEntry? _currentEntry;
  static bool _isShowing = false;

  /// Show snackbar
  static void show(
    BuildContext context,
    AppSnackbar snackbar,
  ) {
    // Remove existing snackbar
    hide();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: snackbar.position == AppSnackbarPosition.top ? 50 : null,
        bottom: snackbar.position == AppSnackbarPosition.bottom ? 50 : null,
        child: Material(
          color: Colors.transparent,
          child: AppSnackbar(
            message: snackbar.message,
            type: snackbar.type,
            position: snackbar.position,
            duration: snackbar.duration,
            actionLabel: snackbar.actionLabel,
            onAction: snackbar.onAction,
            onDismiss: () {
              hide();
              snackbar.onDismiss?.call();
            },
            icon: snackbar.icon,
            showIcon: snackbar.showIcon,
            showCloseButton: snackbar.showCloseButton,
            slideAnimation: snackbar.slideAnimation,
            backdrop: snackbar.backdrop,
            maxWidth: snackbar.maxWidth,
            backgroundColor: snackbar.backgroundColor,
            textColor: snackbar.textColor,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
    _isShowing = true;
  }

  /// Hide current snackbar
  static void hide() {
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
      _isShowing = false;
    }
  }

  /// Check if snackbar is showing
  static bool get isShowing => _isShowing;
}

/// 📢 Snackbar Helpers
class SnackbarHelpers {
  /// Show info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    SnackbarManager.show(
      context,
      AppSnackbar.info(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    SnackbarManager.show(
      context,
      AppSnackbar.success(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    SnackbarManager.show(
      context,
      AppSnackbar.warning(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  /// Show error snackbar
  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    SnackbarManager.show(
      context,
      AppSnackbar.error(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  /// Show login success
  static void showLoginSuccess(BuildContext context, String username) {
    showSuccess(context, 'Welcome back, $username!');
  }

  /// Show logout success
  static void showLogoutSuccess(BuildContext context) {
    showInfo(context, 'You have been logged out');
  }

  /// Show world join success
  static void showWorldJoinSuccess(BuildContext context, String worldName) {
    showSuccess(context, 'Joined world "$worldName"');
  }

  /// Show connection error
  static void showConnectionError(BuildContext context) {
    showError(
      context,
      'Connection failed. Please check your internet.',
      actionLabel: 'Retry',
      onAction: () {
        // Retry logic would go here
      },
    );
  }

  /// Show validation error
  static void showValidationError(BuildContext context, String field) {
    showWarning(context, 'Please check the $field field');
  }

  /// Show save success
  static void showSaveSuccess(BuildContext context) {
    showSuccess(context, 'Settings saved successfully');
  }

  /// Show copy success
  static void showCopySuccess(BuildContext context, String item) {
    showInfo(context, '$item copied to clipboard');
  }

  /// Show invite sent
  static void showInviteSent(BuildContext context, String recipient) {
    showSuccess(context, 'Invite sent to $recipient');
  }

  /// Show update available
  static void showUpdateAvailable(BuildContext context) {
    showInfo(
      context,
      'A new update is available',
      actionLabel: 'Update',
      onAction: () {
        // Update logic would go here
      },
    );
  }
}