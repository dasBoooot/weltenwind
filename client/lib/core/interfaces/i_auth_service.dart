/// 🔐 Authentication Service Interface
/// 
/// Defines the contract for authentication services
library;

import 'package:flutter/foundation.dart';
import '../models/user.dart';

abstract class IAuthService {
  /// Current authentication state
  ValueNotifier<bool> get isAuthenticated;
  
  /// Current user (if authenticated)
  User? get currentUser;
  
  /// Login with email and password
  /// Returns User if successful, throws AuthException if failed
  Future<User?> login(String email, String password);
  
  /// Register new user account
  /// Returns User if successful, throws AuthException if failed
  Future<User?> register(String email, String password, String name);
  
  /// Logout current user
  /// Clears all authentication state
  Future<void> logout();
  
  /// Refresh authentication tokens
  /// Returns true if successful, throws AuthException if failed
  Future<bool> refreshTokens();
  
  /// Validate current tokens
  /// Returns true if tokens are valid and not expired
  Future<bool> validateTokensOnStart();
  
  /// Load stored user data from secure storage
  /// Returns User if found, null if not found or invalid
  Future<User?> loadStoredUser();
  
  /// Request password reset
  /// Sends reset email, throws AuthException if failed
  Future<void> requestPasswordReset(String email);
  
  /// Reset password with token
  /// Returns true if successful, throws AuthException if failed
  Future<bool> resetPassword(String token, String newPassword);
  
  /// Change password for current user
  /// Returns true if successful, throws AuthException if failed
  Future<bool> changePassword(String currentPassword, String newPassword);
  
  /// Enable/disable multi-factor authentication
  /// Returns true if successful, throws AuthException if failed
  Future<bool> configureMFA(bool enable);
  
  /// Verify MFA code
  /// Returns true if code is valid, throws AuthException if failed
  Future<bool> verifyMFA(String code);
  
  /// Get user permissions/roles
  /// Returns list of permissions for current user
  Future<List<String>> getUserPermissions();
  
  /// Check if user has specific permission
  /// Returns true if user has permission
  Future<bool> hasPermission(String permission);
}