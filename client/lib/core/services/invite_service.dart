import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

// Invite-Model für bessere Typisierung
class Invite {
  final int id;
  final String email;
  final String status;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  Invite({
    required this.id,
    required this.email,
    required this.status,
    this.createdAt,
    this.expiresAt,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] as int,
      email: json['email'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

// Strukturierte Fehlercodes für bessere Wartbarkeit
enum InviteErrorCode {
  inviteAlreadySent,
  permissionDenied,
  worldNotFound,
  worldNotOpen,
  invalidEmail,
  networkError,
  unknown,
}

class InviteService {
  static final InviteService _instance = InviteService._internal();
  factory InviteService() => _instance;
  InviteService._internal();

  final ApiService _apiService = ApiService();

  // Strukturierte Fehlerbehandlung mit Error-Codes
  InviteErrorCode _parseErrorCode(Map<String, dynamic> errorData) {
    final errorCode = errorData['errorCode'] as String?;
    final message = errorData['message'] as String? ?? '';
    
    if (errorCode != null) {
      switch (errorCode) {
        case 'INVITE_ALREADY_SENT':
          return InviteErrorCode.inviteAlreadySent;
        case 'PERMISSION_DENIED':
          return InviteErrorCode.permissionDenied;
        case 'WORLD_NOT_FOUND':
          return InviteErrorCode.worldNotFound;
        case 'WORLD_NOT_OPEN':
          return InviteErrorCode.worldNotOpen;
        case 'INVALID_EMAIL':
          return InviteErrorCode.invalidEmail;
        default:
          return InviteErrorCode.unknown;
      }
    }
    
    // Fallback: Text-basierte Erkennung (für Backwards-Kompatibilität)
    if (message.contains('bereits eine Einladung')) {
      return InviteErrorCode.inviteAlreadySent;
    } else if (message.contains('Berechtigung')) {
      return InviteErrorCode.permissionDenied;
    } else if (message.contains('nicht gefunden')) {
      return InviteErrorCode.worldNotFound;
    } else if (message.contains('nicht geöffnet')) {
      return InviteErrorCode.worldNotOpen;
    } else if (message.contains('E-Mail')) {
      return InviteErrorCode.invalidEmail;
    }
    
    return InviteErrorCode.unknown;
  }

  // Benutzerfreundliche Fehlermeldungen basierend auf Error-Codes
  String _getErrorMessage(InviteErrorCode errorCode, String? originalMessage) {
    switch (errorCode) {
      case InviteErrorCode.inviteAlreadySent:
        return 'Diese E-Mail-Adresse hat bereits eine Einladung erhalten';
      case InviteErrorCode.permissionDenied:
        return 'Du hast keine Berechtigung, Einladungen zu versenden';
      case InviteErrorCode.worldNotFound:
        return 'Welt nicht gefunden';
      case InviteErrorCode.worldNotOpen:
        return 'Diese Welt ist nicht für Einladungen geöffnet';
      case InviteErrorCode.invalidEmail:
        return 'Ungültige E-Mail-Adresse';
      case InviteErrorCode.networkError:
        return 'Netzwerkfehler - bitte versuche es erneut';
      case InviteErrorCode.unknown:
        return originalMessage ?? 'Einladung fehlgeschlagen';
    }
  }

  Future<bool> createInvite(int worldId, String email) async {
    try {
      final data = <String, dynamic>{
        'email': email,
      };

      final response = await _apiService.post('/worlds/$worldId/invites', data);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['message']);
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } on http.ClientException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } catch (e) {
      // Fallback für unbekannte Fehler
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Einladung fehlgeschlagen: $e');
    }
  }

  Future<bool> createPublicInvite(int worldId, String email) async {
    try {
      final data = <String, dynamic>{
        'email': email,
      };

      final response = await _apiService.post('/worlds/$worldId/invites/public', data);
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        // Konsistente Fehlerbehandlung wie createInvite
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['message']);
        throw Exception(errorMessage);
      } else {
        throw Exception('Öffentliche Einladung fehlgeschlagen: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } on http.ClientException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Öffentliche Einladung fehlgeschlagen: $e');
    }
  }

  Future<List<Invite>> getInvites(int worldId) async {
    try {
      final response = await _apiService.get('/worlds/$worldId/invites');
      
      if (response.statusCode == 200) {
        final List<dynamic> invitesJson = jsonDecode(response.body);
        return invitesJson.map((json) => Invite.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Einladungen konnten nicht geladen werden: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } on http.ClientException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Einladungen konnten nicht geladen werden: $e');
    }
  }

  // Backwards-Kompatibilität: Alte Methode mit Map-Rückgabe
  Future<List<Map<String, dynamic>>> getInvitesAsMap(int worldId) async {
    final invites = await getInvites(worldId);
    return invites.map((invite) => invite.toJson()).toList();
  }

  Future<bool> deleteInvite(int worldId, int inviteId, {String? token}) async {
    try {
      if (token != null) {
        final data = <String, dynamic>{
          'token': token,
        };
        final response = await _apiService.deleteWithBody('/worlds/$worldId/invites/$inviteId', data);
        return response.statusCode == 200;
      } else {
        final response = await _apiService.delete('/worlds/$worldId/invites/$inviteId');
        return response.statusCode == 200;
      }
    } on FormatException catch (e) {
      throw Exception('Ungültige Server-Antwort: $e');
    } on SocketException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } on http.ClientException catch (e) {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Einladung konnte nicht gelöscht werden: $e');
    }
  }
} 