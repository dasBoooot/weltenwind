import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../config/logger.dart';
import '../../config/env.dart';

/// Service for dynamically loading assets without hardcoding paths in pubspec.yaml
/// This maintains modularity by allowing runtime asset discovery
class DynamicAssetService {
  static final DynamicAssetService _instance = DynamicAssetService._internal();
  factory DynamicAssetService() => _instance;
  DynamicAssetService._internal();

  final Map<String, bool> _assetCache = {};

  /// Check if an asset exists at runtime (including backend URLs)
  Future<bool> assetExists(String assetPath) async {
    if (_assetCache.containsKey(assetPath)) {
      return _assetCache[assetPath]!;
    }

    // Check if it's an asset server URL
    if (assetPath.contains('{{ASSET_IP}}')) {
      final resolvedPath = _replaceAssetPlaceholder(assetPath);
      return await _checkAssetServerAsset(resolvedPath);
    }

    try {
      // Try to load the asset manifest to check if it exists
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final exists = manifestMap.containsKey(assetPath);
      _assetCache[assetPath] = exists;
      
      AppLogger.app.d('🔍 Asset check: $assetPath -> ${exists ? '✅' : '❌'}');
      return exists;
    } catch (e) {
      AppLogger.app.e('❌ Error checking asset: $assetPath - $e');
      _assetCache[assetPath] = false;
      return false;
    }
  }

  /// Try multiple possible asset paths and return the first one that exists
  Future<String?> findExistingAsset(List<String> possiblePaths) async {
    for (final path in possiblePaths) {
      if (await assetExists(path)) {
        AppLogger.app.d('✅ Found existing asset: $path');
        return path;
      }
    }
    
    AppLogger.app.w('⚠️ No existing asset found for paths: $possiblePaths');
    return null;
  }

  /// Generate possible asset paths for a world background
  List<String> generateBackgroundPaths(String worldId, String pageType) {
    return [
      // Local asset paths - prioritize default.png over pageType.png
      'worlds/$worldId/ui/backgrounds/default.png',
      'worlds/$worldId/ui/backgrounds/$pageType.png',
      'worlds/$worldId/backgrounds/default.png',
      'worlds/$worldId/backgrounds/$pageType.png',
      'assets/worlds/$worldId/ui/backgrounds/default.png',
      'assets/worlds/$worldId/ui/backgrounds/$pageType.png',
      'assets/worlds/$worldId/backgrounds/default.png',
      'assets/worlds/$worldId/backgrounds/$pageType.png',
      // API-based asset paths (via backend API) - prioritize default.png
      '{{ASSET_IP}}/api/assets/worlds/$worldId/ui/backgrounds/default.png',
      '{{ASSET_IP}}/api/assets/worlds/$worldId/ui/backgrounds/$pageType.png',
      '{{ASSET_IP}}/api/assets/worlds/$worldId/backgrounds/default.png',
      '{{ASSET_IP}}/api/assets/worlds/$worldId/backgrounds/$pageType.png',
    ];
  }

  /// Replace asset server IP placeholder with actual asset server URL
  String _replaceAssetPlaceholder(String path) {
    // Get asset server URL from environment or config
    final assetUrl = _getAssetUrl();
    final resolvedPath = path.replaceAll('{{ASSET_IP}}', assetUrl);
    AppLogger.app.d('🔍 Asset placeholder replacement: $path -> $resolvedPath');
    return resolvedPath;
  }

  /// Get asset server URL from environment or config
  String _getAssetUrl() {
    // Get from environment config
    return Env.assetUrl;
  }

  /// Check if an asset exists on the asset server
  Future<bool> _checkAssetServerAsset(String assetUrl) async {
    try {
      // For Flutter Web, we can't make direct HTTP requests due to CORS
      // However, we can try a HEAD request for basic validation
      final response = await http.head(Uri.parse(assetUrl));
      
      final exists = response.statusCode == 200;
      AppLogger.app.d('🔍 Asset server check: $assetUrl -> ${exists ? '✅' : '❌'} (${response.statusCode})');
      return exists;
    } catch (e) {
      AppLogger.app.w('⚠️ Asset server check failed: $assetUrl - $e');
      // Fallback: assume it exists and let Image.network() handle the actual loading
      return true;
    }
  }

  /// Clear the asset cache (useful for testing or when assets change)
  void clearCache() {
    _assetCache.clear();
    AppLogger.app.d('🗑️ Asset cache cleared');
  }
}
