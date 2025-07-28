import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'token_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _refreshing = false; // Rate-Limiting für parallele Refreshes

  // Reaktiver Auth-Status für GoRouter
  final ValueNotifier<bool> isAuthenticated = ValueNotifier(false);

  User? get currentUser => _currentUser;

  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (kDebugMode) {
        print('[AuthService] Checking token: ${accessToken != null ? 'present' : 'null'}');
      }
      
      if (accessToken == null || accessToken.isEmpty) {
        if (kDebugMode) {
          print('[AuthService] No access token found');
        }
        isAuthenticated.value = false;
        return false;
      }

      _apiService.setToken(accessToken);
      final response = await _apiService.get('/auth/me');
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUser = User.fromJson(userData);
        isAuthenticated.value = true;
        if (kDebugMode) {
          print('[AuthService] User authenticated successfully');
        }
        return true;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('[AuthService] Token expired, attempting refresh');
        }
        // Token abgelaufen, versuche Refresh
        final refreshed = await refreshTokenIfNeeded();
        isAuthenticated.value = refreshed;
        return refreshed;
      }
      
      if (kDebugMode) {
        print('[AuthService] Authentication failed with status: ${response.statusCode}');
      }
      isAuthenticated.value = false;
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] isLoggedIn() failed: $e');
      }
      await logout();
      return false;
    }
  }

  // Vollständige Token-Validierung beim App-Start (ohne API-Calls)
  Future<bool> validateTokensOnStart() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      final refreshToken = await TokenStorage.getRefreshToken();
      
      if (accessToken == null || refreshToken == null) {
        return false;
      }

      // JWT-Token Format validieren
      if (!_isValidJWT(accessToken) || !_isValidJWT(refreshToken)) {
        return false;
      }

      // Token-Ablauf prüfen (nur lokale Validierung, keine API-Calls)
      final accessExp = _getTokenExpiration(accessToken);
      final refreshExp = _getTokenExpiration(refreshToken);
      
      if (accessExp == null || refreshExp == null) {
        return false;
      }

      final now = DateTime.now();
      
      // Refresh-Token ist abgelaufen
      if (refreshExp.isBefore(now)) {
        return false;
      }
      
      // Access-Token ist abgelaufen, aber Refresh-Token ist noch gültig
      if (accessExp.isBefore(now)) {
        // Token ist abgelaufen, aber wir versuchen nicht zu erneuern
        // Das wird beim ersten API-Call automatisch gemacht
        return true; // Erlaube App-Start, Token-Refresh erfolgt bei Bedarf
      }

      // Beide Token sind gültig
      return true;
    } catch (e) {
      return false;
    }
  }

  // JWT-Token Format validieren
  bool _isValidJWT(String token) {
    try {
      final parts = token.split('.');
      return parts.length == 3;
    } catch (e) {
      return false;
    }
  }

  // Token-Ablaufzeit extrahieren
  DateTime? _getTokenExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int;
      
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userData = data['user'];

        // Tokens speichern und API-Service aktualisieren
        await _saveTokensAndUpdateService(accessToken, refreshToken);
        await TokenStorage.saveUserData(jsonEncode(userData));

        // User-Objekt erstellen
        _currentUser = User.fromJson(userData);
        isAuthenticated.value = true; // Reaktiven Status setzen
        return _currentUser;
      } else if (response.statusCode == 401) {
        throw Exception('Benutzername oder Passwort falsch');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login fehlgeschlagen');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> register(String username, String email, String password) async {
    try {
      final response = await _apiService.post('/auth/register', {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        _currentUser = User.fromJson(userData);
        return _currentUser;
      } else if (response.statusCode == 409) {
        throw Exception('Benutzername oder E-Mail bereits vorhanden');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registrierung fehlgeschlagen');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Erweitertes Logout mit vollständigem Cleanup
  Future<void> logout() async {
    try {
      await TokenStorage.clearTokens();
      _currentUser = null;
      _apiService.clearToken();
      isAuthenticated.value = false; // Reaktiven Status setzen
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Error during logout: $e');
      }
    }
  }

  // Rate-Limited Token-Refresh mit parallelem Schutz
  Future<bool> refreshTokenIfNeeded() async {
    if (_refreshing) {
      // Warten bis aktueller Refresh abgeschlossen ist
      while (_refreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return true; // Annahme: Refresh war erfolgreich
    }

    _refreshing = true;
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await logout();
        return false;
      }

      // Refresh-Token Format validieren
      if (!_isValidJWT(refreshToken)) {
        await logout();
        return false;
      }

      // Refresh-Token Ablauf prüfen
      final refreshExp = _getTokenExpiration(refreshToken);
      if (refreshExp == null || refreshExp.isBefore(DateTime.now())) {
        await logout();
        return false;
      }

      _apiService.setToken(refreshToken);
      final response = await _apiService.post('/auth/refresh', {});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        
        // Refresh-Token-Rotation: Neuen Refresh-Token verwenden falls vorhanden
        final newRefreshToken = data['refreshToken'];
        final currentRefreshToken = await TokenStorage.getRefreshToken();
        final finalRefreshToken = newRefreshToken ?? currentRefreshToken;
        
        // Tokens speichern und API-Service aktualisieren
        await _saveTokensAndUpdateService(newAccessToken, finalRefreshToken);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    } finally {
      _refreshing = false;
    }
  }

  // Optionaler Force-Refresh für manuelle Token-Erneuerung
  Future<bool> forceRefreshToken() async {
    final tokenValid = await refreshTokenIfNeeded();
    if (!tokenValid) {
      await logout();
    }
    return tokenValid;
  }

  // Konsistente Token-Speicherung und API-Service-Update
  Future<void> _saveTokensAndUpdateService(String accessToken, String refreshToken) async {
    await TokenStorage.saveTokens(accessToken, refreshToken);
    _apiService.setToken(accessToken);
  }

  Future<User?> loadStoredUser() async {
    try {
      final userDataString = await TokenStorage.getUserData();
      final accessToken = await TokenStorage.getAccessToken();
      
      if (userDataString != null && accessToken != null) {
        final userData = jsonDecode(userDataString);
        _currentUser = User.fromJson(userData);
        _apiService.setToken(accessToken);
        // isAuthenticated.value wird vom Aufrufer gesetzt, nicht hier
        return _currentUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Error loading stored user: $e');
      }
    }
    return null;
  }

  Future<String?> getCurrentAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  // Token-Status überprüfen (für Debugging und Monitoring)
  Future<Map<String, dynamic>> getTokenStatus() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      final refreshToken = await TokenStorage.getRefreshToken();
      
      if (accessToken == null || refreshToken == null) {
        return {
          'hasAccessToken': false,
          'hasRefreshToken': false,
          'accessTokenValid': false,
          'refreshTokenValid': false,
          'accessTokenExpiresIn': null,
          'refreshTokenExpiresIn': null,
          'isRefreshing': _refreshing,
        };
      }

      final accessExp = _getTokenExpiration(accessToken);
      final refreshExp = _getTokenExpiration(refreshToken);
      final now = DateTime.now();

      return {
        'hasAccessToken': true,
        'hasRefreshToken': true,
        'accessTokenValid': accessExp?.isAfter(now) ?? false,
        'refreshTokenValid': refreshExp?.isAfter(now) ?? false,
        'accessTokenExpiresIn': accessExp?.difference(now).inSeconds,
        'refreshTokenExpiresIn': refreshExp?.difference(now).inSeconds,
        'accessTokenFormat': _isValidJWT(accessToken),
        'refreshTokenFormat': _isValidJWT(refreshToken),
        'isRefreshing': _refreshing,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'hasAccessToken': false,
        'hasRefreshToken': false,
        'accessTokenValid': false,
        'refreshTokenValid': false,
        'isRefreshing': _refreshing,
      };
    }
  }
} 