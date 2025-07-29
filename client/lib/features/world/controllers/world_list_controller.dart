import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../config/logger.dart';
import '../../../core/models/world.dart';
import '../../../core/services/world_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/invite_service.dart';
import '../widgets/world_card.dart';

class WorldListController extends ChangeNotifier {
  final WorldService _worldService;
  final InviteService _inviteService;

  // State
  List<World> _worlds = [];
  List<World> _filteredWorlds = [];
  Map<int, int> _playerCounts = {};
  Map<int, bool> _preRegisteredWorlds = {};
  Map<int, bool> _joinedWorlds = {};
  bool _isLoading = false;
  String? _error;

  // Filters & Sorting
  WorldStatus? _statusFilter;
  WorldCategory? _categoryFilter;
  String _sortBy = 'startDate';
  bool _sortAscending = true;

  // Getters
  List<World> get worlds => _worlds;
  List<World> get filteredWorlds => _filteredWorlds;
  Map<int, int> get playerCounts => _playerCounts;
  Map<int, bool> get preRegisteredWorlds => _preRegisteredWorlds;
  Map<int, bool> get joinedWorlds => _joinedWorlds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WorldStatus? get statusFilter => _statusFilter;
  WorldCategory? get categoryFilter => _categoryFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  WorldListController({
    required WorldService worldService,
    required InviteService inviteService,
  })  : _worldService = worldService,
        _inviteService = inviteService;

  Future<void> loadWorlds() async {
    _setLoading(true);
    _error = null;

    try {
      _worlds = await _worldService.getWorlds();
      await _loadPlayerCounts();
      await _checkPlayerStatuses();
      _applyFiltersAndSorting();
    } catch (e) {
      _error = 'Fehler beim Laden der Welten: $e';
      AppLogger.logError('World-Liste laden fehlgeschlagen', e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadPlayerCounts() async {
    // TODO: Implement actual player count API when available
    // For now, use mock data
    for (final world in _worlds) {
      _playerCounts[world.id] = 0; // Placeholder
    }
    notifyListeners();
  }

  Future<void> _checkPlayerStatuses() async {
    for (final world in _worlds) {
      try {
        // Check if user is in the world
        final isJoined = await _worldService.isPlayerInWorld(world.id);
        
        // Check if user is pre-registered
        final isPreRegistered = await _worldService.isPreRegisteredForWorld(world.id);
        
        _joinedWorlds[world.id] = isJoined;
        _preRegisteredWorlds[world.id] = isPreRegistered;
        notifyListeners();
      } catch (e) {
        AppLogger.logError('Player-Status Check fehlgeschlagen', e, context: {'worldId': world.id});
        _joinedWorlds[world.id] = false;
        _preRegisteredWorlds[world.id] = false;
      }
    }
  }

  void setStatusFilter(WorldStatus? status) {
    _statusFilter = status;
    _applyFiltersAndSorting();
  }

  void setCategoryFilter(WorldCategory? category) {
    _categoryFilter = category;
    _applyFiltersAndSorting();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSorting();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _applyFiltersAndSorting();
  }

  void resetFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _sortBy = 'startDate';
    _sortAscending = true;
    _applyFiltersAndSorting();
  }

  void _applyFiltersAndSorting() {
    var filtered = List<World>.from(_worlds);

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((world) => world.status == _statusFilter).toList();
    }

    // Apply category filter
    if (_categoryFilter != null) {
      filtered = filtered.where((world) {
        return _getWorldCategory(world) == _categoryFilter;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'status':
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case 'playerCount':
          final countA = _playerCounts[a.id] ?? 0;
          final countB = _playerCounts[b.id] ?? 0;
          comparison = countA.compareTo(countB);
          break;
        case 'startDate':
        default:
          comparison = a.startsAt.compareTo(b.startsAt);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    _filteredWorlds = filtered;
    notifyListeners();
  }

  WorldCategory _getWorldCategory(World world) {
    // This is a placeholder logic - you might want to adjust based on your needs
    if (world.name.toLowerCase().contains('pvp')) {
      return WorldCategory.pvp;
    } else if (world.name.toLowerCase().contains('event')) {
      return WorldCategory.event;
    } else if (world.name.toLowerCase().contains('experimental') || 
               world.name.toLowerCase().contains('test')) {
      return WorldCategory.experimental;
    }
    return WorldCategory.classic;
  }

  Future<void> joinWorld(World world) async {
    try {
      await _worldService.joinWorld(world.id);
      _joinedWorlds[world.id] = true;
      
      // Update player count
      final currentCount = _playerCounts[world.id] ?? 0;
      _playerCounts[world.id] = currentCount + 1;
      
      notifyListeners();
    } catch (e) {
      _error = 'Fehler beim Beitreten: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> preRegisterWorld(World world) async {
    try {
      // TODO: Implement pre-registration API call
      await Future.delayed(const Duration(milliseconds: 500)); // Simulated API call
      
      _preRegisteredWorlds[world.id] = true;
      notifyListeners();
    } catch (e) {
      _error = 'Fehler bei der Vorregistrierung: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> cancelPreRegistration(World world) async {
    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        _preRegisteredWorlds[world.id] = false;
        notifyListeners();
      } else {
        throw Exception('Vorregistrierung konnte nicht zurückgezogen werden');
      }
    } catch (e) {
      _error = 'Fehler beim Zurückziehen der Vorregistrierung: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> leaveWorld(World world) async {
    try {
      await _worldService.leaveWorld(world.id);
      _joinedWorlds[world.id] = false;
      
      // Update player count
      final currentCount = _playerCounts[world.id] ?? 0;
      if (currentCount > 0) {
        _playerCounts[world.id] = currentCount - 1;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Fehler beim Verlassen der Welt: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> createInvite(World world, String email) async {
    try {
      final success = await _inviteService.createInvite(world.id, email);
      if (!success) {
        _error = 'Einladung konnte nicht erstellt werden';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Fehler beim Erstellen der Einladung: $e';
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 