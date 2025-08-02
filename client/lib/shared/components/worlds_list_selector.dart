import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/providers/theme_context_provider.dart';
import 'world_preview_card.dart';

/// 📋 Sort Options
enum SortOption {
  name,
  playerCount,
  status,
  lastPlayed,
  created,
}

/// 📋 Sort Direction
enum SortDirection {
  asc,
  desc,
}

/// 📋 Filter Configuration
class WorldFilter {
  final List<WorldStatus> statusFilter;
  final String? playerCountRange;
  final List<String> tagFilter;
  final bool favoritesOnly;

  const WorldFilter({
    this.statusFilter = const [],
    this.playerCountRange,
    this.tagFilter = const [],
    this.favoritesOnly = false,
  });

  WorldFilter copyWith({
    List<WorldStatus>? statusFilter,
    String? playerCountRange,
    List<String>? tagFilter,
    bool? favoritesOnly,
  }) {
    return WorldFilter(
      statusFilter: statusFilter ?? this.statusFilter,
      playerCountRange: playerCountRange ?? this.playerCountRange,
      tagFilter: tagFilter ?? this.tagFilter,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  bool get hasActiveFilters {
    return statusFilter.isNotEmpty ||
           playerCountRange != null ||
           tagFilter.isNotEmpty ||
           favoritesOnly;
  }

  int get activeFilterCount {
    int count = 0;
    if (statusFilter.isNotEmpty) count++;
    if (playerCountRange != null) count++;
    if (tagFilter.isNotEmpty) count += tagFilter.length;
    if (favoritesOnly) count++;
    return count;
  }
}

/// 📋 Worlds List Selector based on World List Selector Schema
/// 
/// Complete world selection interface with search, filters, sorting, and schema-based configuration
class WorldsListSelector extends StatefulWidget {
  final List<WorldData> worlds;
  final Function(WorldData)? onWorldSelected;
  final Function(WorldData)? onWorldJoin;
  final Function(WorldData)? onWorldFavorite;
  final double? height;
  final bool showSearch;
  final bool showFilters;
  final bool showSort;
  final int maxVisibleItems;
  final String searchPlaceholder;

  const WorldsListSelector({
    super.key,
    required this.worlds,
    this.onWorldSelected,
    this.onWorldJoin,
    this.onWorldFavorite,
    this.height,
    this.showSearch = true,
    this.showFilters = true,
    this.showSort = true,
    this.maxVisibleItems = 5,
    this.searchPlaceholder = "Search worlds...",
  });

  @override
  State<WorldsListSelector> createState() => _WorldsListSelectorState();
}

class _WorldsListSelectorState extends State<WorldsListSelector> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  
  String _searchQuery = '';
  WorldFilter _filter = const WorldFilter();
  SortOption _sortOption = SortOption.name;
  SortDirection _sortDirection = SortDirection.asc;
  bool _filtersExpanded = false;
  
  WorldData? _selectedWorld;
  List<WorldData> _filteredWorlds = [];
  Set<String> _availableTags = {};

  @override
  void initState() {
    super.initState();
    _updateFilteredWorlds();
    _updateAvailableTags();
  }

  @override
  void didUpdateWidget(WorldsListSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.worlds != oldWidget.worlds) {
      _updateFilteredWorlds();
      _updateAvailableTags();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_getSearchDebounceDelay(), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _updateFilteredWorlds();
      });
    });
  }

  void _updateFilteredWorlds() {
    _filteredWorlds = widget.worlds.where((world) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = world.name.toLowerCase().contains(_searchQuery);
        final matchesDescription = world.description?.toLowerCase().contains(_searchQuery) ?? false;
        final matchesTags = world.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
        
        if (!matchesName && !matchesDescription && !matchesTags) {
          return false;
        }
      }

      // Status filter
      if (_filter.statusFilter.isNotEmpty && !_filter.statusFilter.contains(world.status)) {
        return false;
      }

      // Player count filter
      if (_filter.playerCountRange != null) {
        if (!_matchesPlayerCountRange(world, _filter.playerCountRange!)) {
          return false;
        }
      }

      // Tags filter
      if (_filter.tagFilter.isNotEmpty) {
        if (!_filter.tagFilter.any((tag) => world.tags.contains(tag))) {
          return false;
        }
      }

      // Favorites filter
      if (_filter.favoritesOnly && !world.isFavorite) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    _filteredWorlds.sort((a, b) {
      int comparison = 0;
      
      switch (_sortOption) {
        case SortOption.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SortOption.playerCount:
          comparison = a.currentPlayers.compareTo(b.currentPlayers);
          break;
        case SortOption.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case SortOption.lastPlayed:
          final aTime = a.lastPlayed ?? DateTime(1970);
          final bTime = b.lastPlayed ?? DateTime(1970);
          comparison = aTime.compareTo(bTime);
          break;
        case SortOption.created:
          comparison = a.id.compareTo(b.id); // Assuming ID order reflects creation order
          break;
      }

      return _sortDirection == SortDirection.asc ? comparison : -comparison;
    });
  }

  void _updateAvailableTags() {
    _availableTags = widget.worlds
        .expand((world) => world.tags)
        .toSet();
  }

  bool _matchesPlayerCountRange(WorldData world, String range) {
    switch (range) {
      case 'empty':
        return world.currentPlayers == 0;
      case 'low':
        return world.currentPlayers >= 1 && world.currentPlayers <= 10;
      case 'medium':
        return world.currentPlayers >= 11 && world.currentPlayers <= 50;
      case 'high':
        return world.currentPlayers > 50;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'WorldsListSelector',
      contextOverrides: {
        'loading': 'false',
        'hasWorlds': _filteredWorlds.isNotEmpty.toString(),
        'sortBy': _sortOption.name,
      },
      builder: (context, contextTheme, extensions) {
        return _buildWorldsList(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildWorldsList(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      height: widget.height,
      decoration: _getContainerDecoration(theme, extensions),
      child: Column(
        children: [
          // Search bar
          if (widget.showSearch)
            _buildSearchBar(theme),
          
          // Filters section
          if (widget.showFilters)
            _buildFiltersSection(theme),
          
          // Sort and results info
          _buildHeaderRow(theme),
          
          // World list
          Expanded(
            child: _buildWorldList(theme, extensions),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(_getPadding()),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.searchPlaceholder,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainer,
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return AnimatedContainer(
      duration: _getAnimationDuration(),
      height: _filtersExpanded ? null : 60,
      child: Column(
        children: [
          // Filter toggle and active count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _getPadding()),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _filtersExpanded = !_filtersExpanded;
                    });
                  },
                  icon: Icon(
                    _filtersExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text('Filters'),
                ),
                
                if (_filter.activeFilterCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filter.activeFilterCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
                
                const Spacer(),
                
                if (_filter.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filter = const WorldFilter();
                        _updateFilteredWorlds();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),
          
          // Filter options
          if (_filtersExpanded)
            _buildFilterOptions(theme),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(_getPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter
          _buildStatusFilter(theme),
          
          const SizedBox(height: 16),
          
          // Player count filter
          _buildPlayerCountFilter(theme),
          
          const SizedBox(height: 16),
          
          // Tags filter
          if (_availableTags.isNotEmpty)
            _buildTagsFilter(theme),
          
          const SizedBox(height: 16),
          
          // Favorites filter
          _buildFavoritesFilter(theme),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: WorldStatus.values.map((status) {
            final isSelected = _filter.statusFilter.contains(status);
            return FilterChip(
              label: Text(_getStatusText(status)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filter = _filter.copyWith(
                      statusFilter: [..._filter.statusFilter, status],
                    );
                  } else {
                    _filter = _filter.copyWith(
                      statusFilter: _filter.statusFilter.where((s) => s != status).toList(),
                    );
                  }
                  _updateFilteredWorlds();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlayerCountFilter(ThemeData theme) {
    const ranges = [
      {'key': 'empty', 'label': 'Empty (0 players)'},
      {'key': 'low', 'label': 'Low (1-10 players)'},
      {'key': 'medium', 'label': 'Medium (11-50 players)'},
      {'key': 'high', 'label': 'High (50+ players)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Player Count', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ranges.map((range) {
            final isSelected = _filter.playerCountRange == range['key'];
            return FilterChip(
              label: Text(range['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filter = _filter.copyWith(
                    playerCountRange: selected ? range['key'] : null,
                  );
                  _updateFilteredWorlds();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsFilter(ThemeData theme) {
    final visibleTags = _availableTags.take(_getMaxVisibleTags()).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: visibleTags.map((tag) {
            final isSelected = _filter.tagFilter.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filter = _filter.copyWith(
                      tagFilter: [..._filter.tagFilter, tag],
                    );
                  } else {
                    _filter = _filter.copyWith(
                      tagFilter: _filter.tagFilter.where((t) => t != tag).toList(),
                    );
                  }
                  _updateFilteredWorlds();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFavoritesFilter(ThemeData theme) {
    return CheckboxListTile(
      title: const Text('Favorites Only'),
      value: _filter.favoritesOnly,
      onChanged: (value) {
        setState(() {
          _filter = _filter.copyWith(favoritesOnly: value ?? false);
          _updateFilteredWorlds();
        });
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getPadding()),
      child: Row(
        children: [
          Text(
            '${_filteredWorlds.length} worlds',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const Spacer(),
          
          if (widget.showSort)
            _buildSortDropdown(theme),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(ThemeData theme) {
    return PopupMenuButton<String>(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort, size: 18),
          const SizedBox(width: 4),
          Text(_getSortOptionText(_sortOption)),
          Icon(
            _sortDirection == SortDirection.asc
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            size: 16,
          ),
        ],
      ),
      itemBuilder: (context) {
        return SortOption.values.map((option) {
          return PopupMenuItem<String>(
            value: '${option.name}_asc',
            child: Row(
              children: [
                Text(_getSortOptionText(option)),
                const Spacer(),
                if (_sortOption == option && _sortDirection == SortDirection.asc)
                  const Icon(Icons.check, size: 16),
              ],
            ),
          );
        }).toList()
        ..addAll(SortOption.values.map((option) {
          return PopupMenuItem<String>(
            value: '${option.name}_desc',
            child: Row(
              children: [
                Text('${_getSortOptionText(option)} (desc)'),
                const Spacer(),
                if (_sortOption == option && _sortDirection == SortDirection.desc)
                  const Icon(Icons.check, size: 16),
              ],
            ),
          );
        }).toList());
      },
      onSelected: (value) {
        final parts = value.split('_');
        final option = SortOption.values.firstWhere((e) => e.name == parts[0]);
        final direction = parts[1] == 'asc' ? SortDirection.asc : SortDirection.desc;
        
        setState(() {
          _sortOption = option;
          _sortDirection = direction;
          _updateFilteredWorlds();
        });
      },
    );
  }

  Widget _buildWorldList(ThemeData theme, Map<String, dynamic>? extensions) {
    if (_filteredWorlds.isEmpty) {
      return _buildEmptyState(theme);
    }

    final gridColumns = _getGridColumns(context);

    return Padding(
      padding: EdgeInsets.all(_getPadding()),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          crossAxisSpacing: _getSpacing(),
          mainAxisSpacing: _getSpacing(),
          childAspectRatio: gridColumns == 1 ? 4.0 : 1.2, // Wide cards for single column, square-ish for multi-column
        ),
        itemCount: _filteredWorlds.length,
        itemBuilder: (context, index) {
          final world = _filteredWorlds[index];
          final isSelected = _selectedWorld?.id == world.id;
          
          return _buildWorldListItem(world, isSelected, theme, extensions);
        },
      ),
    );
  }

  Widget _buildWorldListItem(
    WorldData world,
    bool isSelected,
    ThemeData theme,
    Map<String, dynamic>? extensions,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWorld = world;
        });
        widget.onWorldSelected?.call(world);
      },
      child: AnimatedContainer(
        duration: _getAnimationDuration(),
        height: _getItemHeight(),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            if (_getShowThumbnail())
              _buildItemThumbnail(world, theme),
            
            if (_getShowThumbnail()) const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          world.name,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      if (_getShowStatus())
                        _buildStatusIndicator(world, theme),
                    ],
                  ),
                  
                  // Description
                  if (world.description != null && _getShowDescription())
                    Text(
                      world.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const Spacer(),
                  
                  // Footer
                  Row(
                    children: [
                      // Player count
                      if (_getShowPlayerCount()) ...[
                        Icon(
                          Icons.people,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${world.currentPlayers}/${world.maxPlayers}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      
                      const Spacer(),
                      
                      // Tags
                      if (_getShowTags() && world.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: world.tags.take(_getMaxTags()).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                if (world.isFavorite)
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 16,
                  ),
                
                const Spacer(),
                
                IconButton(
                  onPressed: () => widget.onWorldJoin?.call(world),
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemThumbnail(WorldData world, ThemeData theme) {
    return Container(
      width: _getThumbnailSize(),
      height: _getThumbnailSize(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainer,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: world.thumbnailUrl != null
            ? Image.network(
                world.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.public,
                  size: _getThumbnailSize() * 0.5,
                ),
              )
            : Icon(
                Icons.public,
                size: _getThumbnailSize() * 0.5,
              ),
      ),
    );
  }

  Widget _buildStatusIndicator(WorldData world, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(world.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(world.status),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(world.status),
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getStatusColor(world.status),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No worlds found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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

  /// Get status color
  Color _getStatusColor(WorldStatus status) {
    switch (status) {
      case WorldStatus.online:
        return const Color(0xFF22C55E);
      case WorldStatus.offline:
        return const Color(0xFFEF4444);
      case WorldStatus.maintenance:
        return const Color(0xFFF59E0B);
      case WorldStatus.full:
        return const Color(0xFF8B5CF6);
    }
  }

  /// Get status text
  String _getStatusText(WorldStatus status) {
    switch (status) {
      case WorldStatus.online:
        return 'Online';
      case WorldStatus.offline:
        return 'Offline';
      case WorldStatus.maintenance:
        return 'Maintenance';
      case WorldStatus.full:
        return 'Full';
    }
  }

  /// Get sort option text
  String _getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.name:
        return 'Name';
      case SortOption.playerCount:
        return 'Players';
      case SortOption.status:
        return 'Status';
      case SortOption.lastPlayed:
        return 'Last Played';
      case SortOption.created:
        return 'Created';
    }
  }

  // Schema-based getters
  double _getItemHeight() => 80.0; // Schema default
  double _getSpacing() => 8.0; // Schema default
  double _getBorderRadius() => 12.0; // Schema default
  double _getPadding() => 16.0; // Schema default
  Duration _getSearchDebounceDelay() => const Duration(milliseconds: 300); // Schema default
  Duration _getAnimationDuration() => const Duration(milliseconds: 300); // Schema default
  
  /// 🔥 RESPONSIVE FIX: Calculate responsive grid columns
  int _getGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return 1; // Mobile: 1 column (vertical list)
    } else if (screenWidth < 900) {
      return 2; // Tablet: 2 columns
    } else if (screenWidth < 1200) {
      return 3; // Desktop: 3 columns
    } else {
      return 4; // Large Desktop: 4 columns
    }
  }
  
  bool _getShowThumbnail() => true; // Schema default
  double _getThumbnailSize() => 60.0; // Schema default
  bool _getShowStatus() => true; // Schema default
  bool _getShowPlayerCount() => true; // Schema default
  bool _getShowDescription() => true; // Schema default
  bool _getShowTags() => true; // Schema default
  int _getMaxTags() => 3; // Schema default
  int _getMaxVisibleTags() => 10; // Schema default
}