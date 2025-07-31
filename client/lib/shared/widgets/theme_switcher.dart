import 'package:flutter/material.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';
import '../components/index.dart';
import '../../theme/fantasy_theme.dart';


/// 🎨 Theme-Switcher für Weltenwind
/// 
/// Ermöglicht das Umschalten zwischen verschiedenen Theme-Modi und Styles
class ThemeSwitcher extends StatefulWidget {
  /// Aktueller ThemeMode 
  final ThemeMode currentThemeMode;
  
  /// Callback wenn ThemeMode geändert wird
  final ValueChanged<ThemeMode> onThemeModeChanged;
  
  /// Aktueller Fantasy-Style Preset
  final FantasyStylePreset currentStylePreset;
  
  /// Callback wenn Style-Preset geändert wird
  final ValueChanged<FantasyStylePreset> onStylePresetChanged;
  
  /// Widget als Floating Button anzeigen
  final bool isFloating;
  
  /// Widget kompakt anzeigen (nur Icons)
  final bool isCompact;

  const ThemeSwitcher({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    required this.currentStylePreset,
    required this.onStylePresetChanged,
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        backgroundColor: AppColors.primaryAccent,
        child: Icon(
          _getThemeModeIcon(widget.currentThemeMode),
          color: Colors.white,
        ),
      ),
    );
  }

  /// 📱 Kompakter Switcher (nur Icons)
  Widget _buildCompactSwitcher(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme Mode Toggle
        IconButton(
          onPressed: _cycleThemeMode,
          icon: Icon(
            _getThemeModeIcon(widget.currentThemeMode),
            color: AppColors.primaryAccent,
          ),
          tooltip: _getThemeModeLabel(widget.currentThemeMode),
        ),
        const SizedBox(width: AppSpacing.xs),
        // Style Preset Toggle
        IconButton(
          onPressed: _cycleStylePreset,
          icon: Icon(
            _getStylePresetIcon(widget.currentStylePreset),
            color: AppColors.secondary,
          ),
          tooltip: _getStylePresetLabel(widget.currentStylePreset),
        ),
      ],
    );
  }

  /// 🎛️ Vollständiger Switcher
  Widget _buildFullSwitcher(bool isDark) {
    return AppFrame.magic(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: AppColors.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Theme Settings',
                style: AppTypography.labelLarge(isDark: isDark),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Theme Mode Auswahl
          _buildThemeModeSelector(isDark),
          const SizedBox(height: AppSpacing.md),
          
          // Style Preset Auswahl
          _buildStylePresetSelector(isDark),
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
          style: AppTypography.bodySmall(isDark: isDark),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: ThemeMode.values.map((mode) {
            final isSelected = widget.currentThemeMode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildModeButton(mode, isSelected, isDark),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🎭 Style Preset Selector
  Widget _buildStylePresetSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fantasy Style',
          style: AppTypography.bodySmall(isDark: isDark),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: FantasyStylePreset.values.map((preset) {
            final isSelected = widget.currentStylePreset == preset;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildPresetButton(preset, isSelected, isDark),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🔘 Theme Mode Button
  Widget _buildModeButton(ThemeMode mode, bool isSelected, bool isDark) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () => widget.onThemeModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryAccent.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryAccent 
                : AppColors.surfaceGray.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              _getThemeModeIcon(mode),
              color: isSelected 
                  ? AppColors.primaryAccent 
                  : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              _getThemeModeShortLabel(mode),
              style: AppTypography.bodySmall(
                color: isSelected 
                    ? AppColors.primaryAccent 
                    : AppColors.textSecondary,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Style Preset Button
  Widget _buildPresetButton(FantasyStylePreset preset, bool isSelected, bool isDark) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () => widget.onStylePresetChanged(preset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.secondary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? AppColors.secondary 
                : AppColors.surfaceGray.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              _getStylePresetIcon(preset),
              color: isSelected 
                  ? AppColors.secondary 
                  : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              _getStylePresetShortLabel(preset),
              style: AppTypography.bodySmall(
                color: isSelected 
                    ? AppColors.secondary 
                    : AppColors.textSecondary,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔄 Theme Mode durchschalten
  void _cycleThemeMode() {
    final modes = ThemeMode.values;
    final currentIndex = modes.indexOf(widget.currentThemeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    widget.onThemeModeChanged(modes[nextIndex]);
  }

  /// 🔄 Style Preset durchschalten
  void _cycleStylePreset() {
    final presets = FantasyStylePreset.values;
    final currentIndex = presets.indexOf(widget.currentStylePreset);
    final nextIndex = (currentIndex + 1) % presets.length;
    widget.onStylePresetChanged(presets[nextIndex]);
  }

  /// 💬 Dialog für Theme-Einstellungen
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings'),
        content: _buildFullSwitcher(Theme.of(context).brightness == Brightness.dark),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Mode';
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

  IconData _getStylePresetIcon(FantasyStylePreset preset) {
    switch (preset) {
      case FantasyStylePreset.mystical:
        return Icons.auto_fix_high_rounded;
      case FantasyStylePreset.ancient:
        return Icons.menu_book_rounded;
      case FantasyStylePreset.portal:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String _getStylePresetLabel(FantasyStylePreset preset) {
    switch (preset) {
      case FantasyStylePreset.mystical:
        return 'Mystical (Magic Focus)';
      case FantasyStylePreset.ancient:
        return 'Ancient (Artifact Focus)';
      case FantasyStylePreset.portal:
        return 'Portal (Travel Focus)';
    }
  }

  String _getStylePresetShortLabel(FantasyStylePreset preset) {
    switch (preset) {
      case FantasyStylePreset.mystical:
        return 'Mystic';
      case FantasyStylePreset.ancient:
        return 'Ancient';
      case FantasyStylePreset.portal:
        return 'Portal';
    }
  }
}

/// 🎨 Fantasy Style Preset Extensions
extension FantasyStylePresetExtensions on FantasyStylePreset {
  /// Standard Frame-Variante für dieses Preset
  String get defaultFrameVariant {
    switch (this) {
      case FantasyStylePreset.mystical:
        return 'magic';
      case FantasyStylePreset.ancient:
        return 'artifact';
      case FantasyStylePreset.portal:
        return 'portal';
    }
  }

  /// Standard Button-Variante für Primary Actions
  String get defaultPrimaryButtonVariant {
    switch (this) {
      case FantasyStylePreset.mystical:
        return 'magic';
      case FantasyStylePreset.ancient:
        return 'artifact';
      case FantasyStylePreset.portal:
        return 'portal';
    }
  }

  /// Standard Button-Variante für Secondary Actions
  String get defaultSecondaryButtonVariant {
    switch (this) {
      case FantasyStylePreset.mystical:
        return 'ghost';
      case FantasyStylePreset.ancient:
        return 'ghost';
      case FantasyStylePreset.portal:
        return 'ghost';
    }
  }
}