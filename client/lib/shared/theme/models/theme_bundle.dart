/// 📦 Theme Bundle Model
/// 
/// Defines a collection of related themes for different contexts
library;

import 'world_theme.dart';

class ThemeBundle {
  const ThemeBundle({
    required this.id,
    required this.name,
    required this.description,
    this.version = '1.0.0',
    this.author,
    this.category,
    this.tags = const [],
    this.themes = const [],
    this.parentBundle,
    this.fallbackBundle = 'default',
    this.metadata,
    this.isActive = true,
    this.minAppVersion,
    this.maxAppVersion,
  });

  /// Unique bundle identifier
  final String id;
  
  /// Human-readable bundle name
  final String name;
  
  /// Bundle description
  final String description;
  
  /// Bundle version
  final String version;
  
  /// Bundle author/creator
  final String? author;
  
  /// Bundle category (e.g., 'fantasy', 'sci-fi', 'modern')
  final String? category;
  
  /// Bundle tags for filtering
  final List<String> tags;
  
  /// Themes included in this bundle
  final List<WorldTheme> themes;
  
  /// Parent bundle for inheritance
  final String? parentBundle;
  
  /// Fallback bundle if this one fails to load
  final String fallbackBundle;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;
  
  /// Whether bundle is active/available
  final bool isActive;
  
  /// Minimum app version required
  final String? minAppVersion;
  
  /// Maximum app version supported
  final String? maxAppVersion;

  /// Factory constructor from JSON
  factory ThemeBundle.fromJson(Map<String, dynamic> json) {
    return ThemeBundle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String? ?? '1.0.0',
      author: json['author'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      themes: (json['themes'] as List<dynamic>?)
          ?.map((t) => WorldTheme.fromJson(t as Map<String, dynamic>))
          .toList() ?? const [],
      parentBundle: json['parentBundle'] as String?,
      fallbackBundle: json['fallbackBundle'] as String? ?? 'default',
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      minAppVersion: json['minAppVersion'] as String?,
      maxAppVersion: json['maxAppVersion'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'author': author,
      'category': category,
      'tags': tags,
      'themes': themes.map((t) => t.toJson()).toList(),
      'parentBundle': parentBundle,
      'fallbackBundle': fallbackBundle,
      'metadata': metadata,
      'isActive': isActive,
      'minAppVersion': minAppVersion,
      'maxAppVersion': maxAppVersion,
    };
  }

  /// Get theme by variant
  WorldTheme? getThemeByVariant(String variant) {
    return themes.where((t) => t.variant == variant).firstOrNull;
  }

  /// Get default theme
  WorldTheme? get defaultTheme {
    return themes.where((t) => t.isDefault).firstOrNull ?? 
           themes.firstOrNull;
  }

  /// Get light theme
  WorldTheme? get lightTheme {
    return themes.where((t) => t.hasLight).firstOrNull;
  }

  /// Get dark theme
  WorldTheme? get darkTheme {
    return themes.where((t) => t.hasDark).firstOrNull;
  }

  /// Get all available variants
  List<String> get availableVariants {
    return themes
        .where((t) => t.variant != null)
        .map((t) => t.variant!)
        .toSet()
        .toList();
  }

  /// Check if bundle supports dark mode
  bool get supportsDarkMode {
    return themes.any((t) => t.hasDark);
  }

  /// Check if bundle supports light mode
  bool get supportsLightMode {
    return themes.any((t) => t.hasLight);
  }

  /// Get bundle cache key
  String get cacheKey => '${id}_$version';

  @override
  String toString() => 'ThemeBundle(id: $id, name: $name, themes: ${themes.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeBundle &&
        other.id == id &&
        other.version == version;
  }

  @override
  int get hashCode => Object.hash(id, version);
}

/// Extension for Iterable<WorldTheme>
extension WorldThemeIterable on Iterable<WorldTheme> {
  WorldTheme? get firstOrNull => isEmpty ? null : first;
}