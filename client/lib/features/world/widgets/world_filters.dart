import 'package:flutter/material.dart';
import '../../../core/models/world.dart';
import '../../../l10n/app_localizations.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter
        _buildStatusFilter(context),
        const SizedBox(height: 12),
        
        // Category Filter
        _buildCategoryFilter(context),
        const SizedBox(height: 12),
        
        // Sort Options
        _buildSortOptions(context),
        const SizedBox(height: 12),
        
        // Active Filters & Reset
        if (statusFilter != null || categoryFilter != null)
          _buildActiveFilters(context),
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).worldFiltersStatus,
            style: TextStyle(
              color: Colors.grey[300],
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
                      color: isSelected ? Colors.white : Colors.grey[300],
                    ),
                  ),
                ),
                avatar: Icon(
                  _getStatusIcon(status),
                  size: 16,
                  color: isSelected ? Colors.white : _getStatusColor(status),
                ),
                onSelected: (selected) {
                  onStatusChanged(selected ? status : null);
                },
                backgroundColor: const Color(0xFF2D2D2D),
                selectedColor: _getStatusColor(status).withOpacity(0.3),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? _getStatusColor(status) : Colors.grey[600]!,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).worldFiltersCategory,
            style: TextStyle(
              color: Colors.grey[300],
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
                      color: isSelected ? Colors.white : _getCategoryColor(category),
                    ),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) => Text(
                        _getCategoryLabel(category, context),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
                onSelected: (selected) {
                  onCategoryChanged(selected ? category : null);
                },
                backgroundColor: const Color(0xFF2D2D2D),
                selectedColor: _getCategoryColor(category).withOpacity(0.3),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? _getCategoryColor(category) : Colors.grey[600]!,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).worldFiltersSortBy,
            style: TextStyle(
              color: Colors.grey[300],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: DropdownButton<String>(
              value: sortBy,
              dropdownColor: const Color(0xFF2D2D2D),
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[300]),
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
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: IconButton(
              icon: Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.grey[300],
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

  Widget _buildActiveFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Aktive Filter: ',
            style: TextStyle(
              color: Colors.grey[400],
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
                    backgroundColor: _getStatusColor(filter).withOpacity(0.2),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onStatusChanged(null),
                    side: BorderSide(
                      color: _getStatusColor(filter).withOpacity(0.5),
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
                    backgroundColor: _getCategoryColor(filter).withOpacity(0.2),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onCategoryChanged(null),
                    side: BorderSide(
                      color: _getCategoryColor(filter).withOpacity(0.5),
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
              foregroundColor: Colors.grey[400],
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

  Color _getStatusColor(WorldStatus status) {
    switch (status) {
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
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

  Color _getCategoryColor(WorldCategory category) {
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
} 