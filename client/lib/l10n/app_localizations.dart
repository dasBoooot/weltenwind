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

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Weltenwind'**
  String get appTitle;

  /// Title for the login page
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginTitle;

  /// Button text for login
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginButton;

  /// Title for the registration page
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTitle;

  /// Button text for registration
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterButton;

  /// Button to log out
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogoutButton;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Label for username input field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// Welcome title on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Weltenwind'**
  String get authLoginWelcome;

  /// Subtitle on login page
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your worlds'**
  String get authLoginSubtitle;

  /// Validation error for empty username field
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get authUsernameRequired;

  /// Validation error for username too short
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters long'**
  String get authUsernameMinLength;

  /// Validation error for empty password field
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authPasswordRequired;

  /// Validation error for password too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get authPasswordMinLength;

  /// Checkbox text for 'Stay signed in'
  ///
  /// In en, this message translates to:
  /// **'Stay signed in'**
  String get authRememberMe;

  /// Link text for forgot password
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Text before registration link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// Loading text during sign in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get authLoginLoading;

  /// Label for Google login button
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get authGoogleLabel;

  /// Label for GitHub login button
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get authGithubLabel;

  /// Message when Google login not yet available
  ///
  /// In en, this message translates to:
  /// **'Google login will be available soon'**
  String get authGoogleComingSoon;

  /// Message when GitHub login not yet available
  ///
  /// In en, this message translates to:
  /// **'GitHub login will be available soon'**
  String get authGithubComingSoon;

  /// Welcome title on registration page
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get authRegisterWelcome;

  /// Subtitle on registration page
  ///
  /// In en, this message translates to:
  /// **'Create your account for Weltenwind'**
  String get authRegisterSubtitle;

  /// Alternative validation message for username
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get authUsernameRequiredAlt;

  /// Validation error for invalid characters in username
  ///
  /// In en, this message translates to:
  /// **'Username may only contain letters, numbers and underscores'**
  String get authUsernameInvalidChars;

  /// Validation error for empty email field
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// Text before login link on registration page
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authHaveAccount;

  /// Success message after registration with invite token
  ///
  /// In en, this message translates to:
  /// **'Registration successful! You will be redirected to the invitation...'**
  String get authRegisterSuccessWithInvite;

  /// Success message after normal registration
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome to Weltenwind!'**
  String get authRegisterSuccessWelcome;

  /// Title on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authForgotPasswordTitle;

  /// Description on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get authForgotPasswordDescription;

  /// Label for email input field on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authForgotPasswordEmailLabel;

  /// Validation error for empty email field on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get authForgotPasswordEmailRequired;

  /// Success message after sending password reset link
  ///
  /// In en, this message translates to:
  /// **'Email sent! Please check your inbox.'**
  String get authForgotPasswordSuccess;

  /// Button text to send password reset link
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get authForgotPasswordSendButton;

  /// Button text to go back to login after successful sending
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authForgotPasswordBackToLogin;

  /// Button text to cancel password reset request
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authForgotPasswordCancel;

  /// Error message for invalid reset token
  ///
  /// In en, this message translates to:
  /// **'The reset link is invalid or expired. Please request a new link.'**
  String get authResetPasswordInvalidToken;

  /// Title after successful password reset
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed!'**
  String get authResetPasswordSuccessTitle;

  /// Title on password reset page
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get authResetPasswordTitle;

  /// Message after successful password reset
  ///
  /// In en, this message translates to:
  /// **'You will be automatically redirected to login...'**
  String get authResetPasswordSuccessMessage;

  /// Description on password reset page
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password.'**
  String get authResetPasswordDescription;

  /// Label for new password input field
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authNewPasswordLabel;

  /// Helper text below password input field
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authPasswordHelperText;

  /// Validation error for empty new password
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get authNewPasswordRequired;

  /// Validation error for spaces in password
  ///
  /// In en, this message translates to:
  /// **'Password must not contain spaces'**
  String get authPasswordNoSpaces;

  /// Label for password confirmation input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPasswordLabel;

  /// Validation error for empty password confirmation
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get authConfirmPasswordRequired;

  /// Validation error when passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// Title for password requirements list
  ///
  /// In en, this message translates to:
  /// **'Password Requirements:'**
  String get authPasswordRequirementsTitle;

  /// Password requirement: minimum length
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authRequirementMinLength;

  /// Password requirement: no spaces
  ///
  /// In en, this message translates to:
  /// **'No spaces'**
  String get authRequirementNoSpaces;

  /// Password requirement: passwords match
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get authRequirementPasswordsMatch;

  /// Button text to reset password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPasswordButton;

  /// Button text back to login
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// Navigation item for dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation item for world list
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get navWorldList;

  /// Navigation item for user profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Title for the worlds page
  ///
  /// In en, this message translates to:
  /// **'Game Worlds'**
  String get worldsTitle;

  /// Button text to join a world
  ///
  /// In en, this message translates to:
  /// **'Join World'**
  String get worldJoinButton;

  /// Button text to leave a world
  ///
  /// In en, this message translates to:
  /// **'Leave World'**
  String get worldLeaveButton;

  /// Button text to pre-register for upcoming world
  ///
  /// In en, this message translates to:
  /// **'Pre-Register'**
  String get worldPreRegisterButton;

  /// Button text to cancel pre-registration
  ///
  /// In en, this message translates to:
  /// **'Cancel Pre-Registration'**
  String get worldCancelPreRegisterButton;

  /// Status text for upcoming worlds
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get worldStatusUpcoming;

  /// Status text for open worlds
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get worldStatusOpen;

  /// Status text for running worlds
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get worldStatusRunning;

  /// Status text for closed worlds
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get worldStatusClosed;

  /// Title for invitation page
  ///
  /// In en, this message translates to:
  /// **'World Invitation'**
  String get inviteTitle;

  /// Button text to accept invitation
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get inviteAcceptButton;

  /// Prompt asking user to login for invitation
  ///
  /// In en, this message translates to:
  /// **'Please sign in to accept this invitation'**
  String get inviteLoginPrompt;

  /// Prompt asking user to register for invitation
  ///
  /// In en, this message translates to:
  /// **'Please register to accept this invitation'**
  String get inviteRegisterPrompt;

  /// Message when invitation is expired
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired'**
  String get inviteExpired;

  /// Message when invitation is already accepted
  ///
  /// In en, this message translates to:
  /// **'This invitation has already been accepted'**
  String get inviteAlreadyAccepted;

  /// Message when invitation token is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid invitation link'**
  String get inviteInvalidToken;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneral;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// Authorization error message
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access this resource.'**
  String get errorUnauthorized;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorValidationEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get errorValidationPassword;

  /// Generic OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// Separator word between options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Generic retry button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get buttonRetry;

  /// Generic loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// Subtitle on the landing page
  ///
  /// In en, this message translates to:
  /// **'Your portal to infinite worlds'**
  String get landingSubtitle;

  /// Short description of main features
  ///
  /// In en, this message translates to:
  /// **'🎮 Play • 🌍 Explore • 🤝 Connect'**
  String get landingTagline;

  /// Main CTA button on landing page
  ///
  /// In en, this message translates to:
  /// **'Start free now'**
  String get landingStartButton;

  /// Note below registration button
  ///
  /// In en, this message translates to:
  /// **'No credit card required'**
  String get landingNoCreditCard;

  /// Link to login for existing users
  ///
  /// In en, this message translates to:
  /// **'Already a member? Sign in'**
  String get landingLoginPrompt;

  /// Registration button in CTA area
  ///
  /// In en, this message translates to:
  /// **'Register for free →'**
  String get landingRegisterButton;

  /// Label for player statistics
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get landingStatsPlayers;

  /// Label for online status statistics
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get landingStatsOnline;

  /// Button text to discover more features
  ///
  /// In en, this message translates to:
  /// **'Discover more'**
  String get landingDiscoverMore;

  /// Title of features section
  ///
  /// In en, this message translates to:
  /// **'What makes Weltenwind special?'**
  String get landingFeaturesTitle;

  /// Subtitle of features section
  ///
  /// In en, this message translates to:
  /// **'Experience gaming on a new level'**
  String get landingFeaturesSubtitle;

  /// Title of worlds feature
  ///
  /// In en, this message translates to:
  /// **'Infinite Worlds'**
  String get landingFeatureWorldsTitle;

  /// Description of worlds feature
  ///
  /// In en, this message translates to:
  /// **'Explore hundreds of unique game worlds or create your own'**
  String get landingFeatureWorldsDesc;

  /// Title of community feature
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get landingFeatureCommunityTitle;

  /// Description of community feature
  ///
  /// In en, this message translates to:
  /// **'Connect with players from around the world'**
  String get landingFeatureCommunityDesc;

  /// Title of security feature
  ///
  /// In en, this message translates to:
  /// **'Safe & Fair'**
  String get landingFeatureSecurityTitle;

  /// Description of security feature
  ///
  /// In en, this message translates to:
  /// **'State-of-the-art security and fair rules for everyone'**
  String get landingFeatureSecurityDesc;

  /// Title of performance feature
  ///
  /// In en, this message translates to:
  /// **'Lightning Fast'**
  String get landingFeatureSpeedTitle;

  /// Description of performance feature
  ///
  /// In en, this message translates to:
  /// **'Optimized servers for minimal latency'**
  String get landingFeatureSpeedDesc;

  /// Title of mobile feature
  ///
  /// In en, this message translates to:
  /// **'Play Everywhere'**
  String get landingFeatureMobileTitle;

  /// Description of mobile feature
  ///
  /// In en, this message translates to:
  /// **'On PC, tablet or smartphone - always with you'**
  String get landingFeatureMobileDesc;

  /// Title of rewards feature
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get landingFeatureRewardsTitle;

  /// Description of rewards feature
  ///
  /// In en, this message translates to:
  /// **'Collect achievements and exclusive rewards'**
  String get landingFeatureRewardsDesc;

  /// Title of final call-to-action area
  ///
  /// In en, this message translates to:
  /// **'Ready for your adventure?'**
  String get landingCtaTitle;

  /// Subtitle of final call-to-action area
  ///
  /// In en, this message translates to:
  /// **'Join thousands of players and start today!'**
  String get landingCtaSubtitle;

  /// Copyright notice in footer
  ///
  /// In en, this message translates to:
  /// **'© 2024 Weltenwind. All rights reserved.'**
  String get footerCopyright;

  /// Link to privacy policy in footer
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get footerPrivacy;

  /// Link to legal notice in footer
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get footerLegal;

  /// Link to support in footer
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get footerSupport;
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
