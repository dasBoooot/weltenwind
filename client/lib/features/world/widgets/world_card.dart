import 'package:flutter/material.dart';
import '../../../core/models/world.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';


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
    return _buildCard(context);
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF2A2A2A),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: world.isActive
                ? world.category.color.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            width: world.isActive ? 2 : 1,
          ),
          boxShadow: world.isActive
              ? [
                  BoxShadow(
                    color: world.category.color.withOpacity(0.3),
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
              _buildHeader(context),
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            world.category.color.withOpacity(0.2),
            world.category.color.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryBadge(context),
              _buildStatusBadge(context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorldIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      world.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        world.description?.isNotEmpty == true 
                          ? world.description! 
                          : AppLocalizations.of(context).worldDefaultDescription,
                        style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[300],
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

  Widget _buildWorldIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: world.category.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: world.category.color.withOpacity(0.5),
        ),
      ),
      child: Icon(
        Icons.public,
        color: world.category.color,
        size: 24,
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: world.category.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: world.category.color.withOpacity(0.5),
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

  Widget _buildStatusBadge(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case WorldStatus.open:
        statusColor = Colors.green;
        statusIcon = Icons.lock_open;
        break;
      case WorldStatus.running:
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle;
        break;
      case WorldStatus.closed:
        statusColor = Colors.red;
        statusIcon = Icons.lock;
        break;
      case WorldStatus.archived:
        statusColor = Colors.grey;
        statusIcon = Icons.archive;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
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

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlayerInfo(context),
          const SizedBox(height: 16),
          _buildDateInfo(context),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context).worldPlayersActive(world.playerCount),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).worldStartDate('${world.startsAt.day}.${world.startsAt.month}.${world.startsAt.year}'),
              style: TextStyle(
                color: Colors.grey[400],
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
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).worldEndDate('${endDate.day}.${endDate.month}.${endDate.year}'),
                        style: TextStyle(
                          color: Colors.grey[400],
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

  Widget _buildActionButtons(BuildContext context) {
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
              color: Colors.red[600],
            ));
          }
          // Invite Button als LETZTER Button für pre-registered users
          if (onInvite != null) {
            buttons.add(_buildButton(
              onPressed: onInvite,
              icon: Icons.person_add,
              label: AppLocalizations.of(context).worldInviteButton,
              color: Colors.blue[600],
            ));
          }
        } else {
          if (onPreRegister != null) {
            buttons.add(_buildButton(
              onPressed: onPreRegister,
              icon: Icons.how_to_reg,
              label: AppLocalizations.of(context).worldPreRegisterButton,
              color: Colors.orange[600],
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
              color: Colors.green[600],
            ));
          }
          // Verlassen Button als zweite Option
          if (onLeave != null) {
            buttons.add(_buildButton(
              onPressed: onLeave,
              icon: Icons.exit_to_app,
              label: AppLocalizations.of(context).worldLeaveButton,
              color: Colors.red[600],
            ));
          }
          // Invite Button als LETZTER Button
          if (onInvite != null) {
            buttons.add(_buildButton(
              onPressed: onInvite,
              icon: Icons.person_add,
              label: AppLocalizations.of(context).worldInviteButton,
              color: Colors.blue[600],
            ));
          }
        } else {
          if (onJoin != null) {
            buttons.add(_buildButton(
              onPressed: onJoin,
              icon: Icons.play_arrow,
              label: AppLocalizations.of(context).worldJoinNowButton,
              color: AppTheme.primaryColor,
            ));
          }
        }
        break;
        
      case WorldStatus.closed:
      case WorldStatus.archived:
        // Keine Aktions-Buttons bei geschlossenen/archivierten Welten
        return _buildStatusBadge(context);
    }
    
    // Wenn keine Buttons verfügbar sind
    if (buttons.isEmpty) {
      return _buildStatusBadge(context);
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
    bool iconOnly = false,
    String? tooltip,
  }) {
    if (onPressed == null) return const SizedBox.shrink();
    
    final button = iconOnly
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
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
              foregroundColor: Colors.white,
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
} 