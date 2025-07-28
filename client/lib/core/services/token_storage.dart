import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  static final _secureStorage = const FlutterSecureStorage();

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
    } else {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  static Future<String?> getAccessToken() async {
    if (kIsWeb) {
      return (await SharedPreferences.getInstance()).getString(_accessTokenKey);
    } else {
      return await _secureStorage.read(key: _accessTokenKey);
    }
  }

  static Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      return (await SharedPreferences.getInstance()).getString(_refreshTokenKey);
    } else {
      return await _secureStorage.read(key: _refreshTokenKey);
    }
  }

  static Future<void> saveUserData(String userData) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, userData);
    } else {
      await _secureStorage.write(key: _userDataKey, value: userData);
    }
  }

  static Future<String?> getUserData() async {
    if (kIsWeb) {
      return (await SharedPreferences.getInstance()).getString(_userDataKey);
    } else {
      return await _secureStorage.read(key: _userDataKey);
    }
  }

  static Future<void> clearTokens() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
    } else {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userDataKey);
    }
  }

  static Future<void> clearUserData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
    } else {
      await _secureStorage.delete(key: _userDataKey);
    }
  }

  // Schnelle Prüfung ob Tokens vorhanden sind (für UI/Debugging)
  static Future<bool> hasValidTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return access != null && refresh != null;
  }

  // Vollständiges Cleanup aller gespeicherten Daten
  static Future<void> clearAll() async {
    await clearTokens();
    await clearUserData();
  }
} 