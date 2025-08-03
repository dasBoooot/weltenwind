import 'package:flutter/material.dart';
import '../../../core/models/world.dart';
import '../../../l10n/app_localizations.dart';
// REMOVED: import '../../../core/providers/theme_context_consumer.dart'; // DEPRECATED - using Theme.of(context)

class WorldFilters extends StatelessWidget {
  final WorldStatus? statusFilter;
  final WorldCategory? categoryFilter;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<WorldStatus?> onStatusChanged;
  final ValueChanged<WorldCategory?> onCategoryChanged;
  final ValueChanged<String> onSortByChanged;
  final VoidCallback onSortOrderChanged;
  final VoidCallback onResetFilters;

  const WorldFilters({
    super.key,
    this.statusFilter,
    this.categoryFilter,
    required this.sortBy,
    required this.sortAscending,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onSortByChanged,
    required this.onSortOrderChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFilters(context, Theme.of(context));
  }

  Widget _buildFilters(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter
        _buildStatusFilter(context, theme),
        const SizedBox(height: 12),
        
        // Category Filter
        _buildCategoryFilter(context, theme),
        const SizedBox(height: 12),
        
        // Sort Options
        _buildSortOptions(context, theme),
        const SizedBox(height: 12),
        
        // Active Filters & Reset
        if (statusFilter != null || categoryFilter != null)
          _buildActiveFilters(context, theme),
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).worldFiltersStatus,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          ...WorldStatus.values.map((status) {
            final isSelected = statusFilter == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Builder(
                  builder: (context) => Text(
                    _getStatusLabel(status, context),
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                avatar: Icon(
                  _getStatusIcon(status),
                  size: 16,
                  color: isSelected ? theme.colorScheme.onPrimary : _getStatusColor(status, theme),
                ),
                onSelected: (selected) {
                  onStatusChanged(selected ? status : null);
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: _getStatusColor(status, theme).withValues(alpha: 0.3),
                checkmarkColor: theme.colorScheme.onPrimary,
                side: BorderSide(
                  color: isSelected ? _getStatusColor(status, theme) : theme.colorScheme.outline,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).worldFiltersCategory,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          ...WorldCategory.values.map((category) {
            final isSelected = categoryFilter == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isSelected ? theme.colorScheme.onPrimary : _getCategoryColor(category, theme),
                    ),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) => Text(
                        _getCategoryLabel(category, context),
                        style: TextStyle(
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                onSelected: (selected) {
                  onCategoryChanged(selected ? category : null);
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: _getCategoryColor(category, theme).withValues(alpha: 0.3),
                checkmarkColor: theme.colorScheme.onPrimary,
                side: BorderSide(
                  color: isSelected ? _getCategoryColor(category, theme) : theme.colorScheme.outline,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).worldFiltersSortBy,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: DropdownButton<String>(
              value: sortBy,
              dropdownColor: theme.colorScheme.surface,
              style: TextStyle(color: theme.colorScheme.onPrimary),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
              items: [
                DropdownMenuItem(
                  value: 'startDate',
                  child: Text(AppLocalizations.of(context).worldFiltersSortStartDate),
                ),
                DropdownMenuItem(
                  value: 'name',
                  child: Text(AppLocalizations.of(context).worldFiltersSortName),
                ),
                DropdownMenuItem(
                  value: 'status',
                  child: Text(AppLocalizations.of(context).worldFiltersSortStatus),
                ),
                DropdownMenuItem(
                  value: 'playerCount',
                  child: Text(AppLocalizations.of(context).worldFiltersSortPlayerCount),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onSortByChanged(value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: IconButton(
              icon: Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                size: 20,
              ),
              onPressed: onSortOrderChanged,
              tooltip: sortAscending ? 'Aufsteigend' : 'Absteigend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Aktive Filter: ',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          if (statusFilter != null)
            Builder(
              builder: (context) {
                final filter = statusFilter!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(
                      _getStatusLabel(filter, context),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(filter, theme).withValues(alpha: 0.2),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onStatusChanged(null),
                    side: BorderSide(
                      color: _getStatusColor(filter, theme).withValues(alpha: 0.5),
                    ),
                  ),
                );
              }
            ),
          if (categoryFilter != null)
            Builder(
              builder: (context) {
                final filter = categoryFilter!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(
                      _getCategoryLabel(filter, context),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getCategoryColor(filter, theme).withValues(alpha: 0.2),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onCategoryChanged(null),
                    side: BorderSide(
                      color: _getCategoryColor(filter, theme).withValues(alpha: 0.5),
                    ),
                  ),
                );
              }
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: onResetFilters,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Alle zurücksetzen'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(WorldStatus status, BuildContext context) {
    return status.getDisplayName(context);
  }

  IconData _getStatusIcon(WorldStatus status) {
    switch (status) {
      case WorldStatus.upcoming:
        return Icons.schedule;
      case WorldStatus.open:
        return Icons.lock_open;
      case WorldStatus.running:
        return Icons.play_circle;
      case WorldStatus.closed:
        return Icons.lock;
      case WorldStatus.archived:
        return Icons.archive;
    }
  }

  Color _getStatusColor(WorldStatus status, ThemeData theme) {
    switch (status) {
      case WorldStatus.upcoming:
        return theme.colorScheme.secondary;
      case WorldStatus.open:
        return theme.colorScheme.primary;
      case WorldStatus.running:
        return theme.colorScheme.tertiary;
      case WorldStatus.closed:
        return theme.colorScheme.error;
      case WorldStatus.archived:
        return theme.colorScheme.outline;
    }
  }

  String _getCategoryLabel(WorldCategory category, BuildContext context) {
    return category.getDisplayName(context);
  }

  IconData _getCategoryIcon(WorldCategory category) {
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

  Color _getCategoryColor(WorldCategory category, ThemeData theme) {
    switch (category) {
      case WorldCategory.classic:
        return theme.colorScheme.primary;
      case WorldCategory.pvp:
        return theme.colorScheme.error;
      case WorldCategory.event:
        return theme.colorScheme.tertiary;
      case WorldCategory.experimental:
        return theme.colorScheme.secondary;
    }
  }
} 