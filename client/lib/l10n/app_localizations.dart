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

  /// Button to join a world
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get worldJoinButton;

  /// Button to leave a world
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get worldLeaveButton;

  /// Button to pre-register for a world
  ///
  /// In en, this message translates to:
  /// **'Pre-Register'**
  String get worldPreRegisterButton;

  /// Button text to cancel pre-registration
  ///
  /// In en, this message translates to:
  /// **'Cancel Pre-Registration'**
  String get worldCancelPreRegisterButton;

  /// World Status: Upcoming/Planned
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get worldStatusUpcoming;

  /// World Status: Open for joining
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get worldStatusOpen;

  /// World Status: Currently running
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get worldStatusRunning;

  /// World Status: Closed
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

  /// Main title on world list page
  ///
  /// In en, this message translates to:
  /// **'Choose your world'**
  String get worldListTitle;

  /// Subtitle on world list page
  ///
  /// In en, this message translates to:
  /// **'Select your world'**
  String get worldListSubtitle;

  /// Error message when loading worlds
  ///
  /// In en, this message translates to:
  /// **'Error loading worlds: {error}'**
  String worldListLoadingError(String error);

  /// Title for error when loading worlds
  ///
  /// In en, this message translates to:
  /// **'Error loading worlds'**
  String get worldListErrorTitle;

  /// Unknown error when loading worlds
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get worldListErrorUnknown;

  /// Title when no worlds are available
  ///
  /// In en, this message translates to:
  /// **'No worlds found'**
  String get worldListEmptyTitle;

  /// Message when no worlds were found
  ///
  /// In en, this message translates to:
  /// **'Try different filter settings.'**
  String get worldListEmptyMessage;

  /// Button to refresh world list
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get worldListRefreshButton;

  /// Button to create a new world
  ///
  /// In en, this message translates to:
  /// **'New World'**
  String get worldListCreateButton;

  /// Loading text for world list
  ///
  /// In en, this message translates to:
  /// **'Loading worlds...'**
  String get worldListLoadingText;

  /// Success message after joining a world
  ///
  /// In en, this message translates to:
  /// **'Successfully joined {worldName}!'**
  String worldJoinSuccessful(String worldName);

  /// Detailed success message after joining a world
  ///
  /// In en, this message translates to:
  /// **'Successfully joined world \"{worldName}\"!'**
  String worldJoinSuccessfulDetailed(String worldName);

  /// Message when user is already member of a world
  ///
  /// In en, this message translates to:
  /// **'You are already a member of world \"{worldName}\"!'**
  String worldAlreadyMember(String worldName);

  /// Success message after pre-registration
  ///
  /// In en, this message translates to:
  /// **'Successfully pre-registered for {worldName}!'**
  String worldPreRegisterSuccessful(String worldName);

  /// Message after cancelling pre-registration
  ///
  /// In en, this message translates to:
  /// **'Pre-registration for {worldName} cancelled.'**
  String worldPreRegisterCancelled(String worldName);

  /// Title of dialog for leaving a world
  ///
  /// In en, this message translates to:
  /// **'Leave world?'**
  String get worldLeaveDialogTitle;

  /// Message in dialog for leaving a world
  ///
  /// In en, this message translates to:
  /// **'Do you really want to leave world \"{worldName}\"?'**
  String worldLeaveDialogMessage(String worldName);

  /// Confirmation button for leaving a world
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get worldLeaveConfirm;

  /// Success message after leaving a world
  ///
  /// In en, this message translates to:
  /// **'You have left {worldName}.'**
  String worldLeaveSuccessful(String worldName);

  /// Success message after sending an invitation
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully!'**
  String get worldInviteSent;

  /// Button to play in a world
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get worldPlayButton;

  /// Error message when logging out
  ///
  /// In en, this message translates to:
  /// **'Error logging out'**
  String get worldLogoutError;

  /// Button for new registration
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get worldRegisterNow;

  /// Link for already registered users
  ///
  /// In en, this message translates to:
  /// **'Already registered? Sign in'**
  String get worldAlreadyRegistered;

  /// Button to sign out and register again
  ///
  /// In en, this message translates to:
  /// **'Sign out & register again'**
  String get worldLogoutAndRegister;

  /// Button back to homepage
  ///
  /// In en, this message translates to:
  /// **'Back to homepage'**
  String get worldBackToHome;

  /// Button back to world list
  ///
  /// In en, this message translates to:
  /// **'Back to worlds'**
  String get worldBackToWorlds;

  /// Button for login in world context
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get worldLoginButton;

  /// Button for registration in world context
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get worldRegisterButton;

  /// Button to accept an invitation
  ///
  /// In en, this message translates to:
  /// **'Accept invitation'**
  String get worldAcceptInviteButton;

  /// Button to sign out in world context
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get worldLogoutButton;

  /// Title when world was not found
  ///
  /// In en, this message translates to:
  /// **'World not found'**
  String get worldNotFoundTitle;

  /// Message when world was not found
  ///
  /// In en, this message translates to:
  /// **'The requested world does not exist or is not available.'**
  String get worldNotFoundMessage;

  /// Error when loading a world
  ///
  /// In en, this message translates to:
  /// **'Error loading'**
  String get worldLoadingError;

  /// Title for information about a world
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get worldInformationTitle;

  /// Start date of a world
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String worldStartDate(String date);

  /// End date of a world
  ///
  /// In en, this message translates to:
  /// **'End: {date}'**
  String worldEndDate(String date);

  /// Unknown date
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get worldDateUnknown;

  /// Title for 'About this world' section
  ///
  /// In en, this message translates to:
  /// **'About this world'**
  String get worldAboutTitle;

  /// Default description for a world
  ///
  /// In en, this message translates to:
  /// **'This is an exciting world full of adventures and challenges. Explore unknown territories, form alliances and become a legend!'**
  String get worldAboutDescription;

  /// Title for game rules section
  ///
  /// In en, this message translates to:
  /// **'Game rules'**
  String get worldRulesTitle;

  /// Title for world statistics
  ///
  /// In en, this message translates to:
  /// **'World statistics'**
  String get worldStatsTitle;

  /// Number of active players
  ///
  /// In en, this message translates to:
  /// **'{count} players active'**
  String worldPlayersActive(int count);

  /// Default description for world cards
  ///
  /// In en, this message translates to:
  /// **'An exciting world full of adventures'**
  String get worldDefaultDescription;

  /// Category label for Classic worlds
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get worldCategoryClassic;

  /// Category label for PvP worlds
  ///
  /// In en, this message translates to:
  /// **'Player vs Player'**
  String get worldCategoryPvP;

  /// Category label for Event worlds
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get worldCategoryEvent;

  /// Category label for Experimental worlds
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get worldCategoryExperimental;

  /// Label for status filter
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get worldFiltersStatus;

  /// Label for category filter
  ///
  /// In en, this message translates to:
  /// **'Category: '**
  String get worldFiltersCategory;

  /// Label for sort options
  ///
  /// In en, this message translates to:
  /// **'Sort by: '**
  String get worldFiltersSortBy;

  /// Sort by start date
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get worldFiltersSortStartDate;

  /// Sort by name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get worldFiltersSortName;

  /// Sort by status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get worldFiltersSortStatus;

  /// Sort by player count
  ///
  /// In en, this message translates to:
  /// **'Player Count'**
  String get worldFiltersSortPlayerCount;

  /// Label for active filters
  ///
  /// In en, this message translates to:
  /// **'Active filters: '**
  String get worldFiltersActiveFilters;

  /// Button to reset all filters
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get worldFiltersResetAll;

  /// World Status: Archived
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get worldStatusArchived;

  /// Button to invite players
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get worldInviteButton;

  /// Hint text for user info details
  ///
  /// In en, this message translates to:
  /// **'Click for details'**
  String get userInfoClickForDetails;

  /// Label for roles display
  ///
  /// In en, this message translates to:
  /// **'Roles:'**
  String get userInfoRoles;

  /// Message when joining the world is required
  ///
  /// In en, this message translates to:
  /// **'You must join the world first to see the dashboard'**
  String get navigationJoinRequiredMessage;

  /// Back button in navigation
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navigationBack;

  /// Navigation item for world overview
  ///
  /// In en, this message translates to:
  /// **'World Overview'**
  String get navigationWorldOverview;

  /// Navigation item for world details
  ///
  /// In en, this message translates to:
  /// **'World Details'**
  String get navigationWorldDetails;

  /// Navigation item for dashboard
  ///
  /// In en, this message translates to:
  /// **'To Dashboard'**
  String get navigationDashboard;

  /// Dashboard link when join is required
  ///
  /// In en, this message translates to:
  /// **'Dashboard (Join required)'**
  String get navigationDashboardRequiresJoin;

  /// Title of the navigation widget
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigationTitle;

  /// Subtitle to open the navigation menu
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get navigationOpenMenu;

  /// Tooltip text for locked dashboard feature
  ///
  /// In en, this message translates to:
  /// **'You must join the world to see the dashboard'**
  String get navigationTooltipJoinRequired;

  /// Text for pre-registration in invitation
  ///
  /// In en, this message translates to:
  /// **'to pre-register for'**
  String get worldJoinPreRegisterFor;

  /// Text for joining in invitation
  ///
  /// In en, this message translates to:
  /// **'to join'**
  String get worldJoinToJoin;

  /// Base text for invitation
  ///
  /// In en, this message translates to:
  /// **'You have been invited by {inviter} {action} the world \"{worldName}\".{validity}'**
  String worldJoinInvitedBy(
      String inviter, String worldName, String action, String validity);

  /// Validity date of the invitation
  ///
  /// In en, this message translates to:
  /// **'\n\n⏰ Valid until: {date}'**
  String worldJoinValidUntil(String date);

  /// Message when invitation already accepted
  ///
  /// In en, this message translates to:
  /// **'\n\n✅ This invitation has already been accepted.'**
  String get worldJoinAlreadyAccepted;

  /// Message when invitation expired
  ///
  /// In en, this message translates to:
  /// **'\n\n❌ This invitation expired on {date}.'**
  String worldJoinExpired(String date);

  /// Message for registration with specific email
  ///
  /// In en, this message translates to:
  /// **'You must register with the email address {email}.'**
  String worldJoinMustRegisterWith(String email);

  /// Message when account exists
  ///
  /// In en, this message translates to:
  /// **'Your account with {email} is already registered. Please log in.'**
  String worldJoinAccountExistsLogin(String email);

  /// Message when wrong email is logged in
  ///
  /// In en, this message translates to:
  /// **'This invitation is intended for {inviteEmail}, but you are logged in as {currentEmail}.'**
  String worldJoinWrongEmail(String inviteEmail, String currentEmail);

  /// Message when correct email is logged in
  ///
  /// In en, this message translates to:
  /// **'You are logged in with the correct email address and can now accept the invitation.'**
  String get worldJoinCorrectEmailCanAccept;

  /// Message for unknown status
  ///
  /// In en, this message translates to:
  /// **'Unknown status: {status}'**
  String worldJoinUnknownStatus(String status);

  /// Welcome message after automatic invite acceptance
  ///
  /// In en, this message translates to:
  /// **'Welcome to the world \"{worldName}\"! The invite was automatically accepted.'**
  String worldJoinWelcome(String worldName);

  /// Message when already a member
  ///
  /// In en, this message translates to:
  /// **'You are already a member of this world \"{worldName}\"!'**
  String worldJoinAlreadyMember(String worldName);

  /// Message that joining is possible
  ///
  /// In en, this message translates to:
  /// **'You can now join the world.'**
  String get worldJoinCanJoinNow;

  /// Success message after invite acceptance
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted! Welcome to the world \"{worldName}\"!'**
  String worldJoinInviteAcceptedSuccess(String worldName);

  /// Success message after world join
  ///
  /// In en, this message translates to:
  /// **'Successfully joined the world \"{worldName}\"!'**
  String worldJoinSuccess(String worldName);

  /// Error message on join failure
  ///
  /// In en, this message translates to:
  /// **'Join failed. Please try again.'**
  String get worldJoinFailed;

  /// Error message when invitation already accepted
  ///
  /// In en, this message translates to:
  /// **'This invitation has already been accepted.'**
  String get worldJoinInviteAlreadyAcceptedError;

  /// Error message when invitation not for email
  ///
  /// In en, this message translates to:
  /// **'This invitation is not intended for your email address.'**
  String get worldJoinInviteNotForYourEmail;

  /// Error message when invitation expired
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired.'**
  String get worldJoinInviteExpiredError;

  /// Error message on pre-registration failure
  ///
  /// In en, this message translates to:
  /// **'Error during pre-registration'**
  String get worldJoinPreRegistrationError;

  /// Error message when canceling pre-registration
  ///
  /// In en, this message translates to:
  /// **'Error canceling pre-registration'**
  String get worldJoinCancelPreRegistrationError;

  /// Title of leave dialog
  ///
  /// In en, this message translates to:
  /// **'Leave world?'**
  String get worldJoinLeaveDialogTitle;

  /// Content of leave dialog
  ///
  /// In en, this message translates to:
  /// **'Do you really want to leave the world \"{worldName}\"?'**
  String worldJoinLeaveDialogContent(String worldName);

  /// Text for unknown world
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get worldJoinUnknownWorld;

  /// Button text back to world list
  ///
  /// In en, this message translates to:
  /// **'Back to Worlds'**
  String get worldJoinBackToWorldsButton;

  /// Button text to cancel pre-registration
  ///
  /// In en, this message translates to:
  /// **'Cancel Pre-registration'**
  String get worldJoinCancelPreRegistrationButton;

  /// Button text while canceling pre-registration
  ///
  /// In en, this message translates to:
  /// **'Canceling...'**
  String get worldJoinCancelPreRegistrationInProgress;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String worldJoinGenericError(String error);

  /// Text for unknown errors
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get worldJoinUnknownError;

  /// Text when no information is available
  ///
  /// In en, this message translates to:
  /// **'No information available'**
  String get worldJoinNoInformationAvailable;

  /// Text for unknown world
  ///
  /// In en, this message translates to:
  /// **'Unknown World'**
  String get worldJoinUnknownWorldName;

  /// Text for unknown user
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get worldJoinUnknownUser;

  /// Button text for pre-registration
  ///
  /// In en, this message translates to:
  /// **'Pre-register'**
  String get worldJoinPreRegisterButton;

  /// Button text during pre-registration
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get worldJoinPreRegisterInProgress;

  /// Button text during leaving
  ///
  /// In en, this message translates to:
  /// **'Leaving...'**
  String get worldJoinLeaveInProgress;

  /// Button text for immediate join
  ///
  /// In en, this message translates to:
  /// **'Join Now'**
  String get worldJoinNowButton;

  /// Button text during join
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get worldJoinInProgress;

  /// Status text for closed world
  ///
  /// In en, this message translates to:
  /// **'This world is currently closed'**
  String get worldJoinWorldClosedStatus;

  /// Status text for archived world
  ///
  /// In en, this message translates to:
  /// **'This world is archived'**
  String get worldJoinWorldArchivedStatus;

  /// Error message when loading world data
  ///
  /// In en, this message translates to:
  /// **'Error loading world data: {error}'**
  String worldJoinErrorLoadingWorldData(String error);

  /// Error message when no world ID found
  ///
  /// In en, this message translates to:
  /// **'No world ID found'**
  String get worldJoinNoWorldIdFound;

  /// Error message when no invitation token found
  ///
  /// In en, this message translates to:
  /// **'No invitation token found'**
  String get worldJoinNoInviteTokenFound;

  /// Error message for invalid invitation link
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invitation link'**
  String get worldJoinInvalidOrExpiredInviteLink;

  /// Instruction to log out for invitation
  ///
  /// In en, this message translates to:
  /// **'Please log out and register with the correct email address.'**
  String get worldJoinLogoutForInvite;
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
