import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/logger.dart';
import 'api_service.dart';

class AuthorizationService {
  static final AuthorizationService _instance = AuthorizationService._internal();
  factory AuthorizationService() => _instance;
  AuthorizationService._internal();

  final ApiService _api = ApiService();

  final Map<String, bool> _cache = {};

  String _keyFromParams(Map<String, String> params) {
    final entries = params.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Future<bool> authorizePerm({
    required String perm,
    String scopeType = 'global',
    String objectId = 'global',
  }) async {
    final params = {
      'perm': perm,
      'scopeType': scopeType,
      'objectId': objectId,
    };
    final key = 'perm:${_keyFromParams(params)}';
    if (_cache.containsKey(key)) return _cache[key] == true;
    final uri = Uri.parse('/auth/authorize').replace(queryParameters: params);
    final http.Response res = await _api.get(uri.toString());
    if (res.statusCode == 200) {
      final allowed = (jsonDecode(res.body)['allowed'] == true);
      _cache[key] = allowed;
      return allowed;
    }
    AppLogger.app.w('AuthorizePerm failed: ${res.statusCode}');
    return false;
  }

  Future<bool> authorizeResourceAction({
    required String resource,
    required String action,
    String? worldId,
  }) async {
    final params = {
      'resource': resource,
      'action': action,
      if (worldId != null) 'worldId': worldId,
    };
    final key = 'ra:${_keyFromParams(params)}';
    if (_cache.containsKey(key)) return _cache[key] == true;
    final uri = Uri.parse('/auth/authorize').replace(queryParameters: params);
    final http.Response res = await _api.get(uri.toString());
    if (res.statusCode == 200) {
      final allowed = (jsonDecode(res.body)['allowed'] == true);
      _cache[key] = allowed;
      return allowed;
    }
    AppLogger.app.w('Authorize RA failed: ${res.statusCode}');
    return false;
  }
}


