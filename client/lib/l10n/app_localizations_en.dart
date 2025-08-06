/// Generated file. Do not edit.
///
/// Weltenwind Game Localizations
/// Generated on: {date}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Weltenwind';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authLoginWelcome => 'Welcome to Weltenwind';

  @override
  String get authLoginSubtitle => 'Sign in to manage your worlds';

  @override
  String get authLoginButton => 'Sign In';

  @override
  String get authLoginFailedCredentials =>
      'Login failed. Please check your credentials.';

  @override
  String authLoginFailedGeneric(String error) {
    return 'Login failed: $error';
  }

  @override
  String get authDontHaveAccountRegister => 'Don\'t have an account? Register';

  @override
  String get authRegisterTitle => 'Register';

  @override
  String get authJoinWeltenwind => 'Join Weltenwind';

  @override
  String get authRegisterSubtitle =>
      'Create your account and start your adventure';

  @override
  String get authRegisterButton => 'Register';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Login';

  @override
  String get authValidationFixErrors => 'Please fix the errors above';

  @override
  String get authAcceptTermsRequired =>
      'Please accept Terms of Service and Privacy Policy';

  @override
  String get authRegisterSuccessMessage =>
      'Registration successful! Welcome to Weltenwind!';

  @override
  String get authRegisterFailedGeneric =>
      'Registration failed. Please try again.';

  @override
  String get authEmailExistsError =>
      'An account with this email already exists';

  @override
  String get authUsernameTakenError => 'This username is already taken';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authForgotPasswordTitle => 'Reset Your Password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email address and we\'ll send you instructions to reset your password.';

  @override
  String get authSendResetEmail => 'Send Reset Email';

  @override
  String get authEmailSentTitle => 'Email Sent!';

  @override
  String get authEmailSentMessage =>
      'We\'ve sent password reset instructions to your email address.';

  @override
  String get authNextStepsTitle => 'Next Steps:';

  @override
  String get authStepCheckEmail => '1. Check your email inbox';

  @override
  String get authStepClickLink => '2. Click the reset link in the email';

  @override
  String get authStepCreatePassword => '3. Create a new secure password';

  @override
  String get authStepLogin => '4. Login with your new password';

  @override
  String get authResendEmail => 'Resend Email';

  @override
  String get authPasswordResetSentMessage =>
      'Password reset instructions sent to your email';

  @override
  String get authTooManyResendAttempts =>
      'Too many resend attempts. Please wait before trying again.';

  @override
  String get authResendEmailSuccess => 'Password reset email resent';

  @override
  String get authResendEmailFailed =>
      'Failed to resend email. Please try again later.';

  @override
  String get authEmailNotFoundSecure =>
      'If this email exists in our system, you will receive reset instructions.';

  @override
  String get authUnableToProcessRequest =>
      'Unable to process request. Please try again later.';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authCreateNewPassword => 'Create New Password';

  @override
  String get authResetPasswordSubtitle =>
      'Enter a strong new password for your account.';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authInvalidResetLink => 'Invalid Reset Link';

  @override
  String get authRequestNewResetLink => 'Request New Reset Link';

  @override
  String get authResetLinkInvalidExpired =>
      'This reset link is invalid or has expired';

  @override
  String get authResetPasswordSuccess =>
      'Password reset successfully! You can now login with your new password.';

  @override
  String get authResetPasswordFailed =>
      'Failed to reset password. Please try again.';

  @override
  String get authResetLinkInvalidRequest =>
      'This reset link is invalid or has expired. Please request a new one.';

  @override
  String get authResetLinkExpiredRequest =>
      'This reset link has expired. Please request a new one.';

  @override
  String get authUnableToResetPassword =>
      'Unable to reset password. Please try again or request a new reset link.';

  @override
  String get authSecurityTips => 'Security Tips:';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'Enter your email address';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Create a strong password';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authUsernameHint => 'Choose a unique username';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String get authNetworkError =>
      'Network error. Please check your connection and try again.';

  @override
  String get authPasswordStrengthLabel => 'Password Strength: ';

  @override
  String get authPasswordStrengthVeryWeak => 'Very Weak';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthFair => 'Fair';

  @override
  String get authPasswordStrengthGood => 'Good';

  @override
  String get authPasswordStrengthStrong => 'Strong';

  @override
  String get authIAgreeToThe => 'I agree to the ';

  @override
  String get authTermsOfService => 'Terms of Service';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authPasswordRequirementsTitle => 'Password Requirements:';

  @override
  String get authListBullet => '• ';

  @override
  String get authTooManyResetAttempts =>
      'Too many password reset attempts. Please try again later.';

  @override
  String get authPasswordTooWeak =>
      'Password is too weak. Please choose a stronger password.';

  @override
  String get authTooManyRegistrationAttempts =>
      'Too many registration attempts. Please try again later.';

  @override
  String get authUsernameRequired => 'Username is required';

  @override
  String authUsernameMinLength(int minLength) {
    return 'Username must be at least $minLength characters long';
  }

  @override
  String authUsernameMaxLength(int maxLength) {
    return 'Username must be at most $maxLength characters long';
  }

  @override
  String get authUsernameInvalidChars => 'Username contains invalid characters';

  @override
  String get authUsernameInvalidStart => 'Username cannot start with a number';

  @override
  String get authUsernameReserved => 'This username is reserved';

  @override
  String get authEmailTooLong => 'Email address is too long';

  @override
  String get authEmailInvalid => 'Invalid email address';

  @override
  String get authEmailInvalidChars =>
      'Email address contains invalid characters';

  @override
  String get authEmailInvalidDomain => 'Invalid email domain';

  @override
  String get authConfirmPasswordRequired => 'Password confirmation is required';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String authPasswordMinLength(int minLength) {
    return 'Password must be at least $minLength characters long';
  }

  @override
  String get authPasswordUppercase => 'At least one uppercase letter required';

  @override
  String get authPasswordLowercase => 'At least one lowercase letter required';

  @override
  String get authPasswordNumber => 'At least one number required';

  @override
  String get authPasswordSpecialChar =>
      'At least one special character required';

  @override
  String get authPasswordNotCommon => 'Password cannot be too simple';

  @override
  String get authPasswordNoSequential => 'No sequential characters';

  @override
  String authFieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get authThisField => 'This field';

  @override
  String get worldStatusUpcoming => 'Upcoming';

  @override
  String get worldStatusOpen => 'Open';

  @override
  String get worldStatusRunning => 'Running';

  @override
  String get worldStatusClosed => 'Closed';

  @override
  String get worldStatusArchived => 'Archived';

  @override
  String get worldCategoryClassic => 'Classic';

  @override
  String get worldCategoryPvP => 'PvP';

  @override
  String get worldCategoryEvent => 'Event';

  @override
  String get worldCategoryExperimental => 'Experimental';
}
