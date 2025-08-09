import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../base/base_component.dart';

enum AppTextFieldType {
  text,
  email,
  password,
  number,
  multiline,
}

class AppTextField extends BaseComponent {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.type = AppTextFieldType.text,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLength,
    this.maxLines,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final AppTextFieldType type;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool isRequired;
  final bool isEnabled;
  final bool isReadOnly;
  final int? maxLength;
  final int? maxLines;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final textTheme = getTextTheme(context);
    final isDark = isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        _buildLabel(textTheme, colorScheme),
        const SizedBox(height: 8),
        
        // Text Field
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          decoration: _buildInputDecoration(context, colorScheme, isDark),
          style: _getTextStyle(textTheme),
          keyboardType: _getKeyboardType(),
          textInputAction: _getTextInputAction(),
          inputFormatters: _getInputFormatters(),
          obscureText: type == AppTextFieldType.password,
          maxLength: maxLength,
          maxLines: _getMaxLines(),
          enabled: isEnabled,
          readOnly: isReadOnly,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: _buildValidator(),
        ),
        
        // Helper text
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: 4),
          _buildHelperText(textTheme, colorScheme),
        ],
      ],
    );
  }

  /// Build label widget
  Widget _buildLabel(TextTheme textTheme, ColorScheme colorScheme) {
    return RichText(
      text: TextSpan(
        text: label,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  /// Build helper text widget
  Widget _buildHelperText(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      helperText!,
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  /// Build input decoration
  InputDecoration _buildInputDecoration(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final borderRadius = getBorderRadius(context, radius: 8.0);

    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      
      // Border styling
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2.0,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      
      // Fill styling
      filled: true,
      fillColor: isDark 
          ? colorScheme.surface.withValues(alpha: 0.8)
          : colorScheme.surface,
      
      // Content padding
      contentPadding: getResponsivePadding(
        context,
        mobile: 12.0,
        tablet: 16.0,
        desktop: 16.0,
      ),
      
      // Counter styling
      counterStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 12,
      ),
      
      // Hint styling
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      
      // Helper text styling
      helperMaxLines: 2,
      errorMaxLines: 2,
    );
  }

  /// Get text style for input
  TextStyle _getTextStyle(TextTheme textTheme) {
    return textTheme.bodyLarge ?? const TextStyle();
  }

  /// Get keyboard type based on field type
  TextInputType _getKeyboardType() {
    switch (type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.number:
        return TextInputType.number;
      case AppTextFieldType.multiline:
        return TextInputType.multiline;
      case AppTextFieldType.text:
      case AppTextFieldType.password:
      default:
        return TextInputType.text;
    }
  }

  /// Get text input action
  TextInputAction _getTextInputAction() {
    switch (type) {
      case AppTextFieldType.multiline:
        return TextInputAction.newline;
      case AppTextFieldType.email:
      case AppTextFieldType.password:
        return TextInputAction.next;
      case AppTextFieldType.text:
      case AppTextFieldType.number:
        return TextInputAction.done;
    }
  }

  /// Get input formatters based on type
  List<TextInputFormatter>? _getInputFormatters() {
    switch (type) {
      case AppTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppTextFieldType.email:
        return [FilteringTextInputFormatter.deny(RegExp(r'\s'))]; // No spaces
      default:
        return null;
    }
  }

  /// Get max lines based on type
  int? _getMaxLines() {
    if (maxLines != null) return maxLines;
    
    switch (type) {
      case AppTextFieldType.multiline:
        return null; // Unlimited
      case AppTextFieldType.password:
        return 1;
      default:
        return 1;
    }
  }

  /// Build validator function
  FormFieldValidator<String>? _buildValidator() {
    return (value) {
      // Custom validator takes precedence
      if (validator != null) {
        final result = validator!(value);
        if (result != null) return result;
      }

      // Required validation
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return '$label is required';
      }

      // Type-specific validation
      switch (type) {
        case AppTextFieldType.email:
          if (value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          }
          break;
        
        case AppTextFieldType.password:
          if (value != null && value.isNotEmpty && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          break;
        
        default:
          break;
      }

      return null;
    };
  }
}