import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env.dart';
import '../../config/logger.dart';
import '../../shared/theme/models/named_entrypoints.dart';
import '../infrastructure/app_exception.dart';

class NamedEntrypointsService {
  static final NamedEntrypointsService _instance = NamedEntrypointsService._internal();
  factory NamedEntrypointsService() => _instance;
  NamedEntrypointsService._internal();

  /// Lädt alle verfügbaren Named Entrypoints
  Future<List<WorldManifest>> getAllNamedEntrypoints() async {
    try {
      AppLogger.app.i('📋 Lade alle Named Entrypoints');
      
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/api/themes/named-entrypoints'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final entrypoints = data['entrypoints'] as List;
        
        final manifests = <WorldManifest>[];
        for (final entrypoint in entrypoints) {
          try {
            final manifest = await getNamedEntrypoint(entrypoint['filename']);
            if (manifest != null) {
              manifests.add(manifest);
            }
          } catch (e) {
            AppLogger.app.w('⚠️ Fehler beim Laden des Entrypoints: $e');
          }
        }
        
        AppLogger.app.i('✅ Named Entrypoints erfolgreich geladen (${manifests.length})');
        return manifests;
      } else {
        throw ThemeException(
          'Fehler beim Laden der Named Entrypoints',
          statusCode: response.statusCode,
          themeErrorType: ThemeErrorType.themeLoadFailed,
        );
      }
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der Named Entrypoints: $e');
      rethrow;
    }
  }

  /// Lädt ein spezifisches Named Entrypoint (Manifest)
  Future<WorldManifest?> getNamedEntrypoint(String worldId) async {
    try {
      AppLogger.app.i('📋 Lade Named Entrypoint: $worldId');
      
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/api/themes/named-entrypoints/$worldId/pre-game'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final manifest = WorldManifest.fromJson(data['manifest']);
        
        AppLogger.app.i('✅ Named Entrypoint erfolgreich geladen: $worldId');
        return manifest;
      } else if (response.statusCode == 404) {
        AppLogger.app.w('⚠️ Named Entrypoint nicht gefunden: $worldId');
        return null;
      } else {
        throw ThemeException(
          'Fehler beim Laden des Named Entrypoints',
          statusCode: response.statusCode,
          themeErrorType: ThemeErrorType.themeLoadFailed,
        );
      }
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden des Named Entrypoints: $e');
      rethrow;
    }
  }

  /// Lädt ein Theme für eine spezifische Welt und einen Kontext
  Future<NamedEntrypointResponse?> getNamedEntrypointTheme(
    String worldId,
    String context,
  ) async {
    try {
      AppLogger.app.i('🎨 Lade Named Entrypoint Theme: $worldId/$context');
      
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/api/themes/named-entrypoints/$worldId/$context'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final entrypointResponse = NamedEntrypointResponse.fromJson(data);
        
        AppLogger.app.i('✅ Named Entrypoint Theme erfolgreich geladen: $worldId/$context');
        return entrypointResponse;
      } else if (response.statusCode == 404) {
        AppLogger.app.w('⚠️ Named Entrypoint Theme nicht gefunden: $worldId/$context');
        return null;
      } else {
        throw ThemeException(
          'Fehler beim Laden des Named Entrypoint Themes',
          statusCode: response.statusCode,
          themeErrorType: ThemeErrorType.themeLoadFailed,
        );
      }
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden des Named Entrypoint Themes: $e');
      rethrow;
    }
  }

  /// Lädt das Pre-Game Theme für eine Welt (Hauptmethode für Pre-Game Kontext)
  Future<NamedEntrypointResponse?> getPreGameTheme(String worldId) async {
    return getNamedEntrypointTheme(worldId, ThemeContext.preGame);
  }

  /// Lädt das Game Theme für eine Welt
  Future<NamedEntrypointResponse?> getGameTheme(String worldId) async {
    return getNamedEntrypointTheme(worldId, ThemeContext.game);
  }

  /// Lädt das Loading Theme für eine Welt
  Future<NamedEntrypointResponse?> getLoadingTheme(String worldId) async {
    return getNamedEntrypointTheme(worldId, ThemeContext.loading);
  }

  /// Prüft ob ein Named Entrypoint für eine Welt existiert
  Future<bool> hasNamedEntrypoint(String worldId) async {
    try {
      final manifest = await getNamedEntrypoint(worldId);
      return manifest != null;
    } catch (e) {
      return false;
    }
  }

  /// Lädt alle verfügbaren Welt-IDs
  Future<List<String>> getAvailableWorldIds() async {
    try {
      final manifests = await getAllNamedEntrypoints();
      return manifests.map((manifest) => manifest.id).toList();
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der Welt-IDs: $e');
      return [];
    }
  }

  /// Lädt alle verfügbaren Welten mit Metadaten
  Future<List<Map<String, dynamic>>> getAvailableWorlds() async {
    try {
      final manifests = await getAllNamedEntrypoints();
      return manifests.map((manifest) => {
        'id': manifest.id,
        'name': manifest.name,
        'description': manifest.description,
        'category': manifest.category,
        'version': manifest.version,
        'author': manifest.author,
        'createdAt': manifest.createdAt,
      }).toList();
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der Welten: $e');
      return [];
    }
  }
}
