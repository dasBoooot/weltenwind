import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
            style: theme.elevatedButton.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(
                _blendMagicColor(theme.colorScheme.primary)
              ),
            ),
          ),
        ),
        'portal' => theme.copyWith(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: theme.elevatedButton.style?.copyWith(
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

  @override
  void dispose() {
    _contextManager.dispose();
    super.dispose();
  }
}

/// 🎭 Context-Sensitive Theme Consumer Widget
class ThemeContextConsumer extends StatelessWidget {
  final String componentName;
  final Map<String, dynamic>? contextOverrides;
  final Widget Function(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) builder;

  const ThemeContextConsumer({
    super.key,
    required this.componentName,
    required this.builder,
    this.contextOverrides,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeContextProvider(),
      builder: (context, child) {
        final provider = ThemeContextProvider();
        final theme = provider.getThemeForComponent(componentName, contextOverrides: contextOverrides);
        final extensions = provider.getExtensionsForComponent(componentName);
        
        if (theme == null) {
          // Fallback to standard theme
          return builder(context, Theme.of(context), extensions);
        }
        
        return builder(context, theme, extensions);
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