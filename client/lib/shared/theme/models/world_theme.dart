/// 🎨 World Theme Model
/// 
/// Defines the structure for world-specific themes
library;

import 'package:flutter/material.dart';

class WorldTheme {
  const WorldTheme({
    required this.id,
    required this.name,
    required this.worldId,
    this.description,
    this.version = '1.0.0',
    this.bundle,
    this.variant,
    this.lightThemeData,
    this.darkThemeData,
    this.extensions,
    this.metadata,
    this.isDefault = false,
    this.priority = 0,
    this.tags = const [],
  });

  /// Unique theme identifier
  final String id;
  
  /// Human-readable theme name
  final String name;
  
  /// World this theme belongs to
  final int worldId;
  
  /// Theme description
  final String? description;
  
  /// Theme version
  final String version;
  
  /// Theme bundle name (e.g., 'cyberpunk', 'fantasy', 'modern')
  final String? bundle;
  
  /// Theme variant (e.g., 'dark', 'light', 'neon', 'classic')
  final String? variant;
  
  /// Light theme data
  final ThemeData? lightThemeData;
  
  /// Dark theme data  
  final ThemeData? darkThemeData;
  
  /// Theme extensions for custom properties
  final Map<String, dynamic>? extensions;
  
  /// Theme metadata (author, created, modified, etc.)
  final Map<String, dynamic>? metadata;
  
  /// Whether this is the default theme for the world
  final bool isDefault;
  
  /// Theme priority (higher = preferred)
  final int priority;
  
  /// Theme tags for categorization
  final List<String> tags;

  /// Factory constructor from JSON
  factory WorldTheme.fromJson(Map<String, dynamic> json) {
    return WorldTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      worldId: json['worldId'] as int,
      description: json['description'] as String?,
      version: json['version'] as String? ?? '1.0.0',
      bundle: json['bundle'] as String?,
      variant: json['variant'] as String?,
      extensions: json['extensions'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDefault: json['isDefault'] as bool? ?? false,
      priority: json['priority'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      // ThemeData will be built from the theme definition
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'worldId': worldId,
      'description': description,
      'version': version,
      'bundle': bundle,
      'variant': variant,
      'extensions': extensions,
      'metadata': metadata,
      'isDefault': isDefault,
      'priority': priority,
      'tags': tags,
    };
  }

  /// Copy with method for updates
  WorldTheme copyWith({
    String? id,
    String? name,
    int? worldId,
    String? description,
    String? version,
    String? bundle,
    String? variant,
    ThemeData? lightThemeData,
    ThemeData? darkThemeData,
    Map<String, dynamic>? extensions,
    Map<String, dynamic>? metadata,
    bool? isDefault,
    int? priority,
    List<String>? tags,
  }) {
    return WorldTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      worldId: worldId ?? this.worldId,
      description: description ?? this.description,
      version: version ?? this.version,
      bundle: bundle ?? this.bundle,
      variant: variant ?? this.variant,
      lightThemeData: lightThemeData ?? this.lightThemeData,
      darkThemeData: darkThemeData ?? this.darkThemeData,
      extensions: extensions ?? this.extensions,
      metadata: metadata ?? this.metadata,
      isDefault: isDefault ?? this.isDefault,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }

  /// Get theme key for caching
  String get cacheKey => '${worldId}_${id}_${variant ?? 'default'}';

  /// Get theme bundle with variant
  String get fullBundle {
    if (bundle == null) return 'default';
    if (variant == null) return bundle!;
    return '${bundle}_$variant';
  }

  /// Check if theme has light theme data
  bool get hasLight => lightThemeData != null;

  /// Check if theme has dark theme data
  bool get hasDark => darkThemeData != null;

  /// Check if theme supports both light and dark
  bool get supportsBothModes => hasLight && hasDark;

  @override
  String toString() => 'WorldTheme(id: $id, name: $name, worldId: $worldId, bundle: $bundle)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorldTheme &&
        other.id == id &&
        other.worldId == worldId &&
        other.version == version;
  }

  @override
  int get hashCode => Object.hash(id, worldId, version);
}