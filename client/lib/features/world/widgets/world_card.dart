import 'package:flutter/material.dart';
import '../../../core/models/world.dart';
import '../../../theme/app_theme.dart';

enum WorldCategory {
  classic,
  pvp,
  event,
  experimental,
}

class WorldCard extends StatelessWidget {
  final World world;
  final int playerCount;
  final WorldCategory category;
  final bool isPreRegistered;
  final bool isJoined;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onPreRegister;
  final VoidCallback? onCancelPreRegistration;
  final VoidCallback? onInvite;
  final VoidCallback? onTap;

  const WorldCard({
    super.key,
    required this.world,
    required this.playerCount,
    required this.category,
    this.isPreRegistered = false,
    this.isJoined = false,
    this.onJoin,
    this.onLeave,
    this.onPreRegister,
    this.onCancelPreRegistration,
    this.onInvite,
    this.onTap,
  });

  Color get categoryColor {
    switch (category) {
      case WorldCategory.classic:
        return Colors.blue;
      case WorldCategory.pvp:
        return Colors.red;
      case WorldCategory.event:
        return Colors.purple;
      case WorldCategory.experimental:
        return Colors.orange;
    }
  }

  String get categoryLabel {
    switch (category) {
      case WorldCategory.classic:
        return 'Classic';
      case WorldCategory.pvp:
        return 'PvP';
      case WorldCategory.event:
        return 'Event';
      case WorldCategory.experimental:
        return 'Experimental';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case WorldCategory.classic:
        return Icons.castle;
      case WorldCategory.pvp:
        return Icons.sports_kabaddi;
      case WorldCategory.event:
        return Icons.celebration;
      case WorldCategory.experimental:
        return Icons.science;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1E1E),
              const Color(0xFF2A2A2A),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: world.isActive
                ? categoryColor.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            width: world.isActive ? 2 : 1,
          ),
          boxShadow: world.isActive
              ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
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
              _buildHeader(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.2),
            categoryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryBadge(),
              _buildStatusBadge(),
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
                      'Eine spannende Welt voller Abenteuer',
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
        color: categoryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withOpacity(0.5),
        ),
      ),
      child: Icon(
        Icons.public,
        color: categoryColor,
        size: 24,
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: categoryColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            size: 16,
            color: categoryColor,
          ),
          const SizedBox(width: 6),
          Text(
            categoryLabel,
            style: TextStyle(
              color: categoryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
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
            world.statusText,
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

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlayerInfo(),
          const SizedBox(height: 16),
          _buildDateInfo(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 4),
        Text(
          '$playerCount Spieler aktiv',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo() {
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
              'Start: ${world.startsAt.day}.${world.startsAt.month}.${world.startsAt.year}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (world.endsAt != null) ...[
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
                'Ende: ${world.endsAt!.day}.${world.endsAt!.month}.${world.endsAt!.year}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
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
              label: 'Zurückziehen',
              color: Colors.red[600],
            ));
          }
        } else {
          if (onPreRegister != null) {
            buttons.add(_buildButton(
              onPressed: onPreRegister,
              icon: Icons.how_to_reg,
              label: 'Vorregistrieren',
              color: Colors.orange[600],
            ));
          }
        }
        break;
        
      case WorldStatus.open:
      case WorldStatus.running:
        // Beitreten oder Verlassen
        if (isJoined) {
          if (onLeave != null) {
            buttons.add(_buildButton(
              onPressed: onLeave,
              icon: Icons.exit_to_app,
              label: 'Verlassen',
              color: Colors.red[600],
            ));
          }
        } else {
          if (onJoin != null) {
            buttons.add(_buildButton(
              onPressed: onJoin,
              icon: Icons.play_arrow,
              label: 'Beitreten',
              color: AppTheme.primaryColor,
            ));
          }
        }
        break;
        
      case WorldStatus.closed:
      case WorldStatus.archived:
        // Keine Aktions-Buttons bei geschlossenen/archivierten Welten
        return _buildStatusBadge();
    }
    
    // Invite Button für upcoming, open und running
    if ([WorldStatus.upcoming, WorldStatus.open, WorldStatus.running].contains(world.status) && 
        onInvite != null) {
      buttons.add(_buildButton(
        onPressed: onInvite,
        icon: Icons.person_add,
        label: null,
        color: Colors.purple[600],
        iconOnly: true,
        tooltip: 'Spieler einladen',
      ));
    }
    
    // Wenn keine Buttons verfügbar sind
    if (buttons.isEmpty) {
      return _buildStatusBadge();
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
            label: Text(label!),
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