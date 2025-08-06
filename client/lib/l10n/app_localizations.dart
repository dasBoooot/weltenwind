/// Generated file. Do not edit.
///
/// Weltenwind Game Localizations
/// Generated on: {date}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Weltenwind'**
  String get appTitle;

  /// Title for the login page
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginTitle;

  /// Welcome message on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Weltenwind'**
  String get authLoginWelcome;

  /// Subtitle on login page
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your worlds'**
  String get authLoginSubtitle;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginButton;

  /// Error message for invalid credentials
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get authLoginFailedCredentials;

  /// Generic login error with details
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String authLoginFailedGeneric(String error);

  /// Link text to registration page
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get authDontHaveAccountRegister;

  /// Title for the registration page
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTitle;

  /// Welcome title on registration page
  ///
  /// In en, this message translates to:
  /// **'Join Weltenwind'**
  String get authJoinWeltenwind;

  /// Subtitle on registration page
  ///
  /// In en, this message translates to:
  /// **'Create your account and start your adventure'**
  String get authRegisterSubtitle;

  /// Registration button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterButton;

  /// Link text to login page
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get authAlreadyHaveAccount;

  /// General validation error message
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors above'**
  String get authValidationFixErrors;

  /// Terms acceptance validation error
  ///
  /// In en, this message translates to:
  /// **'Please accept Terms of Service and Privacy Policy'**
  String get authAcceptTermsRequired;

  /// Success message after registration
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome to Weltenwind!'**
  String get authRegisterSuccessMessage;

  /// Generic registration failure message
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get authRegisterFailedGeneric;

  /// Error when email already exists
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get authEmailExistsError;

  /// Error when username is taken
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get authUsernameTakenError;

  /// Link text for forgot password
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Title on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get authForgotPasswordTitle;

  /// Instructions on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you instructions to reset your password.'**
  String get authForgotPasswordSubtitle;

  /// Button to send reset email
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get authSendResetEmail;

  /// Title when reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Email Sent!'**
  String get authEmailSentTitle;

  /// Message when reset email is sent
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent password reset instructions to your email address.'**
  String get authEmailSentMessage;

  /// Title for next steps section
  ///
  /// In en, this message translates to:
  /// **'Next Steps:'**
  String get authNextStepsTitle;

  /// Step 1 in password reset process
  ///
  /// In en, this message translates to:
  /// **'1. Check your email inbox'**
  String get authStepCheckEmail;

  /// Step 2 in password reset process
  ///
  /// In en, this message translates to:
  /// **'2. Click the reset link in the email'**
  String get authStepClickLink;

  /// Step 3 in password reset process
  ///
  /// In en, this message translates to:
  /// **'3. Create a new secure password'**
  String get authStepCreatePassword;

  /// Step 4 in password reset process
  ///
  /// In en, this message translates to:
  /// **'4. Login with your new password'**
  String get authStepLogin;

  /// Button to resend reset email
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get authResendEmail;

  /// Success message when reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Password reset instructions sent to your email'**
  String get authPasswordResetSentMessage;

  /// Rate limit error for resend attempts
  ///
  /// In en, this message translates to:
  /// **'Too many resend attempts. Please wait before trying again.'**
  String get authTooManyResendAttempts;

  /// Success message when email is resent
  ///
  /// In en, this message translates to:
  /// **'Password reset email resent'**
  String get authResendEmailSuccess;

  /// Error message when resend fails
  ///
  /// In en, this message translates to:
  /// **'Failed to resend email. Please try again later.'**
  String get authResendEmailFailed;

  /// Secure message when email not found
  ///
  /// In en, this message translates to:
  /// **'If this email exists in our system, you will receive reset instructions.'**
  String get authEmailNotFoundSecure;

  /// Generic error for request processing
  ///
  /// In en, this message translates to:
  /// **'Unable to process request. Please try again later.'**
  String get authUnableToProcessRequest;

  /// Title for reset password page
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// Title for password reset form
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get authCreateNewPassword;

  /// Instructions on password reset page
  ///
  /// In en, this message translates to:
  /// **'Enter a strong new password for your account.'**
  String get authResetPasswordSubtitle;

  /// Label for new password field
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authNewPassword;

  /// Title when reset link is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid Reset Link'**
  String get authInvalidResetLink;

  /// Button text for requesting new reset link
  ///
  /// In en, this message translates to:
  /// **'Request New Reset Link'**
  String get authRequestNewResetLink;

  /// Error when reset token is invalid
  ///
  /// In en, this message translates to:
  /// **'This reset link is invalid or has expired'**
  String get authResetLinkInvalidExpired;

  /// Success message after password reset
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! You can now login with your new password.'**
  String get authResetPasswordSuccess;

  /// Error message when password reset fails
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password. Please try again.'**
  String get authResetPasswordFailed;

  /// Error when reset link is invalid with action suggestion
  ///
  /// In en, this message translates to:
  /// **'This reset link is invalid or has expired. Please request a new one.'**
  String get authResetLinkInvalidRequest;

  /// Error when reset link is expired with action suggestion
  ///
  /// In en, this message translates to:
  /// **'This reset link has expired. Please request a new one.'**
  String get authResetLinkExpiredRequest;

  /// Generic error for password reset with action suggestions
  ///
  /// In en, this message translates to:
  /// **'Unable to reset password. Please try again or request a new reset link.'**
  String get authUnableToResetPassword;

  /// Title for security tips section
  ///
  /// In en, this message translates to:
  /// **'Security Tips:'**
  String get authSecurityTips;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Hint text for email input
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get authEmailHint;

  /// Validation error for missing email
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Hint text for password input
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get authPasswordHint;

  /// Validation error for missing password
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// Label for username input field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// Hint text for username input
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username'**
  String get authUsernameHint;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// Hint text for confirm password input
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// Link text back to login
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get authNetworkError;

  /// Label for password strength indicator
  ///
  /// In en, this message translates to:
  /// **'Password Strength: '**
  String get authPasswordStrengthLabel;

  /// Password strength level
  ///
  /// In en, this message translates to:
  /// **'Very Weak'**
  String get authPasswordStrengthVeryWeak;

  /// Password strength level
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authPasswordStrengthWeak;

  /// Password strength level
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authPasswordStrengthFair;

  /// Password strength level
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get authPasswordStrengthGood;

  /// Password strength level
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authPasswordStrengthStrong;

  /// Terms agreement prefix text
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get authIAgreeToThe;

  /// Terms of Service link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authTermsOfService;

  /// Privacy Policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// Title for password requirements section
  ///
  /// In en, this message translates to:
  /// **'Password Requirements:'**
  String get authPasswordRequirementsTitle;

  /// Bullet point for lists
  ///
  /// In en, this message translates to:
  /// **'• '**
  String get authListBullet;

  /// Error for too many reset attempts
  ///
  /// In en, this message translates to:
  /// **'Too many password reset attempts. Please try again later.'**
  String get authTooManyResetAttempts;

  /// Error for a weak password
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please choose a stronger password.'**
  String get authPasswordTooWeak;

  /// Error for too many registration attempts
  ///
  /// In en, this message translates to:
  /// **'Too many registration attempts. Please try again later.'**
  String get authTooManyRegistrationAttempts;

  /// Validation error for missing username
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get authUsernameRequired;

  /// Validation error for too short username
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {minLength} characters long'**
  String authUsernameMinLength(int minLength);

  /// Validation error for too long username
  ///
  /// In en, this message translates to:
  /// **'Username must be at most {maxLength} characters long'**
  String authUsernameMaxLength(int maxLength);

  /// Validation error for invalid characters in username
  ///
  /// In en, this message translates to:
  /// **'Username contains invalid characters'**
  String get authUsernameInvalidChars;

  /// Validation error for username starting with number
  ///
  /// In en, this message translates to:
  /// **'Username cannot start with a number'**
  String get authUsernameInvalidStart;

  /// Validation error for reserved username
  ///
  /// In en, this message translates to:
  /// **'This username is reserved'**
  String get authUsernameReserved;

  /// Validation error for too long email
  ///
  /// In en, this message translates to:
  /// **'Email address is too long'**
  String get authEmailTooLong;

  /// Validation error for invalid email
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get authEmailInvalid;

  /// Validation error for invalid characters in email
  ///
  /// In en, this message translates to:
  /// **'Email address contains invalid characters'**
  String get authEmailInvalidChars;

  /// Validation error for invalid email domain
  ///
  /// In en, this message translates to:
  /// **'Invalid email domain'**
  String get authEmailInvalidDomain;

  /// Validation error for missing password confirmation
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get authConfirmPasswordRequired;

  /// Validation error for non-matching passwords
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// Validation error for too short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters long'**
  String authPasswordMinLength(int minLength);

  /// Password requirement for uppercase letters
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter required'**
  String get authPasswordUppercase;

  /// Password requirement for lowercase letters
  ///
  /// In en, this message translates to:
  /// **'At least one lowercase letter required'**
  String get authPasswordLowercase;

  /// Password requirement for numbers
  ///
  /// In en, this message translates to:
  /// **'At least one number required'**
  String get authPasswordNumber;

  /// Password requirement for special characters
  ///
  /// In en, this message translates to:
  /// **'At least one special character required'**
  String get authPasswordSpecialChar;

  /// Password requirement for complexity
  ///
  /// In en, this message translates to:
  /// **'Password cannot be too simple'**
  String get authPasswordNotCommon;

  /// Password requirement against sequential characters
  ///
  /// In en, this message translates to:
  /// **'No sequential characters'**
  String get authPasswordNoSequential;

  /// General validation error message for required fields
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String authFieldRequired(String fieldName);

  /// Generic field name for validation errors
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get authThisField;

  /// Status for upcoming worlds
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get worldStatusUpcoming;

  /// Status for open worlds
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get worldStatusOpen;

  /// Status for running worlds
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get worldStatusRunning;

  /// Status for closed worlds
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get worldStatusClosed;

  /// Status for archived worlds
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get worldStatusArchived;

  /// Category for classic worlds
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get worldCategoryClassic;

  /// Category for PvP worlds
  ///
  /// In en, this message translates to:
  /// **'PvP'**
  String get worldCategoryPvP;

  /// Category for event worlds
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get worldCategoryEvent;

  /// Category for experimental worlds
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get worldCategoryExperimental;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
