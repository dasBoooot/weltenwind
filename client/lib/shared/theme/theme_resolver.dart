library;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/logger.dart';
import '../../config/env.dart';
import '../../core/models/world.dart';
import '../../core/services/named_entrypoints_service.dart';
import '../services/dynamic_asset_service.dart';
import 'models/world_theme.dart';
import 'models/theme_bundle.dart';
import 'models/named_entrypoints.dart';

class ThemeResolver {
  static final ThemeResolver _instance = ThemeResolver._internal();
  factory ThemeResolver() => _instance;
  ThemeResolver._internal();

  final Map<String, ThemeBundle> _bundleCache = {};
  final Map<String, WorldTheme> _themeCache = {};
  final Map<String, Map<String, dynamic>> _themeJsonCache = {};
  final Map<String, NamedEntrypointResponse> _namedEntrypointCache = {};
  final Map<String, String?> _backgroundCache = {};
  
  // Named Entrypoints Service
  final NamedEntrypointsService _namedEntrypointsService = NamedEntrypointsService();

  /// Resolve theme for a specific world using Named Entrypoints
  Future<ThemeData> resolveWorldTheme(
    World world, {
    bool isDarkMode = false,
    String? userPreferredVariant,
    String context = 'pre-game',
  }) async {
    try {
      AppLogger.app.d('🎯 Resolving theme for world: ${world.name} (${world.id}) in context: $context');

      // 1. Try to get world-specific theme from Named Entrypoints
      final namedEntrypointTheme = await _getNamedEntrypointTheme(world.themeBundle ?? 'default', context, isDarkMode);
      if (namedEntrypointTheme != null) {
        AppLogger.app.d('✅ Found Named Entrypoint theme for context: $context');
        return namedEntrypointTheme;
      }

      // 2. Try to get world-specific theme (legacy)
      final worldTheme = await _getWorldTheme(world, isDarkMode);
      if (worldTheme != null) {
        AppLogger.app.d('✅ Found world-specific theme (legacy)');
        return worldTheme;
      }

      // 3. Try to get theme from bundle
      if (world.themeBundle != null) {
        final bundleTheme = await _getBundleTheme(
          world.themeBundle!,
          world.themeVariant ?? userPreferredVariant,
          isDarkMode,
        );
        if (bundleTheme != null) {
          AppLogger.app.d('✅ Found bundle theme: ${world.themeBundle}');
          return bundleTheme;
        }
      }

      // 4. Try parent theme
      if (world.parentTheme != null) {
        final parentTheme = await _getParentTheme(world.parentTheme!, isDarkMode);
        if (parentTheme != null) {
          AppLogger.app.d('✅ Found parent theme: ${world.parentTheme}');
          return parentTheme;
        }
      }

      // 5. Apply theme overrides to fallback
      final fallbackTheme = await _getFallbackTheme(isDarkMode);
      if (world.themeOverrides != null && world.themeOverrides!.isNotEmpty) {
        AppLogger.app.d('🎨 Applying theme overrides to fallback');
        return _applyThemeOverrides(fallbackTheme, world.themeOverrides!);
      }

      AppLogger.app.d('⚡ Using fallback theme');
      return fallbackTheme;

    } catch (e) {
      AppLogger.app.e('❌ Theme resolution failed for world ${world.id}: $e');
      return await _getFallbackTheme(isDarkMode);
    }
  }

  /// Get world-specific theme
  Future<ThemeData?> _getWorldTheme(World world, bool isDarkMode) async {
    final cacheKey = 'world_${world.id}_${isDarkMode ? 'dark' : 'light'}';
    
    // Check cache first
    final cachedTheme = _themeCache[cacheKey];
    if (cachedTheme != null) {
      final themeData = isDarkMode ? cachedTheme.darkThemeData : cachedTheme.lightThemeData;
      if (themeData != null) return themeData;
    }

    // TODO: Load from API/storage
    // For now, return null (no world-specific theme)
    return null;
  }

  /// Get theme from bundle
  Future<ThemeData?> _getBundleTheme(
    String bundleId,
    String? variant,
    bool isDarkMode,
  ) async {
    try {
      final bundle = await _loadBundle(bundleId);
      if (bundle == null) return null;

      // Find theme with matching variant
      final theme = bundle.themes.firstWhere(
        (t) => t.variant == (variant ?? 'default'),
        orElse: () => bundle.themes.first,
      );

      return isDarkMode ? theme.darkThemeData : theme.lightThemeData;
    } catch (e) {
      AppLogger.app.e('❌ Failed to get bundle theme: $e');
      return null;
    }
  }

  /// Load theme bundle from backend
  Future<ThemeBundle?> _loadBundle(String bundleId) async {
    // Check cache first
    if (_bundleCache.containsKey(bundleId)) {
      return _bundleCache[bundleId];
    }

    // Load from backend API
    final bundle = await _loadThemeFromBackend(bundleId);
    if (bundle != null) {
      _bundleCache[bundleId] = bundle;
    }

    return bundle;
  }

  /// Load theme from backend API
  Future<ThemeBundle?> _loadThemeFromBackend(String themeName) async {
    try {
      // Check cache first
      if (_themeJsonCache.containsKey(themeName)) {
        return _createBundleFromJson(themeName, _themeJsonCache[themeName]!);
      }

      // Load from backend API
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/api/themes/$themeName'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        // Cache the JSON data
        _themeJsonCache[themeName] = jsonData;
        
        return _createBundleFromJson(themeName, jsonData);
      } else {
        AppLogger.app.w('⚠️ Failed to load theme from backend: $themeName (${response.statusCode})');
        return null;
      }
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to load theme from backend: $themeName: $e');
      
      // Fallback: Try to load from local assets (for development/testing)
      return await _loadThemeFromLocalAssets(themeName);
    }
  }

  /// Load theme from local assets (fallback for development)
  Future<ThemeBundle?> _loadThemeFromLocalAssets(String themeName) async {
    try {
      // This is only for development/testing when backend is not available
      AppLogger.app.d('🔄 Loading theme from local assets (fallback): $themeName');
      
      // For now, return null - we'll implement this later if needed
      return null;
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to load theme from local assets: $themeName: $e');
      return null;
    }
  }

  /// Create bundle from JSON data
  ThemeBundle? _createBundleFromJson(String themeName, Map<String, dynamic> jsonData) {
    try {
      final name = jsonData['name'] as String? ?? themeName;
      final description = jsonData['description'] as String? ?? '';
      final category = jsonData['category'] as String? ?? 'default';
      
      // Create theme data from JSON
      final lightTheme = _createThemeDataFromJson(jsonData, false);
      final darkTheme = _createThemeDataFromJson(jsonData, true);
      
      return ThemeBundle(
        id: themeName,
        name: name,
        description: description,
        category: category,
        themes: [
          WorldTheme(
            id: '${themeName}_default',
            name: name,
            worldId: 0,
            variant: 'default',
            lightThemeData: lightTheme,
            darkThemeData: darkTheme,
          ),
        ],
      );
    } catch (e) {
      AppLogger.app.e('❌ Failed to create bundle from JSON: $themeName: $e');
      return null;
    }
  }

  /// Create ThemeData from JSON with full theme support
  ThemeData _createThemeDataFromJson(Map<String, dynamic> jsonData, bool isDark) {
    final colors = jsonData['colors'] as Map<String, dynamic>? ?? {};
    final fonts = jsonData['fonts'] as Map<String, dynamic>? ?? {};
    final typography = jsonData['typography'] as Map<String, dynamic>? ?? {};
    final spacing = jsonData['spacing'] as Map<String, dynamic>? ?? {};
    final radius = jsonData['radius'] as Map<String, dynamic>? ?? {};
    final effects = jsonData['effects'] as Map<String, dynamic>? ?? {};
    
    // Extract all colors
    final primaryColors = colors['primary'] as Map<String, dynamic>? ?? {};
    final secondaryColors = colors['secondary'] as Map<String, dynamic>? ?? {};
    final tertiaryColors = colors['tertiary'] as Map<String, dynamic>? ?? {};
    final backgroundColors = colors['background'] as Map<String, dynamic>? ?? {};
    final textColors = colors['text'] as Map<String, dynamic>? ?? {};
    final statusColors = colors['status'] as Map<String, dynamic>? ?? {};
    final borderColors = colors['border'] as Map<String, dynamic>? ?? {};
    final interactiveColors = colors['interactive'] as Map<String, dynamic>? ?? {};
    
    // Parse all color variants
    final primary = _parseColor(primaryColors['main'] ?? '#5F4B8B');
    final primaryLight = _parseColor(primaryColors['light'] ?? primaryColors['main'] ?? '#8E79B9');
    final primaryDark = _parseColor(primaryColors['dark'] ?? primaryColors['main'] ?? '#3F2C5E');
    final onPrimary = _parseColor(primaryColors['contrast'] ?? '#FFFFFF');
    
    final secondary = _parseColor(secondaryColors['main'] ?? '#A3D9B1');
    final secondaryLight = _parseColor(secondaryColors['light'] ?? secondaryColors['main'] ?? '#C8E9CE');
    final secondaryDark = _parseColor(secondaryColors['dark'] ?? secondaryColors['main'] ?? '#6DA884');
    final onSecondary = _parseColor(secondaryColors['contrast'] ?? '#0D1117');
    
    final tertiary = _parseColor(tertiaryColors['main'] ?? '#62757F');
    final tertiaryLight = _parseColor(tertiaryColors['light'] ?? tertiaryColors['main'] ?? '#94A3AC');
    final tertiaryDark = _parseColor(tertiaryColors['dark'] ?? tertiaryColors['main'] ?? '#42535C');
    final onTertiary = _parseColor(tertiaryColors['contrast'] ?? '#FFFFFF');
    
    // Background colors
    final background = _parseColor(backgroundColors['primary'] ?? '#0A0C10');
    final backgroundSecondary = _parseColor(backgroundColors['secondary'] ?? '#13161D');
    final surface = isDark 
        ? _parseColor(backgroundColors['surface_dark'] ?? '#1B1F27')
        : _parseColor(backgroundColors['surface_light'] ?? '#F8FAFC');
    final surfaceVariant = isDark
        ? _parseColor(backgroundColors['surface_light'] ?? '#2A2F3F')
        : _parseColor(backgroundColors['surface_dark'] ?? '#1B1F27');
    final overlay = _parseColor(backgroundColors['overlay'] ?? 'rgba(10, 12, 16, 0.8)');
    
    // Text colors
    final onSurface = _parseColor(textColors['primary'] ?? '#E2E8F0');
    final onSurfaceVariant = _parseColor(textColors['secondary'] ?? '#B9C1CC');
    final onSurfaceMuted = _parseColor(textColors['muted'] ?? '#7B8591');
    final onSurfaceInverse = _parseColor(textColors['inverse'] ?? '#0A0C10');
    final onSurfaceLink = _parseColor(textColors['link'] ?? '#8E79B9');
    
    // Status colors
    final error = _parseColor(statusColors['error'] ?? '#EF4444');
    final success = _parseColor(statusColors['success'] ?? '#10B981');
    final warning = _parseColor(statusColors['warning'] ?? '#F59E0B');
    final info = _parseColor(statusColors['info'] ?? '#3B82F6');
    
    // Border colors
    final outline = _parseColor(borderColors['primary'] ?? '#30363D');
    final outlineVariant = _parseColor(borderColors['secondary'] ?? '#21262D');
    final outlineAccent = _parseColor(borderColors['accent'] ?? '#8E79B9');
    final outlineMuted = _parseColor(borderColors['muted'] ?? '#6B7280');
    
    // Interactive colors
    final hoverColor = _parseColor(interactiveColors['hover'] ?? 'rgba(143, 121, 185, 0.08)');
    final activeColor = _parseColor(interactiveColors['active'] ?? 'rgba(143, 121, 185, 0.15)');
    final focusColor = _parseColor(interactiveColors['focus'] ?? 'rgba(143, 121, 185, 0.3)');
    final disabledColor = _parseColor(interactiveColors['disabled'] ?? '#7B8591');
    
    // Create comprehensive ColorScheme
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryLight,
      onPrimaryContainer: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryLight,
      onSecondaryContainer: onSecondary,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryLight,
      onTertiaryContainer: onTertiary,
      error: error,
      onError: _getContrastColor(error),
      errorContainer: error.withValues(alpha: 0.1),
      onErrorContainer: error,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: Colors.black.withValues(alpha: 0.1),
      scrim: overlay,
      inverseSurface: onSurfaceInverse,
      onInverseSurface: surface,
      inversePrimary: primaryLight,
      surfaceTint: primary.withValues(alpha: 0.05),
    );
    
    // Extract font information
    final primaryFont = fonts['primary'] as Map<String, dynamic>? ?? {};
    final secondaryFont = fonts['secondary'] as Map<String, dynamic>? ?? {};
    
    final primaryFontFamily = primaryFont['family'] as String? ?? 'Roboto';
    final primaryFontFallback = primaryFont['fallback'] as String? ?? "'Times New Roman', serif";
    final primaryFontWeights = (primaryFont['weights'] as List<dynamic>? ?? [400, 500, 600, 700])
        .map((w) => w as int)
        .toList();
    
    final secondaryFontFamily = secondaryFont['family'] as String? ?? 'Roboto';
    final secondaryFontFallback = secondaryFont['fallback'] as String? ?? "'Courier New', Consolas, monospace";
    final secondaryFontWeights = (secondaryFont['weights'] as List<dynamic>? ?? [400, 500, 700])
        .map((w) => w as int)
        .toList();
    
    // Extract typography information
    final headingSizes = typography['headingSizes'] as Map<String, dynamic>? ?? {};
    final bodySizes = typography['bodySizes'] as Map<String, dynamic>? ?? {};
    final lineHeights = typography['lineHeights'] as Map<String, dynamic>? ?? {};
    final fontWeights = typography['fontWeights'] as Map<String, dynamic>? ?? {};
    final letterSpacing = typography['letterSpacing'] as Map<String, dynamic>? ?? {};
    
    // Parse font weights
    const lightWeight = FontWeight.w300;
    const normalWeight = FontWeight.w400;
    const mediumWeight = FontWeight.w500;
    const semiboldWeight = FontWeight.w600;
    const boldWeight = FontWeight.w700;
    
    // Parse line heights
    final tightHeight = _parseLineHeight(lineHeights['tight'] ?? '1.25');
    final normalHeight = _parseLineHeight(lineHeights['normal'] ?? '1.5');
    final relaxedHeight = _parseLineHeight(lineHeights['relaxed'] ?? '1.75');
    
    // Parse letter spacing
    final tightSpacing = _parseLetterSpacing(letterSpacing['tight'] ?? '-0.025em');
    final normalSpacing = _parseLetterSpacing(letterSpacing['normal'] ?? '0em');
    final wideSpacing = _parseLetterSpacing(letterSpacing['wide'] ?? '0.025em');
    final widerSpacing = _parseLetterSpacing(letterSpacing['wider'] ?? '0.05em');
    
    // Create comprehensive TextTheme
    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: _parseSize(headingSizes['h1'] ?? '2.5rem'),
        fontWeight: boldWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      displayMedium: TextStyle(
        fontSize: _parseSize(headingSizes['h2'] ?? '2rem'),
        fontWeight: boldWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      displaySmall: TextStyle(
        fontSize: _parseSize(headingSizes['h3'] ?? '1.5rem'),
        fontWeight: semiboldWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      headlineLarge: TextStyle(
        fontSize: _parseSize(headingSizes['h4'] ?? '1.25rem'),
        fontWeight: semiboldWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      headlineMedium: TextStyle(
        fontSize: _parseSize(headingSizes['h5'] ?? '1.125rem'),
        fontWeight: semiboldWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      headlineSmall: TextStyle(
        fontSize: _parseSize(headingSizes['h6'] ?? '1rem'),
        fontWeight: semiboldWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      titleLarge: TextStyle(
        fontSize: _parseSize(bodySizes['large'] ?? '1.125rem'),
        fontWeight: semiboldWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      titleMedium: TextStyle(
        fontSize: _parseSize(bodySizes['normal'] ?? '1rem'),
        fontWeight: mediumWeight,
        color: onSurface,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      titleSmall: TextStyle(
        fontSize: _parseSize(bodySizes['small'] ?? '0.875rem'),
        fontWeight: mediumWeight,
        color: onSurfaceMuted,
        fontFamily: primaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      bodyLarge: TextStyle(
        fontSize: _parseSize(bodySizes['large'] ?? '1.125rem'),
        fontWeight: normalWeight,
        color: onSurface,
        fontFamily: secondaryFontFamily,
        height: relaxedHeight,
        letterSpacing: normalSpacing,
      ),
      bodyMedium: TextStyle(
        fontSize: _parseSize(bodySizes['normal'] ?? '1rem'),
        fontWeight: normalWeight,
        color: onSurface,
        fontFamily: secondaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      bodySmall: TextStyle(
        fontSize: _parseSize(bodySizes['small'] ?? '0.875rem'),
        fontWeight: normalWeight,
        color: onSurfaceMuted,
        fontFamily: secondaryFontFamily,
        height: normalHeight,
        letterSpacing: normalSpacing,
      ),
      labelLarge: TextStyle(
        fontSize: _parseSize(bodySizes['normal'] ?? '1rem'),
        fontWeight: mediumWeight,
        color: onSurface,
        fontFamily: secondaryFontFamily,
        height: tightHeight,
        letterSpacing: wideSpacing,
      ),
      labelMedium: TextStyle(
        fontSize: _parseSize(bodySizes['small'] ?? '0.875rem'),
        fontWeight: mediumWeight,
        color: onSurfaceMuted,
        fontFamily: secondaryFontFamily,
        height: tightHeight,
        letterSpacing: wideSpacing,
      ),
      labelSmall: TextStyle(
        fontSize: _parseSize(bodySizes['tiny'] ?? '0.75rem'),
        fontWeight: mediumWeight,
        color: onSurfaceMuted,
        fontFamily: secondaryFontFamily,
        height: tightHeight,
        letterSpacing: widerSpacing,
      ),
    );
    
    // Parse spacing values
    final spacingXs = _parseSpacing(spacing['xs'] ?? '0.25rem');
    final spacingSm = _parseSpacing(spacing['sm'] ?? '0.5rem');
    final spacingMd = _parseSpacing(spacing['md'] ?? '1rem');
    final spacingLg = _parseSpacing(spacing['lg'] ?? '1.5rem');
    final spacingXl = _parseSpacing(spacing['xl'] ?? '2rem');
    final spacingXxl = _parseSpacing(spacing['xxl'] ?? '3rem');
    final spacingXxxl = _parseSpacing(spacing['xxxl'] ?? '4rem');
    final spacingSection = _parseSpacing(spacing['section'] ?? '6rem');
    
    // Parse radius values
    final radiusNone = _parseRadius(radius['none'] ?? '0px');
    final radiusSmall = _parseRadius(radius['small'] ?? '6px');
    final radiusMedium = _parseRadius(radius['medium'] ?? '12px');
    final radiusLarge = _parseRadius(radius['large'] ?? '16px');
    final radiusXl = _parseRadius(radius['xl'] ?? '24px');
    final radiusFull = _parseRadius(radius['full'] ?? '9999px');
    
    // Parse effects
    final animations = effects['animations'] as Map<String, dynamic>? ?? {};
    final shadows = effects['shadows'] as Map<String, dynamic>? ?? {};
    
    final animationDurations = animations['duration'] as Map<String, dynamic>? ?? {};
    final animationEasing = animations['easing'] as Map<String, dynamic>? ?? {};
    final animationScale = animations['scale'] as Map<String, dynamic>? ?? {};
    
    final durationFast = _parseDuration(animationDurations['fast'] ?? '150ms');
    final durationNormal = _parseDuration(animationDurations['normal'] ?? '300ms');
    final durationSlow = _parseDuration(animationDurations['slow'] ?? '500ms');
    
    final scaleHover = _parseScale(animationScale['hover'] ?? '1.05');
    final scaleActive = _parseScale(animationScale['active'] ?? '0.95');
    
    // Parse shadows
    final shadowSoftGlow = _parseShadow(shadows['soft_glow'] ?? '0 0 10px rgba(143, 121, 185, 0.3)');
    final shadowFocusRing = _parseShadow(shadows['focus_ring'] ?? '0 0 0 3px rgba(143, 121, 185, 0.5)');
    final shadowTooltip = _parseShadow(shadows['tooltip'] ?? '0 2px 12px rgba(0, 0, 0, 0.4)');
    
    // Additional theme properties
    final borderRadius = _parseRadius(jsonData['borderRadius'] ?? '0.5rem');
    final iconStyle = jsonData['iconStyle'] as String? ?? 'default';
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      
      // Button themes with full spacing and radius support
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          padding: EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: surface,
        margin: EdgeInsets.all(spacingSm),
      ),
      
             // App bar theme
       appBarTheme: AppBarTheme(
         backgroundColor: surface,
         foregroundColor: onSurface,
         elevation: 0,
         centerTitle: true,
         titleTextStyle: textTheme.titleLarge?.copyWith(
           color: onSurface,
           fontWeight: semiboldWeight,
         ),
       ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary.withValues(alpha: 0.1),
        disabledColor: disabledColor.withValues(alpha: 0.1),
        labelStyle: textTheme.bodyMedium,
        padding: EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingXs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: spacingMd,
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: onSurface,
        size: 24,
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
        circularTrackColor: surfaceVariant,
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(radiusSmall),
          boxShadow: [shadowTooltip],
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: onSurface),
        padding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return onSurfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withValues(alpha: 0.5);
          return surfaceVariant;
        }),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      
      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return onSurfaceMuted;
        }),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: surfaceVariant,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.1),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(color: onPrimary),
      ),
      
      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceMuted,
        indicatorColor: primary,
        labelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      
      // Expansion tile theme
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: surface,
        collapsedBackgroundColor: surface,
        textColor: onSurface,
        iconColor: onSurface,
        collapsedTextColor: onSurface,
        collapsedIconColor: onSurface,
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        tileColor: surface,
        selectedTileColor: primary.withValues(alpha: 0.1),
        textColor: onSurface,
        iconColor: onSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      
      // Data table theme
      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.titleMedium?.copyWith(color: onSurface),
        dataTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        dividerThickness: 1,
        columnSpacing: spacingLg,
        horizontalMargin: spacingMd,
      ),
      
      
      
      // Search bar theme
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(surface),
        elevation: WidgetStateProperty.all(2),
        textStyle: WidgetStateProperty.all(textTheme.bodyMedium),
        hintStyle: WidgetStateProperty.all(textTheme.bodyMedium?.copyWith(color: onSurfaceMuted)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      
      
    );
  }

  /// Get theme from Named Entrypoints
  Future<ThemeData?> _getNamedEntrypointTheme(
    String worldId, 
    String context, 
    bool isDarkMode
  ) async {
    final cacheKey = 'named_${worldId}_${context}_${isDarkMode ? 'dark' : 'light'}';
    
    // Check cache first
    if (_namedEntrypointCache.containsKey(cacheKey)) {
      final cachedResponse = _namedEntrypointCache[cacheKey]!;
      return _createThemeDataFromNamedEntrypoint(cachedResponse.theme.data, isDarkMode);
    }

    try {
      // Load from Named Entrypoints API
      final response = await _namedEntrypointsService.getNamedEntrypointTheme(worldId, context);
      
      if (response != null) {
        // Cache the response
        _namedEntrypointCache[cacheKey] = response;
        
        // Create ThemeData from the response
        return _createThemeDataFromNamedEntrypoint(response.theme.data, isDarkMode);
      }
      
      return null;
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to load Named Entrypoint theme for $worldId/$context: $e');
      return null;
    }
  }

  /// Create ThemeData from Named Entrypoint theme data
  ThemeData _createThemeDataFromNamedEntrypoint(Map<String, dynamic> themeData, bool isDarkMode) {
    try {
      // Use the same comprehensive theme creation method
      return _createThemeDataFromJson(themeData, isDarkMode);
    } catch (e) {
      AppLogger.app.e('❌ Failed to create ThemeData from Named Entrypoint: $e');
      return _getFallbackThemeData(isDarkMode);
    }
  }

  /// Parse color string to Color
  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('rgba(')) {
        // Parse rgba(r, g, b, a) format
        final values = colorString.substring(5, colorString.length - 1).split(',');
        final r = int.parse(values[0].trim());
        final g = int.parse(values[1].trim());
        final b = int.parse(values[2].trim());
        final a = (double.parse(values[3].trim()) * 255).round();
        return Color.fromARGB(a, r, g, b);
      }
      return Colors.grey;
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse color: $colorString: $e');
      return Colors.grey;
    }
  }

  /// Parse size string to double
  double _parseSize(String sizeString) {
    try {
      if (sizeString.endsWith('rem')) {
        return double.parse(sizeString.substring(0, sizeString.length - 3)) * 16.0;
      } else if (sizeString.endsWith('px')) {
        return double.parse(sizeString.substring(0, sizeString.length - 2));
      }
      return 16.0;
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse size: $sizeString: $e');
      return 16.0;
    }
  }

  /// Parse spacing string to double
  double _parseSpacing(String spacingString) {
    return _parseSize(spacingString);
  }

  /// Parse radius string to double
  double _parseRadius(String radiusString) {
    try {
      if (radiusString.endsWith('px')) {
        return double.parse(radiusString.replaceAll('px', ''));
      } else if (radiusString.endsWith('rem')) {
        return double.parse(radiusString.replaceAll('rem', '')) * 16; // 1rem = 16px
      }
      return 8.0; // Default fallback
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse radius: $radiusString: $e');
      return 8.0; // Default fallback
    }
  }

  /// Parse line height string to double
  double _parseLineHeight(String lineHeightString) {
    try {
      return double.parse(lineHeightString);
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse line height: $lineHeightString: $e');
      return 1.5; // Default fallback
    }
  }

  /// Parse letter spacing string to double
  double _parseLetterSpacing(String letterSpacingString) {
    try {
      if (letterSpacingString.endsWith('em')) {
        return double.parse(letterSpacingString.replaceAll('em', ''));
      }
      return 0.0; // Default fallback
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse letter spacing: $letterSpacingString: $e');
      return 0.0; // Default fallback
    }
  }

  /// Parse duration string to Duration
  Duration _parseDuration(String durationString) {
    try {
      if (durationString.endsWith('ms')) {
        final ms = int.parse(durationString.replaceAll('ms', ''));
        return Duration(milliseconds: ms);
      } else if (durationString.endsWith('s')) {
        final s = double.parse(durationString.replaceAll('s', ''));
        return Duration(milliseconds: (s * 1000).round());
      }
      return const Duration(milliseconds: 300); // Default fallback
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse duration: $durationString: $e');
      return const Duration(milliseconds: 300); // Default fallback
    }
  }

  /// Parse scale string to double
  double _parseScale(String scaleString) {
    try {
      return double.parse(scaleString);
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse scale: $scaleString: $e');
      return 1.0; // Default fallback
    }
  }

  /// Parse shadow string to BoxShadow
  BoxShadow _parseShadow(String shadowString) {
    try {
      // Simple shadow parsing - can be enhanced for more complex shadows
      if (shadowString.contains('rgba')) {
        // Extract color from rgba
        final colorMatch = RegExp(r'rgba\([^)]+\)').firstMatch(shadowString);
        if (colorMatch != null) {
          final colorString = colorMatch.group(0)!;
          final color = _parseColor(colorString);
          
          // Extract offset and blur values
          final numbers = RegExp(r'\d+(?:\.\d+)?').allMatches(shadowString);
          if (numbers.length >= 3) {
            final dx = double.parse(numbers.elementAt(0).group(0)!);
            final dy = double.parse(numbers.elementAt(1).group(0)!);
            final blur = double.parse(numbers.elementAt(2).group(0)!);
            
            return BoxShadow(
              color: color,
              offset: Offset(dx, dy),
              blurRadius: blur,
            );
          }
        }
      }
      
      // Default shadow
      return BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        offset: const Offset(0, 2),
        blurRadius: 4,
      );
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to parse shadow: $shadowString: $e');
      return BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        offset: const Offset(0, 2),
        blurRadius: 4,
      );
    }
  }

  /// Get contrast color for background
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Get parent theme
  Future<ThemeData?> _getParentTheme(String parentTheme, bool isDarkMode) async {
    // TODO: Implement parent theme resolution
    return null;
  }

  /// Get fallback theme
  Future<ThemeData> _getFallbackTheme(bool isDarkMode) async {
    // Try to load default theme as fallback
    final defaultTheme = await _loadThemeFromBackend('default');
    if (defaultTheme != null) {
      final theme = defaultTheme.themes.first;
      return isDarkMode ? theme.darkThemeData! : theme.lightThemeData!;
    }
    
    // Ultimate fallback
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  /// Apply theme overrides
  ThemeData _applyThemeOverrides(ThemeData baseTheme, Map<String, dynamic> overrides) {
    // TODO: Implement theme override application
    return baseTheme;
  }

  /// Clear cache
  void clearCache() {
    _bundleCache.clear();
    _themeCache.clear();
    _themeJsonCache.clear();
    _namedEntrypointCache.clear();
    _backgroundCache.clear();
    AppLogger.app.i('🗑️ Theme cache cleared');
  }
  
  /// Clear specific cache entries
  void clearThemeCache(String themeName) {
    _bundleCache.remove(themeName);
    _themeJsonCache.remove(themeName);
    AppLogger.app.d('🗑️ Theme cache cleared for: $themeName');
  }
  
  /// Clear background cache for specific world
  void clearBackgroundCache(String worldId) {
    final keysToRemove = _backgroundCache.keys
        .where((key) => key.startsWith('background_${worldId}_'))
        .toList();
    
    for (final key in keysToRemove) {
      _backgroundCache.remove(key);
    }
    
    AppLogger.app.d('🗑️ Background cache cleared for world: $worldId (${keysToRemove.length} entries)');
  }

  /// Get fallback ColorScheme
  ColorScheme _getFallbackColorScheme(bool isDarkMode) {
    return isDarkMode ? const ColorScheme.dark() : const ColorScheme.light();
  }

  /// Get fallback TextTheme
  TextTheme _getFallbackTextTheme() {
    return Typography.material2021().englishLike;
  }

  /// Get fallback ThemeData
  ThemeData _getFallbackThemeData(bool isDarkMode) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _getFallbackColorScheme(isDarkMode),
      textTheme: _getFallbackTextTheme(),
    );
  }

  /// Get Named Entrypoint theme JSON
  Future<Map<String, dynamic>?> _getNamedEntrypointThemeJson(String worldId, String context) async {
    try {
      final cacheKey = 'named_entrypoint_json_${worldId}_$context';
      
      // Check cache first
      if (_themeJsonCache.containsKey(cacheKey)) {
        return _themeJsonCache[cacheKey];
      }

      final response = await _namedEntrypointsService.getNamedEntrypointTheme(worldId, context);
      if (response != null) {
        final themeJson = response.theme.toJson();
        _themeJsonCache[cacheKey] = themeJson;
        return themeJson;
      }
      
      return null;
    } catch (e) {
      AppLogger.app.e('❌ Failed to get Named Entrypoint theme JSON for world $worldId, context $context: $e');
      return null;
    }
  }

  /// Resolve background image for a specific world and context
  Future<String?> resolveBackgroundImage(
    World world, {
    String context = 'pre-game',
    String? pageType,
  }) async {
    try {
      final cacheKey = 'background_${world.themeBundle ?? 'default'}_${context}_${pageType ?? 'default'}';
      
      // Check cache first
      if (_backgroundCache.containsKey(cacheKey)) {
        return _backgroundCache[cacheKey];
      }

      final worldId = world.themeBundle ?? 'default';
      final dynamicAssetService = DynamicAssetService(); // Use singleton

      // Try to get from Named Entrypoints first
      final namedEntrypointTheme = await _getNamedEntrypointThemeJson(worldId, context);
      if (namedEntrypointTheme != null && namedEntrypointTheme['backgrounds'] != null) {
        final backgrounds = namedEntrypointTheme['backgrounds'] as Map<String, dynamic>;
        AppLogger.app.d('🔍 Theme backgrounds: $backgrounds');
        AppLogger.app.d('🔍 Looking for pageType: ${pageType ?? 'auth'}');
        
        final backgroundPath = backgrounds[pageType ?? 'auth'] as String?;
        AppLogger.app.d('🔍 Found background path: $backgroundPath');
        
        if (backgroundPath != null) {
          // Try the specific path from theme
          final specificPath = 'worlds/$worldId/$backgroundPath';
          AppLogger.app.d('🔍 Trying specific path: $specificPath');
          final existingAsset = await dynamicAssetService.findExistingAsset([specificPath]);
          if (existingAsset != null) {
            _backgroundCache[cacheKey] = existingAsset;
            return existingAsset;
          }
        }
      }

      // Fallback: Try multiple possible paths dynamically
      final possiblePaths = dynamicAssetService.generateBackgroundPaths(worldId, pageType ?? 'auth');
      AppLogger.app.d('🔍 Generated paths for world $worldId, pageType ${pageType ?? 'auth'}: $possiblePaths');
      final existingAsset = await dynamicAssetService.findExistingAsset(possiblePaths);
      
      if (existingAsset != null) {
        _backgroundCache[cacheKey] = existingAsset;
        return existingAsset;
      }

      // Ultimate fallback
      AppLogger.app.w('⚠️ No background asset found for world $worldId, pageType ${pageType ?? 'auth'}');
      return null;

    } catch (e) {
      AppLogger.app.e('❌ Background resolution failed for world ${world.themeBundle ?? 'default'}: $e');
      return null;
    }
  }
}