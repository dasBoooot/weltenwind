/// 🌍 World Service Interface
/// 
/// Defines the contract for world management services
library;

import '../models/world.dart';

abstract class IWorldService {
  /// Get list of available worlds
  /// Returns list of worlds user can see
  Future<List<World>> getWorlds({
    String? category,
    String? searchQuery,
    int? limit,
    int? offset,
  });
  
  /// Get world by ID
  /// Returns World if found, throws WorldException if not found
  Future<World> getWorldById(int worldId);
  
  /// Join a world
  /// Returns true if successful, throws WorldException if failed
  Future<bool> joinWorld(int worldId);
  
  /// Leave a world
  /// Returns true if successful, throws WorldException if failed
  Future<bool> leaveWorld(int worldId);
  
  /// Get worlds user has joined
  /// Returns list of joined worlds
  Future<List<World>> getJoinedWorlds();
  
  /// Check if user has joined specific world
  /// Returns true if user is member of world
  Future<bool> isWorldMember(int worldId);
  
  /// Get world categories
  /// Returns list of available world categories
  Future<List<String>> getWorldCategories();
  
  /// Search worlds by query
  /// Returns list of worlds matching search criteria
  Future<List<World>> searchWorlds(String query, {
    String? category,
    List<String>? tags,
    int? limit,
  });
  
  /// Get featured/recommended worlds
  /// Returns list of featured worlds
  Future<List<World>> getFeaturedWorlds();
  
  /// Get world statistics
  /// Returns statistics for specific world
  Future<Map<String, dynamic>> getWorldStats(int worldId);
  
  /// Pre-register for world (if not open yet)
  /// Returns true if successful, throws WorldException if failed
  Future<bool> preRegisterWorld(int worldId);
  
  /// Cancel pre-registration
  /// Returns true if successful, throws WorldException if failed
  Future<bool> cancelPreRegistration(int worldId);
  
  /// Check pre-registration status
  /// Returns true if user is pre-registered
  Future<bool> isPreRegistered(int worldId);
  
  /// Get world invitation link
  /// Returns invitation URL for sharing
  Future<String> getInvitationLink(int worldId);
  
  /// Join world via invitation
  /// Returns true if successful, throws WorldException if failed
  Future<bool> joinViaInvitation(String invitationCode);
  
  /// Get world theme information
  /// Returns theme data for world
  Future<Map<String, dynamic>?> getWorldTheme(int worldId);
  
  /// Check if world supports specific features
  /// Returns true if world has feature enabled
  Future<bool> hasWorldFeature(int worldId, String feature);
  
  /// Get world player count
  /// Returns current and maximum player count
  Future<Map<String, int>> getWorldPlayerCount(int worldId);
}