import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../config/logger.dart';
import 'app_exception.dart';
import 'error_reporter.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final ErrorReporter _reporter = ErrorReporter();
  
  /// Initialize error handling system
  static Future<void> initialize() async {
    final handler = ErrorHandler();
    
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      handler._handleFlutterError(details);
    };

    // Set up Dart error handling for async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      handler._handleDartError(error, stack);
      return true;
    };

    AppLogger.app.i('🛡️ Error Handler initialized');
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    AppLogger.error.e('🔥 Flutter Error: ${details.exception}');
    
    _reporter.reportError(
      error: details.exception,
      stackTrace: details.stack,
      context: {
        'type': 'flutter_error',
        'library': details.library,
        'context': details.context?.toString(),
      },
    );

    // In debug mode, also use Flutter's default error display
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Handle Dart runtime errors
  void _handleDartError(Object error, StackTrace stackTrace) {
    AppLogger.error.e('🔥 Dart Error: $error');
    
    _reporter.reportError(
      error: error,
      stackTrace: stackTrace,
      context: {
        'type': 'dart_error',
        'isolate': 'main',
      },
    );
  }

  /// Handle application exceptions with user feedback
  Future<void> handleException(
    AppException exception, {
    bool showToUser = true,
    bool reportError = true,
  }) async {
    AppLogger.error.e('🚨 App Exception: ${exception.message}');
    
    if (reportError) {
      await _reporter.reportAppException(exception);
    }

    if (showToUser) {
      _showUserFeedback(exception);
    }
  }

  /// Handle unexpected errors with context
  Future<void> handleUnexpectedError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
    bool showToUser = true,
  }) async {
    AppLogger.error.e('💥 Unexpected Error: $error');
    
    await _reporter.reportError(
      error: error,
      stackTrace: stackTrace,
      context: {
        'type': 'unexpected_error',
        ...?context,
      },
    );

    if (showToUser) {
      _showGenericErrorFeedback();
    }
  }

  /// Show user-friendly error feedback
  void _showUserFeedback(AppException exception) {
    // TODO: Implement user feedback system
    // This will show localized error messages to users
    // For now, we just log it
    AppLogger.app.w('📱 User feedback needed for: ${exception.message}');
  }

  /// Show generic error feedback for unexpected errors
  void _showGenericErrorFeedback() {
    // TODO: Implement generic error feedback
    // This will show a generic "something went wrong" message
    AppLogger.app.w('📱 Generic error feedback needed');
  }

  /// Get user-friendly error message for exceptions
  String getUserFriendlyMessage(AppException exception) {
    // TODO: Implement l10n integration
    // This will return localized error messages based on exception type
    switch (exception) {
      case AuthException _:
        return _getAuthErrorMessage(exception);
      case NetworkException _:
        return _getNetworkErrorMessage(exception);
      case WorldException _:
        return _getWorldErrorMessage(exception);
      case ThemeException _:
        return _getThemeErrorMessage(exception);
      case ValidationException _:
        return _getValidationErrorMessage(exception);
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  String _getAuthErrorMessage(AuthException exception) {
    switch (exception.authErrorType) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid email or password.';
      case AuthErrorType.accountLocked:
        return 'Your account has been locked. Please contact support.';
      case AuthErrorType.tokenExpired:
        return 'Your session has expired. Please log in again.';
      case AuthErrorType.sessionTimeout:
        return 'Session timeout. Please log in again.';
      case AuthErrorType.permissionDenied:
        return 'You do not have permission to perform this action.';
      case AuthErrorType.mfaRequired:
        return 'Multi-factor authentication is required.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _getNetworkErrorMessage(NetworkException exception) {
    switch (exception.networkErrorType) {
      case NetworkErrorType.noConnection:
        return 'No internet connection. Please check your network.';
      case NetworkErrorType.timeout:
        return 'Request timed out. Please try again.';
      case NetworkErrorType.serverError:
        return 'Server error. Please try again later.';
      case NetworkErrorType.badRequest:
        return 'Invalid request. Please check your input.';
      case NetworkErrorType.notFound:
        return 'Requested resource not found.';
      case NetworkErrorType.rateLimited:
        return 'Too many requests. Please wait and try again.';
      default:
        return 'Network error. Please check your connection.';
    }
  }

  String _getWorldErrorMessage(WorldException exception) {
    switch (exception.worldErrorType) {
      case WorldErrorType.worldNotFound:
        return 'World not found.';
      case WorldErrorType.worldFull:
        return 'World is full. Please try again later.';
      case WorldErrorType.worldClosed:
        return 'World is currently closed.';
      case WorldErrorType.permissionDenied:
        return 'You do not have permission to join this world.';
      case WorldErrorType.alreadyJoined:
        return 'You have already joined this world.';
      case WorldErrorType.joinTimeout:
        return 'Failed to join world. Please try again.';
      default:
        return 'World operation failed. Please try again.';
    }
  }

  String _getThemeErrorMessage(ThemeException exception) {
    switch (exception.themeErrorType) {
      case ThemeErrorType.themeNotFound:
        return 'Theme not found. Using default theme.';
      case ThemeErrorType.invalidThemeData:
        return 'Invalid theme data. Using fallback theme.';
      case ThemeErrorType.themeLoadFailed:
        return 'Failed to load theme. Using default theme.';
      case ThemeErrorType.bundleNotFound:
        return 'Theme bundle not found. Using default bundle.';
      case ThemeErrorType.schemaValidationFailed:
        return 'Theme validation failed. Using default theme.';
      default:
        return 'Theme error. Using default theme.';
    }
  }

  String _getValidationErrorMessage(ValidationException exception) {
    switch (exception.validationType) {
      case ValidationType.required:
        return '${exception.field ?? 'Field'} is required.';
      case ValidationType.email:
        return 'Please enter a valid email address.';
      case ValidationType.password:
        return 'Password does not meet requirements.';
      case ValidationType.length:
        return '${exception.field ?? 'Field'} length is invalid.';
      case ValidationType.format:
        return '${exception.field ?? 'Field'} format is invalid.';
      case ValidationType.range:
        return '${exception.field ?? 'Field'} is out of range.';
      default:
        return 'Validation failed. Please check your input.';
    }
  }
}