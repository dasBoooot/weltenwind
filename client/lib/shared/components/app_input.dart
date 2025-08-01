import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/modular_theme_service.dart';

/// 📝 Fantasy Input Variants based on Theme Schema
enum AppInputVariant {
  /// Standard filled input
  filled,
  /// Outlined input
  outlined,
  /// Underlined input
  underlined,
  /// Magic input with glow effects
  magic,
  /// Search input with search icon
  search,
  /// Password input with visibility toggle
  password,
}

/// 📝 Weltenwind Schema-Based Fantasy Input
/// 
/// Input component built from JSON Theme Schema inputs configuration
class AppInput extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final AppInputVariant variant;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const AppInput({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.variant = AppInputVariant.filled,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.validator,
    this.focusNode,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  
  bool _isFocused = false;
  bool _isPasswordVisible = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
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

    // Start glow animation for magic variant
    if (widget.variant == AppInputVariant.magic) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = ModularThemeService().getCurrentThemeExtensions();
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: _getContainerDecoration(theme, extensions),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.variant == AppInputVariant.password 
                ? !_isPasswordVisible 
                : widget.obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: _getTextStyle(theme),
            decoration: _getInputDecoration(theme, extensions),
          ),
        );
      },
    );
  }

  /// Container decoration for magic glow effects
  BoxDecoration? _getContainerDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.variant != AppInputVariant.magic) return null;
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.2 + (0.3 * _glowAnimation.value)),
          blurRadius: 8 + (12 * _glowAnimation.value),
          spreadRadius: 1 + (2 * _glowAnimation.value),
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Input decoration based on schema configuration
  InputDecoration _getInputDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    final borderRadius = BorderRadius.circular(_getBorderRadius());
    
    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      
      // Filled configuration from schema
      filled: _isFilled(),
      fillColor: _getFillColor(theme),
      
      // Prefix icon
      prefixIcon: widget.prefixIcon != null 
          ? Icon(widget.prefixIcon, color: _getIconColor(theme))
          : (widget.variant == AppInputVariant.search 
              ? Icon(Icons.search, color: _getIconColor(theme))
              : null),
      
      // Suffix icon
      suffixIcon: _getSuffixIcon(theme),
      
      // Borders based on schema configuration
      border: _getBorder(theme, borderRadius, false, false),
      enabledBorder: _getBorder(theme, borderRadius, false, false),
      focusedBorder: _getBorder(theme, borderRadius, true, false),
      errorBorder: _getBorder(theme, borderRadius, false, true),
      focusedErrorBorder: _getBorder(theme, borderRadius, true, true),
      disabledBorder: _getBorder(theme, borderRadius, false, false).copyWith(
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          width: _getBorderWidth(false),
        ),
      ),
      
      // Padding from schema
      contentPadding: EdgeInsets.symmetric(
        horizontal: _getPaddingHorizontal(),
        vertical: _getPaddingVertical(),
      ),
      
      // Text styles
      labelStyle: _getLabelStyle(theme),
      hintStyle: _getHintStyle(theme),
      helperStyle: _getHelperStyle(theme),
      errorStyle: _getErrorStyle(theme),
    );
  }

  /// Check if input should be filled based on variant and schema
  bool _isFilled() {
    switch (widget.variant) {
      case AppInputVariant.filled:
      case AppInputVariant.magic:
      case AppInputVariant.search:
      case AppInputVariant.password:
        return true; // Schema default: true
      case AppInputVariant.outlined:
      case AppInputVariant.underlined:
        return false;
    }
  }

  /// Fill color
  Color _getFillColor(ThemeData theme) {
    switch (widget.variant) {
      case AppInputVariant.magic:
        return theme.colorScheme.primaryContainer.withValues(alpha: 0.1);
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  /// Get appropriate border
  InputBorder _getBorder(ThemeData theme, BorderRadius borderRadius, bool isFocused, bool isError) {
    switch (widget.variant) {
      case AppInputVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: _getBorderColor(theme, isFocused, isError),
            width: _getBorderWidth(isFocused),
          ),
        );
      case AppInputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: _getBorderColor(theme, isFocused, isError),
            width: _getBorderWidth(isFocused),
          ),
        );
      default: // filled variants
        if (_isFilled()) {
          return OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          );
        } else {
          return OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: _getBorderColor(theme, isFocused, isError),
              width: _getBorderWidth(isFocused),
            ),
          );
        }
    }
  }

  /// Border color based on state
  Color _getBorderColor(ThemeData theme, bool isFocused, bool isError) {
    if (isError) {
      return theme.colorScheme.error;
    }
    if (isFocused) {
      return widget.variant == AppInputVariant.magic 
          ? theme.colorScheme.primary
          : theme.colorScheme.primary;
    }
    return theme.colorScheme.outline;
  }

  /// Border width from schema
  double _getBorderWidth(bool isFocused) {
    return isFocused 
        ? 2.0  // Schema focusedBorderWidth default
        : 1.0; // Schema borderWidth default
  }

  /// Border radius from schema
  double _getBorderRadius() {
    return 12.0; // Schema borderRadius default
  }

  /// Horizontal padding from schema
  double _getPaddingHorizontal() {
    return 16.0; // Schema paddingHorizontal default
  }

  /// Vertical padding from schema
  double _getPaddingVertical() {
    return 16.0; // Schema paddingVertical default
  }

  /// Suffix icon based on variant
  Widget? _getSuffixIcon(ThemeData theme) {
    if (widget.variant == AppInputVariant.password) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: _getIconColor(theme),
        ),
        onPressed: _togglePasswordVisibility,
      );
    }
    
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, color: _getIconColor(theme)),
        onPressed: widget.onSuffixIconTap,
      );
    }
    
    return null;
  }

  /// Icon color
  Color _getIconColor(ThemeData theme) {
    return _isFocused 
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
  }

  /// Text style
  TextStyle _getTextStyle(ThemeData theme) {
    return theme.textTheme.bodyLarge?.copyWith(
      color: widget.enabled 
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
    ) ?? TextStyle(
      color: widget.enabled 
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
    );
  }

  /// Label style
  TextStyle _getLabelStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium?.copyWith(
      color: _isFocused 
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant,
    ) ?? TextStyle(
      color: _isFocused 
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant,
    );
  }

  /// Hint style
  TextStyle _getHintStyle(ThemeData theme) {
    return theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    ) ?? TextStyle(
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  /// Helper style
  TextStyle _getHelperStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    ) ?? TextStyle(
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  /// Error style
  TextStyle _getErrorStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.error,
    ) ?? TextStyle(
      color: theme.colorScheme.error,
    );
  }
}