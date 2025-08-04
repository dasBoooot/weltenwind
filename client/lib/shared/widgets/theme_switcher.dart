import 'package:flutter/material.dart';
import '../../core/providers/theme_provider.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)
import '../../l10n/app_localizations.dart';
import '../dialogs/theme_switcher_fullscreen_dialog.dart';

/// 🎨 Theme-Switcher für Weltenwind
/// 
/// Modernes Theme-System mit Bundle-Support
class ThemeSwitcher extends StatefulWidget {
  /// Theme Provider für vollständige Theme-Verwaltung
  final ThemeProvider themeProvider;
  
  /// Widget als Floating Button anzeigen
  final bool isFloating;
  
  /// Widget kompakt anzeigen (nur Icons)
  final bool isCompact;

  const ThemeSwitcher({
    super.key,
    required this.themeProvider,
    this.isFloating = false,
    this.isCompact = false,
  });

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    widget.themeProvider.addListener(_onThemeProviderChanged);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _onThemeProviderChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    widget.themeProvider.removeListener(_onThemeProviderChanged);
    _animationController.dispose();
    super.dispose();
  }

  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme
    return _buildThemeSwitcher(context, Theme.of(context), null);
  }

  /// 🎨 Theme Switcher Build mit Theme
  Widget _buildThemeSwitcher(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    this.theme = theme; // Update das lokale theme field
    final isDark = theme.brightness == Brightness.dark;
    
    if (widget.isFloating) {
      return _buildFloatingButton(isDark);
    }
    
    if (widget.isCompact) {
      return _buildCompactSwitcher(isDark);
    }
    
    return _buildFullSwitcher(isDark);
  }

  /// 🔘 Floating Action Button Version
  Widget _buildFloatingButton(bool isDark) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        onPressed: _showThemeDialog,
        backgroundColor: theme.colorScheme.primary,
        child: Icon(
          _getThemeModeIcon(widget.themeProvider.themeMode),
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// 📱 Kompakte Version
  Widget _buildCompactSwitcher(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => widget.themeProvider.cycleThemeMode(),
          icon: Icon(_getThemeModeIcon(widget.themeProvider.themeMode)),
                      tooltip: AppLocalizations.of(context).tooltipThemeMode(widget.themeProvider.themeMode.displayName),
        ),
        IconButton(
          onPressed: _showThemeDialog,
          icon: const Icon(Icons.palette_rounded),
                      tooltip: AppLocalizations.of(context).tooltipThemeSettings,
        ),
      ],
    );
  }

  /// 📋 Vollständige Version
  Widget _buildFullSwitcher(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Theme Settings',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Theme Mode Auswahl
          _buildThemeModeSelector(isDark),
          const SizedBox(height: 16),
          
          // Theme Auswahl
          _buildThemeSelector(isDark),
          const SizedBox(height: 16),
          
          // Bundle Auswahl
          _buildBundleSelector(isDark),
          const SizedBox(height: 16),
          
          // Performance Stats
          _buildPerformanceStats(isDark),
        ],
      ),
    );
  }

  /// 🌓 Theme Mode Selector
  Widget _buildThemeModeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: ThemeMode.values.map((mode) {
            final isSelected = widget.themeProvider.themeMode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildModeButton(mode, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🎨 Theme Selector
  Widget _buildThemeSelector(bool isDark) {
    final availableThemes = widget.themeProvider.availableThemes;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Themes (${availableThemes.length})',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (availableThemes.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Loading themes...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: availableThemes.map((theme) {
              final isSelected = widget.themeProvider.currentTheme == theme.filename;
              return _buildThemeButton(theme, isSelected);
            }).toList(),
          ),
      ],
    );
  }

  /// 📦 Bundle Selector
  Widget _buildBundleSelector(bool isDark) {
    final availableBundles = widget.themeProvider.availableBundles;
    final currentBundle = widget.themeProvider.currentBundle;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bundle Configuration',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: availableBundles.entries.map((entry) {
            final bundleName = entry.key;
            final isSelected = currentBundle == bundleName;
            
            return _buildBundleButton(bundleName, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  /// 📊 Performance Stats
  Widget _buildPerformanceStats(bool isDark) {
    final stats = widget.themeProvider.performanceStats;
    if (stats == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Load Time: ${stats['averageLoadTimeMs'] ?? 'N/A'}ms',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Modules: ${stats['activeModules'] ?? 'N/A'}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔘 Theme Mode Button
  Widget _buildModeButton(ThemeMode mode, bool isSelected) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () => widget.themeProvider.setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              mode.icon,
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              _getThemeModeShortLabel(mode),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Theme Button
  Widget _buildThemeButton(ThemeDefinition themeDefinition, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.themeProvider.setTheme(themeDefinition.filename);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.secondary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.secondary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.palette_rounded,
              color: isSelected 
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              themeDefinition.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 📦 Bundle Button
  Widget _buildBundleButton(String bundleName, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.themeProvider.setBundle(bundleName);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.tertiary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.tertiary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              _getBundleIcon(bundleName),
              color: isSelected 
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              _getBundleDisplayName(bundleName),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 💬 Dialog für Theme-Einstellungen - Fullscreen Version
  void _showThemeDialog() {
    showThemeSettingsDialog(
      context, 
      _buildFullSwitcher(theme.brightness == Brightness.dark),
    );
  }

  // ========================================
  // 🏷️ HELPER METHODS
  // ========================================

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.auto_mode_rounded;
    }
  }

  String _getThemeModeShortLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }
  
  /// 📦 Bundle Icon Helper
  IconData _getBundleIcon(String bundleName) {
    switch (bundleName) {
      case 'pre-game-minimal':
        return Icons.speed_rounded;
      case 'world-preview':
        return Icons.preview_rounded;
      case 'full-gaming':
        return Icons.games_rounded;
      case 'performance-optimized':
        return Icons.tune_rounded;
      case 'accessibility-enhanced':
        return Icons.accessibility_rounded;
      case 'developer-preview':
        return Icons.developer_mode_rounded;
      default:
        return Icons.extension_rounded;
    }
  }
  
  /// 📦 Bundle Display Name Helper
  String _getBundleDisplayName(String bundleName) {
    switch (bundleName) {
      case 'pre-game-minimal':
        return 'Minimal';
      case 'world-preview':
        return 'Preview';
      case 'full-gaming':
        return 'Gaming';
      case 'performance-optimized':
        return 'Performance';
      case 'accessibility-enhanced':
        return 'A11y';
      case 'developer-preview':
        return 'Dev';
      default:
        return bundleName;
    }
  }
}