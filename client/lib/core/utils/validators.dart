/// 🔐 Validators - Security-First Input Validation
/// 
/// Comprehensive validation for user inputs with security focus
library;

import '../../l10n/app_localizations.dart';

class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Username validation with security checks
  static String? username(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authUsernameRequired;
    }

    final trimmed = value.trim();

    // Length check
    if (trimmed.length < 3) {
      return l10n.authUsernameMinLength(3);
    }
    if (trimmed.length > 30) {
      return l10n.authUsernameMaxLength(30);
    }

    // Character validation (alphanumeric + underscore, hyphen)
    final validPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return l10n.authUsernameInvalidChars;
    }

    // Must start with letter or number
    final startsWithValidChar = RegExp(r'^[a-zA-Z0-9]');
    if (!startsWithValidChar.hasMatch(trimmed)) {
      return l10n.authUsernameInvalidStart;
    }

    // Security: Check for reserved words
    if (_isReservedUsername(trimmed.toLowerCase())) {
      return l10n.authUsernameReserved;
    }

    return null;
  }

  /// Email validation with security checks
  static String? email(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authEmailRequired;
    }

    final trimmed = value.trim().toLowerCase();

    // Length check
    if (trimmed.length > 254) {
      return l10n.authEmailTooLong;
    }

    // Basic email pattern
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    if (!emailPattern.hasMatch(trimmed)) {
      return l10n.authEmailInvalid;
    }

    // Security: Check for dangerous characters
    if (_containsDangerousChars(trimmed)) {
      return l10n.authEmailInvalidChars;
    }

    // Domain validation
    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return l10n.authEmailInvalid;
    }

    final domain = parts[1];
    if (domain.length > 253 || domain.isEmpty) {
      return l10n.authEmailInvalidDomain;
    }

    // Check for consecutive dots
    if (domain.contains('..')) {
      return l10n.authEmailInvalidDomain;
    }

    return null;
  }

  /// Password validation with comprehensive security checks
  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.authPasswordRequired;
    }

    final requirements = getPasswordRequirements(value, l10n);
    
    final unmetRequirement = requirements.firstWhere((req) => !req.isMet, orElse: () => const PasswordRequirement('', true));
    
    if (!unmetRequirement.isMet) {
      return unmetRequirement.description;
    }

    return null;
  }

  /// Confirm password validation
  static String? confirmPassword(String? value, String originalPassword, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.authConfirmPasswordRequired;
    }

    if (value != originalPassword) {
      return l10n.authPasswordsDoNotMatch;
    }

    return null;
  }

  /// Get password requirements with current status
  static List<PasswordRequirement> getPasswordRequirements(String password, AppLocalizations l10n) {
    return [
      PasswordRequirement(
        l10n.authPasswordMinLength(8),
        password.length >= 8,
      ),
      PasswordRequirement(
        l10n.authPasswordUppercase,
        RegExp(r'[A-Z]').hasMatch(password),
      ),
      PasswordRequirement(
        l10n.authPasswordLowercase,
        RegExp(r'[a-z]').hasMatch(password),
      ),
      PasswordRequirement(
        l10n.authPasswordNumber,
        RegExp(r'[0-9]').hasMatch(password),
      ),
      PasswordRequirement(
        l10n.authPasswordSpecialChar,
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      ),
      PasswordRequirement(
        l10n.authPasswordNotCommon,
        !_isCommonPassword(password.toLowerCase()),
      ),
      // Removed consecutive characters check as requested by user
    ];
  }

  /// Generic text validation for forms
  static String? requiredText(String? value, AppLocalizations l10n, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authFieldRequired(fieldName ?? l10n.authThisField);
    }
    return null;
  }

  /// Security: Check for reserved usernames
  static bool _isReservedUsername(String username) {
    const reserved = {
      'admin', 'administrator', 'root', 'system', 'api', 'www', 'ftp',
      'mail', 'email', 'user', 'test', 'guest', 'null', 'undefined',
      'weltenwind', 'support', 'help', 'info', 'contact', 'about',
      'login', 'register', 'signup', 'signin', 'logout', 'account',
      'profile', 'settings', 'config', 'dashboard', 'home', 'index',
      'security', 'privacy', 'terms', 'legal', 'abuse', 'moderator',
      'mod', 'staff', 'team', 'official', 'bot', 'service',
    };
    return reserved.contains(username);
  }

  /// Security: Check for dangerous characters
  static bool _containsDangerousChars(String input) {
    // Check for script injection attempts
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'onload=', caseSensitive: false),
      RegExp(r'onerror=', caseSensitive: false),
      RegExp(r'<%', caseSensitive: false),
      RegExp(r'%>', caseSensitive: false),
    ];

    return dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Security: Check against common passwords
  static bool _isCommonPassword(String password) {
    const commonPasswords = {
      'password', 'password123', '123456', '12345678', 'qwerty',
      'abc123', 'password1', 'admin', 'letmein', 'welcome',
      'monkey', '1234567890', 'dragon', 'princess', 'login',
      'sunshine', 'master', 'shadow', 'football', 'jesus',
      'michael', 'ninja', 'mustang', 'password12', 'love',
      'freedom', 'whatever', 'jordan', 'hunter', 'hello',
      'ranger', 'welcome123', 'admin123', 'root', 'user',
    };
    return commonPasswords.contains(password);
  }

  // Removed _hasSequentialChars function as consecutive character check was removed
}

/// Password requirement data class
class PasswordRequirement {
  final String description;
  final bool isMet;

  const PasswordRequirement(this.description, this.isMet);

  @override
  String toString() => 'PasswordRequirement($description: $isMet)';
}
