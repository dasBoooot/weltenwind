abstract class AppException implements Exception {
  const AppException(this.message, {this.context, this.statusCode});

  final String message;
  final Map<String, dynamic>? context;
  final int? statusCode;

  @override
  String toString() => 'AppException: $message';
}

/// Authentication related errors
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.context,
    super.statusCode,
    this.authErrorType,
  });

  final AuthErrorType? authErrorType;
}

enum AuthErrorType {
  invalidCredentials,
  accountLocked,
  tokenExpired,
  sessionTimeout,
  permissionDenied,
  mfaRequired,
}

/// Network related errors  
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.context,
    super.statusCode,
    this.networkErrorType,
  });

  final NetworkErrorType? networkErrorType;
}

enum NetworkErrorType {
  noConnection,
  timeout,
  serverError,
  badRequest,
  notFound,
  rateLimited,
}

/// World management errors
class WorldException extends AppException {
  const WorldException(
    super.message, {
    super.context,
    super.statusCode,
    this.worldErrorType,
  });

  final WorldErrorType? worldErrorType;
}

enum WorldErrorType {
  worldNotFound,
  worldFull,
  worldClosed,
  permissionDenied,
  alreadyJoined,
  joinTimeout,
}

/// Theme system errors
class ThemeException extends AppException {
  const ThemeException(
    super.message, {
    super.context,
    super.statusCode,
    this.themeErrorType,
  });

  final ThemeErrorType? themeErrorType;
}

enum ThemeErrorType {
  themeNotFound,
  invalidThemeData,
  themeLoadFailed,
  bundleNotFound,
  schemaValidationFailed,
}

/// Validation errors
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.context,
    this.field,
    this.validationType,
  });

  final String? field;
  final ValidationType? validationType;
}

enum ValidationType {
  required,
  email,
  password,
  length,
  format,
  range,
}