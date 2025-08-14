library;
import 'package:flutter/material.dart';
import '../base/base_component.dart';
import '../../../l10n/app_localizations.dart';
import 'background_image.dart';
import '../../../core/models/world.dart';
import '../../theme/extensions.dart';
import '../../theme/theme_manager.dart';
import '../../theme/theme_resolver.dart';
import 'package:go_router/go_router.dart';

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
      scaffold = PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await onWillPop!();
          }
        },
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
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Fallback for web/router when no native pop is available
                  context.go('/worlds');
                }
              },
            )
          : null,
    );
  }

  /// Build body with responsive padding
  Widget _buildBody(BuildContext context) {
    final screenSize = getScreenSize(context);
    final spacing = Theme.of(context).extension<AppSpacingTheme>();
    final padding = getResponsivePadding(
      context,
      mobile: spacing?.md ?? 16.0,
      tablet: spacing?.lg ?? 24.0,
      desktop: spacing?.xl ?? 32.0,
    );

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
  final World? world;
  final String? pageType;
  final BackgroundOverlayType overlayType;
  final double overlayOpacity;

  AuthScaffold({
    super.key,
    required super.body,
    String? titleText,
    super.backgroundColor,
    this.world,
    this.pageType,
    this.overlayType = BackgroundOverlayType.gradient,
    this.overlayOpacity = 0.3,
  }) : super(
          title: titleText != null ? Text(titleText) : null,
          showBackButton: true,
          centerTitle: true,
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final l10n = AppLocalizations.of(context);

    // Create the main content
    Widget mainContent = Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent
      appBar: _buildAppBar(context, colorScheme, l10n),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0), // Add spacing from app bar
        child: body,
      ),
      extendBodyBehindAppBar: true, // Extend body behind app bar
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );

    // Add WillPopScope if onWillPop is provided
    if (onWillPop != null) {
      mainContent = PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await onWillPop!();
          }
        },
        child: mainContent,
      );
    }

    // Wrap with background image and apply resolved default theme if world is provided (cached Future)
    if (world != null) {
      return _ThemedBackground(
        world: world!,
        pageType: pageType,
        overlayType: overlayType,
        overlayOpacity: overlayOpacity,
        child: mainContent,
      );
    }

    return mainContent;
  }
}

/// Specialized scaffold for world pages
class WorldScaffold extends AppScaffold {
  final World world;
  final String? pageType;
  final String themeContext;
  final BackgroundOverlayType overlayType;
  final double overlayOpacity;

  WorldScaffold({
    super.key,
    required super.body,
    required this.world,
    this.pageType,
    this.themeContext = 'pre-game',
    this.overlayType = BackgroundOverlayType.gradient,
    this.overlayOpacity = 0.3,
    String? worldName,
    List<Widget>? worldActions,
    super.floatingActionButton,
  }) : super(
          title: worldName != null ? Text(worldName) : null,
          actions: worldActions,
          showBackButton: true,
          centerTitle: false,
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final l10n = AppLocalizations.of(context);

    Widget mainContent = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, colorScheme, l10n),
      body: body,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
    );

    if (onWillPop != null) {
      mainContent = PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await onWillPop!();
          }
        },
        child: mainContent,
      );
    }

    // Apply active world theme to content on world pages
    final themedContent = Theme(
      data: ThemeManager().currentTheme,
      child: mainContent,
    );

    return SizedBox.expand(
      child: BackgroundImage(
        world: world,
        pageType: pageType,
        themeContext: themeContext,
        overlayType: overlayType,
        overlayOpacity: overlayOpacity,
        child: themedContent,
      ),
    );
  }
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

/// Main scaffold variant with themed background (uses default app theme, only background is world-driven)
class MainScaffoldWithBackground extends AppScaffold {
  final World world;
  final String? pageType;
  final String themeContext;
  final BackgroundOverlayType overlayType;
  final double overlayOpacity;

  const MainScaffoldWithBackground({
    super.key,
    required super.body,
    required this.world,
    this.pageType,
    this.themeContext = 'pre-game',
    this.overlayType = BackgroundOverlayType.gradient,
    this.overlayOpacity = 0.3,
    super.title,
    super.actions,
    super.floatingActionButton,
    super.bottomNavigationBar,
    super.drawer,
    super.endDrawer,
    super.resizeToAvoidBottomInset,
  }) : super(
          showBackButton: false,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final l10n = AppLocalizations.of(context);

    Widget mainContent = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, colorScheme, l10n),
      body: body,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );

    if (onWillPop != null) {
      mainContent = PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await onWillPop!();
          }
        },
        child: mainContent,
      );
    }

    return SizedBox.expand(
      child: BackgroundImage(
        world: world,
        pageType: pageType,
        themeContext: themeContext,
        overlayType: overlayType,
        overlayOpacity: overlayOpacity,
        child: mainContent,
      ),
    );
  }
}

/// Caches the resolved theme once to avoid rebuild/network loops
class _ThemedBackground extends StatefulWidget {
  final World world;
  final String? pageType;
  final BackgroundOverlayType overlayType;
  final double overlayOpacity;
  final Widget child;
  const _ThemedBackground({
    required this.world,
    required this.child,
    this.pageType,
    this.overlayType = BackgroundOverlayType.gradient,
    this.overlayOpacity = 0.3,
  });

  @override
  State<_ThemedBackground> createState() => _ThemedBackgroundState();
}

class _ThemedBackgroundState extends State<_ThemedBackground> {
  late final Future<ThemeData> _themeFuture;

  @override
  void initState() {
    super.initState();
    _themeFuture = ThemeResolver().resolveWorldTheme(widget.world, context: 'pre-game');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
      future: _themeFuture,
      builder: (ctx, snap) {
        final themedContent = snap.hasData ? Theme(data: snap.data!, child: widget.child) : widget.child;
        final body = SizedBox.expand(
          child: BackgroundImage(
            world: widget.world,
            pageType: widget.pageType,
            overlayType: widget.overlayType,
            overlayOpacity: widget.overlayOpacity,
            child: themedContent,
          ),
        );
        if (snap.connectionState == ConnectionState.waiting) {
          return Stack(children: [body, const Center(child: CircularProgressIndicator())]);
        }
        return body;
      },
    );
  }
}