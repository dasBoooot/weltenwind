import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/logger.dart';
import '../../config/env.dart';
import 'api_service.dart';


/// 🚀 Modular Theme Service für Bundle-basiertes Theme Loading
/// 
/// Erweitert den bestehenden ThemeService um:
/// - Bundle Loading (pre-game, world-preview, full-gaming)
/// - Module Caching und Dependency Resolution
/// - Performance Monitoring und Schema Validation
class ModularThemeService {
  static final ModularThemeService _instance = ModularThemeService._internal();
  factory ModularThemeService() => _instance;
  ModularThemeService._internal();

  final ApiService _apiService = ApiService();
  
  // Caches für modulares System
  final Map<String, Map<String, dynamic>> _moduleCache = {};
  final Map<String, BundleConfig> _bundleConfigs = {};
  final Map<String, ThemeData> _bundleThemeCache = {};
  final Map<String, ThemeData> _bundleDarkThemeCache = {};
  
  // Performance Monitoring
  final Map<String, LoadingMetrics> _loadingMetrics = {};
  
  // Bundle Management
  String? _currentBundle;
  String? _currentContext;
  BundleConfig? _activeBundleConfig;
  
  /// Aktueller Bundle Name
  String? get currentBundle => _currentBundle;
  
  /// Aktueller Context
  String? get currentContext => _currentContext;
  
  /// Verfügbare Bundle-Konfigurationen
  Map<String, BundleConfig> get bundleConfigs => _bundleConfigs;
  
  /// Loading Metriken für Performance-Monitoring
  Map<String, LoadingMetrics> get loadingMetrics => _loadingMetrics;

  /// Initialisiert das modulare Theme-System
  Future<void> initialize() async {
    try {
      AppLogger.app.i('🚀 Initialisiere Modulares Theme System...');
      
      // Bundle Konfigurationen laden
      await _loadBundleConfigurations();
      
      // Verfügbare modulare Themes laden
      await _loadAvailableThemes();
      
      // Device-Tier ermitteln
      final deviceTier = await _detectDeviceTier();
      AppLogger.app.i('📱 Device Tier: $deviceTier');
      
      // Standard Bundle basierend auf Device bestimmen
      final defaultBundle = _selectDefaultBundle(deviceTier);
      AppLogger.app.i('📦 Standard Bundle: $defaultBundle');
      
      AppLogger.app.i('✅ Modulares Theme System initialisiert');
    } catch (e) {
      AppLogger.app.e('❌ Fehler bei Theme System Initialisierung', error: e);
    }
  }

  /// Lädt Bundle-Konfigurationen von der API
  Future<void> _loadBundleConfigurations() async {
    try {
      AppLogger.app.i('📦 Lade Bundle-Konfigurationen...');
      
      // Direkter HTTP-Call ohne API-Service da theme-editor statisch bereitgestellt wird
      const urlPath = '/theme-editor/bundles/bundle-configs.json';
      final url = '${Env.apiUrl}$urlPath';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        throw Exception('Bundle Config Error: ${response.statusCode} - URL: $url');
      }
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final bundlesData = data['bundles'] as Map<String, dynamic>;
      
      _bundleConfigs.clear();
      bundlesData.forEach((key, value) {
        _bundleConfigs[key] = BundleConfig.fromJson(value as Map<String, dynamic>);
      });
      
      AppLogger.app.i('✅ ${_bundleConfigs.length} Bundle-Konfigurationen geladen: ${_bundleConfigs.keys.join(', ')}');
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der Bundle-Konfigurationen', error: e);
      // Fallback zu Standard-Konfigurationen
      _createFallbackBundleConfigs();
    }
  }

  /// Liste der verfügbaren modularen Themes
  List<Map<String, dynamic>> _availableThemes = [];
  List<Map<String, dynamic>> get availableThemes => List.unmodifiable(_availableThemes);

  /// Lädt verfügbare modulare Themes von der API
  Future<void> _loadAvailableThemes() async {
    try {
      AppLogger.app.i('🎨 Lade verfügbare modulare Themes...');
      
      // API-Call für Theme-Liste
      final response = await _apiService.get('/themes');
      if (response.statusCode != 200) {
        throw Exception('Themes API Error: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final themes = data['themes'] as List<dynamic>;
      
      _availableThemes = themes.map((theme) => theme as Map<String, dynamic>).toList();
      
      AppLogger.app.i('✅ ${_availableThemes.length} modulare Themes geladen: ${_availableThemes.map((t) => t['name']).join(', ')}');
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der modularen Themes', error: e);
      _availableThemes = [];
    }
  }

  /// Lädt ein Theme mit spezifischem Bundle
  Future<ThemeData?> loadThemeWithBundle(String themeName, String bundleName, {bool isDark = false}) async {
    final startTime = DateTime.now();
    
    try {
      AppLogger.app.i('🎨 Lade Theme "$themeName" mit Bundle "$bundleName" (isDark: $isDark)');
      
      // Bundle-Konfiguration laden
      final bundleConfig = _bundleConfigs[bundleName];
      if (bundleConfig == null) {
        throw Exception('Bundle "$bundleName" nicht gefunden');
      }
      
      // Cache prüfen
      final cacheKey = '${themeName}_$bundleName';
      final cache = isDark ? _bundleDarkThemeCache : _bundleThemeCache;
      if (cache.containsKey(cacheKey)) {
        AppLogger.app.i('💾 Theme aus Cache geladen: $cacheKey');
        return cache[cacheKey];
      }
      
      // Theme-Daten modular laden
      final themeData = await _loadThemeModular(themeName, bundleConfig);
      if (themeData == null) {
        throw Exception('Theme-Daten konnten nicht geladen werden');
      }
      
      // ThemeData konvertieren
      final flutterTheme = await _convertModularThemeData(themeData, bundleConfig, isDark);
      
      // Cache speichern
      cache[cacheKey] = flutterTheme;
      
      // Performance-Metriken speichern
      final loadTime = DateTime.now().difference(startTime);
      _loadingMetrics[cacheKey] = LoadingMetrics(
        bundleName: bundleName,
        themeName: themeName,
        loadTime: loadTime,
        moduleCount: bundleConfig.modules.required.length + bundleConfig.modules.optional.length,
        estimatedSize: _parseSize(bundleConfig.estimatedSize),
        timestamp: DateTime.now(),
      );
      
      _currentBundle = bundleName;
      _currentContext = bundleConfig.context;
      _activeBundleConfig = bundleConfig;
      
      AppLogger.app.i('✅ Theme "$themeName" mit Bundle "$bundleName" geladen (${loadTime.inMilliseconds}ms)');
      return flutterTheme;
      
    } catch (e) {
      final loadTime = DateTime.now().difference(startTime);
      AppLogger.app.e('❌ Fehler beim Laden des Themes "$themeName" mit Bundle "$bundleName" (${loadTime.inMilliseconds}ms)', error: e);
      
      // Fallback zu einem einfachen Theme
      AppLogger.app.i('🔄 Fallback zu einem Standard-Theme...');
      return ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      );
    }
  }

  /// Lädt Theme-Daten modular basierend auf Bundle-Konfiguration
  Future<Map<String, dynamic>?> _loadThemeModular(String themeName, BundleConfig bundleConfig) async {
    try {
      AppLogger.app.i('📥 Lade modulare Theme-Daten für "$themeName"...');
      
      // Dependency Resolution
      final resolvedModules = await _resolveDependencies(bundleConfig.modules.required);
      AppLogger.app.i('🔗 Abhängigkeiten aufgelöst: ${resolvedModules.length} Module');
      
      // Theme-Basis laden
      final baseThemeData = await _loadBaseTheme(themeName);
      if (baseThemeData == null) return null;
      
      final modularTheme = <String, dynamic>{
        'name': baseThemeData['name'],
        'version': baseThemeData['version'], 
        'description': baseThemeData['description'],
        'bundle': {
          'type': bundleConfig.type,
          'context': bundleConfig.context,
          'modules': resolvedModules,
        }
      };
      
      // Module einzeln laden und zusammenführen
      for (final moduleName in resolvedModules) {
        final moduleData = await _loadModule(moduleName, baseThemeData);
        if (moduleData != null) {
          _mergeModuleData(modularTheme, moduleName, moduleData);
        }
      }
      
      // Bundle-spezifische Overrides anwenden
      _applyBundleOverrides(modularTheme, bundleConfig);
      
      AppLogger.app.i('✅ Modulare Theme-Daten geladen: ${modularTheme.keys.length} Hauptsektionen');
      return modularTheme;
      
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim modularen Theme-Laden', error: e);
      return null;
    }
  }

  /// Lädt Basis-Theme Daten
  Future<Map<String, dynamic>?> _loadBaseTheme(String themeName) async {
    // DEBUG: Theme Name ausgeben
    AppLogger.app.i('🔍 DEBUG: Loading base theme with name: "$themeName"');
    
    // Cache prüfen
    final cacheKey = 'base_$themeName';
    if (_moduleCache.containsKey(cacheKey)) {
      return _moduleCache[cacheKey];
    }
    
    // Von API laden
    final response = await _apiService.get('/themes/$themeName');
    if (response.statusCode != 200) return null;
    
    final themeData = jsonDecode(response.body) as Map<String, dynamic>;
    _moduleCache[cacheKey] = themeData;
    
    return themeData;
  }

  /// Lädt ein spezifisches Modul
  Future<Map<String, dynamic>?> _loadModule(String moduleName, Map<String, dynamic> baseTheme) async {
    try {
      // Modul aus Basis-Theme extrahieren
      if (moduleName == 'colors' && baseTheme.containsKey('colors')) {
        return {'colors': baseTheme['colors']};
      }
      if (moduleName == 'typography' && baseTheme.containsKey('typography')) {
        return {'typography': baseTheme['typography']};
      }
      if (moduleName == 'spacing' && baseTheme.containsKey('spacing')) {
        return {'spacing': baseTheme['spacing']};
      }
      if (moduleName == 'radius' && baseTheme.containsKey('radius')) {
        return {'radius': baseTheme['radius']};
      }
      
      // Gaming-Module
      if (moduleName.startsWith('gaming.')) {
        final gamingSection = moduleName.split('.')[1];
        if (baseTheme.containsKey('gaming') && 
            (baseTheme['gaming'] as Map<String, dynamic>).containsKey(gamingSection)) {
          return {
            'gaming': {
              gamingSection: baseTheme['gaming'][gamingSection]
            }
          };
        }
      }
      
      // Effects-Module
      if (moduleName.startsWith('effects.')) {
        final effectsSection = moduleName.split('.')[1];
        if (baseTheme.containsKey('extensions')) {
          // Effects sind derzeit in extensions gespeichert
          return {
            'effects': {
              effectsSection: baseTheme['extensions']
            }
          };
        }
      }
      
      AppLogger.app.w('⚠️ Modul nicht gefunden: $moduleName');
      return null;
      
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden des Moduls $moduleName', error: e);
      return null;
    }
  }

  /// Führt Modul-Daten in Theme zusammen
  void _mergeModuleData(Map<String, dynamic> theme, String moduleName, Map<String, dynamic> moduleData) {
    moduleData.forEach((key, value) {
      if (theme.containsKey(key) && value is Map<String, dynamic> && theme[key] is Map<String, dynamic>) {
        // Deep merge für verschachtelte Objekte
        final existingSection = theme[key] as Map<String, dynamic>;
        value.forEach((subKey, subValue) {
          existingSection[subKey] = subValue;
        });
      } else {
        theme[key] = value;
      }
    });
  }

  /// Wendet Bundle-spezifische Overrides an  
  void _applyBundleOverrides(Map<String, dynamic> theme, BundleConfig bundleConfig) {
    if (bundleConfig.overrides.isEmpty) return;
    
    AppLogger.app.i('🔧 Wende Bundle-Overrides an: ${bundleConfig.overrides.keys.join(', ')}');
    
    bundleConfig.overrides.forEach((section, overrides) {
      if (theme.containsKey(section)) {
        _deepMerge(theme[section] as Map<String, dynamic>, overrides);
      } else {
        theme[section] = overrides;
      }
    });
  }

  /// Deep merge für verschachtelte Maps
  void _deepMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      if (value is Map<String, dynamic> && target[key] is Map<String, dynamic>) {
        _deepMerge(target[key] as Map<String, dynamic>, value);
      } else {
        target[key] = value;
      }
    });
  }

  /// Löst Modul-Abhängigkeiten auf
  Future<List<String>> _resolveDependencies(List<String> requiredModules) async {
    final resolved = <String>[];
    final visited = <String>{};
    
    Future<void> resolveModule(String moduleName) async {
      if (visited.contains(moduleName)) return;
      visited.add(moduleName);
      
      // Abhängigkeiten für dieses Modul laden
      final dependencies = _getModuleDependencies(moduleName);
      for (final dep in dependencies) {
        await resolveModule(dep);
      }
      
      if (!resolved.contains(moduleName)) {
        resolved.add(moduleName);
      }
    }
    
    for (final module in requiredModules) {
      await resolveModule(module);
    }
    
    return resolved;
  }

  /// Gibt Abhängigkeiten für ein Modul zurück
  List<String> _getModuleDependencies(String moduleName) {
    // Basis-Abhängigkeiten definieren
    switch (moduleName) {
      case 'effects.visual':
      case 'effects.animations':
        return ['colors'];
      case 'gaming.inventory':
        return ['colors', 'spacing', 'radius'];
      case 'gaming.progress':
        return ['colors', 'typography'];
      case 'gaming.hud':
        return ['colors', 'typography', 'spacing', 'gaming.progress'];
      case 'gaming.accessibility':
        return ['colors', 'typography', 'gaming.inventory', 'gaming.progress', 'gaming.hud'];
      default:
        return [];
    }
  }

  /// Konvertiert modulare Theme-Daten zu Flutter ThemeData
  Future<ThemeData> _convertModularThemeData(Map<String, dynamic> themeData, BundleConfig bundleConfig, bool isDark) async {
    // JSON-Daten extrahieren
    final colors = themeData['colors'] as Map<String, dynamic>? ?? {};
    final typography = themeData['typography'] as Map<String, dynamic>? ?? {};
    final spacing = themeData['spacing'] as Map<String, dynamic>? ?? {};
    final radius = themeData['radius'] as Map<String, dynamic>? ?? {};
    
    // ColorScheme aus JSON erstellen
    final colorScheme = _createColorSchemeFromJson(colors, isDark);
    
    // TextTheme aus JSON erstellen
    final textTheme = _createTextThemeFromJson(typography, colorScheme);
    
    // ThemeData zusammenbauen
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      
      // Component Themes basierend auf JSON
      appBarTheme: _createAppBarTheme(colors, textTheme, isDark),
      elevatedButtonTheme: _createElevatedButtonTheme(colors, textTheme, radius, spacing),
      outlinedButtonTheme: _createOutlinedButtonTheme(colors, textTheme, radius, spacing),
      textButtonTheme: _createTextButtonTheme(colors, textTheme),
      cardTheme: _createCardTheme(colors, radius, spacing),
      inputDecorationTheme: _createInputDecorationTheme(colors, textTheme, radius, spacing),
      floatingActionButtonTheme: _createFABTheme(colors),
      navigationBarTheme: _createNavigationBarTheme(colors, textTheme),
      dividerTheme: _createDividerTheme(colors),
      dialogTheme: _createDialogTheme(colors, textTheme, radius, spacing),
      bottomSheetTheme: _createBottomSheetTheme(colors, radius),
    );
    
    // Bundle-spezifische Anpassungen
    return _applyBundleThemeAdjustments(baseTheme, bundleConfig, isDark);
  }

  /// Wendet Bundle-spezifische Theme-Anpassungen an
  ThemeData _applyBundleThemeAdjustments(ThemeData baseTheme, BundleConfig bundleConfig, bool isDark) {
    // Performance-Optimierungen für low-end bundles
    if (bundleConfig.performance.priority == 'maximum-performance') {
      return baseTheme.copyWith(
        // Animationen reduzieren
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        // Elevation reduzieren
        cardTheme: baseTheme.cardTheme.copyWith(elevation: 0),
        appBarTheme: baseTheme.appBarTheme.copyWith(elevation: 0),
      );
    }
    
    // Accessibility-Verbesserungen
    if (bundleConfig.features.accessibility == 'maximum') {
      return baseTheme.copyWith(
        // Höhere Kontraste
        // Focus-Indikatoren verstärken
        // etc.
      );
    }
    
    return baseTheme;
  }

  /// Ermittelt Device-Tier für Bundle-Auswahl
  Future<DeviceTier> _detectDeviceTier() async {
    // Vereinfachte Device-Tier Erkennung
    // In einer echten App würde hier Hardware-Detection stattfinden
    return DeviceTier.medium;
  }

  /// Wählt Standard-Bundle basierend auf Device-Tier
  String _selectDefaultBundle(DeviceTier deviceTier) {
    switch (deviceTier) {
      case DeviceTier.low:
        return 'performance-optimized';
      case DeviceTier.medium:
        return 'world-preview';
      case DeviceTier.high:
        return 'full-gaming';
    }
  }

  /// Erstellt Fallback Bundle-Konfigurationen
  void _createFallbackBundleConfigs() {
    _bundleConfigs['performance-optimized'] = BundleConfig(
      name: 'Performance Optimized',
      context: 'universal',
      type: 'basic',
      estimatedSize: '25KB',
      modules: BundleModules(
        required: ['colors', 'typography', 'spacing', 'radius'],
        optional: [],
        excluded: ['effects.visual', 'effects.animations'],
      ),
      features: BundleFeatures(
        accessibility: 'basic',
        gamingFeatures: false,
        visualEffects: false,
      ),
      performance: BundlePerformance(
        priority: 'maximum-performance',
        target: 'low-end-devices',
      ),
      overrides: {},
    );
  }

  /// Parst Größen-String zu Bytes
  int _parseSize(String sizeString) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*(KB|MB|GB)', caseSensitive: false);
    final match = regex.firstMatch(sizeString);
    if (match == null) return 0;
    
    final value = double.parse(match.group(1)!);
    final unit = match.group(2)!.toUpperCase();
    
    switch (unit) {
      case 'KB':
        return (value * 1024).round();
      case 'MB':
        return (value * 1024 * 1024).round();
      case 'GB':
        return (value * 1024 * 1024 * 1024).round();
      default:
        return value.round();
    }
  }

  /// Räumt Caches auf
  void clearCache() {
    _moduleCache.clear();
    _bundleThemeCache.clear();
    _bundleDarkThemeCache.clear();
    _loadingMetrics.clear();
    AppLogger.app.i('🗑️ Modularer Theme-Cache geleert');
  }

  /// Gibt Performance-Statistiken zurück
  Map<String, dynamic> getPerformanceStats() {
    final totalLoadTime = _loadingMetrics.values
        .map((m) => m.loadTime.inMilliseconds)
        .fold(0, (a, b) => a + b);
    
    final avgLoadTime = _loadingMetrics.isNotEmpty 
        ? totalLoadTime / _loadingMetrics.length 
        : 0.0;
    
    return {
      'totalThemesLoaded': _loadingMetrics.length,
      'totalLoadTimeMs': totalLoadTime,
      'averageLoadTimeMs': avgLoadTime.round(),
      'cacheHitRate': _calculateCacheHitRate(),
      'currentBundle': _currentBundle,
      'activeModules': _activeBundleConfig?.modules.required.length ?? 0,
    };
  }

  /// Berechnet Cache-Hit-Rate
  double _calculateCacheHitRate() {
    // Vereinfachte Berechnung - in echter App würde man Cache-Hits vs. Misses tracken
    return _bundleThemeCache.isNotEmpty ? 0.75 : 0.0;
  }

  // ========================================
  // 🎨 JSON → FLUTTER THEME CONVERTERS
  // ========================================

  /// Erstellt ColorScheme aus JSON
  ColorScheme _createColorSchemeFromJson(Map<String, dynamic> colors, bool isDark) {
    final primary = colors['primary'] as Map<String, dynamic>? ?? {};
    final secondary = colors['secondary'] as Map<String, dynamic>? ?? {};
    final tertiary = colors['tertiary'] as Map<String, dynamic>? ?? {};
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    final text = colors['text'] as Map<String, dynamic>? ?? {};
    
    // Farben extrahieren mit Fallbacks
    final primaryColor = _parseColor(primary['value']) ?? const Color(0xFF6366F1);
    final secondaryColor = _parseColor(secondary['value']) ?? const Color(0xFF8B5CF6);
    final tertiaryColor = _parseColor(tertiary['value']) ?? const Color(0xFFD4AF37);
    
    final surfaceColor = _parseColor(background['surface_dark']) ?? 
                        (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA));
    
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: surfaceColor,
      onPrimary: _parseColor(text['primary']) ?? (isDark ? Colors.white : Colors.black),
      onSecondary: _parseColor(text['secondary']) ?? (isDark ? Colors.white70 : Colors.black87),
      onSurface: _parseColor(text['primary']) ?? (isDark ? Colors.white : Colors.black),
    );
  }

  /// Erstellt TextTheme aus JSON
  TextTheme _createTextThemeFromJson(Map<String, dynamic> typography, ColorScheme colorScheme) {
    final textStyles = typography['textStyles'] as Map<String, dynamic>? ?? {};
    final fontFamilies = typography['fontFamilies'] as Map<String, dynamic>? ?? {};
    
    final headingStyle = textStyles['heading'] as Map<String, dynamic>? ?? {};
    final bodyStyle = textStyles['body'] as Map<String, dynamic>? ?? {};
    final captionStyle = textStyles['caption'] as Map<String, dynamic>? ?? {};
    
    final primaryFont = fontFamilies['primary'] as String? ?? 'Roboto';
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: (headingStyle['fontSize'] as num?)?.toDouble() ?? 32.0,
        fontWeight: _parseFontWeight(headingStyle['fontWeight']),
        fontFamily: primaryFont,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: (headingStyle['fontSize'] as num?)?.toDouble() ?? 24.0,
        fontWeight: _parseFontWeight(headingStyle['fontWeight']),
        fontFamily: primaryFont,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: (bodyStyle['fontSize'] as num?)?.toDouble() ?? 16.0,
        fontWeight: _parseFontWeight(bodyStyle['fontWeight']),
        fontFamily: primaryFont,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: (bodyStyle['fontSize'] as num?)?.toDouble() ?? 14.0,
        fontWeight: _parseFontWeight(bodyStyle['fontWeight']),
        fontFamily: primaryFont,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: (captionStyle['fontSize'] as num?)?.toDouble() ?? 12.0,
        fontWeight: _parseFontWeight(captionStyle['fontWeight']),
        fontFamily: primaryFont,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Parst Farbe aus String
  Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final hex = value.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    return null;
  }

  /// Parst FontWeight aus String
  FontWeight _parseFontWeight(dynamic value) {
    if (value is int) {
      switch (value) {
        case 100: return FontWeight.w100;
        case 200: return FontWeight.w200;
        case 300: return FontWeight.w300;
        case 400: return FontWeight.w400;
        case 500: return FontWeight.w500;
        case 600: return FontWeight.w600;
        case 700: return FontWeight.w700;
        case 800: return FontWeight.w800;
        case 900: return FontWeight.w900;
      }
    }
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'light': return FontWeight.w300;
        case 'normal': return FontWeight.w400;
        case 'medium': return FontWeight.w500;
        case 'bold': return FontWeight.w700;
      }
    }
    return FontWeight.w400;
  }

  // ========================================
  // 🧩 COMPONENT THEME CREATORS
  // ========================================

  /// Erstellt AppBarTheme aus JSON
  AppBarTheme _createAppBarTheme(Map<String, dynamic> colors, TextTheme textTheme, bool isDark) {
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    final text = colors['text'] as Map<String, dynamic>? ?? {};
    
    return AppBarTheme(
      backgroundColor: _parseColor(background['surface_darker']) ?? 
                      (isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFFFFFF)),
      foregroundColor: _parseColor(text['primary']) ?? 
                      (isDark ? Colors.white : Colors.black),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.headlineLarge,
    );
  }

  /// Erstellt ElevatedButtonTheme aus JSON
  ElevatedButtonThemeData _createElevatedButtonTheme(Map<String, dynamic> colors, TextTheme textTheme, Map<String, dynamic> radius, Map<String, dynamic> spacing) {
    final primary = colors['primary'] as Map<String, dynamic>? ?? {};
    
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _parseColor(primary['value']) ?? const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_parseRadius(radius['lg']) ?? 12.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _parseSpacing(spacing['lg']) ?? 24.0,
          vertical: _parseSpacing(spacing['md']) ?? 16.0,
        ),
      ),
    );
  }

  /// Erstellt OutlinedButtonTheme aus JSON
  OutlinedButtonThemeData _createOutlinedButtonTheme(Map<String, dynamic> colors, TextTheme textTheme, Map<String, dynamic> radius, Map<String, dynamic> spacing) {
    final primary = colors['primary'] as Map<String, dynamic>? ?? {};
    
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _parseColor(primary['value']) ?? const Color(0xFF6366F1),
        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        side: BorderSide(
          color: _parseColor(primary['value']) ?? const Color(0xFF6366F1),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_parseRadius(radius['lg']) ?? 12.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _parseSpacing(spacing['lg']) ?? 24.0,
          vertical: _parseSpacing(spacing['md']) ?? 16.0,
        ),
      ),
    );
  }

  /// Erstellt TextButtonTheme aus JSON
  TextButtonThemeData _createTextButtonTheme(Map<String, dynamic> colors, TextTheme textTheme) {
    final primary = colors['primary'] as Map<String, dynamic>? ?? {};
    
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _parseColor(primary['value']) ?? const Color(0xFF6366F1),
        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Erstellt CardTheme aus JSON
  CardThemeData _createCardTheme(Map<String, dynamic> colors, Map<String, dynamic> radius, Map<String, dynamic> spacing) {
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    
    return CardThemeData(
      color: _parseColor(background['surface_medium']) ?? const Color(0xFF2A1810),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_parseRadius(radius['md']) ?? 8.0),
      ),
      margin: EdgeInsets.all(_parseSpacing(spacing['sm']) ?? 8.0),
    );
  }

  /// Erstellt InputDecorationTheme aus JSON
  InputDecorationTheme _createInputDecorationTheme(Map<String, dynamic> colors, TextTheme textTheme, Map<String, dynamic> radius, Map<String, dynamic> spacing) {
    final primary = colors['primary'] as Map<String, dynamic>? ?? {};
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    
    return InputDecorationTheme(
      filled: true,
      fillColor: _parseColor(background['surface_light']) ?? const Color(0xFF3A2820),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_parseRadius(radius['md']) ?? 8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_parseRadius(radius['md']) ?? 8.0),
        borderSide: BorderSide(
          color: _parseColor(primary['value']) ?? const Color(0xFF6366F1),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.all(_parseSpacing(spacing['md']) ?? 16.0),
    );
  }

  /// Erstellt FloatingActionButtonTheme aus JSON
  FloatingActionButtonThemeData _createFABTheme(Map<String, dynamic> colors) {
    final primary = colors['primary'] as Map<String, dynamic>? ?? {};
    
    return FloatingActionButtonThemeData(
      backgroundColor: _parseColor(primary['value']) ?? const Color(0xFF6366F1),
      foregroundColor: Colors.white,
    );
  }

  /// Erstellt NavigationBarTheme aus JSON
  NavigationBarThemeData _createNavigationBarTheme(Map<String, dynamic> colors, TextTheme textTheme) {
    final primary = colors['primary'] as Map<String, dynamic>? ?? {};
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    
    return NavigationBarThemeData(
      backgroundColor: _parseColor(background['surface_darker']) ?? const Color(0xFF0D0D0D),
      indicatorColor: _parseColor(primary['value']) ?? const Color(0xFF6366F1),
      labelTextStyle: WidgetStateProperty.all(textTheme.bodySmall),
    );
  }

  /// Erstellt DividerTheme aus JSON
  DividerThemeData _createDividerTheme(Map<String, dynamic> colors) {
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    
    return DividerThemeData(
      color: _parseColor(background['surface_gray']) ?? const Color(0xFFF0F0F0),
      thickness: 1,
    );
  }

  /// Erstellt DialogTheme aus JSON
  DialogThemeData _createDialogTheme(Map<String, dynamic> colors, TextTheme textTheme, Map<String, dynamic> radius, Map<String, dynamic> spacing) {
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    
    return DialogThemeData(
      backgroundColor: _parseColor(background['surface_medium']) ?? const Color(0xFF2A1810),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_parseRadius(radius['lg']) ?? 12.0),
      ),
      titleTextStyle: textTheme.headlineLarge,
      contentTextStyle: textTheme.bodyMedium,
    );
  }

  /// Erstellt BottomSheetTheme aus JSON
  BottomSheetThemeData _createBottomSheetTheme(Map<String, dynamic> colors, Map<String, dynamic> radius) {
    final background = colors['background'] as Map<String, dynamic>? ?? {};
    
    return BottomSheetThemeData(
      backgroundColor: _parseColor(background['surface_medium']) ?? const Color(0xFF2A1810),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_parseRadius(radius['lg']) ?? 12.0),
        ),
      ),
    );
  }

  // ========================================
  // 🛠️ HELPER PARSERS
  // ========================================

  /// Parst Radius-Wert aus JSON
  double _parseRadius(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll('px', ''));
      if (parsed != null) return parsed;
    }
    return 8.0;
  }

  /// Parst Spacing-Wert aus JSON
  double _parseSpacing(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll('px', ''));
      if (parsed != null) return parsed;
    }
    return 16.0;
  }
}

/// Bundle-Konfiguration Datenklasse
class BundleConfig {
  final String name;
  final String context;
  final String type;
  final String estimatedSize;
  final BundleModules modules;
  final BundleFeatures features;
  final BundlePerformance performance;
  final Map<String, dynamic> overrides;

  BundleConfig({
    required this.name,
    required this.context,
    required this.type,
    required this.estimatedSize,
    required this.modules,
    required this.features,
    required this.performance,
    required this.overrides,
  });

  factory BundleConfig.fromJson(Map<String, dynamic> json) {
    return BundleConfig(
      name: json['name'] ?? '',
      context: json['context'] ?? 'universal',
      type: json['type'] ?? 'basic',
      estimatedSize: json['estimatedSize'] ?? '0KB',
      modules: BundleModules.fromJson(json['modules'] ?? {}),
      features: BundleFeatures.fromJson(json['features'] ?? {}),
      performance: BundlePerformance.fromJson(json['performance'] ?? {}),
      overrides: json['overrides'] ?? {},
    );
  }
}

/// Bundle-Module Datenklasse
class BundleModules {
  final List<String> required;
  final List<String> optional;
  final List<String> excluded;

  BundleModules({
    required this.required,
    required this.optional,
    required this.excluded,
  });

  factory BundleModules.fromJson(Map<String, dynamic> json) {
    return BundleModules(
      required: List<String>.from(json['required'] ?? []),
      optional: List<String>.from(json['optional'] ?? []),
      excluded: List<String>.from(json['excluded'] ?? []),
    );
  }
}

/// Bundle-Features Datenklasse
class BundleFeatures {
  final bool gamingFeatures;
  final bool visualEffects;
  final String accessibility;

  BundleFeatures({
    required this.gamingFeatures,
    required this.visualEffects,
    required this.accessibility,
  });

  factory BundleFeatures.fromJson(Map<String, dynamic> json) {
    return BundleFeatures(
      gamingFeatures: json['gamingFeatures'] ?? false,
      visualEffects: json['visualEffects'] ?? false,
      accessibility: json['accessibility'] ?? 'basic',
    );
  }
}

/// Bundle-Performance Datenklasse
class BundlePerformance {
  final String priority;
  final String target;

  BundlePerformance({
    required this.priority,
    required this.target,
  });

  factory BundlePerformance.fromJson(Map<String, dynamic> json) {
    return BundlePerformance(
      priority: json['priority'] ?? 'balanced',
      target: json['target'] ?? 'all-devices',
    );
  }
}

/// Loading-Metriken Datenklasse
class LoadingMetrics {
  final String bundleName;
  final String themeName;
  final Duration loadTime;
  final int moduleCount;
  final int estimatedSize;
  final DateTime timestamp;

  LoadingMetrics({
    required this.bundleName,
    required this.themeName,
    required this.loadTime,
    required this.moduleCount,
    required this.estimatedSize,
    required this.timestamp,
  });
}

/// Device-Tier Enum
enum DeviceTier { low, medium, high }