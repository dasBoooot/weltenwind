import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class WorldListHeader extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onCreateWorld;
  final bool hasCreatePermission;

  const WorldListHeader({
    super.key,
    this.onRefresh,
    this.onCreateWorld,
    this.hasCreatePermission = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.public,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        
        // Title
        Text(
          AppLocalizations.of(context).appTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          AppLocalizations.of(context).worldListTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[300],
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Action Buttons
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    if (onRefresh != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(AppLocalizations.of(context).worldListRefreshButton),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    if (hasCreatePermission && onCreateWorld != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onCreateWorld,
          icon: const Icon(Icons.add, size: 18),
          label: Text(AppLocalizations.of(context).worldListCreateButton),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          buttons[i],
          if (i < buttons.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
} 