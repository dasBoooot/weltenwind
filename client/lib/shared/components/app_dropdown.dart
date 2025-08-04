import 'package:flutter/material.dart';
import '../../core/services/theme_helper.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)

/// 📋 Dropdown Option Model
class DropdownOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final Color? iconColor;
  final String? group;
  final List<String>? keywords;
  final bool enabled;

  const DropdownOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.iconColor,
    this.group,
    this.keywords,
    this.enabled = true,
  });
}

/// 📋 Dropdown Variants
enum AppDropdownVariant {
  standard,
  outlined,
  filled,
  underlined,
}

/// 📋 Selection Display Types
enum SelectionDisplay {
  tags,
  count,
  list,
}

/// 📋 App Dropdown based on Dropdown Schema
/// 
/// Comprehensive dropdown with search, multi-select, groups, and schema-based configuration
class AppDropdown<T> extends StatefulWidget {
  final List<DropdownOption<T>> options;
  final T? value;
  final List<T>? values;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<List<T>>? onMultiChanged;
  final String? hint;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool multiSelect;
  final bool searchable;
  final bool clearable;
  final bool enabled;
  final AppDropdownVariant variant;
  final double? width;
  final double? maxHeight;
  final String searchPlaceholder;
  final SelectionDisplay selectionDisplay;
  final int? maxSelections;
  final bool showSelectAll;
  final bool closeOnSelect;
  
  // 🦾 Accessibility Parameters
  final String? semanticLabel;
  final String? semanticHint;

  const AppDropdown({
    super.key,
    required this.options,
    this.value,
    this.values,
    this.onChanged,
    this.onMultiChanged,
    this.hint,
    this.label,
    this.helperText,
    this.errorText,
    this.multiSelect = false,
    this.searchable = false,
    this.clearable = true,
    this.enabled = true,
    this.variant = AppDropdownVariant.outlined,
    this.width,
    this.maxHeight,
    this.searchPlaceholder = "Search...",
    this.selectionDisplay = SelectionDisplay.tags,
    this.maxSelections,
    this.showSelectAll = false,
    this.closeOnSelect = true,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  });

  /// Standard single-select dropdown
  const AppDropdown.standard({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.hint,
    this.label,
    this.helperText,
    this.errorText,
    this.searchable = false,
    this.clearable = true,
    this.enabled = true,
    this.width,
    this.maxHeight,
    this.searchPlaceholder = "Search...",
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : multiSelect = false,
       values = null,
       onMultiChanged = null,
       variant = AppDropdownVariant.outlined,
       selectionDisplay = SelectionDisplay.tags,
       maxSelections = null,
       showSelectAll = false,
       closeOnSelect = true;

  /// Multi-select dropdown
  const AppDropdown.multiSelect({
    super.key,
    required this.options,
    this.values,
    this.onMultiChanged,
    this.hint,
    this.label,
    this.helperText,
    this.errorText,
    this.searchable = true,
    this.clearable = true,
    this.enabled = true,
    this.width,
    this.maxHeight,
    this.searchPlaceholder = "Search...",
    this.selectionDisplay = SelectionDisplay.tags,
    this.maxSelections,
    this.showSelectAll = true,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : multiSelect = true,
       value = null,
       onChanged = null,
       variant = AppDropdownVariant.outlined,
       closeOnSelect = false;

  /// Searchable dropdown
  const AppDropdown.searchable({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.hint,
    this.label,
    this.helperText,
    this.errorText,
    this.clearable = true,
    this.enabled = true,
    this.width,
    this.maxHeight,
    this.searchPlaceholder = "Search...",
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : multiSelect = false,
       values = null,
       onMultiChanged = null,
       searchable = true,
       variant = AppDropdownVariant.outlined,
       selectionDisplay = SelectionDisplay.tags,
       maxSelections = null,
       showSelectAll = false,
       closeOnSelect = true;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _searchDebounce;
  
  bool _isOpen = false;
  String _searchQuery = '';
  List<DropdownOption<T>> _filteredOptions = [];
  List<T> _selectedValues = [];
  
  OverlayEntry? _overlayEntry;
  
  // 🦾 Keyboard navigation state
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    
    // Initialize selected values
    if (widget.multiSelect && widget.values != null) {
      _selectedValues = List.from(widget.values!);
    } else if (!widget.multiSelect && widget.value != null) {
      _selectedValues = [widget.value!];
    }
  }

  @override
  void didUpdateWidget(AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.options != oldWidget.options) {
      _updateFilteredOptions();
    }
    
    // Update selected values
    if (widget.multiSelect && widget.values != oldWidget.values) {
      _selectedValues = List.from(widget.values ?? []);
    } else if (!widget.multiSelect && widget.value != oldWidget.value) {
      _selectedValues = widget.value != null ? [widget.value!] : [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _searchDebounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_getSearchDebounceDelay(), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _updateFilteredOptions();
      });
    });
  }

  void _updateFilteredOptions() {
    _filteredOptions = widget.options.where((option) {
      if (_searchQuery.isEmpty) return true;
      
      final searchIn = [
        option.label.toLowerCase(),
        if (option.description != null) option.description!.toLowerCase(),
        if (option.keywords != null) ...option.keywords!.map((k) => k.toLowerCase()),
      ];
      
      return searchIn.any((text) => text.contains(_searchQuery));
    }).toList();
    
    // Reset keyboard highlight when options change
    _resetHighlight();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => _isOpen = true);
    _showOverlay();
  }

  void _closeDropdown() {
    setState(() => _isOpen = false);
    _removeOverlay();
    _searchController.clear();
    _searchQuery = '';
    _updateFilteredOptions();
  }

  void _selectOption(DropdownOption<T> option) {
    if (!option.enabled) return;
    
    if (widget.multiSelect) {
      setState(() {
        if (_selectedValues.contains(option.value)) {
          _selectedValues.remove(option.value);
        } else {
          if (widget.maxSelections == null || _selectedValues.length < widget.maxSelections!) {
            _selectedValues.add(option.value);
          }
        }
      });
      
      widget.onMultiChanged?.call(_selectedValues);
      
      if (!widget.closeOnSelect) return;
    } else {
      setState(() {
        _selectedValues = [option.value];
      });
      
      widget.onChanged?.call(option.value);
    }
    
    if (widget.closeOnSelect) {
      _closeDropdown();
    }
  }

  void _clearSelection() {
    setState(() => _selectedValues.clear());
    
    if (widget.multiSelect) {
      widget.onMultiChanged?.call([]);
    } else {
      widget.onChanged?.call(null);
    }
  }

  void _selectAll() {
    final selectableOptions = _filteredOptions.where((option) => option.enabled).toList();
    setState(() {
      _selectedValues = selectableOptions.map((option) => option.value).toList();
    });
    
    widget.onMultiChanged?.call(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 MODULARES THEME SYSTEM - Smart Theme Loading
    final cachedTheme = ThemeHelper.getCurrentThemeCached(context);
    if (cachedTheme != null) {
      return _buildDropdown(context, cachedTheme, null);
    }
    
    // Fallback für nicht-gecachte Themes  
    return FutureBuilder<ThemeData>(
      future: ThemeHelper.getCurrentTheme(context),
      builder: (context, snapshot) {
        final theme = snapshot.data ?? Theme.of(context);
        return _buildDropdown(context, theme, null);
      },
    );
  }

  Widget _buildDropdown(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Semantics(
      label: _getSemanticLabel(),
      hint: _getSemanticHint(),
      button: true,
      enabled: widget.enabled,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          _handleKeyEvent(event);
        },
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Dropdown button
        SizedBox(
          width: widget.width,
          child: _buildDropdownButton(theme, extensions),
        ),
        
        // Helper text
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        
        // Error text
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton(ThemeData theme, Map<String, dynamic>? extensions) {
    return GestureDetector(
      onTap: widget.enabled ? _toggleDropdown : null,
      child: Container(
        padding: EdgeInsets.all(_getPadding()),
        decoration: _getButtonDecoration(theme, extensions),
        child: Row(
          children: [
            // Selected content
            Expanded(
              child: _buildSelectedContent(theme),
            ),
            
            // Clear button
            if (widget.clearable && _selectedValues.isNotEmpty && widget.enabled) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _clearSelection,
                child: Icon(
                  Icons.clear,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            
            // Dropdown arrow
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: _getAnimationDuration(),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: widget.enabled 
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent(ThemeData theme) {
    if (_selectedValues.isEmpty) {
      return Text(
        widget.hint ?? 'Select an option',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (!widget.multiSelect) {
      final option = widget.options.firstWhere((o) => o.value == _selectedValues.first);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (option.icon != null) ...[
            Icon(
              option.icon,
              size: 18,
              color: option.iconColor ?? theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              option.label,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // Multi-select display
    switch (widget.selectionDisplay) {
      case SelectionDisplay.count:
        return Text(
          '${_selectedValues.length} selected',
          style: theme.textTheme.bodyMedium,
        );
      
      case SelectionDisplay.list:
        final labels = _selectedValues
            .map((value) => widget.options.firstWhere((o) => o.value == value).label)
            .join(', ');
        return Text(
          labels,
          style: theme.textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        );
      
      case SelectionDisplay.tags:
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: _selectedValues.take(3).map((value) {
            final option = widget.options.firstWhere((o) => o.value == value);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                option.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            );
          }).toList()
            ..addAll(_selectedValues.length > 3 ? [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${_selectedValues.length - 3}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ] : []),
        );
    }
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(offset, size),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay(Offset offset, Size buttonSize) {
    // 🎯 SMART NAVIGATION THEME: Verwendet globales Theme
    return _buildOverlayContent(context, Theme.of(context), null, offset, buttonSize);
  }

  Widget _buildOverlayContent(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions, Offset offset, Size buttonSize) {
    return GestureDetector(
      onTap: _closeDropdown,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + buttonSize.height + 4,
              width: widget.width ?? buttonSize.width,
              child: Material(
                elevation: _getElevation(),
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: widget.maxHeight ?? _getMaxHeight(),
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(_getBorderRadius()),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search bar
                      if (widget.searchable)
                        _buildSearchBar(theme),
                      
                      // Select all
                      if (widget.multiSelect && widget.showSelectAll && _filteredOptions.isNotEmpty)
                        _buildSelectAllOption(theme),
                      
                      // Options list
                      Flexible(
                        child: _buildOptionsList(theme, extensions),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(_getPadding()),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.searchPlaceholder,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: const Icon(Icons.clear, size: 20),
                  visualDensity: _getVisualDensity(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: _isDenseMode(),
        ),
      ),
    );
  }

  Widget _buildSelectAllOption(ThemeData theme) {
    final allSelected = _filteredOptions.where((o) => o.enabled).every((o) => _selectedValues.contains(o.value));
    
    return ListTile(
      dense: _isDenseMode(),
      leading: Icon(
        allSelected ? Icons.check_box : Icons.check_box_outline_blank,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        'Select All',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: allSelected ? _clearSelection : _selectAll,
      visualDensity: _getVisualDensity(),
    );
  }

  Widget _buildOptionsList(ThemeData theme, Map<String, dynamic>? extensions) {
    if (_filteredOptions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(_getPadding() * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty ? 'No results found' : 'No options available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredOptions.length,
      itemBuilder: (context, index) {
        final option = _filteredOptions[index];
        final isSelected = _selectedValues.contains(option.value);
        final isHighlighted = index == _highlightedIndex;
        
        return Container(
          color: isHighlighted 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : null,
          child: ListTile(
          dense: _isDenseMode(),
          enabled: option.enabled,
          leading: widget.multiSelect
              ? Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: option.enabled 
                      ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                )
              : option.icon != null
                  ? Icon(
                      option.icon,
                      color: option.enabled 
                          ? (option.iconColor ?? theme.colorScheme.onSurface)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : null,
          title: Text(
            option.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: option.enabled 
                  ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
          subtitle: option.description != null
              ? Text(
                  option.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: option.enabled 
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                )
              : null,
          trailing: !widget.multiSelect && isSelected
              ? Icon(
                  Icons.check,
                  color: theme.colorScheme.primary,
                )
              : null,
          onTap: () => _selectOption(option),
          visualDensity: _getVisualDensity(),
          ),
        );
      },
    );
  }

  /// Get button decoration based on variant
  BoxDecoration _getButtonDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppDropdownVariant.outlined:
        return BoxDecoration(
          border: Border.all(
            color: _isOpen || widget.errorText != null
                ? (widget.errorText != null ? theme.colorScheme.error : theme.colorScheme.primary)
                : theme.colorScheme.outline,
            width: _isOpen ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          color: theme.colorScheme.surface,
        );
      
      case AppDropdownVariant.filled:
        return BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: _isOpen ? Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ) : null,
        );
      
      case AppDropdownVariant.underlined:
        return BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _isOpen || widget.errorText != null
                  ? (widget.errorText != null ? theme.colorScheme.error : theme.colorScheme.primary)
                  : theme.colorScheme.outline,
              width: _isOpen ? 2 : 1,
            ),
          ),
        );
      
      case AppDropdownVariant.standard:
        return BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        );
    }
  }

  // Schema-based getters
  double _getPadding() => 8.0; // Schema default
  double _getBorderRadius() => 8.0; // Schema default
  double _getElevation() => 8.0; // Schema default
  double _getMaxHeight() {
    // 🔥 RESPONSIVE FIX: 40% of screen height instead of hardcoded 250px
    return MediaQuery.of(context).size.height * 0.4;
  }
  bool _isDenseMode() {
    // 🔥 RESPONSIVE FIX: Dense only on desktop, normal on mobile/tablet for touch
    return MediaQuery.of(context).size.width >= 1024;
  }
  VisualDensity _getVisualDensity() {
    // 🔥 RESPONSIVE FIX: Compact only on desktop
    return _isDenseMode() ? VisualDensity.compact : VisualDensity.standard;
  }
  Duration _getSearchDebounceDelay() => const Duration(milliseconds: 300); // Schema default
  Duration _getAnimationDuration() => const Duration(milliseconds: 200); // Schema default

  /// 🦾 ACCESSIBILITY FIX: Handle keyboard navigation
  void _handleKeyEvent(KeyEvent event) {
    if (!_isOpen || _filteredOptions.isEmpty) return;
    
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          _highlightNext();
          break;
        case LogicalKeyboardKey.arrowUp:
          _highlightPrevious();
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          _selectHighlighted();
          break;
        case LogicalKeyboardKey.escape:
          _closeDropdown();
          break;
      }
    }
  }

  /// Navigate to next option
  void _highlightNext() {
    setState(() {
      if (_highlightedIndex < _filteredOptions.length - 1) {
        _highlightedIndex++;
      } else {
        _highlightedIndex = 0; // Wrap around
      }
    });
  }

  /// Navigate to previous option
  void _highlightPrevious() {
    setState(() {
      if (_highlightedIndex > 0) {
        _highlightedIndex--;
      } else {
        _highlightedIndex = _filteredOptions.length - 1; // Wrap around
      }
    });
  }

  /// Select currently highlighted option
  void _selectHighlighted() {
    if (_highlightedIndex >= 0 && _highlightedIndex < _filteredOptions.length) {
      final option = _filteredOptions[_highlightedIndex];
      _selectOption(option);
    }
  }

  /// Reset highlighted index when options change
  void _resetHighlight() {
    _highlightedIndex = -1;
  }

  /// Get semantic label for dropdown
  String _getSemanticLabel() {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.label != null) return widget.label!;
    
    if (widget.multiSelect) {
      return 'Multi-select dropdown';
    } else {
      return 'Dropdown';
    }
  }

  /// Get semantic hint for dropdown
  String? _getSemanticHint() {
    if (widget.semanticHint != null) return widget.semanticHint!;
    
    List<String> hints = [];
    
    if (!widget.enabled) {
      hints.add('Disabled');
    }
    
    if (widget.searchable) {
      hints.add('Searchable');
    }
    
    if (widget.multiSelect) {
      final count = _selectedValues.length;
      if (count > 0) {
        hints.add('$count selected');
      } else {
        hints.add('Multiple selection');
      }
    }
    
    hints.add('Use arrow keys to navigate');
    
    return hints.isNotEmpty ? hints.join(', ') : null;
  }
}

/// 📋 Dropdown Helpers
class DropdownHelpers {
  /// Create language dropdown
  static List<DropdownOption<String>> languages() {
    return [
      const DropdownOption(
        value: 'en',
        label: 'English',
        icon: Icons.language,
      ),
      const DropdownOption(
        value: 'de',
        label: 'Deutsch',
        icon: Icons.language,
      ),
      const DropdownOption(
        value: 'fr',
        label: 'Français',
        icon: Icons.language,
      ),
      const DropdownOption(
        value: 'es',
        label: 'Español',
        icon: Icons.language,
      ),
    ];
  }

  /// Create server region dropdown
  static List<DropdownOption<String>> serverRegions() {
    return [
      const DropdownOption(
        value: 'eu-west',
        label: 'Europe West',
        description: 'Frankfurt, Germany',
        icon: Icons.public,
      ),
      const DropdownOption(
        value: 'us-east',
        label: 'US East',
        description: 'Virginia, USA',
        icon: Icons.public,
      ),
      const DropdownOption(
        value: 'us-west',
        label: 'US West',
        description: 'California, USA',
        icon: Icons.public,
      ),
      const DropdownOption(
        value: 'asia',
        label: 'Asia Pacific',
        description: 'Singapore',
        icon: Icons.public,
      ),
    ];
  }

  /// Create world category dropdown
  static List<DropdownOption<String>> worldCategories() {
    return [
      const DropdownOption(
        value: 'fantasy',
        label: 'Fantasy',
        description: 'Magic and medieval worlds',
        icon: Icons.auto_awesome,
        iconColor: Colors.purple,
      ),
      const DropdownOption(
        value: 'scifi',
        label: 'Sci-Fi',
        description: 'Futuristic and space worlds',
        icon: Icons.rocket_launch,
        iconColor: Colors.blue,
      ),
      const DropdownOption(
        value: 'modern',
        label: 'Modern',
        description: 'Contemporary settings',
        icon: Icons.location_city,
        iconColor: Colors.grey,
      ),
      const DropdownOption(
        value: 'historical',
        label: 'Historical',
        description: 'Past eras and civilizations',
        icon: Icons.account_balance,
        iconColor: Colors.brown,
      ),
    ];
  }
}