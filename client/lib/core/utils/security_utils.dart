/// 🛡️ Security Utils - Security-First Utilities
/// 
/// Comprehensive security utilities for input sanitization, rate limiting, and protection
library;

import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../config/logger.dart';

class SecurityUtils {
  // Rate limiting storage (in production, use secure backend storage)
  static final Map<String, List<DateTime>> _rateLimitStorage = {};
  static final Map<String, String> _sessionTokens = {};
  
  // Security configuration
  static const int maxAttemptsPerHour = 5;
  static const int maxAttemptsPerDay = 20;
  static const int tokenLength = 32;
  
  /// Generate cryptographically secure token
  Future<String> generateSecureToken() async {
    try {
      final random = Random.secure();
      final bytes = List<int>.generate(tokenLength, (i) => random.nextInt(256));
      final token = base64UrlEncode(bytes);
      
      // Store token for validation (in production: use secure backend)
      _sessionTokens[token] = DateTime.now().toIso8601String();
      
      AppLogger.app.d('🔐 Secure token generated');
      return token;
    } catch (e) {
      AppLogger.app.e('❌ Failed to generate secure token', error: e);
      throw SecurityException('Failed to generate secure session');
    }
  }

  /// Validate session token
  bool validateSessionToken(String token) {
    try {
      final timestamp = _sessionTokens[token];
      if (timestamp == null) return false;
      
      final tokenTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(tokenTime);
      
      // Token expires after 1 hour
      if (difference.inHours > 1) {
        _sessionTokens.remove(token);
        return false;
      }
      
      return true;
    } catch (e) {
      AppLogger.app.w('⚠️ Token validation failed', error: e);
      return false;
    }
  }

  /// Rate limiting check
  Future<bool> checkRateLimit(String action, {String? identifier}) async {
    try {
      final key = identifier ?? action;
      final now = DateTime.now();
      
      // Get existing attempts
      final attempts = _rateLimitStorage[key] ?? [];
      
      // Clean old attempts (older than 24 hours)
      attempts.removeWhere((attempt) => 
          now.difference(attempt).inHours > 24);
      
      // Check hourly limit
      final hourlyAttempts = attempts.where((attempt) =>
          now.difference(attempt).inHours < 1).length;
      
      if (hourlyAttempts >= maxAttemptsPerHour) {
        AppLogger.app.w('⚠️ Rate limit exceeded (hourly): $key');
        return false;
      }
      
      // Check daily limit
      if (attempts.length >= maxAttemptsPerDay) {
        AppLogger.app.w('⚠️ Rate limit exceeded (daily): $key');
        return false;
      }
      
      // Record this attempt
      attempts.add(now);
      _rateLimitStorage[key] = attempts;
      
      AppLogger.app.d('✅ Rate limit check passed: $key');
      return true;
    } catch (e) {
      AppLogger.app.e('❌ Rate limit check failed', error: e);
      return false; // Fail secure
    }
  }

  /// Sanitize user input to prevent injection attacks
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // Trim whitespace
    String sanitized = input.trim();
    
    // Remove dangerous characters: first <, >, and double quotes via regex
    sanitized = sanitized.replaceAll(RegExp("[<>\"]"), '');
    // Then remove single quotes without regex to avoid escaping issues
    sanitized = sanitized.replaceAll("'", '');
    
    // Remove script tags and javascript
    sanitized = sanitized.replaceAll(RegExp(r'<script.*?</script>', 
        caseSensitive: false, multiLine: true), '');
    sanitized = sanitized.replaceAll(RegExp(r'javascript:', 
        caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'vbscript:', 
        caseSensitive: false), '');
    
    // Remove event handlers
    sanitized = sanitized.replaceAll(RegExp(r'on\w+\s*=', 
        caseSensitive: false), '');
    
    // Remove server-side includes
    sanitized = sanitized.replaceAll(RegExp(r'<%.*?%>', 
        multiLine: true), '');
    
    return sanitized;
  }

  /// Validate input security (detect potential attacks)
  void validateInputSecurity(String input) {
    if (input.isEmpty) return;
    
    // Check for SQL injection patterns
    final sqlInjectionPatterns = [
      RegExp(r'(\bor\b|\band\b).*(=|<|>)', caseSensitive: false),
      RegExp(r'union\s+select', caseSensitive: false),
      RegExp(r'drop\s+table', caseSensitive: false),
      RegExp(r'insert\s+into', caseSensitive: false),
      RegExp(r'delete\s+from', caseSensitive: false),
      RegExp(r'update\s+set', caseSensitive: false),
      RegExp(r'--', caseSensitive: false),
      RegExp(r'/\*.*\*/', caseSensitive: false),
    ];
    
    for (final pattern in sqlInjectionPatterns) {
      if (pattern.hasMatch(input)) {
        AppLogger.app.w('⚠️ Potential SQL injection detected');
        throw SecurityException('Invalid input detected');
      }
    }
    
    // Check for XSS patterns
    final xssPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'onload=', caseSensitive: false),
      RegExp(r'onerror=', caseSensitive: false),
      RegExp(r'onclick=', caseSensitive: false),
      RegExp(r'onmouseover=', caseSensitive: false),
    ];
    
    for (final pattern in xssPatterns) {
      if (pattern.hasMatch(input)) {
        AppLogger.app.w('⚠️ Potential XSS attack detected');
        throw SecurityException('Invalid input detected');
      }
    }
    
    // Check for path traversal
    if (input.contains('../') || input.contains('..\\')) {
      AppLogger.app.w('⚠️ Potential path traversal detected');
      throw SecurityException('Invalid input detected');
    }
    
    AppLogger.app.d('✅ Input security validation passed');
  }

  /// Hash sensitive data (for logging, comparison, etc.)
  String hashSensitiveData(String data) {
    try {
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      AppLogger.app.e('❌ Failed to hash sensitive data', error: e);
      return 'hash_failed';
    }
  }

  /// Clear sensitive data from memory
  void clearSensitiveData() {
    try {
      // Clear rate limit data older than 24 hours
      final now = DateTime.now();
      _rateLimitStorage.removeWhere((key, attempts) {
        attempts.removeWhere((attempt) => 
            now.difference(attempt).inHours > 24);
        return attempts.isEmpty;
      });
      
      // Clear expired tokens
      _sessionTokens.removeWhere((token, timestamp) {
        final tokenTime = DateTime.parse(timestamp);
        return now.difference(tokenTime).inHours > 1;
      });
      
      AppLogger.app.d('🗑️ Sensitive data cleared');
    } catch (e) {
      AppLogger.app.e('❌ Failed to clear sensitive data', error: e);
    }
  }

  /// Generate secure random string
  String generateRandomString(int length, {bool includeSpecialChars = false}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    final characterSet = includeSpecialChars ? chars + specialChars : chars;
    final random = Random.secure();
    
    return String.fromCharCodes(Iterable.generate(
        length, (_) => characterSet.codeUnitAt(random.nextInt(characterSet.length))));
  }

  /// Validate password strength (returns score 0-100)
  int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int score = 0;
    
    // Length scoring
    if (password.length >= 8) score += 25;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;
    
    // Character variety scoring
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 15;
    
    // Complexity scoring
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars > password.length * 0.6) score += 10; // Good character diversity
    
    // Penalty for common patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score -= 10; // Repeated characters
    if (RegExp(r'123|abc|qwe', caseSensitive: false).hasMatch(password)) score -= 15; // Sequential patterns
    
    return score.clamp(0, 100);
  }

  /// Get security recommendations
  List<String> getSecurityRecommendations() {
    return [
      'Use a unique password for each account',
      'Enable two-factor authentication when available',
      'Regularly update your passwords',
      'Never share your login credentials',
      'Use a password manager for complex passwords',
      'Be cautious of phishing attempts',
      'Log out of shared or public computers',
      'Keep your browser and apps updated',
    ];
  }
}

/// Security exception for security-related errors
class SecurityException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  SecurityException(this.message, {this.code, this.details});

  @override
  String toString() => 'SecurityException: $message';
}