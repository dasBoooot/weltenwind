import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/env.dart';
import 'auth_service.dart';
import '../../routing/app_router.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  late final AuthService _authService;
  String? _deviceFingerprint;
  bool _initialized = false;
  bool _isValidatingToken = false; // Verhindert rekursive Token-Validierung
  
  // Erweiterte Request-Kontext-Verwaltung für parallele Requests
  final Map<String, Map<String, dynamic>> _requestBodies = {};

  // Dependency Injection für bessere Testbarkeit
  ApiService.withAuth(AuthService authService) : _authService = authService;

  // Initialisierung beim ersten Zugriff
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _authService = AuthService(); // Fallback für Singleton-Pattern
      try {
        final accessToken = await _authService.getCurrentAccessToken();
        if (accessToken != null) {
          _token = accessToken;
        }
      } catch (e) {
        // Error loading token
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
            // Debug-Logging für Token-Refresh
            if (kDebugMode) {
              print('[API] Refreshing token, was expiring in ${exp - now} sec');
            }
            
            final refreshed = await _authService.refreshTokenIfNeeded();
            if (refreshed) {
              final newToken = await _authService.getCurrentAccessToken();
              if (newToken != null) {
                setToken(newToken);
                if (kDebugMode) {
                  print('[API] Token refreshed successfully');
                }
              }
            }
          }
        }
      } catch (e) {
        // Token validation error
        if (kDebugMode) {
          print('[API] Token validation error: $e');
        }
        await _authService.refreshTokenIfNeeded();
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
          if (kDebugMode) {
            print('[API] Proactive token refresh triggered, expires in $expiresIn sec');
          }
          
          final refreshed = await _authService.refreshTokenIfNeeded();
          if (refreshed) {
            final newToken = await _authService.getCurrentAccessToken();
            if (newToken != null) {
              setToken(newToken);
              
                          // Request mit neuem Token wiederholen
            return await _retryRequest(endpoint, response.request!.method);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('[API] Proactive token refresh failed: $e');
          }
        }
      }
    }
    
    // Reaktive Token-Erneuerung bei 401
    if (response.statusCode == 401 && !endpoint.startsWith('/auth/')) {
      try {
        if (kDebugMode) {
          print('[API] Reactive token refresh triggered due to 401');
        }
        
        final refreshed = await _authService.refreshTokenIfNeeded();
        if (refreshed) {
          final newToken = await _authService.getCurrentAccessToken();
          if (newToken != null) {
            setToken(newToken);
            
            // Request mit neuem Token wiederholen
            return await _retryRequest(endpoint, response.request!.method);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('[API] Token refresh failed: $e');
        }
        // Bei Token-Refresh-Fehlern automatisch ausloggen
        await _authService.logout();
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

  // Request-Kontext bereinigen (optional für Memory-Management)
  void _clearRequestContext(String endpoint) {
    _requestBodies.remove(endpoint);
  }

  Future<http.Response> get(String endpoint) async {
    await _ensureInitialized();
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    final response = await http.get(
      Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
      headers: _headers,
    );
    
    // Don't log 404 errors for player status checks
    if (response.statusCode == 404 && 
        (endpoint.contains('/players/me') || endpoint.contains('/pre-register/me'))) {
      return response;
    }
    
    return await _handleResponse(response, endpoint);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    // Erweiterte Request-Kontext-Verwaltung für parallele Requests
    _requestBodies[endpoint] = data;
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    final response = await http.post(
      Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    
    return await _handleResponse(response, endpoint);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    // Erweiterte Request-Kontext-Verwaltung für parallele Requests
    _requestBodies[endpoint] = data;
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    final response = await http.put(
      Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    
    return await _handleResponse(response, endpoint);
  }

  Future<http.Response> delete(String endpoint) async {
    await _ensureInitialized();
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('/auth/')) {
      await _ensureValidToken();
    }
    
    final response = await http.delete(
      Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
      headers: _headers,
    );
    
    return await _handleResponse(response, endpoint);
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
} 