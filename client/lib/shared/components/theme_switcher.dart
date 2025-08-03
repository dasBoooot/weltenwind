import 'package:flutter/material.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)

/// 🎨 Theme Option
class ThemeOption {
  final String id;
  final String name;
  final String description;
  final List<Color> previewColors;
  final IconData? icon;
  final bool isDefault;

  const ThemeOption({
    required this.id,
    required this.name,
    required this.description,
    required this.previewColors,
    this.icon,
    this.isDefault = false,
  });
}

/// 🎨 Theme Switcher based on Schema Configuration
/// 
/// Theme selection interface with previews, transitions, and schema-based styling
class ThemeSwitcher extends StatefulWidget {
  final List<ThemeOption> themes;
  final String? currentThemeId;
  final Function(String themeId)? onThemeChanged;
  final bool showPreview;
  final bool showLabels;
  final bool animateTransition;
  final double? previewSize;
  final Duration transitionDuration;
  final Axis direction;

  const ThemeSwitcher({
    super.key,
    required this.themes,
    this.currentThemeId,
    this.onThemeChanged,
    this.showPreview = true,
    this.showLabels = true,
    this.animateTransition = true,
    this.previewSize,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.direction = Axis.horizontal,
  });

  /// Horizontal theme switcher
  const ThemeSwitcher.horizontal({
    super.key,
    required this.themes,
    this.currentThemeId,
    this.onThemeChanged,
    this.showPreview = true,
    this.showLabels = true,
    this.animateTransition = true,
    this.previewSize,
    this.transitionDuration = const Duration(milliseconds: 400),
  }) : direction = Axis.horizontal;

  /// Vertical theme switcher
  const ThemeSwitcher.vertical({
    super.key,
    required this.themes,
    this.currentThemeId,
    this.onThemeChanged,
    this.showPreview = true,
    this.showLabels = true,
    this.animateTransition = true,
    this.previewSize,
    this.transitionDuration = const Duration(milliseconds: 400),
  }) : direction = Axis.vertical;

  /// Compact theme switcher without labels
  const ThemeSwitcher.compact({
    super.key,
    required this.themes,
    this.currentThemeId,
    this.onThemeChanged,
    this.showPreview = true,
    this.animateTransition = true,
    this.previewSize = 30,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.direction = Axis.horizontal,
  }) : showLabels = false;

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> with TickerProviderStateMixin {
  late AnimationController _transitionController;
  
  String? _selectedThemeId;
  ThemeOption? _hoveredTheme;

  @override
  void initState() {
    super.initState();
    
    _selectedThemeId = widget.currentThemeId ?? _getDefaultTheme()?.id;
    
    // Transition animation
    _transitionController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ThemeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.currentThemeId != oldWidget.currentThemeId) {
      _selectedThemeId = widget.currentThemeId;
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  ThemeOption? _getDefaultTheme() {
    try {
      return widget.themes.firstWhere((theme) => theme.isDefault);
    } catch (e) {
      return widget.themes.isNotEmpty ? widget.themes.first : null;
    }
  }

  void _selectTheme(ThemeOption theme) {
    if (_selectedThemeId == theme.id) return;
    
    setState(() {
      _selectedThemeId = theme.id;
    });
    
    if (widget.animateTransition) {
      _transitionController.forward().then((_) {
        _transitionController.reset();
      });
    }
    
    widget.onThemeChanged?.call(theme.id);
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return _buildSwitcher(context, Theme.of(context), null);
  }

  Widget _buildSwitcher(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      padding: EdgeInsets.all(_getSpacing()),
      decoration: _getContainerDecoration(theme, extensions),
      child: widget.direction == Axis.horizontal
          ? _buildHorizontalLayout(theme, extensions)
          : _buildVerticalLayout(theme, extensions),
    );
  }

  Widget _buildHorizontalLayout(ThemeData theme, Map<String, dynamic>? extensions) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.themes.map((themeOption) {
        final isLast = widget.themes.last == themeOption;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(themeOption, theme, extensions),
            if (!isLast) SizedBox(width: _getSpacing()),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildVerticalLayout(ThemeData theme, Map<String, dynamic>? extensions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.themes.map((themeOption) {
        final isLast = widget.themes.last == themeOption;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(themeOption, theme, extensions),
            if (!isLast) SizedBox(height: _getSpacing()),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildThemeOption(
    ThemeOption themeOption,
    ThemeData theme,
    Map<String, dynamic>? extensions,
  ) {
    final isSelected = _selectedThemeId == themeOption.id;
    final isHovered = _hoveredTheme?.id == themeOption.id;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredTheme = themeOption),
      onExit: (_) => setState(() => _hoveredTheme = null),
      child: GestureDetector(
        onTap: () => _selectTheme(themeOption),
        child: AnimatedContainer(
          duration: widget.animateTransition ? widget.transitionDuration : Duration.zero,
          padding: const EdgeInsets.all(8),
          decoration: _getOptionDecoration(isSelected, isHovered, theme, extensions),
          child: widget.direction == Axis.horizontal
              ? _buildHorizontalOption(themeOption, isSelected, theme)
              : _buildVerticalOption(themeOption, isSelected, theme),
        ),
      ),
    );
  }

  Widget _buildHorizontalOption(ThemeOption themeOption, bool isSelected, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preview
        if (widget.showPreview)
          _buildThemePreview(themeOption, isSelected, theme),
        
        // Label
        if (widget.showLabels) ...[
          if (widget.showPreview) const SizedBox(width: 12),
          _buildThemeLabel(themeOption, isSelected, theme),
        ],
      ],
    );
  }

  Widget _buildVerticalOption(ThemeOption themeOption, bool isSelected, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preview
        if (widget.showPreview)
          _buildThemePreview(themeOption, isSelected, theme),
        
        // Label
        if (widget.showLabels) ...[
          if (widget.showPreview) const SizedBox(height: 8),
          _buildThemeLabel(themeOption, isSelected, theme),
        ],
      ],
    );
  }

  Widget _buildThemePreview(ThemeOption themeOption, bool isSelected, ThemeData theme) {
    final size = _getPreviewSize();
    
    return AnimatedContainer(
      duration: widget.animateTransition ? widget.transitionDuration : Duration.zero,
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: isSelected 
              ? theme.colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_getBorderRadius() - 2),
        child: _buildPreviewContent(themeOption, theme),
      ),
    );
  }

  Widget _buildPreviewContent(ThemeOption themeOption, ThemeData theme) {
    if (themeOption.previewColors.length == 1) {
      // Solid color
      return Container(
        color: themeOption.previewColors.first,
        child: themeOption.icon != null
            ? Icon(
                themeOption.icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: _getPreviewSize() * 0.5,
              )
            : null,
      );
    } else if (themeOption.previewColors.length >= 2) {
      // Gradient
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeOption.previewColors,
          ),
        ),
        child: themeOption.icon != null
            ? Icon(
                themeOption.icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: _getPreviewSize() * 0.5,
              )
            : null,
      );
    } else {
      // Fallback
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          themeOption.icon ?? Icons.palette,
          color: theme.colorScheme.onSurface,
          size: _getPreviewSize() * 0.5,
        ),
      );
    }
  }

  Widget _buildThemeLabel(ThemeOption themeOption, bool isSelected, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.direction == Axis.horizontal 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      children: [
        // Name
        Text(
          themeOption.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          textAlign: widget.direction == Axis.vertical 
              ? TextAlign.center 
              : TextAlign.start,
        ),
        
        // Description (if not compact)
        if (themeOption.description.isNotEmpty && widget.direction == Axis.vertical)
          Text(
            themeOption.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Get container decoration
  BoxDecoration _getContainerDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
    );
  }

  /// Get option decoration
  BoxDecoration _getOptionDecoration(
    bool isSelected,
    bool isHovered,
    ThemeData theme,
    Map<String, dynamic>? extensions,
  ) {
    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
    } else if (isHovered) {
      backgroundColor = theme.colorScheme.surfaceContainer;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: isSelected ? Border.all(
        color: theme.colorScheme.primary,
        width: 1,
      ) : null,
    );
  }

  /// Get preview size from schema
  double _getPreviewSize() {
    return widget.previewSize ?? 40.0; // Schema default
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    return 20.0; // Schema default
  }

  /// Get spacing from schema
  double _getSpacing() {
    return 8.0; // Schema default
  }
}

/// 🎨 Theme Switcher Helpers
class ThemeHelpers {
  /// Create default theme options
  static List<ThemeOption> getDefaultThemes() {
    return [
      const ThemeOption(
        id: 'light',
        name: 'Light',
        description: 'Clean and bright theme',
        previewColors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
        icon: Icons.light_mode,
        isDefault: true,
      ),
      const ThemeOption(
        id: 'dark',
        name: 'Dark',
        description: 'Easy on the eyes',
        previewColors: [Color(0xFF121212), Color(0xFF1E1E1E)],
        icon: Icons.dark_mode,
      ),
      const ThemeOption(
        id: 'magic',
        name: 'Magic',
        description: 'Mystical purple theme',
        previewColors: [Color(0xFF7C6BAF), Color(0xFFA594D1)],
        icon: Icons.auto_awesome,
      ),
      const ThemeOption(
        id: 'forest',
        name: 'Forest',
        description: 'Natural green theme',
        previewColors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        icon: Icons.forest,
      ),
      const ThemeOption(
        id: 'ocean',
        name: 'Ocean',
        description: 'Deep blue theme',
        previewColors: [Color(0xFF1565C0), Color(0xFF2196F3)],
        icon: Icons.water,
      ),
      const ThemeOption(
        id: 'sunset',
        name: 'Sunset',
        description: 'Warm orange theme',
        previewColors: [Color(0xFFFF5722), Color(0xFFFF9800)],
        icon: Icons.wb_sunny,
      ),
    ];
  }

  /// Create theme option from extensions
  static ThemeOption? fromExtensions(
    String id,
    String name,
    Map<String, dynamic>? extensions,
  ) {
    if (extensions == null) return null;

    List<Color> previewColors = [];
    
    // Try to get magic gradient
    if (extensions.containsKey('magicGradient')) {
      final colors = extensions['magicGradient'] as List<dynamic>?;
      if (colors != null) {
        previewColors = colors
            .map((color) => _parseColor(color.toString()))
            .where((color) => color != null)
            .cast<Color>()
            .toList();
      }
    }

    // Fallback to portal gradient
    if (previewColors.isEmpty && extensions.containsKey('portalGradient')) {
      final colors = extensions['portalGradient'] as List<dynamic>?;
      if (colors != null) {
        previewColors = colors
            .map((color) => _parseColor(color.toString()))
            .where((color) => color != null)
            .cast<Color>()
            .toList();
      }
    }

    if (previewColors.isEmpty) return null;

    return ThemeOption(
      id: id,
      name: name,
      description: 'Custom theme',
      previewColors: previewColors,
      icon: Icons.palette,
    );
  }

  /// Parse color from hex string
  static Color? _parseColor(String colorString) {
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