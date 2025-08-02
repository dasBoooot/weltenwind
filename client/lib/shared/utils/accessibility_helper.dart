import 'package:flutter/material.dart';

/// 🦾 Accessibility Helper for Schema-based Components
class AccessibilityHelper {
  /// Wrap widget with semantic information
  static Widget withSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? textField,
    bool? image,
    bool? slider,
    bool? focusable,
    bool? selected,
    bool? enabled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    String? increasedValue,
    String? decreasedValue,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      textField: textField ?? false,
      image: image ?? false,
      slider: slider ?? false,
      focusable: focusable ?? true,
      selected: selected,
      enabled: enabled ?? true,
      onTap: onTap,
      onLongPress: onLongPress,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  /// Gaming-specific semantic labels
  static Widget gameElement({
    required Widget child,
    required String elementType,
    String? status,
    String? value,
    VoidCallback? onTap,
  }) {
    final Map<String, String> gameLabels = {
      'minimap': 'Game minimap showing player position and nearby entities',
      'healthBar': 'Player health: $value',
      'manaBar': 'Player mana: $value',
      'inventorySlot': 'Inventory slot',
      'buffIcon': 'Active buff: $elementType',
      'debuffIcon': 'Active debuff: $elementType',
    };

    return withSemantics(
      child: child,
      label: gameLabels[elementType] ?? elementType,
      value: value,
      onTap: onTap,
      hint: status,
    );
  }

  /// Button semantic wrapper
  static Widget button({
    required Widget child,
    required String label,
    String? hint,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return withSemantics(
      child: child,
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
    );
  }

  /// Text field semantic wrapper
  static Widget textField({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool enabled = true,
  }) {
    return withSemantics(
      child: child,
      label: label,
      hint: hint,
      value: value,
      textField: true,
      enabled: enabled,
    );
  }

  /// Progress indicator semantic wrapper
  static Widget progressIndicator({
    required Widget child,
    required double progress,
    String? label,
    String? type,
  }) {
    final percentage = (progress * 100).round();
    return withSemantics(
      child: child,
      label: label ?? '$type progress',
      value: '$percentage percent',
      slider: true,
    );
  }

  /// Card/container semantic wrapper
  static Widget card({
    required Widget child,
    String? label,
    String? hint,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return withSemantics(
      child: child,
      label: label,
      hint: hint,
      button: onTap != null,
      selected: selected,
      onTap: onTap,
    );
  }

  /// List item semantic wrapper
  static Widget listItem({
    required Widget child,
    required int index,
    required int total,
    String? label,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return withSemantics(
      child: child,
      label: label,
      hint: 'Item ${index + 1} of $total',
      button: onTap != null,
      selected: selected,
      onTap: onTap,
    );
  }

  /// Tab semantic wrapper
  static Widget tab({
    required Widget child,
    required String label,
    required int index,
    required int total,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return withSemantics(
      child: child,
      label: label,
      hint: 'Tab ${index + 1} of $total',
      button: true,
      selected: selected,
      onTap: onTap,
    );
  }

  /// Icon button semantic wrapper
  static Widget iconButton({
    required Widget child,
    required String label,
    String? hint,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return withSemantics(
      child: child,
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
    );
  }

  /// Checkbox semantic wrapper
  static Widget checkbox({
    required Widget child,
    required String label,
    required bool value,
    String? hint,
    bool enabled = true,
    ValueChanged<bool?>? onChanged,
  }) {
    return withSemantics(
      child: child,
      label: label,
      hint: hint,
      value: value ? 'Checked' : 'Unchecked',
      button: true,
      enabled: enabled,
      onTap: enabled ? () => onChanged?.call(!value) : null,
    );
  }

  /// Dropdown semantic wrapper
  static Widget dropdown({
    required Widget child,
    String? label,
    String? value,
    String? hint,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return withSemantics(
      child: child,
      label: label ?? 'Dropdown',
      value: value,
      hint: hint ?? 'Double tap to open dropdown',
      button: true,
      enabled: enabled,
      onTap: onTap,
    );
  }

  /// Gaming HUD element wrapper
  static Widget hudElement({
    required Widget child,
    required String type,
    String? status,
    double? value,
    double? maxValue,
  }) {
    String semanticValue = '';
    if (value != null) {
      if (maxValue != null) {
        final percentage = ((value / maxValue) * 100).round();
        semanticValue = '$percentage percent';
      } else {
        semanticValue = value.toString();
      }
    }

    return withSemantics(
      child: child,
      label: type,
      value: semanticValue,
      hint: status,
    );
  }

  /// World/level selection semantic wrapper
  static Widget worldSelector({
    required Widget child,
    required String worldName,
    String? description,
    String? playerCount,
    String? status,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    String hint = '';
    if (description != null) hint += description;
    if (playerCount != null) hint += '. $playerCount players online';
    if (status != null) hint += '. Status: $status';

    return withSemantics(
      child: child,
      label: worldName,
      hint: hint.isNotEmpty ? hint : null,
      button: true,
      selected: selected,
      onTap: onTap,
    );
  }
}