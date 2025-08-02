import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config/logger.dart';

/// 🎨 World Theme Types for Theme Selection
enum WorldType { 
  fantasy, scifi, medieval, modern, horror, cyberpunk, steampunk, nature 
}

/// 🎯 Theme Context Manager für kontextabhängige Theme-Bereitstellung
/// 
/// Verwaltet verschiedene Kontext-Modi:
/// - weltId: Welt-spezifische Themes
/// - playerState: Spielerstatus-basierte Modifikationen  
/// - uiContext: UI-Modus-spezifische Sub-Themes
/// - platformContext: Plattform-basierte Anpassungen
/// - visualMode: Dark/Light/HighContrast Modi
class ThemeContextManager extends ChangeNotifier {
  static final ThemeContextManager _instance = ThemeContextManager._internal();
  factory ThemeContextManager() => _instance;
  ThemeContextManager._internal();

  // Context State
  WorldContext? _worldContext;
  PlayerStateContext? _playerStateContext;
  UIContext _uiContext = UIContext.main;
  PlatformContext _platformContext = PlatformContext.auto;
  VisualModeContext _visualModeContext = VisualModeContext.auto;

  // Context History for Debugging
  final List<ThemeContextEvent> _contextHistory = [];
  
  // Stream Controllers for Live Updates
  final StreamController<ThemeContextChange> _contextChangeController = 
      StreamController<ThemeContextChange>.broadcast();

  /// Current Context Getters
  WorldContext? get worldContext => _worldContext;
  PlayerStateContext? get playerStateContext => _playerStateContext;
  UIContext get uiContext => _uiContext;
  PlatformContext get platformContext => _platformContext;
  VisualModeContext get visualModeContext => _visualModeContext;

  /// Context Change Stream
  Stream<ThemeContextChange> get contextChanges => _contextChangeController.stream;

  /// Context History
  List<ThemeContextEvent> get contextHistory => List.unmodifiable(_contextHistory);

  /// 🌍 Set World Context
  Future<void> setWorldContext(String? worldId, {WorldType? worldType}) async {
    final oldContext = _worldContext;
    
    if (worldId == null) {
      _worldContext = null;
    } else {
      _worldContext = WorldContext(
        worldId: worldId,
        worldType: worldType ?? WorldType.fantasy,
        bundleId: _generateBundleIdForWorld(worldId, worldType),
        timestamp: DateTime.now(),
      );
    }

    await _notifyContextChange(
      type: ThemeContextType.world,
      oldValue: oldContext?.bundleId,
      newValue: _worldContext?.bundleId,
      reason: 'World change to $worldId',
    );
  }

  /// 👤 Set Player State Context
  Future<void> setPlayerStateContext(PlayerState? playerState) async {
    final oldContext = _playerStateContext;
    
    if (playerState == null) {
      _playerStateContext = null;
    } else {
      _playerStateContext = PlayerStateContext(
        state: playerState,
        intensity: _calculateStateIntensity(playerState),
        effects: _getEffectsForState(playerState),
        timestamp: DateTime.now(),
      );
    }

    await _notifyContextChange(
      type: ThemeContextType.playerState,
      oldValue: oldContext?.state.toString(),
      newValue: _playerStateContext?.state.toString(),
      reason: 'Player state change to $playerState',
    );
  }

  /// 🖥️ Set UI Context
  Future<void> setUIContext(UIContext uiContext) async {
    final oldContext = _uiContext;
    _uiContext = uiContext;

    await _notifyContextChange(
      type: ThemeContextType.ui,
      oldValue: oldContext.toString(),
      newValue: uiContext.toString(),
      reason: 'UI context change to $uiContext',
    );
  }

  /// 📱 Set Platform Context
  Future<void> setPlatformContext(PlatformContext platformContext) async {
    final oldContext = _platformContext;
    _platformContext = platformContext;

    await _notifyContextChange(
      type: ThemeContextType.platform,
      oldValue: oldContext.toString(),
      newValue: platformContext.toString(),
      reason: 'Platform context change to $platformContext',
    );
  }

  /// 🎨 Set Visual Mode Context
  Future<void> setVisualModeContext(VisualModeContext visualModeContext) async {
    final oldContext = _visualModeContext;
    _visualModeContext = visualModeContext;

    await _notifyContextChange(
      type: ThemeContextType.visualMode,
      oldValue: oldContext.toString(),
      newValue: visualModeContext.toString(),
      reason: 'Visual mode change to $visualModeContext',
    );
  }

  /// 🎯 Get Complete Context for Theme Resolution
  ThemeContext getCompleteContext() {
    return ThemeContext(
      worldContext: _worldContext,
      playerStateContext: _playerStateContext,
      uiContext: _uiContext,
      platformContext: _platformContext,
      visualModeContext: _visualModeContext,
      priority: _calculateContextPriority(),
      timestamp: DateTime.now(),
    );
  }

  /// 📦 Get Bundle ID for Current Context
  String getBundleIdForContext() {
    // Priority: World > UI > Platform > Default
    if (_worldContext != null) {
      return _worldContext!.bundleId;
    }
    
    return switch (_uiContext) {
      UIContext.login => 'pre-game-minimal',
      UIContext.worldSelection => 'world-preview', 
      UIContext.inGame => 'full-gaming',
      UIContext.modal => 'performance-optimized',
      UIContext.overlay => 'performance-optimized',
      UIContext.dialog => 'performance-optimized',
      UIContext.debug => 'pre-game-minimal',
      _ => 'pre-game-minimal',
    };
  }

  /// 🔄 Reset Context (for logout, world exit)
  Future<void> resetContext({bool keepPlatform = true}) async {
    _worldContext = null;
    _playerStateContext = null;
    _uiContext = UIContext.main;
    
    if (!keepPlatform) {
      _platformContext = PlatformContext.auto;
    }

    await _notifyContextChange(
      type: ThemeContextType.reset,
      oldValue: 'mixed',
      newValue: 'reset',
      reason: 'Context reset',
    );
  }

  /// 📊 Get Context Debug Information
  Map<String, dynamic> getContextDebugInfo() {
    return {
      'current': {
        'world': _worldContext?.toJson(),
        'playerState': _playerStateContext?.toJson(),
        'ui': _uiContext.toString(),
        'platform': _platformContext.toString(),
        'visualMode': _visualModeContext.toString(),
      },
      'bundleId': getBundleIdForContext(),
      'priority': _calculateContextPriority(),
      'historyLength': _contextHistory.length,
      'lastChange': _contextHistory.isNotEmpty 
          ? _contextHistory.last.timestamp.toIso8601String()
          : null,
    };
  }

  /// 🔔 Private: Notify Context Change
  Future<void> _notifyContextChange({
    required ThemeContextType type,
    String? oldValue,
    String? newValue,
    required String reason,
  }) async {
    final event = ThemeContextEvent(
      type: type,
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
      timestamp: DateTime.now(),
    );

    _contextHistory.add(event);
    
    // Keep history manageable
    if (_contextHistory.length > 50) {
      _contextHistory.removeAt(0);
    }

    final change = ThemeContextChange(
      event: event,
      newContext: getCompleteContext(),
      bundleId: getBundleIdForContext(),
    );

    _contextChangeController.add(change);
    notifyListeners();

    AppLogger.app.i('🎯 Theme Context Change: ${type.name} → $newValue ($reason)');
  }

  /// 🎮 Private: Generate Bundle ID for World
  String _generateBundleIdForWorld(String worldId, WorldType? worldType) {
    final type = worldType ?? WorldType.fantasy;
    
    return switch (type) {
            WorldType.fantasy => 'full-gaming',
      WorldType.scifi => 'full-gaming',
      WorldType.medieval => 'full-gaming',
      WorldType.modern => 'full-gaming',
      _ => 'full-gaming',
    };
  }

  /// 🎲 Private: Calculate State Intensity
  double _calculateStateIntensity(PlayerState state) {
    return switch (state) {
      PlayerState.normal => 0.0,
      PlayerState.buffed => 0.7,
      PlayerState.debuffed => 0.6,
      PlayerState.cursed => 0.9,
      PlayerState.blessed => 0.8,
      PlayerState.poisoned => 0.5,
      PlayerState.burning => 0.8,
      PlayerState.frozen => 0.6,
      PlayerState.invisible => 0.3,
      PlayerState.invincible => 1.0,
    };
  }

  /// ✨ Private: Get Effects for State
  List<String> _getEffectsForState(PlayerState state) {
    return switch (state) {
      PlayerState.normal => [],
      PlayerState.buffed => ['glow', 'sparkles'],
      PlayerState.debuffed => ['desaturate', 'blur'],
      PlayerState.cursed => ['dark_glow', 'corruption'],
      PlayerState.blessed => ['holy_glow', 'light_rays'],
      PlayerState.poisoned => ['green_tint', 'bubbles'],
      PlayerState.burning => ['fire_glow', 'heat_wave'],
      PlayerState.frozen => ['ice_crystals', 'frost'],
      PlayerState.invisible => ['transparency', 'shimmer'],
      PlayerState.invincible => ['golden_aura', 'energy_field'],
    };
  }

  /// 📈 Private: Calculate Context Priority
  int _calculateContextPriority() {
    int priority = 0;
    
    if (_worldContext != null) priority += 100;
    if (_playerStateContext != null) priority += 50;
    priority += _uiContext.index * 10;
    priority += _visualModeContext.index * 5;
    
    return priority;
  }

  @override
  void dispose() {
    _contextChangeController.close();
    super.dispose();
  }
}

/// 🌍 World Context Data Class
class WorldContext {
  final String worldId;
  final WorldType worldType;
  final String bundleId;
  final DateTime timestamp;

  WorldContext({
    required this.worldId,
    required this.worldType,
    required this.bundleId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'worldId': worldId,
    'worldType': worldType.name,
    'bundleId': bundleId,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 👤 Player State Context Data Class
class PlayerStateContext {
  final PlayerState state;
  final double intensity;
  final List<String> effects;
  final DateTime timestamp;

  PlayerStateContext({
    required this.state,
    required this.intensity,
    required this.effects,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'state': state.name,
    'intensity': intensity,
    'effects': effects,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 🎯 Complete Theme Context
class ThemeContext {
  final WorldContext? worldContext;
  final PlayerStateContext? playerStateContext;
  final UIContext uiContext;
  final PlatformContext platformContext;
  final VisualModeContext visualModeContext;
  final int priority;
  final DateTime timestamp;

  ThemeContext({
    this.worldContext,
    this.playerStateContext,
    required this.uiContext,
    required this.platformContext,
    required this.visualModeContext,
    required this.priority,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'world': worldContext?.toJson(),
    'playerState': playerStateContext?.toJson(),
    'ui': uiContext.name,
    'platform': platformContext.name,
    'visualMode': visualModeContext.name,
    'priority': priority,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 🔄 Context Change Event
class ThemeContextEvent {
  final ThemeContextType type;
  final String? oldValue;
  final String? newValue;
  final String reason;
  final DateTime timestamp;

  ThemeContextEvent({
    required this.type,
    this.oldValue,
    this.newValue,
    required this.reason,
    required this.timestamp,
  });
}

/// 📡 Context Change Notification
class ThemeContextChange {
  final ThemeContextEvent event;
  final ThemeContext newContext;
  final String bundleId;

  ThemeContextChange({
    required this.event,
    required this.newContext,
    required this.bundleId,
  });
}

/// 🏷️ Enums for Context Types
enum ThemeContextType { world, playerState, ui, platform, visualMode, reset }

enum UIContext { 
  main, login, register, worldSelection, inGame, 
  modal, overlay, dialog, settings, debug 
}

enum PlatformContext { auto, mobile, tablet, desktop, web }

enum VisualModeContext { auto, light, dark, highContrast, colorBlind }

enum PlayerState { 
  normal, buffed, debuffed, cursed, blessed, 
  poisoned, burning, frozen, invisible, invincible 
}