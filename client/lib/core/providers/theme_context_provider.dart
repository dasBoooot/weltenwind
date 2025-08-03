import 'package:flutter/material.dart';
import '../services/theme_context_manager.dart';
import '../services/modular_theme_service.dart';
import '../../config/logger.dart';

/// 🎯 Theme Context Provider für kontextsensitive Theme-Bereitstellung
/// 
/// Zentraler Provider, der alle Komponenten mit kontextabhängigen Themes versorgt.
/// Reagiert automatisch auf Context-Änderungen und stellt sicher, dass alle
/// Komponenten immer das korrekte Theme für ihren aktuellen Kontext erhalten.
class ThemeContextProvider extends ChangeNotifier {
  static final ThemeContextProvider _instance = ThemeContextProvider._internal();
  factory ThemeContextProvider() => _instance;
  ThemeContextProvider._internal() {
    _initialize();
  }

  final ThemeContextManager _contextManager = ThemeContextManager();
  final ModularThemeService _themeService = ModularThemeService();

  // Current Context & Theme State
  ThemeContext? _currentContext;
  ThemeData? _currentTheme;
  ThemeData? _currentDarkTheme;
  Map<String, dynamic>? _currentExtensions;
  bool _isDarkMode = false;

  // Context Change Tracking
  bool _isUpdating = false;
  DateTime? _lastUpdate;

  /// Current Context Getters
  ThemeContext? get currentContext => _currentContext;
  ThemeData? get currentTheme => _currentTheme;
  ThemeData? get currentDarkTheme => _currentDarkTheme;
  Map<String, dynamic>? get currentExtensions => _currentExtensions;
  bool get isDarkMode => _isDarkMode;
  bool get isUpdating => _isUpdating;
  
  /// Theme Service Getter (for preloaders)
  ModularThemeService get themeService => _themeService;

  /// 🚀 Initialize Provider
  Future<void> _initialize() async {
    try {
      AppLogger.app.i('🎯 Initializing ThemeContextProvider...');
      
      // Listen to context changes
      _contextManager.contextChanges.listen(_handleContextChange);
      
      // Set initial context
      await _updateContext();
      
      AppLogger.app.i('✅ ThemeContextProvider initialized');
    } catch (e) {
      AppLogger.app.e('❌ Error initializing ThemeContextProvider', error: e);
    }
  }

  /// 🔄 Update Context (manual trigger)
  Future<void> updateContext() async {
    await _updateContext();
  }

  /// 🌍 Set World Context
  Future<void> setWorldContext(String? worldId, {WorldType? worldType}) async {
    await _contextManager.setWorldContext(worldId, worldType: worldType);
  }

  /// 👤 Set Player State Context  
  Future<void> setPlayerState(PlayerState? playerState) async {
    await _contextManager.setPlayerStateContext(playerState);
  }

  /// 🖥️ Set UI Context
  Future<void> setUIContext(UIContext uiContext) async {
    await _contextManager.setUIContext(uiContext);
  }

  /// 📱 Set Platform Context
  Future<void> setPlatformContext(PlatformContext platformContext) async {
    await _contextManager.setPlatformContext(platformContext);
  }

  /// 🎨 Toggle Dark Mode
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _contextManager.setVisualModeContext(
        isDark ? VisualModeContext.dark : VisualModeContext.light
      );
    }
  }

  /// 📦 Switch to specific Bundle
  Future<void> switchToBundle(String bundleId) async {
    try {
      _isUpdating = true;
      notifyListeners();

      final theme = await _themeService.getBundle(bundleId, isDark: _isDarkMode);
      if (theme != null) {
        _currentTheme = theme;
        _currentExtensions = _themeService.getCurrentThemeExtensions();
        _lastUpdate = DateTime.now();
      }

      _isUpdating = false;
      notifyListeners();
      
      AppLogger.app.i('🔄 Switched to bundle: $bundleId');
    } catch (e) {
      _isUpdating = false;
      notifyListeners();
      AppLogger.app.e('❌ Error switching to bundle $bundleId', error: e);
    }
  }

  /// 🎮 Get Theme for specific Component Context
  ThemeData? getThemeForComponent(String componentName, {Map<String, dynamic>? contextOverrides}) {
    if (_currentTheme == null) return null;

    // Component-specific context modifications
    var theme = _currentTheme!;
    
    if (contextOverrides != null) {
      // Apply component-specific overrides
      theme = _applyComponentOverrides(theme, componentName, contextOverrides);
    }

    return theme;
  }

  /// 🎨 Get Extensions for specific Component Context
  Map<String, dynamic>? getExtensionsForComponent(String componentName) {
    if (_currentExtensions == null) return null;
    
    // Component-specific extensions can be filtered here
    return Map<String, dynamic>.from(_currentExtensions!);
  }

  // 🔥 HYBRID-SYSTEM: New Methods for Mixed-Context Support

  /// 🌍 Get World-specific Theme from themeName (mit Bundle-Resolution)
  ThemeData? getWorldTheme(String worldThemeName) {
    try {
      // 🎯 THEME-NAME zu BUNDLE-NAME Resolution
      final bundleName = getBundleForTheme(worldThemeName);
      
      print('🔍 [THEME-DEBUG] getWorldTheme: $worldThemeName → Bundle: $bundleName');
      
      // Verwende gecachtes Theme falls verfügbar
      final cachedTheme = _themeService.getCachedTheme(bundleName, isDark: _isDarkMode);
      
      if (cachedTheme != null) {
        print('✅ [THEME-DEBUG] Cached theme found for: $worldThemeName ($bundleName)');
        return cachedTheme;
      }
      
      // Async load falls nicht cached
      print('🔄 [THEME-DEBUG] Theme not cached, loading async: $worldThemeName ($bundleName)');
      _loadThemeAsync(worldThemeName, bundleName);
      
      // ✅ RETURN NULL to trigger Smart Fallback
      return null;
    } catch (e) {
      AppLogger.app.e('❌ Error loading world theme: $worldThemeName', error: e);
      return _currentTheme;
    }
  }

  /// 🎯 Public: Get Bundle for Theme Name - DYNAMISCH  
  String getBundleForTheme(String themeName) {
    // TODO: Ersetze durch dynamisches Schema-Loading
    // Temporärer Fallback bis alle Provider umgestellt sind
    switch (themeName) {
      case 'default': return 'pre-game-minimal';
      case 'tolkien':
      case 'space':
      case 'roman':
      case 'nature':
      case 'cyberpunk':
        return 'full-gaming';
      default: 
        return 'world-preview'; // Fallback
    }
  }

  /// 📊 Private: Track loading states to prevent infinite loops
  final Set<String> _loadingThemes = <String>{};

  /// 🔄 Private: Load Theme Async und notifiziere UI (mit Loop-Prevention)
  Future<void> _loadThemeAsync(String themeName, String bundleName) async {
    // 🛡️ LOOP PREVENTION: Don't load if already loading
    final loadKey = '$themeName:$bundleName';
    if (_loadingThemes.contains(loadKey)) {
      print('⚠️ [THEME-DEBUG] Already loading: $themeName ($bundleName) - SKIP');
      return;
    }

    try {
      _loadingThemes.add(loadKey);
      print('🔄 [THEME-DEBUG] Loading theme async: $themeName ($bundleName)');
      
      final theme = await _themeService.getBundle(bundleName, isDark: _isDarkMode);
      if (theme != null) {
        print('✅ [THEME-DEBUG] Theme loaded async: $themeName');
        
        // 🎯 SMART NOTIFY: Only notify after successful load + small delay
        await Future.delayed(const Duration(milliseconds: 100));
        print('🔔 [THEME-DEBUG] Notifying UI of theme change: $themeName');
        notifyListeners();
      }
    } catch (e) {
      print('❌ [THEME-DEBUG] Async theme load failed: $themeName - $e');
    } finally {
      _loadingThemes.remove(loadKey);
    }
  }

  /// 🌍 Get World-specific Extensions
  Map<String, dynamic>? getWorldExtensions(String worldThemeName) {
    try {
      final bundleName = getBundleForTheme(worldThemeName);
      return _themeService.getBundleExtensions(bundleName);
    } catch (e) {
      AppLogger.app.e('❌ Error loading world extensions: $worldThemeName', error: e);
      return null;
    }
  }

  /// 🗺️ Get Theme for specific Area from staticAreas mapping
  ThemeData? getThemeForArea(String componentName, Map<String, String> staticAreas) {
    final areaTheme = staticAreas[componentName];
    if (areaTheme != null) {
      return getThemeFromBundle(areaTheme);
    }
    
    // Check for wildcard or parent area mappings
    for (final entry in staticAreas.entries) {
      if (componentName.startsWith(entry.key) || entry.key == '*') {
        return getThemeFromBundle(entry.value);
      }
    }
    
    return _currentTheme;
  }

  /// 🗺️ Get Extensions for specific Area
  Map<String, dynamic>? getExtensionsForArea(String componentName, Map<String, String> staticAreas) {
    final areaTheme = staticAreas[componentName];
    if (areaTheme != null) {
      return _themeService.getBundleExtensions(areaTheme);
    }
    
    return _currentExtensions;
  }

  /// 📦 Get Theme from specific Bundle (synchron mit Cache)
  ThemeData? getThemeFromBundle(String bundleId) {
    try {
      print('🔍 [THEME-DEBUG] getThemeFromBundle: $bundleId');
      
      // Verwende gecachtes Theme falls verfügbar
      final cachedTheme = _themeService.getCachedTheme(bundleId, isDark: _isDarkMode);
      print('🔍 [THEME-DEBUG] cachedTheme for $bundleId: ${cachedTheme != null ? "FOUND" : "NULL"}');
      
      if (cachedTheme != null) {
        print('✅ [THEME-DEBUG] Returning cached theme for $bundleId');
        return cachedTheme;
      }
      
      print('🔍 [THEME-DEBUG] _currentTheme: ${_currentTheme != null ? "FOUND" : "NULL"}');
      
      // BESSERER FALLBACK: Verwende globalen ThemeProvider falls verfügbar
      if (_currentTheme == null) {
        print('🔧 [THEME-DEBUG] _currentTheme is null, trying async bundle load for $bundleId');
        // Versuche Bundle asynchron zu laden
        _loadBundleAsync(bundleId);
        return null; // Trigger Flutter default theme until loaded
      }
      
      // Fallback zu aktuellem Theme
      return _currentTheme;
    } catch (e) {
      AppLogger.app.e('❌ Error loading theme from bundle: $bundleId', error: e);
      print('❌ [THEME-DEBUG] Error in getThemeFromBundle: $bundleId - $e');
      return null; // Return null to trigger Flutter default theme
    }
  }

  /// 📊 Get Context Debug Info
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentContext': _currentContext?.toJson(),
      'hasTheme': _currentTheme != null,
      'hasDarkTheme': _currentDarkTheme != null,
      'hasExtensions': _currentExtensions != null,
      'isDarkMode': _isDarkMode,
      'isUpdating': _isUpdating,
      'lastUpdate': _lastUpdate?.toIso8601String(),
      'contextManager': _contextManager.getContextDebugInfo(),
      'themeService': _themeService.getPerformanceStats(),
    };
  }

  /// 🔔 Private: Handle Context Change
  Future<void> _handleContextChange(ThemeContextChange change) async {
    AppLogger.app.i('🔄 Context changed: ${change.event.type.name}');
    await _updateContext();
  }

  /// 🔄 Private: Update Context and Theme
  Future<void> _updateContext() async {
    try {
      _isUpdating = true;
      notifyListeners();

      // Get current complete context
      _currentContext = _contextManager.getCompleteContext();
      
      if (_currentContext != null) {
        // Load theme for current context
        final theme = await _themeService.getTheme(_currentContext!, isDark: _isDarkMode);
        final darkTheme = await _themeService.getTheme(_currentContext!, isDark: true);
        
        if (theme != null) {
          _currentTheme = theme;
          _currentDarkTheme = darkTheme ?? theme;
          _currentExtensions = _themeService.getCurrentThemeExtensions();
          _lastUpdate = DateTime.now();
        }
      }

      _isUpdating = false;
      notifyListeners();
      
    } catch (e) {
      _isUpdating = false;
      notifyListeners();
      AppLogger.app.e('❌ Error updating context', error: e);
    }
  }

  /// 🎨 Private: Apply Component-specific Overrides
  ThemeData _applyComponentOverrides(
    ThemeData baseTheme, 
    String componentName, 
    Map<String, dynamic> overrides
  ) {
    // Component-specific theme modifications
    return switch (componentName) {
      'AppButton' => _applyButtonOverrides(baseTheme, overrides),
      'AppCard' => _applyCardOverrides(baseTheme, overrides),
      'AppInput' => _applyInputOverrides(baseTheme, overrides),
      'GameMinimap' => _applyMinimapOverrides(baseTheme, overrides),
      'GameInventorySlot' => _applyInventoryOverrides(baseTheme, overrides),
      _ => baseTheme,
    };
  }

  /// 🔘 Private: Button-specific Overrides
  ThemeData _applyButtonOverrides(ThemeData theme, Map<String, dynamic> overrides) {
    if (overrides.containsKey('variant')) {
      final variant = overrides['variant'] as String;
      return switch (variant) {
        'magic' => theme.copyWith(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(
                _blendMagicColor(theme.colorScheme.primary)
              ),
            ),
          ),
        ),
        'portal' => theme.copyWith(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(
                _blendPortalColor(theme.colorScheme.secondary)
              ),
            ),
          ),
        ),
        _ => theme,
      };
    }
    return theme;
  }

  /// 🃏 Private: Card-specific Overrides
  ThemeData _applyCardOverrides(ThemeData theme, Map<String, dynamic> overrides) {
    if (overrides.containsKey('variant')) {
      final variant = overrides['variant'] as String;
      return switch (variant) {
        'magic' => theme.copyWith(
          cardTheme: theme.cardTheme.copyWith(
            color: _blendMagicColor(theme.colorScheme.surface),
          ),
        ),
        'artifact' => theme.copyWith(
          cardTheme: theme.cardTheme.copyWith(
            color: _blendArtifactColor(theme.colorScheme.surface),
          ),
        ),
        _ => theme,
      };
    }
    return theme;
  }

  /// 📝 Private: Input-specific Overrides
  ThemeData _applyInputOverrides(ThemeData theme, Map<String, dynamic> overrides) {
    // Input-specific modifications can be added here
    return theme;
  }

  /// 🗺️ Private: Minimap-specific Overrides
  ThemeData _applyMinimapOverrides(ThemeData theme, Map<String, dynamic> overrides) {
    // Minimap-specific modifications can be added here
    return theme;
  }

  /// 🎒 Private: Inventory-specific Overrides
  ThemeData _applyInventoryOverrides(ThemeData theme, Map<String, dynamic> overrides) {
    // Inventory-specific modifications can be added here
    return theme;
  }

  /// 🎨 Private: Color Blending Helpers
  Color _blendMagicColor(Color baseColor) {
    return Color.lerp(baseColor, const Color(0xFF7C6BAF), 0.3) ?? baseColor;
  }

  Color _blendPortalColor(Color baseColor) {
    return Color.lerp(baseColor, const Color(0xFF4A90E2), 0.3) ?? baseColor;
  }

  Color _blendArtifactColor(Color baseColor) {
    return Color.lerp(baseColor, const Color(0xFFD4AF37), 0.2) ?? baseColor;
  }

  /// 🔄 Private: Asynchron Bundle laden falls nicht im Cache
  Future<void> _loadBundleAsync(String bundleId) async {
    try {
      print('🔄 [THEME-DEBUG] Loading bundle async: $bundleId');
      final theme = await _themeService.getBundle(bundleId, isDark: _isDarkMode);
      if (theme != null) {
        print('✅ [THEME-DEBUG] Bundle loaded async: $bundleId');
        notifyListeners(); // Trigger rebuild
      }
    } catch (e) {
      print('❌ [THEME-DEBUG] Async bundle load failed: $bundleId - $e');
    }
  }

  @override
  void dispose() {
    _contextManager.dispose();
    super.dispose();
  }
}

/// 🎭 Context-Sensitive Theme Consumer Widget with Hybrid-System Support
class ThemeContextConsumer extends StatelessWidget {
  final String componentName;
  final Map<String, dynamic>? contextOverrides;
  final Widget Function(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) builder;
  
  // 🔥 HYBRID-SYSTEM: Mixed-Context Support
  final bool enableMixedContext;
  final Map<String, String>? staticAreas;      // Page-Level Area-Mappings
  final Map<String, String>? dynamicAreas;    // Component-Level Area-Mappings
  final String? fallbackTheme;
  final String? worldThemeOverride;            // Für World-spezifische Themes

  const ThemeContextConsumer({
    super.key,
    required this.componentName,
    required this.builder,
    this.contextOverrides,
    
    // 🎨 HYBRID-SYSTEM PARAMETERS
    this.enableMixedContext = false,
    this.staticAreas,
    this.dynamicAreas, 
    this.fallbackTheme,
    this.worldThemeOverride,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeContextProvider(),
      builder: (context, child) {
        final provider = ThemeContextProvider();

        // 🎯 HYBRID-SYSTEM: Mixed-Context Theme Resolution
        ThemeData? resolvedTheme;
        Map<String, dynamic>? resolvedExtensions;

        if (enableMixedContext && worldThemeOverride != null) {
          // 🌍 WORLD-SPECIFIC THEME für dynamische Inhalte
          resolvedTheme = provider.getWorldTheme(worldThemeOverride!);
          resolvedExtensions = provider.getWorldExtensions(worldThemeOverride!);
          print('🌍 [THEME-DEBUG] Context World Theme: $worldThemeOverride (Component: $componentName)');
          
          // 🛡️ Smart World Theme Fallback: If World Theme is loading, try its bundle directly
          if (resolvedTheme == null) {
            final worldBundleName = provider.getBundleForTheme(worldThemeOverride!);
            resolvedTheme = provider.getThemeFromBundle(worldBundleName);
            print('🎯 [THEME-DEBUG] World Theme loading, using bundle: $worldBundleName (for theme: $worldThemeOverride)');
          }
        } else if (enableMixedContext && staticAreas != null) {
          // 🗺️ STATIC AREA MAPPING für Page-Level Bereiche
          resolvedTheme = provider.getThemeForArea(componentName, staticAreas!);
          resolvedExtensions = provider.getExtensionsForArea(componentName, staticAreas!);
          print('🗺️ [THEME-DEBUG] Context Area Theme: ${staticAreas.toString()} (Component: $componentName)');
        } else {
          // 🎨 STANDARD Theme Resolution
          resolvedTheme = provider.getThemeForComponent(componentName, contextOverrides: contextOverrides);
          resolvedExtensions = provider.getExtensionsForComponent(componentName);
          print('🎨 [THEME-DEBUG] Context Standard Theme (Component: $componentName)');
        }

        // 🔄 FALLBACK Handling (NUR wenn kein worldThemeOverride vorhanden!)
        if (resolvedTheme == null) {
          if (fallbackTheme != null && worldThemeOverride == null) {
            // 🛡️ Fallback NUR wenn KEIN World Theme Override vorhanden
            resolvedTheme = provider.getThemeFromBundle(fallbackTheme!);
            print('🔄 [THEME-DEBUG] Context Fallback Theme: $fallbackTheme (Component: $componentName)');
          }
          resolvedTheme ??= Theme.of(context);
          if (resolvedTheme == Theme.of(context)) {
            print('⚠️ [THEME-DEBUG] Context using Flutter Default Theme (Component: $componentName)');
          }
        }

        return builder(context, resolvedTheme, resolvedExtensions);
      },
    );
  }
}

/// 🎯 Context-Sensitive Component Mixin
mixin ThemeContextMixin<T extends StatefulWidget> on State<T> {
  ThemeContextProvider? _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeContextProvider();
    _themeProvider?.addListener(_onThemeContextChanged);
  }

  @override
  void dispose() {
    _themeProvider?.removeListener(_onThemeContextChanged);
    super.dispose();
  }

  void _onThemeContextChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when theme context changes
      });
    }
  }

  /// Get context-sensitive theme for this component
  ThemeData getContextTheme({Map<String, dynamic>? contextOverrides}) {
    final theme = _themeProvider?.getThemeForComponent(
      widget.runtimeType.toString(),
      contextOverrides: contextOverrides,
    );
    return theme ?? Theme.of(context);
  }

  /// Get context-sensitive extensions for this component
  Map<String, dynamic>? getContextExtensions() {
    return _themeProvider?.getExtensionsForComponent(widget.runtimeType.toString());
  }
}