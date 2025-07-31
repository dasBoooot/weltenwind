import 'package:flutter/material.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';
import '../../theme/tokens/shadows.dart';

/// 🎯 Fantasy Button Variants
enum AppButtonVariant {
  /// Hauptaktion - gefüllt mit Primary-Color
  primary,
  /// Sekundäre Aktion - Outline-Style
  secondary,
  /// Tertiäre Aktion - nur Text
  tertiary,
  /// Magische Aktion - mit Glow-Effekt
  magic,
  /// Portal-Aktion - mit Aqua-Glow
  portal,
  /// Artefakt-Aktion - Golden mit Glow
  artifact,
  /// Erfolg - Grüner Glow
  success,
  /// Fehler/Gefahr - Roter Glow
  danger,
  /// Geist-Button - durchsichtig
  ghost,
}

/// 📏 Button-Größen
enum AppButtonSize {
  small,
  medium,
  large,
  extraLarge,
}

/// 🎯 Weltenwind Fantasy Button
/// 
/// Magische Buttons mit verschiedenen Effekten und Animationen
class AppButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const AppButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.onLongPress,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height,
    this.padding,
    this.enabled = true,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  // ========================================
  // 🏭 FACTORY CONSTRUCTORS - Häufige Varianten
  // ========================================

  factory AppButton.primary({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  factory AppButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }

  factory AppButton.magic({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.magic,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }

  factory AppButton.portal({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.portal,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }

  factory AppButton.artifact({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.artifact,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }

  factory AppButton.success({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.success,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }

  factory AppButton.danger({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.danger,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }

  factory AppButton.ghost({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.ghost,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = widget.enabled && widget.onPressed != null && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.isExpanded ? double.infinity : widget.width,
        height: widget.height ?? _getButtonHeight(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: _getDecoration(context, isDark, isEnabled),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? () => _handleTap() : null,
              onLongPress: widget.onLongPress,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              splashColor: _getSplashColor(isDark).withValues(alpha: 0.2),
              highlightColor: _getSplashColor(isDark).withValues(alpha: 0.1),
              child: Container(
                padding: widget.padding ?? _getPadding(),
                child: _buildContent(theme, isDark, isEnabled),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onPressed!();
    }
  }

  void _setPressed(bool pressed) {
    if (_isPressed != pressed) {
      setState(() {
        _isPressed = pressed;
      });
    }
  }

  Widget _buildContent(ThemeData theme, bool isDark, bool isEnabled) {
    if (widget.isLoading) {
      return _buildLoadingContent(isDark);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: _getContentColor(isDark, isEnabled),
          ),
          if (widget.text != null || widget.child != null)
            SizedBox(width: _getIconSpacing()),
        ],
        if (widget.text != null)
          Flexible(
            child: Text(
              widget.text!,
              style: _getTextStyle(theme, isDark, isEnabled),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else if (widget.child != null)
          Flexible(child: widget.child!),
        if (widget.suffixIcon != null) ...[
          if (widget.text != null || widget.child != null)
            SizedBox(width: _getIconSpacing()),
          Icon(
            widget.suffixIcon,
            size: _getIconSize(),
            color: _getContentColor(isDark, isEnabled),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingContent(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getContentColor(isDark, true),
            ),
          ),
        ),
        if (widget.text != null) ...[
          SizedBox(width: _getIconSpacing()),
          Text(
            widget.text!,
            style: _getTextStyle(Theme.of(context), isDark, true),
          ),
        ],
      ],
    );
  }

  // ========================================
  // 🎨 STYLING METHODS
  // ========================================

  BoxDecoration _getDecoration(BuildContext context, bool isDark, bool isEnabled) {
    return BoxDecoration(
      color: _getBackgroundColor(isDark, isEnabled),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: _getBorder(isDark, isEnabled),
      boxShadow: _getShadows(isEnabled),
      gradient: _getGradient(isDark, isEnabled),
    );
  }

  Color _getBackgroundColor(bool isDark, bool isEnabled) {
    if (!isEnabled) {
      return isDark ? AppColors.surfaceLight.withValues(alpha: 0.3) : AppColors.surfaceGray.withValues(alpha: 0.5);
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return isDark ? AppColors.primaryAccent : AppColors.primary;
      case AppButtonVariant.secondary:
        return Colors.transparent;
      case AppButtonVariant.tertiary:
        return Colors.transparent;
      case AppButtonVariant.magic:
        return AppColors.primary;
      case AppButtonVariant.portal:
        return AppColors.aqua;
      case AppButtonVariant.artifact:
        return AppColors.secondary;
      case AppButtonVariant.success:
        return AppColors.success;
      case AppButtonVariant.danger:
        return AppColors.error;
      case AppButtonVariant.ghost:
        return isDark ? AppColors.surfaceMedium.withValues(alpha: 0.5) : AppColors.surfaceGray.withValues(alpha: 0.3);
    }
  }

  Color _getContentColor(bool isDark, bool isEnabled) {
    if (!isEnabled) {
      return isDark ? AppColors.textDisabled : AppColors.textTertiaryLight;
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.magic:
      case AppButtonVariant.success:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.portal:
      case AppButtonVariant.artifact:
        return AppColors.surfaceDark;
      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
      case AppButtonVariant.ghost:
        return isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    }
  }

  Border? _getBorder(bool isDark, bool isEnabled) {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return Border.all(
          color: isEnabled
              ? (isDark ? AppColors.primaryAccent : AppColors.primary)
              : (isDark ? AppColors.textDisabled : AppColors.textTertiaryLight),
          width: 1.5,
        );
      case AppButtonVariant.ghost:
        return Border.all(
          color: isEnabled
              ? (isDark ? AppColors.surfaceLight : AppColors.surfaceGray)
              : (isDark ? AppColors.textDisabled : AppColors.textTertiaryLight),
          width: 1.0,
        );
      default:
        return null;
    }
  }

  List<BoxShadow> _getShadows(bool isEnabled) {
    if (!isEnabled) return AppShadows.none;
    if (_isPressed) return AppShadows.pressed;

    switch (widget.variant) {
      case AppButtonVariant.magic:
        return AppShadows.magicGlow;
      case AppButtonVariant.portal:
        return AppShadows.portalGlow;
      case AppButtonVariant.artifact:
        return AppShadows.goldenGlow;
      case AppButtonVariant.success:
        return AppShadows.successGlow;
      case AppButtonVariant.danger:
        return AppShadows.errorGlow;
      case AppButtonVariant.primary:
        return AppShadows.small;
      default:
        return AppShadows.none;
    }
  }

  Gradient? _getGradient(bool isDark, bool isEnabled) {
    if (!isEnabled) return null;

    switch (widget.variant) {
      case AppButtonVariant.magic:
        return AppColors.magicGradient;
      case AppButtonVariant.portal:
        return AppColors.portalGradient;
      default:
        return null;
    }
  }

  Color _getSplashColor(bool isDark) {
    switch (widget.variant) {
      case AppButtonVariant.magic:
        return AppColors.glow;
      case AppButtonVariant.portal:
        return AppColors.aqua;
      case AppButtonVariant.artifact:
        return AppColors.secondary;
      case AppButtonVariant.success:
        return AppColors.success;
      case AppButtonVariant.danger:
        return AppColors.error;
      default:
        return isDark ? AppColors.primaryAccent : AppColors.primary;
    }
  }

  // ========================================
  // 📏 SIZE & DIMENSION METHODS
  // ========================================

  double _getButtonHeight() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 32.0;
      case AppButtonSize.medium:
        return 40.0;
      case AppButtonSize.large:
        return 48.0;
      case AppButtonSize.extraLarge:
        return 56.0;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.buttonPaddingHorizontal, vertical: AppSpacing.buttonPaddingVertical);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.buttonPaddingLarge, vertical: AppSpacing.md);
      case AppButtonSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg);
    }
  }

  double _getBorderRadius() {
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

  double _getIconSpacing() {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppSpacing.xs;
      case AppButtonSize.medium:
        return AppSpacing.sm;
      case AppButtonSize.large:
        return AppSpacing.md;
      case AppButtonSize.extraLarge:
        return AppSpacing.lg;
    }
  }

  TextStyle _getTextStyle(ThemeData theme, bool isDark, bool isEnabled) {
    final baseStyle = switch (widget.size) {
      AppButtonSize.small => AppTypography.labelMedium(isDark: isDark),
      AppButtonSize.medium => AppTypography.labelLarge(isDark: isDark),
      AppButtonSize.large => AppTypography.labelLarge(isDark: isDark),
      AppButtonSize.extraLarge => AppTypography.h6(isDark: isDark),
    };

    return baseStyle.copyWith(
      color: _getContentColor(isDark, isEnabled),
      fontWeight: FontWeight.w600,
    );
  }
}