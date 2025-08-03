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

  /// Button for signing out
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
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
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// Loading text during login
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

  /// Coming soon text for Google login
  ///
  /// In en, this message translates to:
  /// **'Google login will be available soon'**
  String get authGoogleComingSoon;

  /// Coming soon text for GitHub login
  ///
  /// In en, this message translates to:
  /// **'GitHub login will be available soon'**
  String get authGithubComingSoon;

  /// Welcome title on registration page
  ///
  /// In en, this message translates to:
  /// **'Join Weltenwind'**
  String get authRegisterWelcome;

  /// Subtitle on registration page
  ///
  /// In en, this message translates to:
  /// **'Create your account and start your adventure'**
  String get authRegisterSubtitle;

  /// Alternative validation error for empty username field
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get authUsernameRequiredAlt;

  /// Validation error for invalid username characters
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, and underscores'**
  String get authUsernameInvalidChars;

  /// Validation error for empty email field
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEmailRequired;

  /// Text before login link on register page
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// Success message after registration
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome to Weltenwind!'**
  String get authRegisterSuccessWelcome;

  /// Title for forgot password page
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authForgotPasswordTitle;

  /// Description on forgot password page
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a link to reset your password.'**
  String get authForgotPasswordDescription;

  /// Label for email input on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authForgotPasswordEmailLabel;

  /// Validation error for empty email on forgot password
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get authForgotPasswordEmailRequired;

  /// Success message after sending password reset email
  ///
  /// In en, this message translates to:
  /// **'Email sent! Please check your inbox.'**
  String get authForgotPasswordSuccess;

  /// Button text for sending password reset link
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get authForgotPasswordSendButton;

  /// Button text to go back to login after successful sending
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
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
  /// **'Password Changed Successfully!'**
  String get authResetPasswordSuccessTitle;

  /// Title on password reset page
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get authResetPasswordTitle;

  /// Message after successful password reset
  ///
  /// In en, this message translates to:
  /// **'You will be automatically redirected to sign in...'**
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

  /// Helper text under password input field
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
  /// **'Password cannot contain spaces'**
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

  /// Title for password requirements section
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
  /// **'No spaces allowed'**
  String get authRequirementNoSpaces;

  /// Password requirement: passwords match validation
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get authRequirementPasswordsMatch;

  /// Button text for password reset
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPasswordButton;

  /// Link text to go back to login
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
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

  /// Title for worlds section
  ///
  /// In en, this message translates to:
  /// **'Game Worlds'**
  String get worldsTitle;

  /// Button text to leave a world
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get worldLeaveButton;

  /// Button text to pre-register for a world
  ///
  /// In en, this message translates to:
  /// **'Pre-Register'**
  String get worldPreRegisterButton;

  /// Button text to cancel pre-registration
  ///
  /// In en, this message translates to:
  /// **'Cancel Pre-Registration'**
  String get worldCancelPreRegisterButton;

  /// Status label for upcoming worlds
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get worldStatusUpcoming;

  /// Status label for open worlds
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get worldStatusOpen;

  /// Status label for running worlds
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get worldStatusRunning;

  /// Status label for closed worlds
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get worldStatusClosed;

  /// General error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneral;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// Unauthorized access error message
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access this resource.'**
  String get errorUnauthorized;

  /// Email validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorValidationEmail;

  /// Password validation error message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get errorValidationPassword;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// Or conjunction text
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Retry button text
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

  /// Tagline on the landing page
  ///
  /// In en, this message translates to:
  /// **'🎮 Play • 🌍 Explore • 🤝 Connect'**
  String get landingTagline;

  /// Main CTA button on landing page
  ///
  /// In en, this message translates to:
  /// **'Start Free Now'**
  String get landingStartButton;

  /// No credit card disclaimer
  ///
  /// In en, this message translates to:
  /// **'No credit card required'**
  String get landingNoCreditCard;

  /// Login prompt for existing users
  ///
  /// In en, this message translates to:
  /// **'Already a member? Sign in'**
  String get landingLoginPrompt;

  /// Registration button text
  ///
  /// In en, this message translates to:
  /// **'Register for Free →'**
  String get landingRegisterButton;

  /// Player count label in stats
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get landingStatsPlayers;

  /// Online count label in stats
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get landingStatsOnline;

  /// Discover more button text
  ///
  /// In en, this message translates to:
  /// **'Discover More'**
  String get landingDiscoverMore;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'What makes Weltenwind special?'**
  String get landingFeaturesTitle;

  /// Features section subtitle
  ///
  /// In en, this message translates to:
  /// **'Experience gaming on a new level'**
  String get landingFeaturesSubtitle;

  /// Worlds feature title
  ///
  /// In en, this message translates to:
  /// **'Infinite Worlds'**
  String get landingFeatureWorldsTitle;

  /// Worlds feature description
  ///
  /// In en, this message translates to:
  /// **'Explore hundreds of unique game worlds or create your own'**
  String get landingFeatureWorldsDesc;

  /// Community feature title
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get landingFeatureCommunityTitle;

  /// Community feature description
  ///
  /// In en, this message translates to:
  /// **'Connect with players from around the world'**
  String get landingFeatureCommunityDesc;

  /// Security feature title
  ///
  /// In en, this message translates to:
  /// **'Safe & Fair'**
  String get landingFeatureSecurityTitle;

  /// Security feature description
  ///
  /// In en, this message translates to:
  /// **'State-of-the-art security and fair rules for everyone'**
  String get landingFeatureSecurityDesc;

  /// Speed feature title
  ///
  /// In en, this message translates to:
  /// **'Lightning Fast'**
  String get landingFeatureSpeedTitle;

  /// Speed feature description
  ///
  /// In en, this message translates to:
  /// **'Optimized servers for minimal latency'**
  String get landingFeatureSpeedDesc;

  /// Mobile feature title
  ///
  /// In en, this message translates to:
  /// **'Play Everywhere'**
  String get landingFeatureMobileTitle;

  /// Mobile feature description
  ///
  /// In en, this message translates to:
  /// **'On PC, tablet or smartphone - always with you'**
  String get landingFeatureMobileDesc;

  /// Rewards feature title
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get landingFeatureRewardsTitle;

  /// Rewards feature description
  ///
  /// In en, this message translates to:
  /// **'Collect achievements and exclusive rewards'**
  String get landingFeatureRewardsDesc;

  /// Final CTA section title
  ///
  /// In en, this message translates to:
  /// **'Ready for your adventure?'**
  String get landingCtaTitle;

  /// Final CTA section subtitle
  ///
  /// In en, this message translates to:
  /// **'Join thousands of players and start today!'**
  String get landingCtaSubtitle;

  /// Copyright notice in footer
  ///
  /// In en, this message translates to:
  /// **'© 2024 Weltenwind. All rights reserved.'**
  String get footerCopyright;

  /// Privacy link in footer
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get footerPrivacy;

  /// Legal link in footer
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get footerLegal;

  /// Support link in footer
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get footerSupport;

  /// Main title on world list page
  ///
  /// In en, this message translates to:
  /// **'Choose Your World'**
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

  /// Title for world loading error
  ///
  /// In en, this message translates to:
  /// **'Error Loading Worlds'**
  String get worldListErrorTitle;

  /// Unknown error when loading worlds
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get worldListErrorUnknown;

  /// Title when no worlds available
  ///
  /// In en, this message translates to:
  /// **'No Worlds Found'**
  String get worldListEmptyTitle;

  /// Message when no worlds found
  ///
  /// In en, this message translates to:
  /// **'Try different filter settings.'**
  String get worldListEmptyMessage;

  /// Button to refresh world list
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get worldListRefreshButton;

  /// Button to create new world
  ///
  /// In en, this message translates to:
  /// **'New World'**
  String get worldListCreateButton;

  /// Loading text for world list
  ///
  /// In en, this message translates to:
  /// **'Loading worlds...'**
  String get worldListLoadingText;

  /// Message when user is already member of world
  ///
  /// In en, this message translates to:
  /// **'You are already a member of world \"{worldName}\"!'**
  String worldAlreadyMember(String worldName);

  /// Success message for pre-registration
  ///
  /// In en, this message translates to:
  /// **'Successfully pre-registered for {worldName}!'**
  String worldPreRegisterSuccessful(String worldName);

  /// Message when pre-registration is cancelled
  ///
  /// In en, this message translates to:
  /// **'Pre-registration for {worldName} cancelled.'**
  String worldPreRegisterCancelled(String worldName);

  /// Dialog title for leaving world
  ///
  /// In en, this message translates to:
  /// **'Leave World?'**
  String get worldLeaveDialogTitle;

  /// Dialog message for leaving world
  ///
  /// In en, this message translates to:
  /// **'Do you really want to leave world \"{worldName}\"?'**
  String worldLeaveDialogMessage(String worldName);

  /// Confirm button for leaving world
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get worldLeaveConfirm;

  /// Success message when leaving world
  ///
  /// In en, this message translates to:
  /// **'You have left {worldName}.'**
  String worldLeaveSuccessful(String worldName);

  /// Button to start playing in world
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get worldPlayButton;

  /// Error message when logout fails
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get worldLogoutError;

  /// Register now button text
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get worldRegisterNow;

  /// Sign in prompt for registered users
  ///
  /// In en, this message translates to:
  /// **'Already registered? Sign in'**
  String get worldAlreadyRegistered;

  /// Sign out and register again button
  ///
  /// In en, this message translates to:
  /// **'Sign out & register again'**
  String get worldLogoutAndRegister;

  /// Back to home button text
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get worldBackToHome;

  /// Back to worlds button text
  ///
  /// In en, this message translates to:
  /// **'Back to Worlds'**
  String get worldBackToWorlds;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get worldLoginButton;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get worldRegisterButton;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get worldLogoutButton;

  /// Title when world not found
  ///
  /// In en, this message translates to:
  /// **'World Not Found'**
  String get worldNotFoundTitle;

  /// Message when world not found
  ///
  /// In en, this message translates to:
  /// **'The requested world does not exist or is not available.'**
  String get worldNotFoundMessage;

  /// Generic world loading error
  ///
  /// In en, this message translates to:
  /// **'Error Loading'**
  String get worldLoadingError;

  /// World information section title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get worldInformationTitle;

  /// World start date label
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String worldStartDate(String date);

  /// World end date label
  ///
  /// In en, this message translates to:
  /// **'End: {date}'**
  String worldEndDate(String date);

  /// Unknown date placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get worldDateUnknown;

  /// World about section title
  ///
  /// In en, this message translates to:
  /// **'About This World'**
  String get worldAboutTitle;

  /// Default world description
  ///
  /// In en, this message translates to:
  /// **'This is an exciting world full of adventures and challenges. Explore unknown territories, form alliances and become a legend!'**
  String get worldAboutDescription;

  /// World rules section title
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get worldRulesTitle;

  /// World statistics section title
  ///
  /// In en, this message translates to:
  /// **'World Statistics'**
  String get worldStatsTitle;

  /// Active players count
  ///
  /// In en, this message translates to:
  /// **'{count} players active'**
  String worldPlayersActive(int count);

  /// Default world description
  ///
  /// In en, this message translates to:
  /// **'An exciting world full of adventures'**
  String get worldDefaultDescription;

  /// Classic world category
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get worldCategoryClassic;

  /// PvP world category
  ///
  /// In en, this message translates to:
  /// **'Player vs Player'**
  String get worldCategoryPvP;

  /// Event world category
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get worldCategoryEvent;

  /// Experimental world category
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get worldCategoryExperimental;

  /// Status filter label
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get worldFiltersStatus;

  /// Category filter label
  ///
  /// In en, this message translates to:
  /// **'Category:'**
  String get worldFiltersCategory;

  /// Sort by filter label
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get worldFiltersSortBy;

  /// Sort by start date option
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get worldFiltersSortStartDate;

  /// Sort by name option
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get worldFiltersSortName;

  /// Sort by status option
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get worldFiltersSortStatus;

  /// Sort by player count option
  ///
  /// In en, this message translates to:
  /// **'Player Count'**
  String get worldFiltersSortPlayerCount;

  /// Active filters label
  ///
  /// In en, this message translates to:
  /// **'Active filters:'**
  String get worldFiltersActiveFilters;

  /// Reset all filters button
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get worldFiltersResetAll;

  /// Archived world status
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get worldStatusArchived;

  /// Click for details tooltip
  ///
  /// In en, this message translates to:
  /// **'Click for details'**
  String get userInfoClickForDetails;

  /// User roles label
  ///
  /// In en, this message translates to:
  /// **'Roles:'**
  String get userInfoRoles;

  /// Message when user needs to join world for dashboard
  ///
  /// In en, this message translates to:
  /// **'You must join the world first to see the dashboard'**
  String get navigationJoinRequiredMessage;

  /// Back navigation button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navigationBack;

  /// World overview navigation item
  ///
  /// In en, this message translates to:
  /// **'World Overview'**
  String get navigationWorldOverview;

  /// World details navigation item
  ///
  /// In en, this message translates to:
  /// **'World Details'**
  String get navigationWorldDetails;

  /// Dashboard navigation item
  ///
  /// In en, this message translates to:
  /// **'To Dashboard'**
  String get navigationDashboard;

  /// Dashboard navigation when join required
  ///
  /// In en, this message translates to:
  /// **'Dashboard (Join required)'**
  String get navigationDashboardRequiresJoin;

  /// Navigation section title
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigationTitle;

  /// Open menu button text
  ///
  /// In en, this message translates to:
  /// **'Open Menu'**
  String get navigationOpenMenu;

  /// Tooltip when join required for dashboard
  ///
  /// In en, this message translates to:
  /// **'You must join the world to see the dashboard'**
  String get navigationTooltipJoinRequired;

  /// Success message when joining world
  ///
  /// In en, this message translates to:
  /// **'Successfully joined world \"{worldName}\"!'**
  String worldJoinSuccess(String worldName);

  /// Error message when joining world fails
  ///
  /// In en, this message translates to:
  /// **'Join failed. Please try again.'**
  String get worldJoinFailed;

  /// Error message for pre-registration failure
  ///
  /// In en, this message translates to:
  /// **'Error during pre-registration'**
  String get worldJoinPreRegistrationError;

  /// Error message when canceling pre-registration fails
  ///
  /// In en, this message translates to:
  /// **'Error canceling pre-registration'**
  String get worldJoinCancelPreRegistrationError;

  /// Leave world dialog title
  ///
  /// In en, this message translates to:
  /// **'Leave World?'**
  String get worldJoinLeaveDialogTitle;

  /// Leave world dialog content
  ///
  /// In en, this message translates to:
  /// **'Do you really want to leave world \"{worldName}\"?'**
  String worldJoinLeaveDialogContent(String worldName);

  /// Unknown world placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get worldJoinUnknownWorld;

  /// Back to worlds button text
  ///
  /// In en, this message translates to:
  /// **'Back to Worlds'**
  String get worldJoinBackToWorldsButton;

  /// Cancel pre-registration button text
  ///
  /// In en, this message translates to:
  /// **'Cancel Pre-registration'**
  String get worldJoinCancelPreRegistrationButton;

  /// Canceling pre-registration loading text
  ///
  /// In en, this message translates to:
  /// **'Canceling...'**
  String get worldJoinCancelPreRegistrationInProgress;

  /// Generic error message with details
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String worldJoinGenericError(String error);

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get worldJoinUnknownError;

  /// Unknown world name placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown World'**
  String get worldJoinUnknownWorldName;

  /// Pre-register button text
  ///
  /// In en, this message translates to:
  /// **'Pre-register'**
  String get worldJoinPreRegisterButton;

  /// Pre-registration loading text
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get worldJoinPreRegisterInProgress;

  /// Leaving world loading text
  ///
  /// In en, this message translates to:
  /// **'Leaving...'**
  String get worldJoinLeaveInProgress;

  /// Join now button text
  ///
  /// In en, this message translates to:
  /// **'Join Now'**
  String get worldJoinNowButton;

  /// Joining world loading text
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get worldJoinInProgress;

  /// Message when world is closed
  ///
  /// In en, this message translates to:
  /// **'This world is currently closed'**
  String get worldJoinWorldClosedStatus;

  /// Message when world is archived
  ///
  /// In en, this message translates to:
  /// **'This world is archived'**
  String get worldJoinWorldArchivedStatus;

  /// Error loading world data
  ///
  /// In en, this message translates to:
  /// **'Error loading world data: {error}'**
  String worldJoinErrorLoadingWorldData(String error);

  /// Invite page title
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get invitePageTitle;

  /// Invite welcome title
  ///
  /// In en, this message translates to:
  /// **'You\'ve Been Invited!'**
  String get inviteWelcomeTitle;

  /// Invite welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to world \"{worldName}\"'**
  String inviteWelcomeSubtitle(String worldName);

  /// Invited by user text
  ///
  /// In en, this message translates to:
  /// **'Invited by {username}'**
  String inviteFromUser(String username);

  /// Invitation details section title
  ///
  /// In en, this message translates to:
  /// **'Invitation Details'**
  String get inviteDetailsTitle;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get inviteDetailsEmail;

  /// World field label
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get inviteDetailsWorld;

  /// Status field label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inviteDetailsStatus;

  /// Expiration field label
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get inviteDetailsExpires;

  /// Hint to register for joining world
  ///
  /// In en, this message translates to:
  /// **'You need an account to join the world.'**
  String get inviteActionRegisterHint;

  /// Register and join button text
  ///
  /// In en, this message translates to:
  /// **'Register & Join'**
  String get inviteActionRegisterAndJoin;

  /// Sign in prompt for existing users
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get inviteActionAlreadyHaveAccount;

  /// Hint to login for joining world
  ///
  /// In en, this message translates to:
  /// **'You already have an account. Sign in to join the world.'**
  String get inviteActionLoginHint;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get inviteActionLogin;

  /// Accept invitation hint
  ///
  /// In en, this message translates to:
  /// **'Hello {username}! You can now accept or decline the invitation.'**
  String inviteActionAcceptHint(String username);

  /// Accept invitation button text
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get inviteActionAccept;

  /// Decline invitation button text
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get inviteActionDecline;

  /// Wrong email hint
  ///
  /// In en, this message translates to:
  /// **'You are signed in as {currentEmail}, but the invitation is for {inviteEmail}. You need to sign out and register with the correct email.'**
  String inviteActionWrongEmailHint(String currentEmail, String inviteEmail);

  /// Sign out and register button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out & Register'**
  String get inviteActionLogoutAndRegister;

  /// Unknown status message
  ///
  /// In en, this message translates to:
  /// **'Unknown status. Please try again later.'**
  String get inviteActionUnknownStatus;

  /// No invitation data error
  ///
  /// In en, this message translates to:
  /// **'No invitation data available.'**
  String get inviteErrorNoData;

  /// Invalid or expired invitation error
  ///
  /// In en, this message translates to:
  /// **'Invitation invalid or expired'**
  String get inviteErrorInvalidOrExpired;

  /// Error loading invitation data
  ///
  /// In en, this message translates to:
  /// **'Error loading invitation data: {error}'**
  String inviteErrorLoadingData(String error);

  /// Error accepting invitation
  ///
  /// In en, this message translates to:
  /// **'Error accepting invitation'**
  String get inviteErrorAcceptFailed;

  /// Error accepting invitation with details
  ///
  /// In en, this message translates to:
  /// **'Error accepting invitation: {error}'**
  String inviteErrorAcceptException(String error);

  /// Error declining invitation
  ///
  /// In en, this message translates to:
  /// **'Error declining invitation'**
  String get inviteErrorDeclineFailed;

  /// Error declining invitation with details
  ///
  /// In en, this message translates to:
  /// **'Error declining invitation: {error}'**
  String inviteErrorDeclineException(String error);

  /// Invitation declined success message
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get inviteDeclineSuccess;

  /// Discover more worlds header in marketing
  ///
  /// In en, this message translates to:
  /// **'Discover more exciting worlds'**
  String get marketingDiscoverMoreWorlds;

  /// Marketing call-to-action text
  ///
  /// In en, this message translates to:
  /// **'Discover hundreds of worlds, create your own, or join existing communities!'**
  String get marketingCallToAction;

  /// Community feature title in marketing
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get marketingFeatureCommunityTitle;

  /// Community feature description in marketing
  ///
  /// In en, this message translates to:
  /// **'Play with friends'**
  String get marketingFeatureCommunityDesc;

  /// Create feature title in marketing
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get marketingFeatureCreateTitle;

  /// Create feature description in marketing
  ///
  /// In en, this message translates to:
  /// **'Build your world'**
  String get marketingFeatureCreateDesc;

  /// Explore feature title in marketing
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get marketingFeatureExploreTitle;

  /// Explore feature description in marketing
  ///
  /// In en, this message translates to:
  /// **'New adventures'**
  String get marketingFeatureExploreDesc;

  /// Browse all worlds button text
  ///
  /// In en, this message translates to:
  /// **'Browse All Worlds'**
  String get marketingBrowseAllWorlds;

  /// Invitation creation date label
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get inviteDetailsCreated;

  /// Invite widget title
  ///
  /// In en, this message translates to:
  /// **'Send invitation for {worldName}'**
  String inviteWidgetTitle(String worldName);

  /// No description provided for @inviteWidgetEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get inviteWidgetEmailLabel;

  /// No description provided for @inviteWidgetEmailHint.
  ///
  /// In en, this message translates to:
  /// **'friend@example.com'**
  String get inviteWidgetEmailHint;

  /// No description provided for @inviteWidgetEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get inviteWidgetEmailRequired;

  /// No description provided for @inviteWidgetEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get inviteWidgetEmailInvalid;

  /// No description provided for @inviteWidgetSendEmailOption.
  ///
  /// In en, this message translates to:
  /// **'Send email automatically'**
  String get inviteWidgetSendEmailOption;

  /// No description provided for @inviteWidgetSendEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Disable to create invitation link only'**
  String get inviteWidgetSendEmailHint;

  /// No description provided for @inviteWidgetSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get inviteWidgetSendButton;

  /// No description provided for @inviteWidgetCreateLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Create Link'**
  String get inviteWidgetCreateLinkButton;

  /// No description provided for @inviteWidgetSuccessWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Invitation successfully sent to {email}!'**
  String inviteWidgetSuccessWithEmail(String email);

  /// No description provided for @inviteWidgetSuccessLinkOnly.
  ///
  /// In en, this message translates to:
  /// **'Invitation link successfully created!'**
  String get inviteWidgetSuccessLinkOnly;

  /// No description provided for @inviteWidgetCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get inviteWidgetCopyLink;

  /// No description provided for @inviteWidgetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Player'**
  String get inviteWidgetDialogTitle;

  /// No description provided for @inviteWidgetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inviteWidgetCancel;

  /// No description provided for @inviteWidgetLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation Link:'**
  String get inviteWidgetLinkTitle;

  /// No description provided for @worldInviteButton.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get worldInviteButton;

  /// No description provided for @authLoginSuccessButInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Login successful, but invitation could not be accepted.'**
  String get authLoginSuccessButInviteFailed;

  /// No description provided for @authRegisterSuccessButInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration successful, but invitation could not be accepted.'**
  String get authRegisterSuccessButInviteFailed;

  /// Generic navigation loading text
  ///
  /// In en, this message translates to:
  /// **'Loading page...'**
  String get navigationLoadingGeneric;

  /// Navigation loading error text
  ///
  /// In en, this message translates to:
  /// **'Error loading page'**
  String get navigationLoadingError;

  /// Navigation loading retry button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get navigationLoadingRetry;

  /// Loading text for world list page
  ///
  /// In en, this message translates to:
  /// **'Loading worlds...'**
  String get navigationLoadingWorldList;

  /// Loading text for dashboard page
  ///
  /// In en, this message translates to:
  /// **'Preparing dashboard...'**
  String get navigationLoadingDashboard;

  /// Loading text for world join page
  ///
  /// In en, this message translates to:
  /// **'Loading world...'**
  String get navigationLoadingWorldJoin;

  /// Error message when services are not available
  ///
  /// In en, this message translates to:
  /// **'Service unavailable. App will restart...'**
  String get navigationErrorServiceUnavailable;

  /// Error message for network issues
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your internet connection.'**
  String get navigationErrorNetwork;

  /// Error message for loading timeout
  ///
  /// In en, this message translates to:
  /// **'Loading takes too long. Please try again.'**
  String get navigationErrorTimeout;

  /// Error message for theme loading issues
  ///
  /// In en, this message translates to:
  /// **'Theme loading issues. Page will show with default theme.'**
  String get navigationErrorTheme;

  /// Generic error message for navigation
  ///
  /// In en, this message translates to:
  /// **'Unexpected error while loading page.'**
  String get navigationErrorGeneric;

  /// Loading message for world list
  ///
  /// In en, this message translates to:
  /// **'Loading worlds...'**
  String get worldListLoading;

  /// Empty state message for world list
  ///
  /// In en, this message translates to:
  /// **'No worlds available'**
  String get worldListEmpty;

  /// Empty state description for world list
  ///
  /// In en, this message translates to:
  /// **'No worlds have been created yet. Create your first world!'**
  String get worldListEmptyDescription;

  /// Error message for world list
  ///
  /// In en, this message translates to:
  /// **'Error loading worlds'**
  String get worldListError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No results message for world list
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get worldListNoResults;

  /// Clear filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;
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
