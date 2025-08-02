import 'package:flutter/material.dart';
import '../../../core/models/world.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/theme_context_consumer.dart';


class WorldCard extends StatelessWidget {
  final World world;
  final bool isPreRegistered;
  final bool isJoined;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onPlay;
  final VoidCallback? onPreRegister;
  final VoidCallback? onCancelPreRegistration;
  final VoidCallback? onInvite;
  final VoidCallback? onTap;

  const WorldCard({
    super.key,
    required this.world,
    this.isPreRegistered = false,
    this.isJoined = false,
    this.onJoin,
    this.onLeave,
    this.onPlay,
    this.onPreRegister,
    this.onCancelPreRegistration,
    this.onInvite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 World-spezifisches Theme laden mit ThemeContextConsumer
    return ThemeContextConsumer(
      componentName: 'WorldCard',
      worldThemeOverride: world.themeBundle, // Theme-Name aus DB
      fallbackBundle: 'world-preview',
      builder: (context, theme, extensions) {
        return _buildCard(context, theme, extensions);
      },
    );
  }

  Widget _buildCard(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: world.isActive
                ? world.category.color.withValues(alpha: 0.5)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: world.isActive ? 2 : 1,
          ),
          boxShadow: world.isActive
              ? [
                  BoxShadow(
                    color: world.category.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              _buildHeader(context, theme, extensions),
              _buildContent(context, theme, extensions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            world.category.color.withValues(alpha: 0.2),
            world.category.color.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryBadge(context, theme),
              _buildStatusBadge(context, theme),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorldIcon(theme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      world.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        world.description?.isNotEmpty == true 
                          ? world.description! 
                          : AppLocalizations.of(context).worldDefaultDescription,
                        style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorldIcon(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: world.category.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: world.category.color.withValues(alpha: 0.5),
        ),
      ),
      child: Icon(
        Icons.public,
        color: world.category.color,
        size: 24,
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: world.category.color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: world.category.color.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            world.category.icon,
            size: 16,
            color: world.category.color,
          ),
          const SizedBox(width: 6),
          Text(
            world.category.getDisplayName(context),
            style: TextStyle(
              color: world.category.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        statusColor = theme.colorScheme.secondary;
        statusIcon = Icons.schedule;
        break;
      case WorldStatus.open:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.lock_open;
        break;
      case WorldStatus.running:
        statusColor = theme.colorScheme.tertiary;
        statusIcon = Icons.play_circle;
        break;
      case WorldStatus.closed:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.lock;
        break;
      case WorldStatus.archived:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.archive;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            world.status.getDisplayName(context),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlayerInfo(context, theme),
          const SizedBox(height: 16),
          _buildDateInfo(context, theme),
          const SizedBox(height: 16),
          _buildActionButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context).worldPlayersActive(world.playerCount),
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).worldStartDate('${world.startsAt.day}.${world.startsAt.month}.${world.startsAt.year}'),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (world.endsAt != null) ...[
          Builder(
            builder: (_) {
              final endDate = world.endsAt!;
              return Column(
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).worldEndDate('${endDate.day}.${endDate.month}.${endDate.year}'),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    final List<Widget> buttons = [];
    
    // Status-basierte Button-Logik
    switch (world.status) {
      case WorldStatus.upcoming:
        // Vorregistrierung oder Zurückziehen
        if (isPreRegistered) {
          if (onCancelPreRegistration != null) {
            buttons.add(_buildButton(
              onPressed: onCancelPreRegistration,
              icon: Icons.cancel,
              label: AppLocalizations.of(context).worldLeaveButton,
              color: _getButtonColor('leave', theme),
              theme: theme,
            ));
          }
          // Invite Button als LETZTER Button für pre-registered users
          if (onInvite != null) {
            buttons.add(_buildButton(
              onPressed: onInvite,
              icon: Icons.person_add,
              label: AppLocalizations.of(context).worldInviteButton,
              color: _getButtonColor('invite', theme),
              theme: theme,
            ));
          }
        } else {
          if (onPreRegister != null) {
            buttons.add(_buildButton(
              onPressed: onPreRegister,
              icon: Icons.how_to_reg,
              label: AppLocalizations.of(context).worldPreRegisterButton,
              color: _getButtonColor('preregister', theme),
              theme: theme,
            ));
          }
        }
        break;
        
      case WorldStatus.open:
      case WorldStatus.running:
        // Beitreten oder Verlassen
        if (isJoined) {
          // Spielen Button immer zuerst anzeigen wenn verfügbar
          if (onPlay != null) {
            buttons.add(_buildButton(
              onPressed: onPlay,
              icon: Icons.play_circle_filled,
              label: AppLocalizations.of(context).worldPlayButton,
              color: _getButtonColor('play', theme),
              theme: theme,
            ));
          }
          // Verlassen Button als zweite Option
          if (onLeave != null) {
            buttons.add(_buildButton(
              onPressed: onLeave,
              icon: Icons.exit_to_app,
              label: AppLocalizations.of(context).worldLeaveButton,
              color: _getButtonColor('leave', theme),
              theme: theme,
            ));
          }
          // Invite Button als LETZTER Button
          if (onInvite != null) {
            buttons.add(_buildButton(
              onPressed: onInvite,
              icon: Icons.person_add,
              label: AppLocalizations.of(context).worldInviteButton,
              color: _getButtonColor('invite', theme),
              theme: theme,
            ));
          }
        } else {
          if (onJoin != null) {
            buttons.add(_buildButton(
              onPressed: onJoin,
              icon: Icons.play_arrow,
              label: AppLocalizations.of(context).worldJoinNowButton,
              color: _getButtonColor('join', theme),
              theme: theme,
            ));
          }
        }
        break;
        
      case WorldStatus.closed:
      case WorldStatus.archived:
        // Keine Aktions-Buttons bei geschlossenen/archivierten Welten
        return _buildStatusBadge(context, theme);
    }
    
    // Wenn keine Buttons verfügbar sind
    if (buttons.isEmpty) {
      return _buildStatusBadge(context, theme);
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: buttons,
    );
  }
  
  Widget _buildButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String? label,
    required Color? color,
    required ThemeData theme,
    bool iconOnly = false,
    String? tooltip,
  }) {
    if (onPressed == null) return const SizedBox.shrink();
    
    final button = iconOnly
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Icon(icon, size: 16),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label ?? ''),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
    
    // Wrap mit Tooltip wenn vorhanden
    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }
    
    return button;
  }

  /// Get theme-based button color for different actions
  Color _getButtonColor(String action, ThemeData theme) {
    switch (action) {
      case 'join':
        return theme.colorScheme.primary;        // Most important action - primary color
      case 'play':
        return theme.colorScheme.secondary;      // Positive action - secondary color
      case 'invite':
        return theme.colorScheme.tertiary;       // Social action - tertiary color
      case 'preregister':
        return theme.colorScheme.secondary;      // Future action - secondary color
      case 'leave':
        return theme.colorScheme.error;          // Destructive action - error color
      default:
        return theme.colorScheme.primary;        // Fallback
    }
  }
} 