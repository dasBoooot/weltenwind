import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/logger.dart';
import '../../config/env.dart';

/// Service für das Laden der Client-Konfiguration vom Backend
/// Ermöglicht dynamische URL-Konfiguration für Skalierung
class ClientConfigService {
  static final ClientConfigService _instance = ClientConfigService._internal();
  factory ClientConfigService() => _instance;
  ClientConfigService._internal();

  bool _isInitialized = false;
  bool _isLoading = false;
  DateTime? _lastLoadTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Client-Konfiguration vom Backend laden
  Future<bool> loadConfiguration() async {
    if (_isLoading) {
      AppLogger.app.d('🔄 Client configuration already loading, skipping...');
      return _isInitialized;
    }

    // Prüfe Cache
    if (_isInitialized && _lastLoadTime != null) {
      final timeSinceLastLoad = DateTime.now().difference(_lastLoadTime!);
      if (timeSinceLastLoad < _cacheDuration) {
        AppLogger.app.d('✅ Using cached client configuration (${timeSinceLastLoad.inSeconds}s old)');
        return true;
      }
    }

    _isLoading = true;
    
    try {
      AppLogger.app.i('🔧 Loading client configuration from backend...');
      
      // Verwende die aktuellen URLs (können noch die Defaults sein)
      final configUrl = '${Env.apiUrl}/api/client-config';
      
      AppLogger.app.d('🔧 Attempting to load client config from: $configUrl');
      
      final response = await http.get(
        Uri.parse(configUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5)); // Kürzeres Timeout

      if (response.statusCode == 200) {
        final configData = json.decode(response.body) as Map<String, dynamic>;
        
        // URLs aktualisieren
        final apiUrl = configData['apiUrl'] as String?;
        final clientUrl = configData['clientUrl'] as String?;
        final assetUrl = configData['assetUrl'] as String?;
        final environment = configData['environment'] as String?;
        
        if (apiUrl != null) {
          Env.setApiUrl(apiUrl.replaceAll('/api', '')); // Entferne /api da es separat definiert ist
        }
        if (clientUrl != null) {
          Env.setClientUrl('$clientUrl/game'); // Füge /game hinzu
        }
        if (assetUrl != null) {
          Env.setAssetUrl(assetUrl);
        }
        
        _isInitialized = true;
        _lastLoadTime = DateTime.now();
        
        AppLogger.app.i('✅ Client configuration loaded successfully', error: {
          'environment': environment,
          'apiUrl': Env.apiUrl,
          'clientUrl': Env.clientUrl,
          'assetUrl': Env.assetUrl,
          'timestamp': _lastLoadTime!.toIso8601String(),
        });
        
        return true;
        
      } else {
        AppLogger.app.w('⚠️ Failed to load client configuration: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      AppLogger.app.w('⚠️ Error loading client configuration: $e');
      // Nicht als Fehler loggen, da es normal ist, wenn Backend nicht verfügbar ist
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Prüfe ob die Konfiguration aktuell ist
  bool get isConfigurationCurrent {
    if (!_isInitialized || _lastLoadTime == null) return false;
    
    final timeSinceLastLoad = DateTime.now().difference(_lastLoadTime!);
    return timeSinceLastLoad < _cacheDuration;
  }

  /// Erzwinge Neuladen der Konfiguration
  Future<bool> reloadConfiguration() async {
    _isInitialized = false;
    _lastLoadTime = null;
    return await loadConfiguration();
  }

  /// Initialisiere die Konfiguration beim App-Start
  Future<bool> initialize() async {
    AppLogger.app.i('🚀 Initializing client configuration...');
    
    // Versuche Backend-Konfiguration zu laden
    final success = await loadConfiguration();
    
    if (success) {
      AppLogger.app.i('✅ Client configuration initialized successfully');
    } else {
      AppLogger.app.w('⚠️ Using default configuration (backend unavailable)');
      // Verwende Default-Konfiguration - App soll trotzdem funktionieren
      _isInitialized = true;
      _lastLoadTime = DateTime.now();
    }
    
    // Immer true zurückgeben, damit die App startet
    return true;
  }

  /// Debug-Informationen über die aktuelle Konfiguration
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'isLoading': _isLoading,
      'lastLoadTime': _lastLoadTime?.toIso8601String(),
      'isConfigurationCurrent': isConfigurationCurrent,
      'currentUrls': {
        'apiUrl': Env.apiUrl,
        'clientUrl': Env.clientUrl,
        'assetUrl': Env.assetUrl,
      },
      'cacheDuration': _cacheDuration.inMinutes,
    };
  }
}
