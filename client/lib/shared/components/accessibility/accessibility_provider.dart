import 'package:flutter/material.dart';
import '../../../core/services/modular_theme_service.dart';

/// 🦾 Color Blind Types from Accessibility Schema
enum ColorBlindType {
  none,
  protanopia,    // Red-blind
  deuteranopia,  // Green-blind
  tritanopia,    // Blue-blind
  achromatopsia, // Complete color blind
  autoDetect,
}

/// 📊 Color Blind Severity from Schema
enum ColorBlindSeverity {
  mild,
  moderate,
  severe,
}

/// 🎮 Accessibility Settings from Gaming Schema
class AccessibilitySettings {
  final bool colorBlindEnabled;
  final ColorBlindType colorBlindType;
  final ColorBlindSeverity colorBlindSeverity;
  final bool useShapesForRarity;
  final bool usePatternsForRarity;
  final bool increasedContrast;
  final bool useSymbolsForRarity;
  final bool highContrastHealth;
  final bool avoidGradients;
  final bool largeFocusIndicators;
  final bool reducedMotion;
  final double buttonSizeMultiplier;
  final bool simplifiedInterface;

  const AccessibilitySettings({
    this.colorBlindEnabled = false,
    this.colorBlindType = ColorBlindType.autoDetect,
    this.colorBlindSeverity = ColorBlindSeverity.moderate,
    this.useShapesForRarity = true,
    this.usePatternsForRarity = true,
    this.increasedContrast = true,
    this.useSymbolsForRarity = true,
    this.highContrastHealth = true,
    this.avoidGradients = false,
    this.largeFocusIndicators = false,
    this.reducedMotion = false,
    this.buttonSizeMultiplier = 1.0,
    this.simplifiedInterface = false,
  });

  AccessibilitySettings copyWith({
    bool? colorBlindEnabled,
    ColorBlindType? colorBlindType,
    ColorBlindSeverity? colorBlindSeverity,
    bool? useShapesForRarity,
    bool? usePatternsForRarity,
    bool? increasedContrast,
    bool? useSymbolsForRarity,
    bool? highContrastHealth,
    bool? avoidGradients,
    bool? largeFocusIndicators,
    bool? reducedMotion,
    double? buttonSizeMultiplier,
    bool? simplifiedInterface,
  }) {
    return AccessibilitySettings(
      colorBlindEnabled: colorBlindEnabled ?? this.colorBlindEnabled,
      colorBlindType: colorBlindType ?? this.colorBlindType,
      colorBlindSeverity: colorBlindSeverity ?? this.colorBlindSeverity,
      useShapesForRarity: useShapesForRarity ?? this.useShapesForRarity,
      usePatternsForRarity: usePatternsForRarity ?? this.usePatternsForRarity,
      increasedContrast: increasedContrast ?? this.increasedContrast,
      useSymbolsForRarity: useSymbolsForRarity ?? this.useSymbolsForRarity,
      highContrastHealth: highContrastHealth ?? this.highContrastHealth,
      avoidGradients: avoidGradients ?? this.avoidGradients,
      largeFocusIndicators: largeFocusIndicators ?? this.largeFocusIndicators,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      buttonSizeMultiplier: buttonSizeMultiplier ?? this.buttonSizeMultiplier,
      simplifiedInterface: simplifiedInterface ?? this.simplifiedInterface,
    );
  }
}

/// 🦾 Accessibility Provider based on Gaming Accessibility Schema
/// 
/// Provides accessibility settings and color adaptations for gaming UI
class AccessibilityProvider extends ChangeNotifier {
  AccessibilitySettings _settings = const AccessibilitySettings();

  AccessibilitySettings get settings => _settings;

  /// Update accessibility settings
  void updateSettings(AccessibilitySettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  /// Get color blind safe rarity color from schema
  Color getRarityColor(String rarity, ThemeData theme) {
    if (!_settings.colorBlindEnabled) {
      return _getDefaultRarityColor(rarity, theme);
    }

    // Schema default alternative colors for color blind users
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFFFFFFFF); // White - Schema default
      case 'uncommon':
        return const Color(0xFFFFD700); // Gold - Schema default
      case 'rare':
        return const Color(0xFFFF6B35); // Orange - Schema default
      case 'epic':
        return const Color(0xFF8E44AD); // Purple - Schema default
      case 'legendary':
        return const Color(0xFF000000); // Black - Schema default
      case 'mythic':
        return const Color(0xFFE74C3C); // Red - Schema default
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Get rarity symbol from schema
  String getRaritySymbol(String rarity) {
    if (!_settings.useSymbolsForRarity) return '';
    
    // Schema default symbols
    switch (rarity.toLowerCase()) {
      case 'common':
        return '○'; // Schema default
      case 'uncommon':
        return '△'; // Schema default
      case 'rare':
        return '◇'; // Schema default
      case 'epic':
        return '◆'; // Schema default
      case 'legendary':
        return '★'; // Schema default
      case 'mythic':
        return '※'; // Schema default
      default:
        return '';
    }
  }

  /// Get color blind safe health/resource color from schema
  Color getResourceColor(String resourceType, ThemeData theme) {
    if (!_settings.colorBlindEnabled || !_settings.highContrastHealth) {
      return _getDefaultResourceColor(resourceType, theme);
    }

    // Schema default alternative colors for color blind users
    switch (resourceType.toLowerCase()) {
      case 'health':
        return const Color(0xFF000000); // Black - Schema default
      case 'mana':
        return const Color(0xFF4A4A4A); // Dark Gray - Schema default
      case 'stamina':
        return const Color(0xFF8A8A8A); // Gray - Schema default
      case 'experience':
        return const Color(0xFFFFFFFF); // White - Schema default
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Check if gradients should be avoided
  bool shouldAvoidGradients() {
    return _settings.colorBlindEnabled && _settings.avoidGradients;
  }

  /// Get focus indicator size multiplier
  double getFocusIndicatorSize() {
    return _settings.largeFocusIndicators ? 1.5 : 1.0;
  }

  /// Get button size multiplier for motor disabilities
  double getButtonSizeMultiplier() {
    return _settings.buttonSizeMultiplier;
  }

  /// Check if animations should be reduced
  bool shouldReduceMotion() {
    return _settings.reducedMotion;
  }

  /// Get increased contrast factor
  double getContrastMultiplier() {
    if (!_settings.increasedContrast) return 1.0;
    
    switch (_settings.colorBlindSeverity) {
      case ColorBlindSeverity.mild:
        return 1.2;
      case ColorBlindSeverity.moderate:
        return 1.5;
      case ColorBlindSeverity.severe:
        return 2.0;
    }
  }

  /// Get default rarity colors (fallback)
  Color _getDefaultRarityColor(String rarity, ThemeData theme) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      case 'mythic':
        return Colors.red;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Get default resource colors (fallback)
  Color _getDefaultResourceColor(String resourceType, ThemeData theme) {
    switch (resourceType.toLowerCase()) {
      case 'health':
        return Colors.red;
      case 'mana':
        return Colors.blue;
      case 'stamina':
        return Colors.yellow;
      case 'experience':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
}

/// 🎯 Accessibility Provider Widget for InheritedWidget access
class AccessibilityProviderWidget extends InheritedNotifier<AccessibilityProvider> {
  const AccessibilityProviderWidget({
    super.key,
    required AccessibilityProvider super.notifier,
    required super.child,
  });

  static AccessibilityProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AccessibilityProviderWidget>()?.notifier;
  }

  static AccessibilityProvider of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<AccessibilityProviderWidget>()?.notifier ??
          AccessibilityProvider();
    } else {
      return (context.getElementForInheritedWidgetOfExactType<AccessibilityProviderWidget>()?.widget
              as AccessibilityProviderWidget?)?.notifier ??
          AccessibilityProvider();
    }
  }
}