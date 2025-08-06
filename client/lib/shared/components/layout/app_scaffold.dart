/// 🎯 App Scaffold Component
/// 
/// Professional scaffold component with theme integration
library;

import 'package:flutter/material.dart';
import '../base/base_component.dart';
import '../../../l10n/app_localizations.dart';

class AppScaffold extends BaseComponent {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.appBarElevation,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset,
    this.onWillPop,
  });

  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? appBarElevation;
  final bool extendBodyBehindAppBar;
  final bool? resizeToAvoidBottomInset;
  final Future<bool> Function()? onWillPop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final l10n = AppLocalizations.of(context);

    Widget scaffold = Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: _buildAppBar(context, colorScheme, l10n),
      body: _buildBody(context),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );

    // Add WillPopScope if onWillPop is provided
    if (onWillPop != null) {
      scaffold = WillPopScope(
        onWillPop: onWillPop,
        child: scaffold,
      );
    }

    return scaffold;
  }

  /// Build app bar
  AppBar? _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    // Don't show app bar if no title and no back button needed
    if (title == null && !showBackButton && (actions == null || actions!.isEmpty)) {
      return null;
    }

    return AppBar(
      title: title,
      centerTitle: centerTitle,
      elevation: appBarElevation ?? getElevation(context, base: 1.0),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back', // l10n?.back ?? 'Back',
              onPressed: () => Navigator.pop(context),
            )
          : null,
    );
  }

  /// Build body with responsive padding
  Widget _buildBody(BuildContext context) {
    final screenSize = getScreenSize(context);
    final padding = getResponsivePadding(context);

    // Apply responsive constraints for desktop
    if (screenSize == ScreenSize.desktop) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: padding,
            child: body,
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: body,
    );
  }
}

/// Specialized scaffold for authentication pages
class AuthScaffold extends AppScaffold {
  AuthScaffold({
    super.key,
    required super.body,
    String? titleText,
    super.backgroundColor,
  }) : super(
          title: titleText != null ? Text(titleText) : null,
          showBackButton: true,
          centerTitle: true,
        );
}

/// Specialized scaffold for world pages
class WorldScaffold extends AppScaffold {
  WorldScaffold({
    super.key,
    required super.body,
    String? worldName,
    List<Widget>? worldActions,
    super.floatingActionButton,
  }) : super(
          title: worldName != null ? Text(worldName) : null,
          actions: worldActions,
          showBackButton: true,
          centerTitle: false,
        );
}

/// Specialized scaffold for main pages (no back button)
class MainScaffold extends AppScaffold {
  const MainScaffold({
    super.key,
    required super.body,
    super.title,
    super.actions,
    super.floatingActionButton,
    super.bottomNavigationBar,
    super.drawer,
  }) : super(
          showBackButton: false,
          centerTitle: false,
        );
}