import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/modular_theme_service.dart';

/// 🎮 RPG Item Rarity based on Gaming Schema
enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

/// 🎒 Inventory Slot Component based on Gaming Schema
/// 
/// RPG inventory slot with rarity colors, drag & drop, and hover effects
class InventorySlot extends StatefulWidget {
  final Widget? child;
  final ItemRarity? itemRarity;
  final bool isEmpty;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? itemName;
  final int? itemCount;
  final double? size;

  const InventorySlot({
    super.key,
    this.child,
    this.itemRarity,
    this.isEmpty = true,
    this.isSelected = false,
    this.isHighlighted = false,
    this.onTap,
    this.onLongPress,
    this.itemName,
    this.itemCount,
    this.size,
  });

  @override
  State<InventorySlot> createState() => _InventorySlotState();
}

class _InventorySlotState extends State<InventorySlot> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start glow animation for rare+ items
    if (widget.itemRarity != null && _shouldGlow(widget.itemRarity!)) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _shouldGlow(ItemRarity rarity) {
    return rarity == ItemRarity.epic || 
           rarity == ItemRarity.legendary || 
           rarity == ItemRarity.mythic;
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
  }

  void _handleHoverExit(PointerExitEvent event) {  
    setState(() => _isHovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = ModularThemeService().getCurrentThemeExtensions();
    final slotSize = widget.size ?? _getDefaultSlotSize();
    
    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: slotSize,
          height: slotSize,
          decoration: _getDecoration(theme, extensions),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            child: Stack(
              children: [
                // Slot content
                if (widget.child != null)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: widget.child!,
                    ),
                  ),
                
                // Item count badge
                if (widget.itemCount != null && widget.itemCount! > 1)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.itemCount.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                
                // Selection indicator
                if (widget.isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(_getBorderRadius()),
                      ),
                    ),
                  ),
                
                // Highlight indicator
                if (widget.isHighlighted)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(_getBorderRadius()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get decoration based on rarity and state
  BoxDecoration _getDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: _getBorder(theme),
      boxShadow: _getShadows(theme, extensions),
    );
  }

  /// Background color based on slot state
  Color _getBackgroundColor(ThemeData theme) {
    if (widget.isEmpty) {
      return theme.colorScheme.surfaceContainer.withValues(alpha: 0.5);
    }
    return theme.colorScheme.surfaceContainerHighest;
  }

  /// Border based on rarity
  Border _getBorder(ThemeData theme) {
    final borderColor = _getRarityColor(theme);
    return Border.all(
      color: borderColor,
      width: _getBorderWidth(),
    );
  }

  /// Get rarity color
  Color _getRarityColor(ThemeData theme) {
    if (widget.itemRarity == null) {
      return theme.colorScheme.outline.withValues(alpha: 0.5);
    }

    switch (widget.itemRarity!) {
      case ItemRarity.common:
        return theme.colorScheme.outline;
      case ItemRarity.uncommon:
        return const Color(0xFF4CAF50); // Green
      case ItemRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case ItemRarity.epic:
        return const Color(0xFF9C27B0); // Purple
      case ItemRarity.legendary:
        return const Color(0xFFFF9800); // Orange/Gold
      case ItemRarity.mythic:
        return const Color(0xFFE91E63); // Pink/Red
    }
  }

  /// Rarity glow effects
  List<BoxShadow> _getShadows(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.itemRarity == null || !_shouldGlow(widget.itemRarity!)) {
      return [
        BoxShadow(
          color: theme.colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];
    }

    final rarityColor = _getRarityColor(theme);
    final glowIntensity = 0.3 + (0.4 * _glowAnimation.value);
    final baseGlow = _isHovered ? 1.2 : 1.0;

    return [
      BoxShadow(
        color: rarityColor.withValues(alpha: glowIntensity * baseGlow),
        blurRadius: 8 + (6 * _glowAnimation.value * baseGlow),
        spreadRadius: 1 + (2 * _glowAnimation.value * baseGlow),
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Default slot size from gaming schema
  double _getDefaultSlotSize() {
    // TODO: Get from gaming schema - inventory.slots.size
    return 64.0;
  }

  /// Border radius from gaming schema
  double _getBorderRadius() {
    // TODO: Get from gaming schema - inventory.slots.borderRadius
    return 8.0;
  }

  /// Border width based on rarity
  double _getBorderWidth() {
    if (widget.itemRarity == null) return 1.0;
    
    switch (widget.itemRarity!) {
      case ItemRarity.common:
        return 1.0;
      case ItemRarity.uncommon:
        return 1.5;
      case ItemRarity.rare:
        return 2.0;
      case ItemRarity.epic:
      case ItemRarity.legendary:
      case ItemRarity.mythic:
        return 2.5;
    }
  }
}