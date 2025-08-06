/// 🎨 Named Entrypoints Models
/// 
/// Models für die neue Named Entrypoints Struktur mit kontext-spezifischen Themes
library;

class ThemeContext {
  static const String preGame = 'pre-game';
  static const String game = 'game';
  static const String loading = 'loading';
  
  static const List<String> all = [preGame, game, loading];
}

class ThemeEntrypoint {
  final String file;
  final String export;
  
  const ThemeEntrypoint({
    required this.file,
    required this.export,
  });
  
  factory ThemeEntrypoint.fromJson(Map<String, dynamic> json) {
    return ThemeEntrypoint(
      file: json['file'] as String,
      export: json['export'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'export': export,
    };
  }
}

class ManifestEntrypoints {
  final Map<String, ThemeEntrypoint> themes;
  final String? themeCss;
  final String? preThemeCss;
  
  const ManifestEntrypoints({
    required this.themes,
    this.themeCss,
    this.preThemeCss,
  });
  
  factory ManifestEntrypoints.fromJson(Map<String, dynamic> json) {
    final themesMap = <String, ThemeEntrypoint>{};
    final themesJson = json['themes'] as Map<String, dynamic>? ?? {};
    
    for (final entry in themesJson.entries) {
      themesMap[entry.key] = ThemeEntrypoint.fromJson(entry.value);
    }
    
    return ManifestEntrypoints(
      themes: themesMap,
      themeCss: json['themeCss'] as String?,
      preThemeCss: json['preThemeCss'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'themes': themes.map((key, value) => MapEntry(key, value.toJson())),
      'themeCss': themeCss,
      'preThemeCss': preThemeCss,
    };
  }
}

class WorldManifest {
  final String id;
  final String name;
  final String version;
  final String description;
  final String category;
  final String author;
  final String createdAt;
  final ManifestEntrypoints entrypoints;
  final Map<String, dynamic> assets;
  final Map<String, dynamic> config;
  final Map<String, dynamic> pre;
  final Map<String, dynamic> bundle;
  
  const WorldManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.category,
    required this.author,
    required this.createdAt,
    required this.entrypoints,
    required this.assets,
    required this.config,
    required this.pre,
    required this.bundle,
  });
  
  factory WorldManifest.fromJson(Map<String, dynamic> json) {
    return WorldManifest(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      author: json['author'] as String,
      createdAt: json['createdAt'] as String,
      entrypoints: ManifestEntrypoints.fromJson(json['entrypoints']),
      assets: json['assets'] as Map<String, dynamic>,
      config: json['config'] as Map<String, dynamic>,
      pre: json['pre'] as Map<String, dynamic>,
      bundle: json['bundle'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'description': description,
      'category': category,
      'author': author,
      'createdAt': createdAt,
      'entrypoints': entrypoints.toJson(),
      'assets': assets,
      'config': config,
      'pre': pre,
      'bundle': bundle,
    };
  }
}

class NamedEntrypointResponse {
  final WorldManifest manifest;
  final NamedEntrypointTheme theme;
  
  const NamedEntrypointResponse({
    required this.manifest,
    required this.theme,
  });
  
  factory NamedEntrypointResponse.fromJson(Map<String, dynamic> json) {
    return NamedEntrypointResponse(
      manifest: WorldManifest.fromJson(json['manifest']),
      theme: NamedEntrypointTheme.fromJson(json['theme']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'manifest': manifest.toJson(),
      'theme': theme.toJson(),
    };
  }
}

class NamedEntrypointTheme {
  final String context;
  final String export;
  final Map<String, dynamic> data;
  
  const NamedEntrypointTheme({
    required this.context,
    required this.export,
    required this.data,
  });
  
  factory NamedEntrypointTheme.fromJson(Map<String, dynamic> json) {
    return NamedEntrypointTheme(
      context: json['context'] as String,
      export: json['export'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'context': context,
      'export': export,
      'data': data,
    };
  }
}
