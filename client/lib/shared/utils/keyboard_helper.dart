import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ⌨️ Keyboard Navigation Helper for Gaming UI
class KeyboardHelper {
  /// Gaming-specific key mappings
  static const Map<String, LogicalKeyboardKey> gamingKeys = {
    'inventory': LogicalKeyboardKey.keyI,
    'map': LogicalKeyboardKey.keyM,
    'settings': LogicalKeyboardKey.escape,
    'chat': LogicalKeyboardKey.enter,
    'help': LogicalKeyboardKey.f1,
  };

  /// Handle arrow key navigation
  static bool handleArrowKeys(
    KeyEvent event,
    VoidCallback? onUp,
    VoidCallback? onDown,
    VoidCallback? onLeft,
    VoidCallback? onRight,
  ) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          onUp?.call();
          return true;
        case LogicalKeyboardKey.arrowDown:
          onDown?.call();
          return true;
        case LogicalKeyboardKey.arrowLeft:
          onLeft?.call();
          return true;
        case LogicalKeyboardKey.arrowRight:
          onRight?.call();
          return true;
      }
    }
    return false;
  }

  /// Handle gaming shortcuts
  static bool handleGamingShortcuts(
    KeyEvent event,
    Map<String, VoidCallback> shortcuts,
  ) {
    if (event is KeyDownEvent) {
      for (final entry in gamingKeys.entries) {
        if (event.logicalKey == entry.value && shortcuts.containsKey(entry.key)) {
          shortcuts[entry.key]?.call();
          return true;
        }
      }
    }
    return false;
  }

  /// Create keyboard listener widget
  static Widget listener({
    required Widget child,
    VoidCallback? onUp,
    VoidCallback? onDown,
    VoidCallback? onLeft,
    VoidCallback? onRight,
    VoidCallback? onEnter,
    VoidCallback? onEscape,
    Map<String, VoidCallback>? gamingShortcuts,
    FocusNode? focusNode,
  }) {
    return KeyboardListener(
      focusNode: focusNode ?? FocusNode(),
      onKeyEvent: (event) {
        // Handle arrow keys
        if (handleArrowKeys(event, onUp, onDown, onLeft, onRight)) {
          return;
        }

        // Handle common keys
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.enter:
              onEnter?.call();
              break;
            case LogicalKeyboardKey.escape:
              onEscape?.call();
              break;
          }
        }

        // Handle gaming shortcuts
        if (gamingShortcuts != null) {
          handleGamingShortcuts(event, gamingShortcuts);
        }
      },
      child: child,
    );
  }

  /// Tab navigation helper
  static Widget tabNavigator({
    required Widget child,
    required List<FocusNode> focusNodes,
    int initialIndex = 0,
  }) {
    return _TabNavigatorWidget(
      focusNodes: focusNodes,
      initialIndex: initialIndex,
      child: child,
    );
  }
}

/// Internal tab navigator widget
class _TabNavigatorWidget extends StatefulWidget {
  final Widget child;
  final List<FocusNode> focusNodes;
  final int initialIndex;

  const _TabNavigatorWidget({
    required this.child,
    required this.focusNodes,
    this.initialIndex = 0,
  });

  @override
  State<_TabNavigatorWidget> createState() => _TabNavigatorWidgetState();
}

class _TabNavigatorWidgetState extends State<_TabNavigatorWidget> {
  late int _currentIndex;
  late FocusNode _containerFocusNode;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _containerFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _containerFocusNode.dispose();
    super.dispose();
  }

  void _focusNext() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.focusNodes.length;
      widget.focusNodes[_currentIndex].requestFocus();
    });
  }

  void _focusPrevious() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.focusNodes.length) % widget.focusNodes.length;
      widget.focusNodes[_currentIndex].requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _containerFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.tab) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              _focusPrevious();
            } else {
              _focusNext();
            }
          }
        }
      },
      child: widget.child,
    );
  }
}

/// Gaming HUD keyboard shortcuts
class GamingKeyboardShortcuts {
  static Map<String, VoidCallback> getHudShortcuts({
    VoidCallback? toggleInventory,
    VoidCallback? toggleMap,
    VoidCallback? toggleSettings,
    VoidCallback? toggleChat,
    VoidCallback? showHelp,
  }) {
    return {
      'inventory': toggleInventory ?? () {},
      'map': toggleMap ?? () {},
      'settings': toggleSettings ?? () {},
      'chat': toggleChat ?? () {},
      'help': showHelp ?? () {},
    };
  }

  /// Pre-game keyboard shortcuts
  static Map<String, VoidCallback> getPreGameShortcuts({
    VoidCallback? quickJoin,
    VoidCallback? refreshWorlds,
    VoidCallback? showSettings,
    VoidCallback? showHelp,
  }) {
    return {
      if (quickJoin != null) 'enter': quickJoin,
      if (refreshWorlds != null) 'refresh': refreshWorlds,
      if (showSettings != null) 'settings': showSettings,
      if (showHelp != null) 'help': showHelp,
    };
  }
}