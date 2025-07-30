import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/world.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../../config/logger.dart';

// PreRegistrationStatus-Model für bessere Typisierung
class PreRegistrationStatus {
  final bool isPreRegistered;
  final DateTime? registeredAt;
  final String? status;
  final Map<String, dynamic>? config;

  PreRegistrationStatus({
    required this.isPreRegistered,
    this.registeredAt,
    this.status,
    this.config,
  });

  factory PreRegistrationStatus.fromJson(Map<String, dynamic> json) {
    return PreRegistrationStatus(
      isPreRegistered: json['isPreRegistered'] == true,
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : null,
      status: json['status'] as String?,
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPreRegistered': isPreRegistered,
      'registeredAt': registeredAt?.toIso8601String(),
      'status': status,
      'config': config,
    };
  }
}

// Strukturierte Fehlercodes für bessere Wartbarkeit
enum WorldErrorCode {
  worldNotFound,
  permissionDenied,
  worldArchived,
  alreadyRegistered,
  alreadyPreRegistered,
  preRegistrationClosed,
  notAuthenticated,
  networkError,
  unknown,
}

class WorldService {
  static final WorldService _instance = WorldService._internal();
  factory WorldService() => _instance;
  WorldService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Strukturierte Fehlerbehandlung mit Error-Codes
  WorldErrorCode _parseErrorCode(Map<String, dynamic> errorData) {
    final errorCode = errorData['errorCode'] as String?;
    final message = errorData['error'] as String? ?? errorData['message'] as String? ?? '';
    
    if (errorCode != null) {
      switch (errorCode) {
        case 'WORLD_NOT_FOUND':
          return WorldErrorCode.worldNotFound;
        case 'PERMISSION_DENIED':
          return WorldErrorCode.permissionDenied;
        case 'WORLD_ARCHIVED':
          return WorldErrorCode.worldArchived;
        case 'ALREADY_REGISTERED':
          return WorldErrorCode.alreadyRegistered;
        case 'ALREADY_PRE_REGISTERED':
          return WorldErrorCode.alreadyPreRegistered;
        case 'PRE_REGISTRATION_CLOSED':
          return WorldErrorCode.preRegistrationClosed;
        case 'NOT_AUTHENTICATED':
          return WorldErrorCode.notAuthenticated;
        default:
          return WorldErrorCode.unknown;
      }
    }
    
    // Fallback: Text-basierte Erkennung (für Backwards-Kompatibilität)
    if (message.contains('nicht gefunden')) {
      return WorldErrorCode.worldNotFound;
    } else if (message.contains('Berechtigung')) {
      return WorldErrorCode.permissionDenied;
    } else if (message.contains('archiviert')) {
      return WorldErrorCode.worldArchived;
    } else if (message.contains('bereits registriert')) {
      return WorldErrorCode.alreadyRegistered;
    } else if (message.contains('bereits vorregistriert')) {
      return WorldErrorCode.alreadyPreRegistered;
    } else if (message.contains('geschlossen')) {
      return WorldErrorCode.preRegistrationClosed;
    } else if (message.contains('angemeldet')) {
      return WorldErrorCode.notAuthenticated;
    }
    
    return WorldErrorCode.unknown;
  }

  // Benutzerfreundliche Fehlermeldungen basierend auf Error-Codes
  String _getErrorMessage(WorldErrorCode errorCode, String? originalMessage) {
    switch (errorCode) {
      case WorldErrorCode.worldNotFound:
        return 'Welt nicht gefunden';
      case WorldErrorCode.permissionDenied:
        return 'Du hast keine Berechtigung für diese Aktion';
      case WorldErrorCode.worldArchived:
        return 'Diese Welt ist nicht mehr verfügbar';
      case WorldErrorCode.alreadyRegistered:
        return 'Du bist bereits Mitglied dieser Welt';
      case WorldErrorCode.alreadyPreRegistered:
        return 'Du bist bereits für diese Welt vorregistriert';
      case WorldErrorCode.preRegistrationClosed:
        return 'Vorregistrierung für diese Welt ist nicht möglich';
      case WorldErrorCode.notAuthenticated:
        return 'Du musst angemeldet sein';
      case WorldErrorCode.networkError:
        return 'Netzwerkfehler - bitte versuche es erneut';
      case WorldErrorCode.unknown:
        return originalMessage ?? 'Aktion fehlgeschlagen';
    }
  }

  Future<List<World>> getWorlds() async {
    try {
      final response = await _apiService.get('/worlds');
      
      if (response.statusCode == 200) {
        final List<dynamic> worldsJson = jsonDecode(response.body);
        return worldsJson.map((json) => World.fromJson(json)).toList();
      } else {
        throw Exception('Welten konnten nicht geladen werden: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Welten konnten nicht geladen werden: $e');
    }
  }

  Future<World> getWorld(int worldId) async {
    try {
      final response = await _apiService.get('/worlds/$worldId');
      
      if (response.statusCode == 200) {
        final worldJson = jsonDecode(response.body);
        return World.fromJson(worldJson);
      } else {
        throw Exception('Welt konnte nicht geladen werden: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Welt konnte nicht geladen werden: $e');
    }
  }

  Future<bool> joinWorld(int worldId) async {
    try {
      final response = await _apiService.post('/worlds/$worldId/join', {});
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['error']);
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Beitritt fehlgeschlagen: $e');
    }
  }

  Future<bool> preRegisterWorld(int worldId, String email, {Map<String, dynamic>? config}) async {
    try {
      final data = <String, dynamic>{
        'email': email,
      };
      if (config != null) {
        data['config'] = config;
      }

      final response = await _apiService.post('/worlds/$worldId/pre-register', data);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['error']);
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Vorregistrierung fehlgeschlagen: $e');
    }
  }

  Future<bool> preRegisterWorldAuthenticated(int worldId, {Map<String, dynamic>? config}) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception(_getErrorMessage(WorldErrorCode.notAuthenticated, null));
      }

      final data = <String, dynamic>{
        'email': currentUser.email,
      };
      if (config != null) {
        data['config'] = config;
      }

      final response = await _apiService.post('/worlds/$worldId/pre-register', data);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['error']);
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Vorregistrierung fehlgeschlagen: $e');
    }
  }

  Future<bool> cancelPreRegistration(int worldId, String email) async {
    try {
      final response = await _apiService.delete('/worlds/$worldId/pre-register?email=$email');
      
      return response.statusCode == 200;
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Vorregistrierung konnte nicht storniert werden: $e');
    }
  }

  Future<bool> cancelPreRegistrationAuthenticated(int worldId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception(_getErrorMessage(WorldErrorCode.notAuthenticated, null));
      }

      return await cancelPreRegistration(worldId, currentUser.email);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Vorregistrierung konnte nicht storniert werden: $e');
    }
  }

  Future<bool> leaveWorld(int worldId) async {
    try {
      final response = await _apiService.delete('/worlds/$worldId/players/me');
      
      return response.statusCode == 200;
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(WorldErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Welt konnte nicht verlassen werden: $e');
    }
  }

  Future<bool> isPlayerInWorld(int worldId) async {
    try {
      final response = await _apiService.get('/worlds/$worldId/players/me');
      
      return response.statusCode == 200;
    } catch (e) {
      // 404 means user is not in this world, which is normal
      // Don't log this as an error
      return false;
    }
  }

  // Neue typsichere Methode mit PreRegistrationStatus-Model
  Future<PreRegistrationStatus> getPreRegistrationStatus(int worldId) async {
    try {
      final response = await _apiService.get('/worlds/$worldId/pre-register/me');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PreRegistrationStatus.fromJson(responseData);
      }
      return PreRegistrationStatus(isPreRegistered: false);
    } catch (e) {
      // 404 means user is not pre-registered, which is normal
      // Don't log this as an error
      return PreRegistrationStatus(isPreRegistered: false);
    }
  }

  // Backwards-Kompatibilität: Alte Methode mit bool-Rückgabe
  Future<bool> isPreRegisteredForWorld(int worldId) async {
    final status = await getPreRegistrationStatus(worldId);
    return status.isPreRegistered;
  }

  // Invite-Token Validierung
  Future<Map<String, dynamic>?> validateInviteToken(String token) async {
    try {
      // API-Call ohne Authentifizierung (öffentlicher Endpoint)
      final response = await _apiService.get('/invites/validate/$token');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.logError('Fehler bei Token-Validierung', e, context: {'token': '${token.substring(0, 8)}...'});
      // Fallback für bessere UX
      return null;
    }
  }

  // Invite akzeptieren und User der Welt hinzufügen
  Future<Map<String, dynamic>?> acceptInvite(String token) async {
    try {
      AppLogger.app.i('🎫 Invite wird akzeptiert', error: {'token': '${token.substring(0, 8)}...'});
      
      // API-Call mit Authentifizierung (da User eingeloggt sein muss)
      final response = await _apiService.post('/invites/accept/$token', {});
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': responseData['data']['world']?['id'],
            'worldName': responseData['data']['world']?['name']
          });
          return responseData['data'];
        }
      }
      
      // Fehlerbehandlung für spezifische HTTP-Status-Codes
      if (response.statusCode == 409) {
        AppLogger.app.w('⚠️ Invite bereits akzeptiert', error: {'token': '${token.substring(0, 8)}...'});
        throw Exception('Invite bereits akzeptiert');
      } else if (response.statusCode == 403) {
        AppLogger.app.w('⚠️ E-Mail-Mismatch bei Invite', error: {'token': '${token.substring(0, 8)}...'});
        throw Exception('Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt');
      } else if (response.statusCode == 410) {
        AppLogger.app.w('⚠️ Invite-Token abgelaufen', error: {'token': '${token.substring(0, 8)}...'});
        throw Exception('Invite-Token ist abgelaufen');
      }
      
      return null;
    } catch (e) {
      AppLogger.logError('Fehler bei Invite-Akzeptierung', e, context: {'token': '${token.substring(0, 8)}...'});
      rethrow;
    }
  }
} 