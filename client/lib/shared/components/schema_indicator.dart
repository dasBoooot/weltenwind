import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../core/providers/theme_context_provider.dart';

/// 🛠️ Schema Indicator Mode
enum SchemaIndicatorMode {
  compact,
  normal,
  expanded,
}

/// 🛠️ Schema Indicator Position
enum SchemaIndicatorPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
  floating,
}

/// 🛠️ Schema Indicator based on Schema Indicator Schema
/// 
/// Development helper for live schema visualization, debugging, and theme analysis
class SchemaIndicator extends StatefulWidget {
  final bool enabled;
  final SchemaIndicatorPosition position;
  final SchemaIndicatorMode mode;
  final bool draggable;
  final bool collapsible;
  final Duration refreshInterval;
  final VoidCallback? onDismiss;

  const SchemaIndicator({
    super.key,
    this.enabled = false,
    this.position = SchemaIndicatorPosition.bottomRight,
    this.mode = SchemaIndicatorMode.normal,
    this.draggable = true,
    this.collapsible = true,
    this.refreshInterval = const Duration(seconds: 1),
    this.onDismiss,
  });

  @override
  State<SchemaIndicator> createState() => _SchemaIndicatorState();
}

class _SchemaIndicatorState extends State<SchemaIndicator> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isVisible = false;
  bool _isExpanded = false;

  Offset _dragOffset = Offset.zero;
  
  Map<String, dynamic>? _currentExtensions;
  String? _currentThemeName;
  List<String> _loadedModules = [];
  List<Map<String, dynamic>> _validationErrors = [];

  /// Current environment check
  bool get _isDevelopment {
    bool isDev = false;
    assert(isDev = true); // This only executes in debug mode
    return isDev;
  }

  @override
  void initState() {
    super.initState();
    
    // Only enable in development by default
    _isVisible = widget.enabled && _isDevelopment;
    
    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Pulse animation for updates
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    if (_isVisible) {
      _slideController.forward();
    }
    
    // Start data refresh timer
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startRefreshTimer() {
    Future.delayed(widget.refreshInterval, () {
      if (mounted && _isVisible) {
        _refreshData();
        _startRefreshTimer();
      }
    });
  }

  void _refreshData() {
    setState(() {
      _currentExtensions = <String, dynamic>{}; // TODO: Get from ThemeContextConsumer
      _currentThemeName = 'Current Theme'; // Would get from service
      _loadedModules = _getLoadedModules();
      _validateCurrentSchema();
    });
    
    // Pulse animation on data update
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  List<String> _getLoadedModules() {
    // Mock data - in real implementation would get from ModularThemeService
    return [
      'main.schema.json',
      'gaming/hud.schema.json',
      'effects/visual.schema.json',
      'accessibility.schema.json',
    ];
  }

  void _validateCurrentSchema() {
    // Mock validation - in real implementation would validate current schema
    _validationErrors = [
      if (_currentExtensions == null) {
        'warning': 'No theme extensions loaded',
        'path': 'extensions',
        'message': 'Consider loading a theme with fantasy extensions',
      },
    ];
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
    
    if (_isVisible) {
      _slideController.forward();
      _refreshData();
    } else {
      _slideController.reverse();
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schema data copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportSchema() {
    final schemaData = {
      'theme': _currentThemeName,
      'extensions': _currentExtensions,
      'modules': _loadedModules,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(schemaData);
    _copyToClipboard(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return _buildToggleButton();
    }

    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'SchemaIndicator',
      contextOverrides: {
        'mode': widget.mode.name,
        'visible': _isVisible.toString(),
        'animated': 'true',
      },
      builder: (context, contextTheme, extensions) {
        return _buildIndicatorContent(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildIndicatorContent(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Stack(
      children: [
        // Main indicator
        AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildIndicator(theme),
              ),
            );
          },
        ),
        
        // Toggle button when collapsed
        if (!_isExpanded)
          _buildToggleButton(),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton.small(
        onPressed: _isVisible ? _toggleExpanded : _toggleVisibility,
        backgroundColor: _getBackgroundColor().withValues(alpha: 0.9),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Icon(
                _isVisible 
                    ? (_isExpanded ? Icons.close : Icons.code)
                    : Icons.bug_report,
                color: _getForegroundColor(),
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onPanStart: widget.draggable ? (details) {
          // Dragging state tracking removed
        } : null,
        onPanUpdate: widget.draggable ? (details) {
          setState(() {
            _dragOffset += details.delta;
          });
        } : null,
        onPanEnd: widget.draggable ? (details) {
          // Dragging state tracking removed
        } : null,
        child: Transform.translate(
          offset: _dragOffset,
          child: Container(
            width: _getIndicatorWidth(),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: _getIndicatorDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
                
                // Content
                if (_isExpanded)
                  Flexible(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAccentColor().withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bug_report,
            size: 16,
            color: _getAccentColor(),
          ),
          const SizedBox(width: 8),
          Text(
            'Schema Debug',
            style: TextStyle(
              color: _getForegroundColor(),
              fontSize: _getFontSize(),
              fontWeight: FontWeight.bold,
              fontFamily: _getFontFamily(),
            ),
          ),
          const Spacer(),
          if (widget.collapsible)
            GestureDetector(
              onTap: _toggleExpanded,
              child: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: _getForegroundColor(),
              ),
            ),
          const SizedBox(width: 8),
          if (widget.onDismiss != null)
            GestureDetector(
              onTap: widget.onDismiss,
              child: Icon(
                Icons.close,
                size: 16,
                color: _getForegroundColor(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Theme
          _buildInfoSection('Theme', _currentThemeName ?? 'Unknown'),
          
          const SizedBox(height: 8),
          
          // Loaded Modules
          _buildInfoSection('Modules', '${_loadedModules.length} loaded'),
          
          const SizedBox(height: 8),
          
          // Extensions
          if (_currentExtensions != null)
            _buildExtensionsSection(),
          
          const SizedBox(height: 8),
          
          // Validation Status
          _buildValidationSection(),
          
          const SizedBox(height: 8),
          
          // Actions
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: _getForegroundColor().withValues(alpha: 0.7),
            fontSize: _getFontSize(),
            fontFamily: _getFontFamily(),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: _getForegroundColor(),
              fontSize: _getFontSize(),
              fontFamily: _getFontFamily(),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExtensionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Extensions:',
          style: TextStyle(
            color: _getForegroundColor().withValues(alpha: 0.7),
            fontSize: _getFontSize(),
            fontFamily: _getFontFamily(),
          ),
        ),
        const SizedBox(height: 4),
        ...(_currentExtensions?.entries.take(3).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '• ${entry.key}',
              style: TextStyle(
                color: _getAccentColor(),
                fontSize: _getFontSize() - 1,
                fontFamily: _getFontFamily(),
              ),
            ),
          );
        }) ?? []),
      ],
    );
  }

  Widget _buildValidationSection() {
    final hasErrors = _validationErrors.isNotEmpty;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasErrors ? Icons.warning : Icons.check_circle,
          size: 14,
          color: hasErrors ? _getWarningColor() : _getSuccessColor(),
        ),
        const SizedBox(width: 4),
        Text(
          hasErrors ? '${_validationErrors.length} issues' : 'Valid',
          style: TextStyle(
            color: hasErrors ? _getWarningColor() : _getSuccessColor(),
            fontSize: _getFontSize(),
            fontFamily: _getFontFamily(),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.copy,
          tooltip: 'Copy Schema',
          onPressed: _exportSchema,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.refresh,
          tooltip: 'Refresh',
          onPressed: _refreshData,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.info,
          tooltip: 'Info',
          onPressed: () {
            // Show detailed info dialog
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _getAccentColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 14,
            color: _getAccentColor(),
          ),
        ),
      ),
    );
  }

  /// Get indicator decoration
  BoxDecoration _getIndicatorDecoration() {
    return BoxDecoration(
      color: _getBackgroundColor(),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      boxShadow: _getShadow() ? [
        BoxShadow(
          color: _getShadowColor(),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ] : null,
    );
  }

  /// Get indicator width based on mode
  double _getIndicatorWidth() {
    switch (widget.mode) {
      case SchemaIndicatorMode.compact:
        return 200;
      case SchemaIndicatorMode.normal:
        return 280;
      case SchemaIndicatorMode.expanded:
        return 360;
    }
  }

  // Schema-based styling getters
  Color _getBackgroundColor() => const Color(0x90000000); // Debug-specific: keeps contrast
  Color _getForegroundColor() => const Color(0xFFFFFFFF); // Debug-specific: keeps contrast
  Color _getAccentColor() => const Color(0xFF007AFF); // Debug-specific: keeps contrast
  Color _getWarningColor() => const Color(0xFFFF9500); // Debug-specific: keeps contrast

  Color _getShadowColor() => const Color(0x4D000000); // Debug-specific: subtle shadow
  Color _getSuccessColor() => const Color(0xFF34C759); // Debug-specific: success green
  
  String _getFontFamily() => 'monospace'; // Schema default
  double _getFontSize() => 11.0; // Schema default
  double _getBorderRadius() => 8.0; // Schema default
  bool _getShadow() => true; // Schema default
}

/// 🛠️ Schema Indicator Manager
class SchemaIndicatorManager {
  static bool _isEnabled = false;
  static OverlayEntry? _overlayEntry;
  
  /// Enable/disable globally
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// Check if enabled
  static bool get isEnabled => _isEnabled;
  
  /// Show indicator as overlay
  static void show(BuildContext context) {
    if (_overlayEntry != null) return;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => SchemaIndicator(
        enabled: true,
        onDismiss: hide,
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  /// Hide indicator
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  /// Toggle indicator
  static void toggle(BuildContext context) {
    if (_overlayEntry != null) {
      hide();
    } else {
      show(context);
    }
  }
}

/// 🛠️ Schema Indicator Helpers
class SchemaIndicatorHelpers {
  /// Debug extension for easy access
  static Widget debugOverlay({
    required Widget child,
    bool enabled = false,
  }) {
    return Stack(
      children: [
        child,
        if (enabled)
          const SchemaIndicator(enabled: true),
      ],
    );
  }
  
  /// Hot key listener
  static Widget withHotkey({
    required Widget child,
    String hotkey = 'Ctrl+D',
  }) {
    return Builder(
      builder: (context) => KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          // Simplified hotkey detection - in real implementation would parse hotkey string
          if (HardwareKeyboard.instance.isControlPressed && event.logicalKey.keyLabel == 'D') {
            SchemaIndicatorManager.toggle(context);
          }
        },
        child: child,
      ),
    );
  }
  
  /// Development-only wrapper
  static Widget developmentOnly({
    required Widget child,
    Widget? productionChild,
  }) {
    bool isDevelopment = false;
    assert(isDevelopment = true);
    
    if (isDevelopment) {
      return child;
    } else {
      return productionChild ?? const SizedBox.shrink();
    }
  }
}