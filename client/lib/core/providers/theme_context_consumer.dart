import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/theme_helper.dart';
import '../../config/logger.dart';

/// 🎭 Theme Context Consumer - Component-Level Theme Overrides
/// 
/// Ermöglicht es einzelnen Komponenten, das Page-Level Theme zu überschreiben.
/// Verwendet die neue saubere Architektur:
/// 
/// ThemeRootProvider (global)
/// └── ThemePageProvider (page-level)  
///     └── ThemeContextConsumer (component-level overrides)
class ThemeContextConsumer extends StatefulWidget {
  /// Name der Komponente für Debugging
  final String componentName;
  
  /// Builder-Funktion die das Theme erhält
  final Widget Function(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) builder;
  
  /// Context-Overrides für diese spezifische Komponente
  final Map<String, String>? contextOverrides;
  
  /// World-spezifisches Theme Override (für World Cards, etc.)
  final String? worldThemeOverride;
  
  /// Fallback Bundle falls alle anderen Themes fehlschlagen  
  final String? fallbackBundle;

  const ThemeContextConsumer({
    super.key,
    required this.componentName,
    required this.builder,
    this.contextOverrides,
    this.worldThemeOverride,
    this.fallbackBundle,
  });

  @override
  State<ThemeContextConsumer> createState() => _ThemeContextConsumerState();
}

class _ThemeContextConsumerState extends State<ThemeContextConsumer> {
  ThemeData? _cachedTheme;
  ThemeData? _cachedDarkTheme;
  Map<String, dynamic>? _cachedExtensions;
  bool _isLoading = false;
  
  // Fix: Cache Future to prevent recreation on every build
  Future<ThemeData>? _cachedThemeFuture;
  Future<ThemeData>? _cachedDarkThemeFuture;

  @override
  void initState() {
    super.initState();
    _loadTheme(isDark: false);
  }

  @override
  void didUpdateWidget(ThemeContextConsumer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reload theme wenn sich Context-Parameter ändern
    if (oldWidget.contextOverrides != widget.contextOverrides ||
        oldWidget.worldThemeOverride != widget.worldThemeOverride ||
        oldWidget.fallbackBundle != widget.fallbackBundle) {
      // Fix: Clear cached futures to force reload
      _cachedThemeFuture = null;
      _cachedDarkThemeFuture = null;
      _cachedTheme = null;
      _cachedDarkTheme = null;
      _loadTheme(isDark: false);
    }
  }

  /// 🔄 Theme laden (async)
  Future<void> _loadTheme({required bool isDark}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.app.d('🎭 Loading theme for ${widget.componentName}');
      
      ThemeData? resolvedTheme;
      
      // 🌍 1. WORLD THEME OVERRIDE (höchste Priorität)
      final worldThemeOverride = widget.worldThemeOverride;
      if (worldThemeOverride != null) {
        resolvedTheme = await _loadWorldTheme(worldThemeOverride, isDark: isDark);
        if (resolvedTheme != null) {
          AppLogger.app.d('🌍 Using world theme override: $worldThemeOverride');
        }
      }
      
      // 🎯 2. CONTEXT OVERRIDES  
      final contextOverrides = widget.contextOverrides;
      if (resolvedTheme == null && contextOverrides != null) {
        resolvedTheme = await ThemeHelper.getCurrentTheme(
          context, 
          isDark: isDark, 
          contextOverrides: contextOverrides,
        );
        AppLogger.app.d('🎯 Using context override theme');
      }
      
      // 🎨 3. PAGE/GLOBAL THEME
      resolvedTheme ??= await ThemeHelper.getCurrentTheme(context, isDark: isDark);
      
      // 🔄 4. FALLBACK BUNDLE - Additional safety (rarely needed but available)
      final fallbackBundle = widget.fallbackBundle;
      if (fallbackBundle != null && resolvedTheme == null) {
        // Direkt über ModularThemeService laden
        final themeService = ThemeHelper.themeService;
        final fallbackTheme = await themeService.getBundle(fallbackBundle, isDark: isDark);
        if (fallbackTheme != null) {
          resolvedTheme = fallbackTheme;
          AppLogger.app.d('🔄 Using fallback bundle: $fallbackBundle');
        }
      }
      
      // ⚠️ 5. FLUTTER DEFAULT als letzter Ausweg
      resolvedTheme ??= Theme.of(context);
      
      setState(() {
        if (isDark) {
          _cachedDarkTheme = resolvedTheme;
        } else {
          _cachedTheme = resolvedTheme;
        }
        _isLoading = false;
      });
      
    } catch (e) {
      AppLogger.app.e('❌ Error loading theme for ${widget.componentName}', error: e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 🌍 Private: World-spezifisches Theme laden
  Future<ThemeData?> _loadWorldTheme(String worldTheme, {required bool isDark}) async {
    try {
      // ✅ DYNAMISCH: Bundle-Name aus Theme-Schema laden
      final bundleName = await _getBundleForThemeDynamic(worldTheme);
      final themeService = ThemeHelper.themeService;
      
      AppLogger.app.d('🌍 Loading world theme: $worldTheme → Bundle: $bundleName');
      return await themeService.getBundle(bundleName, themeName: worldTheme, isDark: isDark);
      
    } catch (e) {
      AppLogger.app.e('❌ Error loading world theme: $worldTheme', error: e);
      return null;
    }
  }

  /// 🎯 Private: Bundle für World-Theme dynamisch bestimmen (aus Theme-Schema)
  Future<String> _getBundleForThemeDynamic(String themeName) async {
    try {
      // 1. Theme-Schema von Server laden
      final themeSchema = await _loadThemeSchema(themeName);
      
      // 2. Bundle-Name DIREKT aus Schema lesen - KEINE Mappings!
      final bundleName = themeSchema['bundle']?['name'] as String?;
      
      if (bundleName != null && bundleName.isNotEmpty) {
        AppLogger.app.d('✅ Found bundle name in schema: $themeName → $bundleName');
        return bundleName;
      }
      
      // 3. Fallback falls bundle.name nicht definiert
      AppLogger.app.w('⚠️ No bundle.name in schema for $themeName, using fallback');
      return 'world-preview';
      
    } catch (e) {
      AppLogger.app.w('⚠️ Could not load theme schema for $themeName, using fallback', error: e);
      return 'world-preview'; // Fallback
    }
  }

  /// 🔄 Private: Theme-Schema von Server laden
  Future<Map<String, dynamic>> _loadThemeSchema(String themeName) async {
    final url = 'http://192.168.2.168:3000/theme-editor/schemas/$themeName.json';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Theme schema not found: $themeName');
    }
  }





  @override
  Widget build(BuildContext context) {
    // Bestimme aktuellen Dark Mode - verwende MediaQuery statt Theme.of(context)
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    
    // Fix: Use cached Future to prevent recreation on every build
    final themeFuture = isDark ? _cachedDarkThemeFuture : _cachedThemeFuture;
    
    // If we have a cached theme, return it immediately
    final cachedTheme = isDark ? _cachedDarkTheme : _cachedTheme;
    if (cachedTheme != null) {
      return widget.builder(context, cachedTheme, _cachedExtensions);
    }
    
    // Only use FutureBuilder if we don't have a cached theme
    if (themeFuture != null) {
      return FutureBuilder<ThemeData>(
        future: themeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          }
          
          if (snapshot.hasError) {
            print('❌ [THEME-DEBUG] Theme loading failed for ${widget.componentName}: ${snapshot.error}');
            return widget.builder(context, Theme.of(context), _cachedExtensions);
          }
          
          final effectiveTheme = snapshot.data ?? Theme.of(context);
          return widget.builder(context, effectiveTheme, _cachedExtensions);
        },
      );
    }
    
    // Fallback: Load theme and return default while loading
    _initializeTheme(isDark);
    return widget.builder(context, Theme.of(context), _cachedExtensions);
  }

  /// Initialize theme loading and cache the Future
  void _initializeTheme(bool isDark) {
    if (isDark) {
      _cachedDarkThemeFuture ??= _getEffectiveTheme(isDark);
    } else {
      _cachedThemeFuture ??= _getEffectiveTheme(isDark);
    }
  }

  /// 🔄 Get Effective Theme mit async loading
  Future<ThemeData> _getEffectiveTheme(bool isDark) async {
    // 1. Cached theme falls verfügbar
    final cachedTheme = isDark ? _cachedDarkTheme : _cachedTheme;
    if (cachedTheme != null) {
      return cachedTheme;
    }

    // 2. World Theme Override hat Priorität
    final worldThemeOverride = widget.worldThemeOverride;
    if (worldThemeOverride != null) {
      final worldTheme = await _loadWorldTheme(worldThemeOverride, isDark: isDark);
      if (worldTheme != null) {
        if (mounted) {
          setState(() {
            if (isDark) {
              _cachedDarkTheme = worldTheme;
            } else {
              _cachedTheme = worldTheme;
            }
          });
        }
        return worldTheme;
      }
    }

    // 3. ThemeHelper für Page/Global Context
    try {
      final theme = await ThemeHelper.getCurrentTheme(context, isDark: isDark);
      if (mounted) {
        setState(() {
          if (isDark) {
            _cachedDarkTheme = theme;
          } else {
            _cachedTheme = theme;
          }
        });
      }
      return theme;
    } catch (e) {
      print('❌ [THEME-DEBUG] ThemeHelper failed for ${widget.componentName}: $e');
    }

    // 4. Fallback Bundle als letzter Ausweg
    final fallbackBundle = widget.fallbackBundle;
    if (fallbackBundle != null) {
      try {
        final themeService = ThemeHelper.themeService;
        final fallbackTheme = await themeService.getBundle(fallbackBundle, isDark: isDark);
        if (fallbackTheme != null) {
          print('🔄 [THEME-DEBUG] Using fallback bundle: $fallbackBundle');
          return fallbackTheme;
        }
      } catch (e) {
        print('❌ [THEME-DEBUG] Fallback bundle failed: $fallbackBundle - $e');
      }
    }

    // 5. Flutter Default als allerletzter Ausweg
    return Theme.of(context);
  }

  /// 🔄 Loading Widget während Theme lädt
  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            SizedBox(height: 16),
            Text(
              'Lade Theme...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}