import 'package:flutter/material.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)

/// 🏗️ App Scaffold based on Schema Configuration
/// 
/// Main layout structure with background gradient, AppBar integration, and schema-based configuration
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool showBackgroundGradient;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = false,
    this.showBackgroundGradient = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return _buildScaffold(context, Theme.of(context), null);
  }

  Widget _buildScaffold(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Scaffold(
      appBar: _shouldShowAppBar() ? appBar : null,
      body: _buildBody(context, theme, extensions),
      floatingActionButton: _shouldShowFloatingActionButton() ? floatingActionButton : null,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: _getResizeToAvoidBottomInset(),
      extendBodyBehindAppBar: _getExtendBodyBehindAppBar(),
      backgroundColor: _getBackgroundColor(theme, extensions),
    );
  }

  /// Build body with optional background gradient
  Widget _buildBody(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    if (!_shouldShowBackgroundGradient()) {
      return body;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(theme, extensions),
      ),
      child: body,
    );
  }

  /// Get background gradient from schema and extensions
  LinearGradient? _getBackgroundGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    if (!showBackgroundGradient) return null;

    // Try to get magic gradient from extensions first
    if (extensions != null && extensions.containsKey('magicGradient')) {
      final colors = (extensions['magicGradient'] as List<dynamic>?)
          ?.map((color) => _parseColor(color.toString()) ?? theme.colorScheme.surface)
          .toList();
      
      if (colors != null && colors.length >= 2) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.map((color) => color.withValues(alpha: 0.1)).toList(),
        );
      }
    }

    // Default theme-based gradient
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.surface,
        theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ],
    );
  }

  /// Get background color from schema
  Color? _getBackgroundColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (backgroundColor != null) return backgroundColor;
    
    // Schema default: transparent when gradient is shown
    if (showBackgroundGradient) {
      return Colors.transparent;
    }
    
    return theme.colorScheme.surface;
  }

  /// Check if AppBar should be shown from schema
  bool _shouldShowAppBar() {
    // Schema default: true
    return true;
  }

  /// Check if FloatingActionButton should be shown from schema
  bool _shouldShowFloatingActionButton() {
    // Schema default: false
    return false;
  }

  /// Get extendBodyBehindAppBar from schema
  bool _getExtendBodyBehindAppBar() {
    // Schema default: false, but allow override
    return extendBodyBehindAppBar;
  }

  /// Get resizeToAvoidBottomInset from schema
  bool? _getResizeToAvoidBottomInset() {
    if (resizeToAvoidBottomInset != null) return resizeToAvoidBottomInset;
    
    // Schema default: true
    return true;
  }

  /// Check if background gradient should be shown from schema
  bool _shouldShowBackgroundGradient() {
    // Schema default: true, but allow override
    return showBackgroundGradient;
  }

  /// Helper: Parse color from hex string
  Color? _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }
}

/// 🏗️ Scaffold Builder Helper
/// 
/// Convenient builder for common scaffold patterns
class AppScaffoldBuilder {
  /// Create scaffold with AppBar
  static Widget withAppBar({
    required Widget body,
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    bool showBackgroundGradient = true,
  }) {
    return Builder(
      builder: (context) => AppScaffold(
        appBar: AppBar(
          title: titleWidget ?? (title != null ? Text(title) : null),
          actions: actions,
        ),
        body: body,
        showBackgroundGradient: showBackgroundGradient,
      ),
    );
  }

  /// Create scaffold without AppBar
  static Widget withoutAppBar({
    required Widget body,
    bool showBackgroundGradient = true,
  }) {
    return AppScaffold(
      appBar: null,
      body: body,
      showBackgroundGradient: showBackgroundGradient,
    );
  }

  /// Create scaffold with custom background
  static Widget withCustomBackground({
    required Widget body,
    PreferredSizeWidget? appBar,
    Color? backgroundColor,
  }) {
    return AppScaffold(
      appBar: appBar,
      body: body,
      backgroundColor: backgroundColor,
      showBackgroundGradient: false,
    );
  }

  /// Create scaffold for forms/auth pages
  static Widget forAuth({
    required Widget body,
    String? title,
  }) {
    return Builder(
      builder: (context) => AppScaffold(
        appBar: title != null 
            ? AppBar(
                title: Text(title),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
            : null,
        body: body,
        showBackgroundGradient: true,
        extendBodyBehindAppBar: title != null,
      ),
    );
  }

  /// Create scaffold for game pages
  static Widget forGame({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? floatingActionButton,
  }) {
    return AppScaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      showBackgroundGradient: true,
      extendBodyBehindAppBar: true,
    );
  }
}