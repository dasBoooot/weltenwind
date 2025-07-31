import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/env.dart';
import '../../config/logger.dart';
import 'auth_service.dart';
import '../../routing/app_router.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  AuthService? _authService;
  String? _deviceFingerprint;
  bool _initialized = false;
  bool _isValidatingToken = false; // Verhindert rekursive Token-Validierung
  
  // Erweiterte Request-Kontext-Verwaltung für parallele Requests
  final Map<String, Map<String, dynamic>> _requestBodies = {};

  // Dependency Injection für bessere Testbarkeit
  ApiService.withAuth(AuthService authService) {
    _authService = authService;
    _initialized = true; // Als initialisiert markieren wenn explizit gesetzt
  }

  // Initialisierung beim ersten Zugriff
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _authService ??= AuthService(); // Fallback nur wenn nicht bereits gesetzt
      try {
        final accessToken = await _authService!.getCurrentAccessToken();
        if (accessToken != null) {
          _token = accessToken;
        }
      } catch (e) {
        // Error loading token - continue without token
      }
      _initialized = true;
    }
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // Einfacher Device-Fingerprint
  String get deviceFingerprint {
    final currentFingerprint = _deviceFingerprint;
    if (currentFingerprint != null) {
      return currentFingerprint;
    }
    final fingerprint = kIsWeb 
        ? 'web_browser_${DateTime.now().millisecondsSinceEpoch}'
        : 'flutter_app_${DateTime.now().millisecondsSinceEpoch}';
    _deviceFingerprint = fingerprint;
    return fingerprint;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Device-Fingerprint': deviceFingerprint,
      'X-Client-Timezone': 'Europe/Berlin',
      'X-Client-Time': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Vollständige Token-Validierung mit JWT-Decoding (mit Rekursionsschutz)
  Future<void> _ensureValidToken() async {
    if (_token != null && !_isValidatingToken) {
      _isValidatingToken = true;
      try {
        final token = _token;
        if (token == null) return;
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
          final exp = payload['exp'] as int;
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          
          // Token erneuern wenn weniger als 60 Sekunden gültig
          if (exp - now < 60) {
            // Log Token-Refresh
            AppLogger.api.i('🔄 Token läuft ab in ${exp - now}s - erneuere proaktiv');
            
            final refreshed = await _authService!.refreshTokenIfNeeded();
            if (refreshed) {
              final newToken = await _authService!.getCurrentAccessToken();
              if (newToken != null) {
                setToken(newToken);
                AppLogger.api.i('✅ Token erfolgreich erneuert');
              }
            }
          }
        }
      } catch (e) {
        // Token validation error
        AppLogger.api.w('⚠️ Token-Validierung fehlgeschlagen', error: e);
                  await _authService!.refreshTokenIfNeeded();
      } finally {
        _isValidatingToken = false;
      }
    }
  }

  // Response-Interceptor mit Header-Parsing für proaktive Token-Erneuerung
  Future<http.Response> _handleResponse(http.Response response, String endpoint) async {
    // Proaktive Token-Erneuerung basierend auf Response-Headers
    if (response.headers['x-token-expires-soon'] == 'true') {
      final expiresIn = int.tryParse(response.headers['x-token-expires-in'] ?? '0');
      if (expiresIn != null && expiresIn < 60) {
        try {
          AppLogger.api.i('🔄 Proaktive Token-Erneuerung - läuft ab in ${expiresIn}s');
          
                      final refreshed = await _authService!.refreshTokenIfNeeded();
            if (refreshed) {
              final newToken = await _authService!.getCurrentAccessToken();
            if (newToken != null) {
              setToken(newToken);
              
                          // Request mit neuem Token wiederholen
            return await _retryRequest(endpoint, response.request!.method);
            }
          }
        } catch (e) {
          AppLogger.api.e('❌ Proaktive Token-Erneuerung fehlgeschlagen', error: e);
        }
      }
    }
    
    // Reaktive Token-Erneuerung bei 401
    if (response.statusCode == 401 && !endpoint.startsWith('/auth/')) {
      try {
        AppLogger.api.i('🔄 Reactive Token-Refresh wegen 401');
        
                    final refreshed = await _authService!.refreshTokenIfNeeded();
            if (refreshed) {
              final newToken = await _authService!.getCurrentAccessToken();
          if (newToken != null) {
            setToken(newToken);
            
            // Request mit neuem Token wiederholen
            return await _retryRequest(endpoint, response.request!.method);
          }
        }
      } catch (e) {
        AppLogger.api.e('❌ Token-Refresh fehlgeschlagen', error: e);
        // Bei Token-Refresh-Fehlern automatisch ausloggen
                  await _authService!.logout();
        // Cache invalidieren nach Logout
        AppRouter.invalidateAuthCache();
      }
    }
    return response;
  }

  // Vollständige Request-Wiederholung für alle HTTP-Methoden mit erweiterter Kontext-Verwaltung
  Future<http.Response> _retryRequest(String endpoint, String method) async {
    switch (method) {
      case 'GET':
        return await http.get(
          Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
          headers: _headers,
        );
      case 'POST':
        final cachedBody = _requestBodies[endpoint];
        if (cachedBody != null) {
          return await http.post(
            Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
            headers: _headers,
            body: jsonEncode(cachedBody),
          );
        }
        break;
      case 'PUT':
        final cachedBody = _requestBodies[endpoint];
        if (cachedBody != null) {
          return await http.put(
            Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
            headers: _headers,
            body: jsonEncode(cachedBody),
          );
        }
        break;
      case 'DELETE':
        return await http.delete(
          Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
          headers: _headers,
        );
    }
    return http.Response('Request retry failed', 500);
  }

  Future<http.Response> deleteWithBody(String endpoint, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    // Erweiterte Request-Kontext-Verwaltung für parallele Requests
    _requestBodies[endpoint] = data;
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    final request = http.Request('DELETE', Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'));
    request.headers.addAll(_headers);
    request.body = jsonEncode(data);
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return await _handleResponse(response, endpoint);
  }

  // Helper für das Sanitieren von sensiblen Daten aus dem Request-Body
  Map<String, dynamic> _sanitizeAuthData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.key == 'password' || entry.key == 'token') {
        sanitized[entry.key] = '***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  // Helper für das Sanitieren von sensiblen Daten aus der Response-Body
  String _sanitizeAuthResponse(String body) {
    try {
      final decodedBody = jsonDecode(body);
      if (decodedBody is Map<String, dynamic>) {
        final sanitized = <String, dynamic>{};
        for (final entry in decodedBody.entries) {
          if (entry.key.contains('token') || entry.key.contains('Token')) {
            sanitized[entry.key] = '***';
          } else {
            sanitized[entry.key] = entry.value;
          }
        }
        return jsonEncode(sanitized);
      }
    } catch (e) {
      // If JSON parsing fails, return truncated body
      return body.length > 100 ? '${body.substring(0, 100)}...' : body;
    }
    return body;
  }


  Future<http.Response> get(String endpoint) async {
    await _ensureInitialized();
    
    // Log API Request
    AppLogger.logApiRequest('GET', endpoint, headers: _headers);
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
        headers: _headers,
      );
      
      // Log API Response
      AppLogger.logApiResponse('GET', endpoint, response.statusCode, body: response.body);
      
      // Don't log 404 errors for player status checks
      if (response.statusCode == 404 && 
          (endpoint.contains('/players/me') || endpoint.contains('/pre-register/me'))) {
        return response;
      }
      
      return await _handleResponse(response, endpoint);
    } catch (error, stackTrace) {
      // Log API Error
      AppLogger.logApiError('GET', endpoint, error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    // Erweiterte Request-Kontext-Verwaltung für parallele Requests
    _requestBodies[endpoint] = data;
    
    // Log API Request (ohne sensitive Daten für Auth-Endpoints)
    final logBody = endpoint.startsWith('/auth/') ? _sanitizeAuthData(data) : data;
    AppLogger.logApiRequest('POST', endpoint, headers: _headers, body: logBody);
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    try {
      final response = await http.post(
        Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      // Log API Response (ohne sensitive Response-Daten)
      final logResponseBody = endpoint.startsWith('/auth/') ? _sanitizeAuthResponse(response.body) : response.body;
      AppLogger.logApiResponse('POST', endpoint, response.statusCode, body: logResponseBody);
      
      return await _handleResponse(response, endpoint);
    } catch (error, stackTrace) {
      // Log API Error
      AppLogger.logApiError('POST', endpoint, error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    // Erweiterte Request-Kontext-Verwaltung für parallele Requests
    _requestBodies[endpoint] = data;
    
    // Log API Request
    AppLogger.logApiRequest('PUT', endpoint, headers: _headers, body: data);
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    try {
      final response = await http.put(
        Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      // Log API Response
      AppLogger.logApiResponse('PUT', endpoint, response.statusCode, body: response.body);
      
      return await _handleResponse(response, endpoint);
    } catch (error, stackTrace) {
      // Log API Error
      AppLogger.logApiError('PUT', endpoint, error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    await _ensureInitialized();
    
    // Log API Request
    AppLogger.logApiRequest('DELETE', endpoint, headers: _headers);
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    try {
      final response = await http.delete(
        Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
        headers: _headers,
      );
      
      // Log API Response
      AppLogger.logApiResponse('DELETE', endpoint, response.statusCode, body: response.body);
      
      return await _handleResponse(response, endpoint);
    } catch (error, stackTrace) {
      // Log API Error
      AppLogger.logApiError('DELETE', endpoint, error, stackTrace: stackTrace);
      rethrow;
    }
  }
} 