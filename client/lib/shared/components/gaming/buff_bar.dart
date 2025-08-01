import 'package:flutter/material.dart';
import '../../../core/services/modular_theme_service.dart';

/// 🔮 Buff/Debuff Types
enum BuffType {
  buff,
  debuff,
  neutral,
}

/// ⏱️ Buff Duration Types  
enum BuffDurationType {
  permanent,
  timed,
  stacks,
}

/// 🔮 Buff Data
class BuffData {
  final String id;
  final String name;
  final IconData icon;
  final BuffType type;
  final BuffDurationType durationType;
  final Duration? duration;
  final Duration? maxDuration;
  final int? stacks;
  final int? maxStacks;
  final Color? customColor;
  final bool isActive;

  const BuffData({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.durationType = BuffDurationType.timed,
    this.duration,
    this.maxDuration,
    this.stacks,
    this.maxStacks,
    this.customColor,
    this.isActive = true,
  });

  /// Get remaining time as percentage (0.0 to 1.0)
  double get remainingPercentage {
    if (durationType != BuffDurationType.timed || duration == null || maxDuration == null) {
      return 1.0;
    }
    return duration!.inMilliseconds / maxDuration!.inMilliseconds;
  }

  /// Get stacks as percentage (0.0 to 1.0)
  double get stacksPercentage {
    if (durationType != BuffDurationType.stacks || stacks == null || maxStacks == null) {
      return 1.0;
    }
    return stacks! / maxStacks!;
  }
}

/// 🔮 Gaming Buff Bar Component based on HUD Schema
/// 
/// Displays active buffs/debuffs with timers and stack counts
class GameBuffBar extends StatefulWidget {
  final List<BuffData> buffs;
  final Axis direction;
  final double slotSize;
  final double spacing;
  final int maxSlots;
  final bool showTimers;
  final bool showStacks;
  final bool showTooltips;
  final VoidCallback? onBuffTap;

  const GameBuffBar({
    super.key,
    required this.buffs,
    this.direction = Axis.horizontal,
    this.slotSize = 48.0, // Schema default
    this.spacing = 4.0, // Schema default
    this.maxSlots = 10, // Schema default
    this.showTimers = true,
    this.showStacks = true,
    this.showTooltips = true,
    this.onBuffTap,
  });

  @override
  State<GameBuffBar> createState() => _GameBuffBarState();
}

class _GameBuffBarState extends State<GameBuffBar> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = ModularThemeService().getCurrentThemeExtensions();
    final visibleBuffs = widget.buffs.take(widget.maxSlots).toList();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return widget.direction == Axis.horizontal
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildBuffSlots(theme, extensions, visibleBuffs),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildBuffSlots(theme, extensions, visibleBuffs),
              );
      },
    );
  }

  /// Build buff slots
  List<Widget> _buildBuffSlots(ThemeData theme, Map<String, dynamic>? extensions, List<BuffData> buffs) {
    final slots = <Widget>[];
    
    for (int i = 0; i < widget.maxSlots; i++) {
      if (i < buffs.length) {
        slots.add(_buildBuffSlot(theme, extensions, buffs[i]));
      } else {
        slots.add(_buildEmptySlot(theme));
      }
      
      // Add spacing between slots
      if (i < widget.maxSlots - 1) {
        if (widget.direction == Axis.horizontal) {
          slots.add(SizedBox(width: widget.spacing));
        } else {
          slots.add(SizedBox(height: widget.spacing));
        }
      }
    }
    
    return slots;
  }

  /// Build individual buff slot
  Widget _buildBuffSlot(ThemeData theme, Map<String, dynamic>? extensions, BuffData buff) {
    return Tooltip(
      message: widget.showTooltips ? _getTooltipText(buff) : '',
      child: GestureDetector(
        onTap: widget.onBuffTap,
        child: Container(
          width: widget.slotSize,
          height: widget.slotSize,
          decoration: _getBuffDecoration(theme, buff),
          child: Stack(
            children: [
              // Background progress indicator
              if (widget.showTimers && buff.durationType == BuffDurationType.timed)
                _buildTimerProgress(theme, buff),
              
              // Icon
              Center(
                child: Transform.scale(
                  scale: _shouldPulse(buff) ? _pulseAnimation.value : 1.0,
                  child: Icon(
                    buff.icon,
                    color: _getIconColor(theme, buff),
                    size: widget.slotSize * 0.6,
                  ),
                ),
              ),
              
              // Stack count
              if (widget.showStacks && buff.stacks != null && buff.stacks! > 1)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getBuffTypeColor(theme, buff.type),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${buff.stacks}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              
              // Duration text (for short durations)
              if (widget.showTimers && 
                  buff.durationType == BuffDurationType.timed && 
                  buff.duration != null && 
                  buff.duration!.inSeconds <= 10)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${buff.duration!.inSeconds}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty buff slot
  Widget _buildEmptySlot(ThemeData theme) {
    return Container(
      width: widget.slotSize,
      height: widget.slotSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }

  /// Build timer progress indicator
  Widget _buildTimerProgress(ThemeData theme, BuffData buff) {
    return Positioned.fill(
      child: CircularProgressIndicator(
        value: buff.remainingPercentage,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getBuffTypeColor(theme, buff.type).withValues(alpha: 0.3),
        ),
        strokeWidth: 2,
      ),
    );
  }

  /// Get buff slot decoration
  BoxDecoration _getBuffDecoration(ThemeData theme, BuffData buff) {
    final buffColor = buff.customColor ?? _getBuffTypeColor(theme, buff.type);
    
    return BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: Border.all(
        color: buffColor,
        width: _getBorderWidth(),
      ),
      boxShadow: [
        BoxShadow(
          color: buffColor.withValues(alpha: 0.3),
          blurRadius: 4,
          spreadRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  /// Get buff type color
  Color _getBuffTypeColor(ThemeData theme, BuffType type) {
    switch (type) {
      case BuffType.buff:
        return const Color(0xFF2ECC71); // Green - Schema default
      case BuffType.debuff:
        return const Color(0xFFE74C3C); // Red - Schema default
      case BuffType.neutral:
        return theme.colorScheme.primary; // Theme primary
    }
  }

  /// Get icon color
  Color _getIconColor(ThemeData theme, BuffData buff) {
    return buff.isActive 
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
  }

  /// Check if buff should pulse
  bool _shouldPulse(BuffData buff) {
    if (buff.durationType == BuffDurationType.timed && buff.duration != null) {
      return buff.duration!.inSeconds <= 5; // Pulse when < 5 seconds remaining
    }
    return false;
  }

  /// Get tooltip text
  String _getTooltipText(BuffData buff) {
    String text = buff.name;
    
    if (buff.durationType == BuffDurationType.timed && buff.duration != null) {
      final seconds = buff.duration!.inSeconds;
      if (seconds > 60) {
        final minutes = seconds ~/ 60;
        text += '\n${minutes}m ${seconds % 60}s';
      } else {
        text += '\n${seconds}s';
      }
    }
    
    if (buff.stacks != null && buff.stacks! > 1) {
      text += '\nStacks: ${buff.stacks}';
    }
    
    return text;
  }

  /// Border radius from schema
  double _getBorderRadius() {
    return 8.0; // Schema default
  }

  /// Border width from schema
  double _getBorderWidth() {
    return 2.0; // Schema default
  }
}