# 🌍 Weltenwind i18n String Extraction Report

**Gesamt gefunden:** 145 Strings
**Neue Strings:** 145 (noch nicht in .arb)
**Bereits vorhanden:** 0

## 📊 Kategorien

- **auth**: 8 Strings
- **button**: 24 Strings
- **dialog**: 2 Strings
- **error**: 45 Strings
- **form**: 14 Strings
- **invite**: 1 Strings
- **navigation**: 11 Strings
- **ui**: 24 Strings
- **world**: 16 Strings

## 🎯 Konfidenz-Verteilung

- **Hoch (≥80%)**: 124 Strings ✅
- **Mittel (60-79%)**: 18 Strings ⚠️
- **Niedrig (<60%)**: 3 Strings ❓

## 📝 Quote-Types

- **'-Quotes**: 134 Strings
- **"-Quotes**: 11 Strings

## 🔍 Neue Strings (Priorität: Hoch → Niedrig)

### 🏷️ AUTH

**authPasswordIfResponsestatuscode** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\auth_service.dart:83:18`
- 📝 Original: `': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
```

**authIfResponsestatuscode200** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\auth_service.dart:200:84`
- 📝 Original: `'
      });

      if (response.statusCode == 200) {
        AppLogger.auth.i(AppLocalizations.of(context)!.errorPasswordErfolgreichZurückgesetzt);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        AppLogger.auth.w(AppLocalizations.of(context)!.errorPasswordresetApifehler, error: {
          '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
final response = await _apiService.post('/auth/reset-password', {
        'token': token,
        'password': newPassword, // Backend erwartet 'password', nicht 'newPassword'
      });

      if (response.statusCode == 200) {
```

**authReturnServiceAs** 🔥 (Confidence: 1.0)
- 📁 `lib\main.dart:6:125`
- 📝 Original: `');
    }
    return service as T;
  }

  static bool has<T>() {
    return _services.containsKey(T);
  }

  static void clear() {
    _services.clear();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere das Logging-System
  AppLogger.initialize();
  AppLogger.app.i(AppLocalizations.of(context)!.errorWeltenwindappWirdGestartet);

  // Flutter Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.logError(
      '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import 'package:flutter/foundation.dart';
import 'app.dart';
import 'config/logger.dart';
import '../l10n/app_localizations.dartAppLocalizations.of(context)!.uiServicecontainerFürDependencyService $T not registered');
    }
    return service as T;
  }
```

### 🏷️ BUTTON

**buttonChildText_issuccess** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\forgot_password_page.dart:143:70`
- 📝 Original: `'),
                              child: Text(
                                _isSuccess ? AppLocalizations.of(context)!.buttonZurückZumLogin : '`
- 🎯 Widget: Widget: TextButton
- 🔧 Context:
```dart
// Back to login link
                            TextButton(
                              onPressed: () => context.goNamed('login'),
                              child: Text(
                                _isSuccess ? AppLocalizations.of(context)!.buttonZurückZumLogin : 'Abbrechen',
                                style: const TextStyle(
```

**buttonLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\register_page.dart:263:53`
- 📝 Original: `',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFF2D2D2D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red[400]!),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Passwort',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                                suffixIcon: IconButton(
```

**buttonLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\reset_password_page.dart:162:63`
- 📝 Original: `',
                                    labelStyle: TextStyle(color: Colors.grey[400]),
                                    prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF2D2D2D),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[600]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[600]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red[400]!),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                    ),
                                    helperText: '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
}
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Neues Passwort',
                                    labelStyle: TextStyle(color: Colors.grey[400]),
                                    prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                                    suffixIcon: IconButton(
```

**buttonStyleElevatedbuttonstylefromBackgroundcolor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\landing\landing_page.dart:86:93`
- 📝 Original: `'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.rocket_launch,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Text(
                                                            AppLocalizations.of(context)!.uiJetztKostenlosStarten,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(context)!.uiKeineKreditkarteErforderlich,
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.8),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 16),
                                            
                                            // Secondary CTA - Login
                                            Container(
                                              width: double.infinity,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2D2D2D),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                                  width: 2,
                                                ),
                                              ),
                                              child: ElevatedButton.icon(
                                                onPressed: () => context.goNamed('`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
],
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () => context.goNamed('register'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
```

**buttonStyleElevatedbuttonstylefromBackgroundcolor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\landing\landing_page.dart:326:79`
- 📝 Original: `'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      AppLocalizations.of(context)!.uiKostenlosRegistrieren,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Footer
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[800] ?? Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.world2024WeltenwindAlle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () => context.goNamed('register'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 48),
```

**buttonStyleElevatedbuttonstylefromBackgroundcolor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:877:123`
- 📝 Original: `'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            }
            break;
            
          case WorldStatus.open:
          case WorldStatus.running:
            // Beitreten, Spielen oder Verlassen
            if (_isJoined) {
              // Spielen Button
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: _playWorld,
                    icon: const Icon(Icons.play_circle_filled),
                    label: const Text('`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _preRegisterWorld,
                    icon: const Icon(Icons.how_to_reg),
                    label: Text(_isPreRegistering ? AppLocalizations.of(context)!.buttonWirdRegistriert : 'Vorregistrieren'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
```

**buttonWeltVerlassen** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:925:68`
- 📝 Original: `'Welt verlassen'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _leaveWorld,
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(_isJoining ? 'Wird verlassen...' : 'Welt verlassen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
```

**buttonInfotextApplocalizationsofcontextbuttonbaseinfotextnnactiontextnnbittemeldedichShowlogoutbutton** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:137:215`
- 📝 Original: `';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['emailAppLocalizations.of(context)!.authUserMitFalscherDiese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
```

**buttonStyleElevatedbuttonstylefromBackgroundcolor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:389:183`
- 📝 Original: `'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('`
- 🎯 Widget: Widget: OutlinedButton
- 🔧 Context:
```dart
child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? AnmeldenAppLocalizations.of(context)!.buttonStyleOutlinedbuttonstylefromForegroundcolorAbmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
```

**buttonIconConstIconiconsarrow_back** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:405:70`
- 📝 Original: `'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text(AppLocalizations.of(context)!.buttonZurückZurStartseite),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('`
- 🎯 Widget: Widget: OutlinedButton
- 🔧 Context:
```dart
width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text(AppLocalizations.of(context)!.buttonZurückZurStartseite),
                            style: OutlinedButton.styleFrom(
```

**buttonStyleElevatedbuttonstylefromBackgroundcolor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:425:64`
- 📝 Original: `'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                        child: const Text(
                          AppLocalizations.of(context)!.buttonZurückZuDen,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
```

**buttonPendingRedirectSetzen** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:769:463`
- 📝 Original: `';
              
              // Pending Redirect setzen für Post-Auth-Redirect
              _authService.setPendingInviteRedirect(widget.inviteToken!);
              
              context.go(registerRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '`
- 🎯 Widget: Widget: Card
- 🔧 Context:
```dart
children: [
              Expanded(child: _buildStatCard('Status', _getWorldStatusText(), Icons.circle)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Typ', 'StandardAppLocalizations.of(context)!.worldIconspublicWidget_buildinfocardstring$label:AppLocalizations.of(context)!.uiStyleThemeofcontexttextthemebodysmallcopywithColor/go/auth/login?email=${Uri.encodeComponent(_inviteEmail!)}AppLocalizations.of(context)!.buttonPendingRedirectSetzenAnmeldenAppLocalizations.of(context)!.uiStyleTextstylefontsize16/go/auth/register?email=${Uri.encodeComponent(_inviteEmail!)}';
              
              // Pending Redirect setzen für Post-Auth-Redirect
              _authService.setPendingInviteRedirect(widget.inviteToken!);
```

**buttonStyleElevatedbuttonstylefromBackgroundcolor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:425:64`
- 📝 Original: `'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                        child: const Text(
                          AppLocalizations.of(context)!.buttonZurückZuDen,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
```

**buttonWeltVerlassen** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_list_page.dart:252:27`
- 📝 Original: `'Welt verlassen?'`
- 🎯 Widget: Widget: AlertDialog
- 🔧 Context:
```dart
final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
```

### 🏷️ DIALOG

**dialogStyleConstTextstyle** 🔥 (Confidence: 1.0)
- 📁 `lib\shared\widgets\invite_dialog.dart:3:132`
- 📝 Original: `',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.uiGebenSieDie,
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              autofocus: true, // Barrierefreiheit: Sofortiger Fokus
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Weiße Schrift
              decoration: InputDecoration(
                labelText: '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../l10n/app_localizations.dartAppLocalizations.of(context)!.dialogClassInvitedialogExtendsEinladung für ${widget.worldName}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
```

### 🏷️ ERROR

**errorThrowExceptionerrormessageElse** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\invite_service.dart:84:144`
- 📝 Original: `']);
        throw Exception(errorMessage);
      } else {
        throw Exception(AppLocalizations.of(context)!.errorÖffentlicheEinladungFehlgeschlagen);
      }
    } on FormatException catch (e) {
      throw Exception(AppLocalizations.of(context)!.errorUngültigeServerantwortE);
    } on SocketException {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
'email': email,
      };

      final response = await _apiService.post('/worlds/$worldId/invites/publicAppLocalizations.of(context)!.authDataIfResponsestatuscodemessage']);
        throw Exception(errorMessage);
      } else {
        throw Exception(AppLocalizations.of(context)!.errorÖffentlicheEinladungFehlgeschlagen);
```

**errorCaseInviteerrorcodepermissiondeniedReturn** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\invite_service.dart:44:170`
- 📝 Original: `';
      case InviteErrorCode.permissionDenied:
        return AppLocalizations.of(context)!.errorDuHastKeine;
      case InviteErrorCode.worldNotFound:
        return AppLocalizations.of(context)!.errorWeltNichtGefunden;
      case InviteErrorCode.worldNotOpen:
        return AppLocalizations.of(context)!.errorDieseWeltIst;
      case InviteErrorCode.invalidEmail:
        return AppLocalizations.of(context)!.errorUngültigeEmailadresse;
      case InviteErrorCode.networkError:
        return AppLocalizations.of(context)!.errorNetzwerkfehlerBitteVersuche;
      case InviteErrorCode.unknown:
        return originalMessage ?? AppLocalizations.of(context)!.errorEinladungFehlgeschlagen;
    }
  }

  Future<bool> createInvite(int worldId, String email) async {
    try {
      final data = <String, dynamic>{
        '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return InviteErrorCode.worldNotFound;
    } else if (message.contains(AppLocalizations.of(context)!.errorNichtGeöffnet)) {
      return InviteErrorCode.worldNotOpen;
    } else if (message.contains('E-MailAppLocalizations.of(context)!.errorReturnInviteerrorcodeinvalidemailReturnDiese E-Mail-Adresse hat bereits eine Einladung erhalten';
      case InviteErrorCode.permissionDenied:
        return AppLocalizations.of(context)!.errorDuHastKeine;
      case InviteErrorCode.worldNotFound:
```

**errorCaseInviteerrorcodepermissiondeniedReturn** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\invite_service.dart:44:170`
- 📝 Original: `';
      case InviteErrorCode.permissionDenied:
        return AppLocalizations.of(context)!.errorDuHastKeine;
      case InviteErrorCode.worldNotFound:
        return AppLocalizations.of(context)!.errorWeltNichtGefunden;
      case InviteErrorCode.worldNotOpen:
        return AppLocalizations.of(context)!.errorDieseWeltIst;
      case InviteErrorCode.invalidEmail:
        return AppLocalizations.of(context)!.errorUngültigeEmailadresse;
      case InviteErrorCode.networkError:
        return AppLocalizations.of(context)!.errorNetzwerkfehlerBitteVersuche;
      case InviteErrorCode.unknown:
        return originalMessage ?? AppLocalizations.of(context)!.errorEinladungFehlgeschlagen;
    }
  }

  Future<bool> createInvite(int worldId, String email) async {
    try {
      final data = <String, dynamic>{
        '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return InviteErrorCode.worldNotFound;
    } else if (message.contains(AppLocalizations.of(context)!.errorNichtGeöffnet)) {
      return InviteErrorCode.worldNotOpen;
    } else if (message.contains('E-MailAppLocalizations.of(context)!.errorReturnInviteerrorcodeinvalidemailReturnDiese E-Mail-Adresse hat bereits eine Einladung erhalten';
      case InviteErrorCode.permissionDenied:
        return AppLocalizations.of(context)!.errorDuHastKeine;
      case InviteErrorCode.worldNotFound:
```

**errorThrowExceptionerrormessageElse** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\invite_service.dart:84:144`
- 📝 Original: `']);
        throw Exception(errorMessage);
      } else {
        throw Exception(AppLocalizations.of(context)!.errorÖffentlicheEinladungFehlgeschlagen);
      }
    } on FormatException catch (e) {
      throw Exception(AppLocalizations.of(context)!.errorUngültigeServerantwortE);
    } on SocketException {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
'email': email,
      };

      final response = await _apiService.post('/worlds/$worldId/invites/publicAppLocalizations.of(context)!.authDataIfResponsestatuscodemessage']);
        throw Exception(errorMessage);
      } else {
        throw Exception(AppLocalizations.of(context)!.errorÖffentlicheEinladungFehlgeschlagen);
```

**errorOnFormatexceptionCatch** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\invite_service.dart:105:193`
- 📝 Original: `');
      }
    } on FormatException catch (e) {
      throw Exception(AppLocalizations.of(context)!.errorUngültigeServerantwortE);
    } on SocketException {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } on http.ClientException {
      throw Exception(_getErrorMessage(InviteErrorCode.networkError, null));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(AppLocalizations.of(context)!.errorEinladungenKonntenNicht);
    }
  }

  // Backwards-Kompatibilität: Alte Methode mit Map-Rückgabe
  Future<List<Map<String, dynamic>>> getInvitesAsMap(int worldId) async {
    final invites = await getInvites(worldId);
    return invites.map((invite) => invite.toJson()).toList();
  }

  Future<bool> deleteInvite(int worldId, int inviteId, {String? token}) async {
    try {
      if (token != null) {
        final data = <String, dynamic>{
          '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
Future<List<Invite>> getInvites(int worldId) async {
    try {
      final response = await _apiService.get('/worlds/$worldId/invitesAppLocalizations.of(context)!.worldIfResponsestatuscode200Einladungen konnten nicht geladen werden: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception(AppLocalizations.of(context)!.errorUngültigeServerantwortE);
```

**errorWeltenKonntenNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:46:23`
- 📝 Original: `'Welten konnten nicht geladen werden: $e'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (e is Exception) {
        rethrow;
      }
      throw Exception('Welten konnten nicht geladen werden: $e');
    }
  }
```

**errorWeltKonnteNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:70:23`
- 📝 Original: `'Welt konnte nicht geladen werden: $e'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (e is Exception) {
        rethrow;
      }
      throw Exception('Welt konnte nicht geladen werden: $e');
    }
  }
```

**errorWeltKonnteNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:186:23`
- 📝 Original: `'Welt konnte nicht verlassen werden: $e'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (e is Exception) {
        rethrow;
      }
      throw Exception('Welt konnte nicht verlassen werden: $e');
    }
  }
```

**errorThrowExceptionapplocalizationsofcontexterrordieseeinladungistElse** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:244:103`
- 📝 Original: `'});
        throw Exception(AppLocalizations.of(context)!.errorDieseEinladungIst);
      } else if (response.statusCode == 410) {
        AppLogger.app.w(AppLocalizations.of(context)!.errorInvitetokenAbgelaufen, error: {'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return responseData['dataAppLocalizations.of(context)!.worldFehlerbehandlungFürSpezifische⚠️ Invite bereits akzeptiert', error: {'token': token.substring(0, 8) + '...'});
        throw Exception('Invite bereits akzeptiert');
      } else if (response.statusCode == 403) {
        AppLogger.app.w('⚠️ E-Mail-Mismatch bei Invite', error: {'token': token.substring(0, 8) + '...'});
        throw Exception(AppLocalizations.of(context)!.errorDieseEinladungIst);
      } else if (response.statusCode == 410) {
        AppLogger.app.w(AppLocalizations.of(context)!.errorInvitetokenAbgelaufen, error: {'token': token.substring(0, 8) + '...'});
```

**errorWeltenKonntenNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:46:23`
- 📝 Original: `'Welten konnten nicht geladen werden: $e'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (e is Exception) {
        rethrow;
      }
      throw Exception('Welten konnten nicht geladen werden: $e');
    }
  }
```

**errorWeltKonnteNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:70:23`
- 📝 Original: `'Welt konnte nicht geladen werden: $e'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (e is Exception) {
        rethrow;
      }
      throw Exception('Welt konnte nicht geladen werden: $e');
    }
  }
```

**errorTrueElseStrukturierte** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:80:37`
- 📝 Original: `'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
```

**errorTrueElseStrukturierte** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:108:37`
- 📝 Original: `'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
```

**errorTrueElseStrukturierte** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:136:37`
- 📝 Original: `'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
        final errorCode = _parseErrorCode(errorData);
        final errorMessage = _getErrorMessage(errorCode, errorData['`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        // Strukturierte Fehlerbehandlung
        final errorData = jsonDecode(response.body);
```

**errorTLogThis** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:206:13`
- 📝 Original: `'t log this as an error
      return PreRegistrationStatus(isPreRegistered: false);
    }
  }

  // Backwards-Kompatibilität: Alte Methode mit bool-Rückgabe
  Future<bool> isPreRegisteredForWorld(int worldId) async {
    final status = await getPreRegistrationStatus(worldId);
    return status.isPreRegistered;
  }

  // Invite-Token Validierung
  Future<Map<String, dynamic>?> validateInviteToken(String token) async {
    try {
      // API-Call ohne Authentifizierung (öffentlicher Endpoint)
      final response = await _apiService.get('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return PreRegistrationStatus(isPreRegistered: false);
    } catch (e) {
      // 404 means user is not pre-registered, which is normal
      // Don't log this as an error
      return PreRegistrationStatus(isPreRegistered: false);
    }
  }
```

**errorNullApploggerappiapplocalizationsofcontexterrorinviteerfolgreichakzeptiertError** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:236:66`
- 📝 Original: `'] != null) {
          AppLogger.app.i(AppLocalizations.of(context)!.errorInviteErfolgreichAkzeptiert, error: {
            '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          AppLogger.app.i(AppLocalizations.of(context)!.errorInviteErfolgreichAkzeptiert, error: {
            'worldId': responseData['data']['world']?['id'],
            'worldName': responseData['data']['world']?['name']
```

**errorThrowExceptionapplocalizationsofcontexterrordieseeinladungistElse** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:244:103`
- 📝 Original: `'});
        throw Exception(AppLocalizations.of(context)!.errorDieseEinladungIst);
      } else if (response.statusCode == 410) {
        AppLogger.app.w(AppLocalizations.of(context)!.errorInvitetokenAbgelaufen, error: {'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return responseData['dataAppLocalizations.of(context)!.worldFehlerbehandlungFürSpezifische⚠️ Invite bereits akzeptiert', error: {'token': token.substring(0, 8) + '...'});
        throw Exception('Invite bereits akzeptiert');
      } else if (response.statusCode == 403) {
        AppLogger.app.w('⚠️ E-Mail-Mismatch bei Invite', error: {'token': token.substring(0, 8) + '...'});
        throw Exception(AppLocalizations.of(context)!.errorDieseEinladungIst);
      } else if (response.statusCode == 410) {
        AppLogger.app.w(AppLocalizations.of(context)!.errorInvitetokenAbgelaufen, error: {'token': token.substring(0, 8) + '...'});
```

**errorThrowExceptionapplocalizationsofcontexterrorinvitetokenistabgelaufenReturn** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:247:128`
- 📝 Original: `'});
        throw Exception(AppLocalizations.of(context)!.errorInvitetokenIstAbgelaufen);
      }
      
      return null;
    } catch (e) {
      AppLogger.logError(AppLocalizations.of(context)!.errorFehlerBeiInviteakzeptierung, e, context: {'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
AppLogger.app.w('⚠️ E-Mail-Mismatch bei Invite', error: {'token': token.substring(0, 8) + '...'});
        throw Exception(AppLocalizations.of(context)!.errorDieseEinladungIst);
      } else if (response.statusCode == 410) {
        AppLogger.app.w(AppLocalizations.of(context)!.errorInvitetokenAbgelaufen, error: {'token': token.substring(0, 8) + '...'});
        throw Exception(AppLocalizations.of(context)!.errorInvitetokenIstAbgelaufen);
      }
```

**errorFinallyIfMounted** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\login_page.dart:42:63`
- 📝 Original: `');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 12,
                        color: const Color(0xFF1A1A1A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A1A1A),
                                Color(0xFF2A2A2A),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo/Title with Animation
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.8, end: 1.0),
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.primaryColor.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.public,
                                        size: 40,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppLocalizations.of(context)!.worldWillkommenBeiWeltenwind,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.worldMeldeDichAn,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[300],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Username field with better validation
                                  TextFormField(
                                    controller: _usernameController,
                                    style: const TextStyle(color: Colors.white),
                                    autofillHints: const [AutofillHints.username],
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) {
                                      if (!_hasInteractedWithUsername) {
                                        setState(() {
                                          _hasInteractedWithUsername = true;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
} catch (e) {
      AppLogger.logError('Login fehlgeschlagen', e);
      setState(() {
        _loginError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
```

**errorApploggerappiapplocalizationsofcontexterrorregistrationqueryparametergeladenError** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\register_page.dart:20:59`
- 📝 Original: `'];
    
    AppLogger.app.i(AppLocalizations.of(context)!.errorRegistrationQueryparameterGeladen, error: {
      '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
// Query-Parameter aus der URL lesen
    final routeData = GoRouterState.of(context);
    _inviteToken = routeData.uri.queryParameters['invite_token'];
    _prefilledEmail = routeData.uri.queryParameters['email'];
    
    AppLogger.app.i(AppLocalizations.of(context)!.errorRegistrationQueryparameterGeladen, error: {
      'hasInviteToken': _inviteToken != null,
```

**error_invitetokenNull** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\register_page.dart:23:22`
- 📝 Original: `': _inviteToken != null,
      '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
_prefilledEmail = routeData.uri.queryParameters['email'];
    
    AppLogger.app.i(AppLocalizations.of(context)!.errorRegistrationQueryparameterGeladen, error: {
      'hasInviteToken': _inviteToken != null,
      'hasPrefilledEmail': _prefilledEmail != null,
      'inviteToken': _inviteToken?.substring(0, 8),
      'emailAppLocalizations.of(context)!.auth_prefilledemailEmailVorbefüllen📧 E-Mail vorbefüllt', error: {'emailAppLocalizations.of(context)!.error_prefilledemailOverrideVoid✅ Registrierung erfolgreich', error: {
```

**errorScaffoldmessengerofcontextshowsnackbarConstSnackbar** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\register_page.dart:56:137`
- 📝 Original: `'});
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppLocalizations.of(context)!.inviteRegistrierungErfolgreichDu),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Kurze Verzögerung für bessere UX
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              context.goNamed(AppLocalizations.of(context)!.worldWorldjoinbytoken, pathParameters: {'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
}
          } else if (_inviteToken != null) {
            // Fallback: Wenn Invite-Token in Query-Parametern, direkt zur Invite-Seite
            AppLogger.app.i(AppLocalizations.of(context)!.errorInvitetokenInQuery, error: {'token': _inviteToken!.substring(0, 8) + '...'});
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
```

**errorScaffoldmessengerofcontextshowsnackbarConstSnackbar** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\register_page.dart:56:137`
- 📝 Original: `'});
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppLocalizations.of(context)!.inviteRegistrierungErfolgreichDu),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Kurze Verzögerung für bessere UX
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              context.goNamed(AppLocalizations.of(context)!.worldWorldjoinbytoken, pathParameters: {'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
}
          } else if (_inviteToken != null) {
            // Fallback: Wenn Invite-Token in Query-Parametern, direkt zur Invite-Seite
            AppLogger.app.i(AppLocalizations.of(context)!.errorInvitetokenInQuery, error: {'token': _inviteToken!.substring(0, 8) + '...'});
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
```

**errorEinladungKonnteNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\controllers\world_list_controller.dart:99:18`
- 📝 Original: `'Einladung konnte nicht erstellt werden'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
try {
      final success = await _inviteService.createInvite(world.id, email);
      if (!success) {
        _error = 'Einladung konnte nicht erstellt werden';
      }
      notifyListeners();
      return success;
```

**errorFehlerBeimLaden** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\widgets\world_list_states.dart:116:15`
- 📝 Original: `'Fehler beim Laden'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
            const SizedBox(height: 16),
            Text(
              'Fehler beim Laden',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
```

**errorBackgroundcolorColorsorangeDuration** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:180:387`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = AppLocalizations.of(context)!.errorDuKannstNun;
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i(AppLocalizations.of(context)!.worldVersucheInviteakzeptierungFür);
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-JoinAppLocalizations.of(context)!.navigationSuccessAwait_worldservicejoinworld_worldidEinladung akzeptiert! Willkommen in der Welt "`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}AppLocalizations.of(context)!.worldDasInviteWurde${_world!.name}AppLocalizations.of(context)!.worldBeigetretenBackgroundcolorColorsgreenInvite bereits akzeptiertAppLocalizations.of(context)!.errorIstKeinFehler${_world?.name}AppLocalizations.of(context)!.worldIfMountedScaffoldmessengerofcontextshowsnackbar${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
```

**errorEFehlerNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:190:74`
- 📝 Original: `', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = AppLocalizations.of(context)!.errorDuKannstNun;
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i(AppLocalizations.of(context)!.worldVersucheInviteakzeptierungFür);
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
}
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = AppLocalizations.of(context)!.errorDuKannstNun;
```

**errorDieseEinladungIst** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:249:24`
- 📝 Original: `'Diese Einladung ist abgelaufen.'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
} else if (e.toString().contains(AppLocalizations.of(context)!.errorNichtFürDeine)) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = AppLocalizations.of(context)!.errorEinFehlerIstException: ', '')}AppLocalizations.of(context)!.errorFinallySetstate_isjoiningErfolgreich für ${world.name} vorregistriert!AppLocalizations.of(context)!.worldBackgroundcolorColorsgreenElseFehler bei der Vorregistrierung';
        });
```

**errorFinallyIfMounted** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:291:62`
- 📝 Original: `');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLocalizations.of(context)!.buttonWeltVerlassen),
        content: Text(AppLocalizations.of(context)!.buttonMöchtestDuDie),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
}
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
```

**errorBackgroundcolorColorsorangeDuration** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:180:387`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = AppLocalizations.of(context)!.errorDuKannstNun;
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i(AppLocalizations.of(context)!.worldVersucheInviteakzeptierungFür);
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-JoinAppLocalizations.of(context)!.navigationSuccessAwait_worldservicejoinworld_worldidEinladung akzeptiert! Willkommen in der Welt "`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}AppLocalizations.of(context)!.worldDasInviteWurde${_world!.name}AppLocalizations.of(context)!.worldBeigetretenBackgroundcolorColorsgreenInvite bereits akzeptiertAppLocalizations.of(context)!.errorIstKeinFehler${_world?.name}AppLocalizations.of(context)!.worldIfMountedScaffoldmessengerofcontextshowsnackbar${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
```

**errorEFehlerNicht** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:190:74`
- 📝 Original: `', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = AppLocalizations.of(context)!.errorDuKannstNun;
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i(AppLocalizations.of(context)!.worldVersucheInviteakzeptierungFür);
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
}
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = AppLocalizations.of(context)!.errorDuKannstNun;
```

**errorElse_joinerrorApplocalizationsofcontexterroreinfehleristexception** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:249:56`
- 📝 Original: `';
        } else {
          _joinError = AppLocalizations.of(context)!.errorEinFehlerIstException: '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
} else if (e.toString().contains(AppLocalizations.of(context)!.errorNichtFürDeine)) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = AppLocalizations.of(context)!.errorEinFehlerIstException: ', '')}AppLocalizations.of(context)!.errorFinallySetstate_isjoiningErfolgreich für ${world.name} vorregistriert!AppLocalizations.of(context)!.worldBackgroundcolorColorsgreenElseFehler bei der Vorregistrierung';
        });
```

**errorBackgroundcolorColorsorangeDuration** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:180:387`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = AppLocalizations.of(context)!.errorDuKannstNun;
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i(AppLocalizations.of(context)!.worldVersucheInviteakzeptierungFür);
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-JoinAppLocalizations.of(context)!.navigationSuccessAwait_worldservicejoinworld_worldidEinladung akzeptiert! Willkommen in der Welt "`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}AppLocalizations.of(context)!.worldDasInviteWurde${_world!.name}AppLocalizations.of(context)!.worldBeigetretenBackgroundcolorColorsgreenInvite bereits akzeptiertAppLocalizations.of(context)!.errorIstKeinFehler${_world?.name}AppLocalizations.of(context)!.worldIfMountedScaffoldmessengerofcontextshowsnackbar${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
```

**error_isloadingFalseNormale** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:19:75`
- 📝 Original: `';
        _isLoading = false;
      });
    }
  }

  // **NORMALE NAVIGATION: Einfach und direkt**
  Future<void> _handleNormalFlow() async {
    if (widget.worldId == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorKeineWeltidGefunden;
        _isLoading = false;
      });
      return;
    }
    
    // World laden
    _world = await _worldService.getWorld(int.parse(widget.worldId!));
    
    // Status prüfen
    await _checkWorldStatus();
    
    // Fertig!
    setState(() {
      _isLoading = false;
    });
  }

  // **INVITE-FLOW: Komplex mit Auth-Prüfung**
  Future<void> _handleInviteFlow() async {
    if (widget.inviteToken == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorKeinEinladungstokenGefunden;
        _isLoading = false;
      });
      return;
    }
    
    // Token validieren
    final tokenData = await _worldService.validateInviteToken(widget.inviteToken!);
    
    if (tokenData == null || tokenData['`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
'username': currentUser?.username,
        'changedAppLocalizations.of(context)!.authWasauthenticated_isauthenticatedUiFehler beim Prüfen des Authentication-StatusAppLocalizations.of(context)!.errorE_isauthenticatedFalse💥 FEHLER in _loadWorldData: $e');
      setState(() {
        _errorMessage = 'Fehler beim Laden der Welt-Daten: ${e.toString()}';
        _isLoading = false;
      });
    }
```

**errorFinallyIfMounted** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:291:62`
- 📝 Original: `');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLocalizations.of(context)!.buttonWeltVerlassen),
        content: Text(AppLocalizations.of(context)!.buttonMöchtestDuDie),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
}
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
```

**errorFehlerBeimLaden** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_list_page.dart:481:41`
- 📝 Original: `'Fehler beim Laden der Welten'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Fehler beim Laden der Welten',
                                        style: TextStyle(
                                          color: Colors.red[200],
                                          fontWeight: FontWeight.bold,
```

**errorBackgroundcolorAppthemeerrorcolorElse** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_list_page.dart:98:75`
- 📝 Original: `'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        } else {
          // For 401/404/token errors, just set loading to false
          setState(() {
            _isLoading = false;
          });
          
          // If token is invalid, redirect to login
          if (e.toString().contains('`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Laden der Welten: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
```

**errorWorldidFuturevoid_joinworldworld** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_list_page.dart:197:292`
- 📝 Original: `': world.id});
          }
        }
      }
    }
  }

  Future<void> _joinWorld(World world) async {
    try {
      final success = await _worldService.joinWorld(world.id);
      if (success && mounted) {
        setState(() {
          _joinedWorlds[world.id] = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.worldErfolgreichZuWorldname),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to world dashboard
        context.goNamed(AppLocalizations.of(context)!.worldWorlddashboard, pathParameters: {'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
}
        } else {
          // Only log other errors
          AppLogger.logError('Player-Status Check fehlgeschlagen', e, context: {'worldIdAppLocalizations.of(context)!.errorWorldidFuturevoid_checkpreregistrationstatuses404AppLocalizations.of(context)!.authIfMountedSetstatePre-Registration Status Check fehlgeschlagen', e, context: {'worldId': world.id});
          }
        }
      }
```

**errorFehlerBeimLaden** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_list_page.dart:481:41`
- 📝 Original: `'Fehler beim Laden der Welten'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Fehler beim Laden der Welten',
                                        style: TextStyle(
                                          color: Colors.red[200],
                                          fontWeight: FontWeight.bold,
```

### 🏷️ FORM

**formIf_emailregexhasmatchvaluetrimReturn** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\forgot_password_page.dart:68:278`
- 📝 Original: `';
                                  }
                                  if (!_emailRegex.hasMatch(value.trim())) {
                                    return AppLocalizations.of(context)!.authBitteGibEine;
                                  }
                                  return null;
                                },
                              ),
                            
                            if (!_isSuccess) const SizedBox(height: 16),
                            
                            // Error message
                            if (_errorMessage != null && !_isSuccess)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red[900]!.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[400]!.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(color: Colors.red[200], fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Submit button
                            if (!_isSuccess)
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _requestPasswordReset,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'E-Mail gesendet! Bitte überprüfe deinen Posteingang.AppLocalizations.of(context)!.uiStyleTextstylecolorColorsgreen200E-Mail-AdresseAppLocalizations.of(context)!.formLabelstyleTextstylecolorColorsgrey400Bitte gib deine E-Mail-Adresse ein';
                                  }
                                  if (!_emailRegex.hasMatch(value.trim())) {
                                    return AppLocalizations.of(context)!.authBitteGibEine;
```

**formLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\login_page.dart:159:63`
- 📝 Original: `',
                                      labelStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                      filled: true,
                                      fillColor: const Color(0xFF2D2D2D),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return AppLocalizations.of(context)!.formBitteGibDeinen;
                                      }
                                      if (value.trim().length < 3) {
                                        return AppLocalizations.of(context)!.authBenutzernameMussMindestens;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Password field with better validation
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    autofillHints: const [AutofillHints.password],
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _isLoading ? null : _login(),
                                    onChanged: (_) {
                                      if (!_hasInteractedWithPassword) {
                                        setState(() {
                                          _hasInteractedWithPassword = true;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
}
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Benutzername',
                                      labelStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                      filled: true,
```

**formLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\register_page.dart:170:57`
- 📝 Original: `',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                filled: true,
                                fillColor: const Color(0xFF2D2D2D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red[400]!),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Benutzername',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                filled: true,
```

**formLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\register_page.dart:217:51`
- 📝 Original: `',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
                                filled: true,
                                fillColor: const Color(0xFF2D2D2D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red[400]!),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'E-Mail',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
                                filled: true,
```

**formHelperstyleTextstylecolorColorsgrey500** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\reset_password_page.dart:198:70`
- 📝 Original: `',
                                    helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!.formBitteGibEin;
                                    }
                                    if (value.length < 6) {
                                      return '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                    ),
                                    helperText: 'Mindestens 6 Zeichen',
                                    helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                  validator: (value) {
```

**form_buildrequirementapplocalizationsofcontextformpasswörterstimmenüberein_passwordcontrollertextisnotempty_passwordcontrollertext** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\reset_password_page.dart:304:78`
- 📝 Original: `')),
                                      _buildRequirement(AppLocalizations.of(context)!.formPasswörterStimmenÜberein, 
                                        _passwordController.text.isNotEmpty && 
                                        _passwordController.text == _confirmPasswordController.text),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Error message
                              if (_errorMessage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900]!.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[400]!.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(color: Colors.red[200], fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Submit button
                              if (!_isSuccess)
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
_buildRequirement('Mindestens 6 Zeichen', 
                                        _passwordController.text.length >= 6),
                                      _buildRequirement(AppLocalizations.of(context)!.formKeineLeerzeichen, 
                                        !_passwordController.text.contains(' ')),
                                      _buildRequirement(AppLocalizations.of(context)!.formPasswörterStimmenÜberein, 
                                        _passwordController.text.isNotEmpty && 
                                        _passwordController.text == _confirmPasswordController.text),
```

**formStyleThemeofcontexttextthemeheadlinesmallcopywithColor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:499:37`
- 📝 Original: `',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? AppLocalizations.of(context)!.formKeineInformationVerfügbar,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "Zurück"-Link (User kommt von externem Link)**
                      if (widget.inviteToken == null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                          child: const Text(
                            AppLocalizations.of(context)!.buttonZurückZuDen,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public_off,
                        size: 80,
                        color: Colors.orange[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.worldWeltNichtGefunden,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.worldDieAngeforderteWelt,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(AppLocalizations.of(context)!.buttonZurückZuDen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorldContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(24),
        child: Card(
          elevation: 16,
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header mit Welt-Name und Status
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Welt-Name und Status
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _world?.name ?? AppLocalizations.of(context)!.worldUnbekannteWelt,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
```

**formStyleThemeofcontexttextthemeheadlinesmallcopywithColor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:499:37`
- 📝 Original: `',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? AppLocalizations.of(context)!.formKeineInformationVerfügbar,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "Zurück"-Link (User kommt von externem Link)**
                      if (widget.inviteToken == null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                          child: const Text(
                            AppLocalizations.of(context)!.buttonZurückZuDen,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public_off,
                        size: 80,
                        color: Colors.orange[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.worldWeltNichtGefunden,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.worldDieAngeforderteWelt,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(AppLocalizations.of(context)!.buttonZurückZuDen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorldContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(24),
        child: Card(
          elevation: 16,
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header mit Welt-Name und Status
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Welt-Name und Status
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _world?.name ?? AppLocalizations.of(context)!.worldUnbekannteWelt,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
```

**formLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 1.0)
- 📁 `lib\shared\widgets\invite_dialog.dart:27:43`
- 📝 Original: `',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Weiße Schrift
              decoration: InputDecoration(
                labelText: 'E-Mail-Adresse',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
                filled: true,
```

**formLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 1.0)
- 📁 `lib\shared\widgets\pre_register_dialog.dart:26:43`
- 📝 Original: `',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Weiße Schrift
              decoration: InputDecoration(
                labelText: 'E-Mail-Adresse',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
                filled: true,
```

### 🏷️ INVITE

**inviteIfIsacceptedValiditytext** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:108:248`
- 📝 Original: `';
      
      if (isAccepted) {
        validityText = AppLocalizations.of(context)!.inviteNnDieseEinladung;
      } else if (isExpired) {
        validityText = '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
: 'beizutretenAppLocalizations.of(context)!.uiGültigkeitstextErstellenString';
    if (expiresAt != null) {
      final expiresAtLocal = expiresAt.toLocal();
      final dateStr = '${expiresAtLocal.day.toString().padLeft(2, '0')}.${expiresAtLocal.month.toString().padLeft(2, '0')}.${expiresAtLocal.year} ${expiresAtLocal.hour.toString().padLeft(2, '0')}:${expiresAtLocal.minute.toString().padLeft(2, '0')}';
      
      if (isAccepted) {
        validityText = AppLocalizations.of(context)!.inviteNnDieseEinladung;
```

### 🏷️ NAVIGATION

**navigationBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:223:267`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteTokenAppLocalizations.of(context)!.worldWidgetinvitetokensubstring08Setstatebereits akzeptiert')) {
          _joinError = AppLocalizations.of(context)!.errorDieseEinladungWurde;
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains(AppLocalizations.of(context)!.errorNichtFürDeine)) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = AppLocalizations.of(context)!.errorEinFehlerIstException: ', '')}AppLocalizations.of(context)!.errorFinallySetstate_isjoiningErfolgreich für ${world.name} vorregistriert!AppLocalizations.of(context)!.worldBackgroundcolorColorsgreenElseFehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.AppLocalizations.of(context)!.worldBackgroundcolorColorsorangeElseFehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLocalizations.of(context)!.buttonWeltVerlassen),
        content: Text(AppLocalizations.of(context)!.buttonMöchtestDuDie),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('AbbrechenAppLocalizations.of(context)!.buttonTextbuttonOnpressedNavigatorofcontextpoptrueVerlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.AppLocalizations.of(context)!.worldBackgroundcolorColorsorangeCatchException: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'idAppLocalizations.of(context)!.worldWorldidtostringWeltstatusBestimmenUnbekanntAppLocalizations.of(context)!.worldReturnWorldstatustextWeltstatusfarbe🎫 Navigation zur Registration mit Invite-E-Mail', error: {'emailAppLocalizations.of(context)!.errorEmailFixedInvitetokenregister', queryParameters: {'email': email, 'invite_tokenAppLocalizations.of(context)!.navigationWidgetinvitetokenNavigationZu🎫 Navigation zum Login für Invite', error: {'emailAppLocalizations.of(context)!.errorEmailFixedInvitetokenlogin', queryParameters: {'invite_tokenAppLocalizations.of(context)!.authWidgetinvitetokenUserAbmelden🎫 User logout für Invite-Umleitung', error: {'inviteEmailAppLocalizations.of(context)!.error_inviteemailFixedInvitetokenregister', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError(AppLocalizations.of(context)!.errorLogoutFürInvite, e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim AbmeldenAppLocalizations.of(context)!.errorBackgroundcolorColorsredOverrideworld-join',
                routeParams: {'idAppLocalizations.of(context)!.navigationWidgetworldidIsjoinedworld_isjoinedFehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter FehlerAppLocalizations.of(context)!.errorStyleThemeofcontexttextthemebodylargecopywithColorJetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? AnmeldenAppLocalizations.of(context)!.buttonStyleOutlinedbuttonstylefromForegroundcolorAbmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text(AppLocalizations.of(context)!.buttonZurückZurStartseite),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                        child: const Text(
                          AppLocalizations.of(context)!.buttonZurückZuDen,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? AppLocalizations.of(context)!.formKeineInformationVerfügbar,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
}
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-JoinAppLocalizations.of(context)!.navigationSuccessAwait_worldservicejoinworld_worldidEinladung akzeptiert! Willkommen in der Welt "${_world!.name}AppLocalizations.of(context)!.worldErfolgreichDerWelt${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
```

**navigationBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:223:267`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteTokenAppLocalizations.of(context)!.worldWidgetinvitetokensubstring08Setstatebereits akzeptiert')) {
          _joinError = AppLocalizations.of(context)!.errorDieseEinladungWurde;
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains(AppLocalizations.of(context)!.errorNichtFürDeine)) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = AppLocalizations.of(context)!.errorEinFehlerIstException: ', '')}AppLocalizations.of(context)!.errorFinallySetstate_isjoiningErfolgreich für ${world.name} vorregistriert!AppLocalizations.of(context)!.worldBackgroundcolorColorsgreenElseFehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.AppLocalizations.of(context)!.worldBackgroundcolorColorsorangeElseFehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLocalizations.of(context)!.buttonWeltVerlassen),
        content: Text(AppLocalizations.of(context)!.buttonMöchtestDuDie),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('AbbrechenAppLocalizations.of(context)!.buttonTextbuttonOnpressedNavigatorofcontextpoptrueVerlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.AppLocalizations.of(context)!.worldBackgroundcolorColorsorangeCatchException: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'idAppLocalizations.of(context)!.worldWorldidtostringWeltstatusBestimmenUnbekanntAppLocalizations.of(context)!.worldReturnWorldstatustextWeltstatusfarbe🎫 Navigation zur Registration mit Invite-E-Mail', error: {'emailAppLocalizations.of(context)!.errorEmailFixedInvitetokenregister', queryParameters: {'email': email, 'invite_tokenAppLocalizations.of(context)!.navigationWidgetinvitetokenNavigationZu🎫 Navigation zum Login für Invite', error: {'emailAppLocalizations.of(context)!.errorEmailFixedInvitetokenlogin', queryParameters: {'invite_tokenAppLocalizations.of(context)!.authWidgetinvitetokenUserAbmelden🎫 User logout für Invite-Umleitung', error: {'inviteEmailAppLocalizations.of(context)!.error_inviteemailFixedInvitetokenregister', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError(AppLocalizations.of(context)!.errorLogoutFürInvite, e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim AbmeldenAppLocalizations.of(context)!.errorBackgroundcolorColorsredOverrideworld-join',
                routeParams: {'idAppLocalizations.of(context)!.navigationWidgetworldidIsjoinedworld_isjoinedFehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter FehlerAppLocalizations.of(context)!.errorStyleThemeofcontexttextthemebodylargecopywithColorJetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? AnmeldenAppLocalizations.of(context)!.buttonStyleOutlinedbuttonstylefromForegroundcolorAbmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text(AppLocalizations.of(context)!.buttonZurückZurStartseite),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                        child: const Text(
                          AppLocalizations.of(context)!.buttonZurückZuDen,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? AppLocalizations.of(context)!.formKeineInformationVerfügbar,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
}
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-JoinAppLocalizations.of(context)!.navigationSuccessAwait_worldservicejoinworld_worldidEinladung akzeptiert! Willkommen in der Welt "${_world!.name}AppLocalizations.of(context)!.worldErfolgreichDerWelt${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
```

**navigationBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:223:267`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteTokenAppLocalizations.of(context)!.worldWidgetinvitetokensubstring08Setstatebereits akzeptiert')) {
          _joinError = AppLocalizations.of(context)!.errorDieseEinladungWurde;
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains(AppLocalizations.of(context)!.errorNichtFürDeine)) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = AppLocalizations.of(context)!.errorEinFehlerIstException: ', '')}AppLocalizations.of(context)!.errorFinallySetstate_isjoiningErfolgreich für ${world.name} vorregistriert!AppLocalizations.of(context)!.worldBackgroundcolorColorsgreenElseFehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.AppLocalizations.of(context)!.worldBackgroundcolorColorsorangeElseFehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLocalizations.of(context)!.buttonWeltVerlassen),
        content: Text(AppLocalizations.of(context)!.buttonMöchtestDuDie),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('AbbrechenAppLocalizations.of(context)!.buttonTextbuttonOnpressedNavigatorofcontextpoptrueVerlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.AppLocalizations.of(context)!.worldBackgroundcolorColorsorangeCatchException: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'idAppLocalizations.of(context)!.worldWorldidtostringWeltstatusBestimmenUnbekanntAppLocalizations.of(context)!.worldReturnWorldstatustextWeltstatusfarbe🎫 Navigation zur Registration mit Invite-E-Mail', error: {'emailAppLocalizations.of(context)!.errorEmailFixedInvitetokenregister', queryParameters: {'email': email, 'invite_tokenAppLocalizations.of(context)!.navigationWidgetinvitetokenNavigationZu🎫 Navigation zum Login für Invite', error: {'emailAppLocalizations.of(context)!.errorEmailFixedInvitetokenlogin', queryParameters: {'invite_tokenAppLocalizations.of(context)!.authWidgetinvitetokenUserAbmelden🎫 User logout für Invite-Umleitung', error: {'inviteEmailAppLocalizations.of(context)!.error_inviteemailFixedInvitetokenregister', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError(AppLocalizations.of(context)!.errorLogoutFürInvite, e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim AbmeldenAppLocalizations.of(context)!.errorBackgroundcolorColorsredOverrideworld-join',
                routeParams: {'idAppLocalizations.of(context)!.navigationWidgetworldidIsjoinedworld_isjoinedFehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter FehlerAppLocalizations.of(context)!.errorStyleThemeofcontexttextthemebodylargecopywithColorJetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? AnmeldenAppLocalizations.of(context)!.buttonStyleOutlinedbuttonstylefromForegroundcolorAbmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text(AppLocalizations.of(context)!.buttonZurückZurStartseite),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                        child: const Text(
                          AppLocalizations.of(context)!.buttonZurückZuDen,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? AppLocalizations.of(context)!.formKeineInformationVerfügbar,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
}
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-JoinAppLocalizations.of(context)!.navigationSuccessAwait_worldservicejoinworld_worldidEinladung akzeptiert! Willkommen in der Welt "${_world!.name}AppLocalizations.of(context)!.worldErfolgreichDerWelt${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
```

### 🏷️ UI

**uiStyleTextstylefontsize16** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:785:28`
- 📝 Original: `',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // **ACCEPT INVITE BUTTON (wenn User korrekt angemeldet)**
    if (_showAcceptInviteButton && widget.inviteToken != null) {
      buttons.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: _isJoining || !isInviteValid ? null : () => _joinWorld(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
),
            ),
            child: const Text(
              'Registrieren',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
```

**uiStyleTextstylefontsize16** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:831:24`
- 📝 Original: `',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // FALLBACK: Normale World-Join-Buttons wenn keine spezifischen Buttons
    if (buttons.isEmpty) {
      // **NORMALE WORLD-JOIN LOGIC** (wenn kein Invite-Token)
      if (widget.inviteToken == null && _world != null) {
        final world = _world!;
        
        // **STATUS-BASIERTE INTELLIGENTE BUTTON-LOGIK**
        switch (world.status) {
          case WorldStatus.upcoming:
            // Vorregistrierung oder Zurückziehen
            if (_isPreRegistered) {
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                    icon: const Icon(Icons.cancel),
                    label: Text(_isPreRegistering ? '`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
),
            ),
            child: const Text(
              'Abmelden',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
```

### 🏷️ WORLD

**worldIfResponsestatuscode200** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\world_service.dart:52:63`
- 📝 Original: `');
      
      if (response.statusCode == 200) {
        final worldJson = jsonDecode(response.body);
        return World.fromJson(worldJson);
      } else {
        throw Exception(AppLocalizations.of(context)!.errorWeltKonnteNicht);
      }
    } on FormatException catch (e) {
      throw Exception('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
Future<World> getWorld(int worldId) async {
    try {
      final response = await _apiService.get('/worlds/$worldId');
      
      if (response.statusCode == 200) {
        final worldJson = jsonDecode(response.body);
```

**worldActiontypetextvaliditytextJeNach** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:115:164`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = AppLocalizations.of(context)!.buttonDuMusstDich;
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'loginAppLocalizations.of(context)!.authMailIstBekanntDein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['emailAppLocalizations.of(context)!.authUserMitFalscherDiese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_worldAppLocalizations.of(context)!.buttonUserRichtigAngemeldetDu bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.AppLocalizations.of(context)!.inviteSetstate_infomessageInfotext✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
} else if (isExpired) {
        validityText = '\n\n❌ Diese Einladung ist am $dateStr abgelaufen.';
      } else {
        validityText = '\n\n⏰ Gültig bis: $dateStrAppLocalizations.of(context)!.inviteFinalBaseinfotextDu wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
```

**worldIconscategory_buildinfocardapplocalizationsofcontextworldweltid** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:714:48`
- 📝 Original: `', Icons.category),
          _buildInfoCard(AppLocalizations.of(context)!.worldWeltid, '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
style: TextStyle(color: Colors.grey[300], height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildInfoCard('Kategorie', 'Standard', Icons.category),
          _buildInfoCard(AppLocalizations.of(context)!.worldWeltid, '#${_world?.id ?? 'N/A'}', Icons.tag),
          _buildInfoCard('Erstellt', _world?.createdAt.toString().split(' ')[0] ?? 'UnbekanntAppLocalizations.of(context)!.worldIconsaccess_timeWidget_buildrulestabSpielregeln',
                style: TextStyle(
```

**worldActiontypetextvaliditytextJeNach** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:115:164`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = AppLocalizations.of(context)!.buttonDuMusstDich;
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'loginAppLocalizations.of(context)!.authMailIstBekanntDein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['emailAppLocalizations.of(context)!.authUserMitFalscherDiese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_worldAppLocalizations.of(context)!.buttonUserRichtigAngemeldetDu bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.AppLocalizations.of(context)!.inviteSetstate_infomessageInfotext✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
} else if (isExpired) {
        validityText = '\n\n❌ Diese Einladung ist am $dateStr abgelaufen.';
      } else {
        validityText = '\n\n⏰ Gültig bis: $dateStrAppLocalizations.of(context)!.inviteFinalBaseinfotextDu wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
```

**worldActiontypetextvaliditytextJeNach** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:115:164`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = AppLocalizations.of(context)!.buttonDuMusstDich;
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'loginAppLocalizations.of(context)!.authMailIstBekanntDein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['emailAppLocalizations.of(context)!.authUserMitFalscherDiese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_worldAppLocalizations.of(context)!.buttonUserRichtigAngemeldetDu bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.AppLocalizations.of(context)!.inviteSetstate_infomessageInfotext✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
} else if (isExpired) {
        validityText = '\n\n❌ Diese Einladung ist am $dateStr abgelaufen.';
      } else {
        validityText = '\n\n⏰ Gültig bis: $dateStrAppLocalizations.of(context)!.inviteFinalBaseinfotextDu wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
```

**worldActiontypetextvaliditytextJeNach** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:115:164`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = AppLocalizations.of(context)!.buttonDuMusstDich;
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'loginAppLocalizations.of(context)!.authMailIstBekanntDein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['emailAppLocalizations.of(context)!.authUserMitFalscherDiese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_worldAppLocalizations.of(context)!.buttonUserRichtigAngemeldetDu bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontext;
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.AppLocalizations.of(context)!.inviteSetstate_infomessageInfotext✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
} else if (isExpired) {
        validityText = '\n\n❌ Diese Einladung ist am $dateStr abgelaufen.';
      } else {
        validityText = '\n\n⏰ Gültig bis: $dateStrAppLocalizations.of(context)!.inviteFinalBaseinfotextDu wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
```

**worldWähleDeineWelt** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_list_page.dart:403:33`
- 📝 Original: `'Wähle deine Welt aus'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
// Subtitle
                              Text(
                                'Wähle deine Welt aus',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.grey[300],
                                ),
```

**worldBackgroundcolorColorsorangeCatch** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_list_page.dart:286:60`
- 📝 Original: `'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Prüfe ob es ein Token-Problem ist
        if (e.toString().contains('`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
```

**worldWeltNichtGefunden** 🔥 (Confidence: 1.0)
- 📁 `lib\routing\app_router.dart:274:21`
- 📝 Original: `'Welt nicht gefunden'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                  const SizedBox(height: 24),
                  Text(
                    'Welt nicht gefunden',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
```

**worldDieAngeforderteWelt** 🔥 (Confidence: 1.0)
- 📁 `lib\routing\app_router.dart:282:21`
- 📝 Original: `'Die angeforderte Welt existiert nicht oder wurde entfernt.'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                  const SizedBox(height: 16),
                  Text(
                    'Die angeforderte Welt existiert nicht oder wurde entfernt.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
```

### 🏷️ FORM

**form_buildrequirementapplocalizationsofcontextformpasswörterstimmenüberein_passwordcontrollertextisnotempty_passwordcontrollertext** 🔥 (Confidence: 1.0)
- 📁 `lib\features\auth\reset_password_page.dart:304:78`
- 📝 Original: `')),
                                      _buildRequirement(AppLocalizations.of(context)!.formPasswörterStimmenÜberein, 
                                        _passwordController.text.isNotEmpty && 
                                        _passwordController.text == _confirmPasswordController.text),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Error message
                              if (_errorMessage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900]!.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[400]!.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(color: Colors.red[200], fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Submit button
                              if (!_isSuccess)
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
_buildRequirement('Mindestens 6 Zeichen', 
                                        _passwordController.text.length >= 6),
                                      _buildRequirement(AppLocalizations.of(context)!.formKeineLeerzeichen, 
                                        !_passwordController.text.contains(' ')),
                                      _buildRequirement(AppLocalizations.of(context)!.formPasswörterStimmenÜberein, 
                                        _passwordController.text.isNotEmpty && 
                                        _passwordController.text == _confirmPasswordController.text),
```

**formStyleThemeofcontexttextthemeheadlinesmallcopywithColor** 🔥 (Confidence: 1.0)
- 📁 `lib\features\world\world_join_page.dart:499:37`
- 📝 Original: `',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? AppLocalizations.of(context)!.formKeineInformationVerfügbar,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "Zurück"-Link (User kommt von externem Link)**
                      if (widget.inviteToken == null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                          child: const Text(
                            AppLocalizations.of(context)!.buttonZurückZuDen,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public_off,
                        size: 80,
                        color: Colors.orange[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.worldWeltNichtGefunden,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.worldDieAngeforderteWelt,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => context.goNamed(AppLocalizations.of(context)!.buttonWorldlist),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(AppLocalizations.of(context)!.buttonZurückZuDen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorldContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(24),
        child: Card(
          elevation: 16,
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header mit Welt-Name und Status
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Welt-Name und Status
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _world?.name ?? AppLocalizations.of(context)!.worldUnbekannteWelt,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
```

### 🏷️ NAVIGATION

**navigationClassDashboardpageExtends** 🔥 (Confidence: 1.0)
- 📁 `lib\features\dashboard\dashboard_page.dart:6:39`
- 📝 Original: `';

class DashboardPage extends StatelessWidget {
  final String worldId;
  
  const DashboardPage({super.key, required this.worldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 12,
                    color: const Color(0xFF1A1A1A), // Dunkle Karte
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A1A1A),
                            Color(0xFF2A2A2A),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.rocket_launch,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Title
                            Text(
                              AppLocalizations.of(context)!.worldWeltdashboard,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Subtitle
                            Text(
                              AppLocalizations.of(context)!.worldWeltIdWorldid,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Info message
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.construction,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import '../../theme/background_widget.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../l10n/app_localizations.dart';

class DashboardPage extends StatelessWidget {
  final String worldId;
```

**navigationIfWorldidparamNull** 🔥 (Confidence: 1.0)
- 📁 `lib\shared\widgets\navigation_widget.dart:19:51`
- 📝 Original: `'];
      if (worldIdParam != null) {
        items.add(NavigationItem(
          icon: Icons.info_outline,
          label: AppLocalizations.of(context)!.navigationWeltdetails,
          onTap: () => context.goNamed('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
onTap: () => context.goNamed(AppLocalizations.of(context)!.navigationWorldlist),
      isActive: widget.currentRoute == 'world-listAppLocalizations.of(context)!.navigationWeltdetailsAnzeigenVonworld-dashboard' || widget.currentRoute == 'world-join') 
        && widget.routeParams?['id'] != null) {
      final worldIdParam = widget.routeParams?['id'];
      if (worldIdParam != null) {
        items.add(NavigationItem(
          icon: Icons.info_outline,
```

### 🏷️ BUTTON

**buttonInfotextApplocalizationsofcontextbuttonbaseinfotextnnactiontextnnbittemeldedichShowlogoutbutton** 🔥 (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:137:215`
- 📝 Original: `';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['emailAppLocalizations.of(context)!.authUserMitFalscherDiese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = AppLocalizations.of(context)!.buttonBaseinfotextnnactiontextnnbitteMeldeDich;
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
```

### 🏷️ DIALOG

**dialogStyleConstTextstyle** 🔥 (Confidence: 0.9)
- 📁 `lib\shared\widgets\invite_dialog.dart:3:132`
- 📝 Original: `',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.uiGebenSieDie,
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              autofocus: true, // Barrierefreiheit: Sofortiger Fokus
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Weiße Schrift
              decoration: InputDecoration(
                labelText: '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../l10n/app_localizations.dartAppLocalizations.of(context)!.dialogClassInvitedialogExtendsEinladung für ${widget.worldName}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
```

### 🏷️ ERROR

**errorCaseInviteerrorcodepermissiondeniedReturn** 🔥 (Confidence: 0.9)
- 📁 `lib\core\services\invite_service.dart:44:170`
- 📝 Original: `';
      case InviteErrorCode.permissionDenied:
        return AppLocalizations.of(context)!.errorDuHastKeine;
      case InviteErrorCode.worldNotFound:
        return AppLocalizations.of(context)!.errorWeltNichtGefunden;
      case InviteErrorCode.worldNotOpen:
        return AppLocalizations.of(context)!.errorDieseWeltIst;
      case InviteErrorCode.invalidEmail:
        return AppLocalizations.of(context)!.errorUngültigeEmailadresse;
      case InviteErrorCode.networkError:
        return AppLocalizations.of(context)!.errorNetzwerkfehlerBitteVersuche;
      case InviteErrorCode.unknown:
        return originalMessage ?? AppLocalizations.of(context)!.errorEinladungFehlgeschlagen;
    }
  }

  Future<bool> createInvite(int worldId, String email) async {
    try {
      final data = <String, dynamic>{
        '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return InviteErrorCode.worldNotFound;
    } else if (message.contains(AppLocalizations.of(context)!.errorNichtGeöffnet)) {
      return InviteErrorCode.worldNotOpen;
    } else if (message.contains('E-MailAppLocalizations.of(context)!.errorReturnInviteerrorcodeinvalidemailReturnDiese E-Mail-Adresse hat bereits eine Einladung erhalten';
      case InviteErrorCode.permissionDenied:
        return AppLocalizations.of(context)!.errorDuHastKeine;
      case InviteErrorCode.worldNotFound:
```

**errorStyleConstTextstyle** 🔥 (Confidence: 0.9)
- 📁 `lib\shared\widgets\pre_register_dialog.dart:3:334`
- 📝 Original: `',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.worldGebenSieIhre,
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Weiße Schrift
              decoration: InputDecoration(
                labelText: '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../l10n/app_localizations.dartAppLocalizations.of(context)!.dialogClassPreregisterdialogExtendsVorregistrierung erfolgreich!AppLocalizations.of(context)!.uiBackgroundcolorColorsgreenCatchFehler: ${e.toString()}AppLocalizations.of(context)!.errorBackgroundcolorAppthemeerrorcolorFinallyVorregistrierung für ${widget.worldName}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
```

**errorUnbekannterFehler** 🔥 (Confidence: 0.9)
- 📁 `lib\shared\widgets\splash_screen.dart:89:27`
- 📝 Original: `'Unbekannter Fehler'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
const SizedBox(height: 10),
              
              Text(
                _error ?? 'Unbekannter Fehler',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
```

### 🏷️ UI

**uiStyleThemeofcontexttextthemeheadlinemediumcopywithColor** 🔥 (Confidence: 0.9)
- 📁 `lib\features\auth\reset_password_page.dart:106:133`
- 📝 Original: `',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              Text(
                                _isSuccess 
                                  ? AppLocalizations.of(context)!.uiDuWirstAutomatisch
                                  : AppLocalizations.of(context)!.uiBitteGibDein,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              
                              // Success Animation
                              if (_isSuccess)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 64,
                                    color: Colors.green,
                                  ),
                                ),
                              
                              // Password fields
                              if (!_isSuccess) ...[
                                // New Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  autofillHints: const [AutofillHints.newPassword],
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (!_hasInteractedWithPassword) {
                                      setState(() {
                                        _hasInteractedWithPassword = true;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
const SizedBox(height: 20),
                              
                              Text(
                                _isSuccess ? AppLocalizations.of(context)!.uiPasswortErfolgreichGeändert : 'Neues Passwort festlegen',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
```

**uiStyleTextstyleColor** 🔥 (Confidence: 0.9)
- 📁 `lib\features\world\widgets\world_card.dart:34:79`
- 📝 Original: `',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final List<Widget> buttons = [];
    
    // Status-basierte Button-Logik
    switch (world.status) {
      case WorldStatus.upcoming:
        // Vorregistrierung oder Zurückziehen
        if (isPreRegistered) {
          if (onCancelPreRegistration != null) {
            buttons.add(_buildButton(
              onPressed: onCancelPreRegistration,
              icon: Icons.cancel,
              label: '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      const SizedBox(width: 4),
                      Text(
                        'Ende: ${endDate.day}.${endDate.month}.${endDate.year}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
```

### 🏷️ WORLD

**worldReturnNullCatch** 🔥 (Confidence: 0.9)
- 📁 `lib\core\services\world_service.dart:226:36`
- 📝 Original: `'];
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.logError(AppLocalizations.of(context)!.errorFehlerBeiTokenvalidierung, e, context: {'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        }
      }
```

**worldStyleTextstyleColor** 🔥 (Confidence: 0.9)
- 📁 `lib\shared\widgets\user_info_widget.dart:16:98`
- 📝 Original: `',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Expand/Collapse Icon
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ],
                      ),
                      
                      // Erweiterte Details
                      if (_isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 12),
                        
                        // Email
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                                            // Rollen
                    if (user.roles != null && user.roles!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.security, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(
                            '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return Colors.orange[400] ?? Colors.orange;
      case 'world-admin':
        return Colors.indigo[400] ?? Colors.indigo;
      case 'userAppLocalizations.of(context)!.worldDefaultReturnColorsgreen400Klicken für Details',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
```

### 🏷️ AUTH

**authIfIsvalidApploggerappwapplocalizationsofcontextauthtokensungültiglogout** 🔥 (Confidence: 0.9)
- 📁 `lib\app.dart:45:206`
- 📝 Original: `');
        
        if (!isValid) {
          AppLogger.app.w(AppLocalizations.of(context)!.authTokensUngültigLogout);
          await authService.logout();
        }
      } catch (e) {
        AppLogger.app.e(AppLocalizations.of(context)!.errorTokenvalidierungFehlgeschlagen, error: e);
        // Bei Token-Validierungsfehlern einfach ausloggen
        await authService.logout();
      }
      
      // 4. Gespeicherte User-Daten laden (nur wenn Tokens gültig)
      if (isValid) {
        try {
          final user = await authService.loadStoredUser();
          if (user != null) {
            authService.isAuthenticated.value = true;
            AppLogger.app.i(AppLocalizations.of(context)!.authUserGeladenUnd);
          } else {
            AppLogger.app.i(AppLocalizations.of(context)!.errorKeinGespeicherterUser);
          }
        } catch (e) {
          AppLogger.app.e('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
// 1. Environment initialisieren
    await Env.initialize();
    
    AppLogger.app.i('🌍 Environment initialisiertAppLocalizations.of(context)!.ui2ServicesInitialisieren⚙️ Services registriertAppLocalizations.of(context)!.auth3TokenvalidierungBeim🔑 Tokens valid: $isValid');
        
        if (!isValid) {
          AppLogger.app.w(AppLocalizations.of(context)!.authTokensUngültigLogout);
```

### 🏷️ BUTTON

**buttonWirdZurückgezogen** 🔥 (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:857:53`
- 📝 Original: `'Wird zurückgezogen...'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                    icon: const Icon(Icons.cancel),
                    label: Text(_isPreRegistering ? 'Wird zurückgezogen...' : AppLocalizations.of(context)!.buttonVorregistrierungZurückziehen),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
```

### 🏷️ FORM

**formLabelstyleTextstylecolorColorsgrey400** 🔥 (Confidence: 0.9)
- 📁 `lib\features\auth\login_page.dart:159:63`
- 📝 Original: `',
                                      labelStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                      filled: true,
                                      fillColor: const Color(0xFF2D2D2D),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return AppLocalizations.of(context)!.formBitteGibDeinen;
                                      }
                                      if (value.trim().length < 3) {
                                        return AppLocalizations.of(context)!.authBenutzernameMussMindestens;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Password field with better validation
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    autofillHints: const [AutofillHints.password],
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _isLoading ? null : _login(),
                                    onChanged: (_) {
                                      if (!_hasInteractedWithPassword) {
                                        setState(() {
                                          _hasInteractedWithPassword = true;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
}
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Benutzername',
                                      labelStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                      filled: true,
```

**formHelperstyleTextstylecolorColorsgrey500** 🔥 (Confidence: 0.9)
- 📁 `lib\features\auth\reset_password_page.dart:198:70`
- 📝 Original: `',
                                    helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!.formBitteGibEin;
                                    }
                                    if (value.length < 6) {
                                      return '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                    ),
                                    helperText: 'Mindestens 6 Zeichen',
                                    helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                  validator: (value) {
```

### 🏷️ NAVIGATION

**navigationItemsaddnavigationitemIconIconsarrow_back** 🔥 (Confidence: 0.9)
- 📁 `lib\shared\widgets\navigation_widget.dart:4:251`
- 📝 Original: `') {
      items.add(NavigationItem(
        icon: Icons.arrow_back,
        label: AppLocalizations.of(context)!.navigationZurück,
        onTap: () => Navigator.of(context).canPop() 
          ? Navigator.of(context).pop()
          : context.goNamed(AppLocalizations.of(context)!.navigationWorldlist),
      ));
      
      items.add(NavigationItem(
        icon: Icons.remove,
        label: '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../l10n/app_localizations.dartAppLocalizations.of(context)!.navigationClassNavigationwidgetExtendsSie müssen erst der Welt beitreten, um das Dashboard zu sehenAppLocalizations.of(context)!.worldBackgroundcolorColorsorange700Durationworld-list') {
      items.add(NavigationItem(
        icon: Icons.arrow_back,
        label: AppLocalizations.of(context)!.navigationZurück,
```

### 🏷️ UI

**uiHeaders_headersReturn** 🔥 (Confidence: 0.9)
- 📁 `lib\core\services\api_service.dart:65:62`
- 📝 Original: `'),
          headers: _headers,
        );
    }
    return http.Response(AppLocalizations.of(context)!.uiRequestRetryFailed, 500);
  }

  Future<http.Response> deleteWithBody(String endpoint, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    // Erweiterte Request-Kontext-Verwaltung für parallele Requests
    _requestBodies[endpoint] = data;
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return await http.put(
            Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpointAppLocalizations.of(context)!.uiHeaders_headersBodyDELETE':
        return await http.delete(
          Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
          headers: _headers,
        );
    }
```

**uiStyleTextstyleColor** 🔥 (Confidence: 0.9)
- 📁 `lib\features\landing\landing_page.dart:187:137`
- 📝 Original: `',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.expand_more,
                            color: AppTheme.primaryColor,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Features Section
                if (_showFeatures)
                  FadeTransition(
                    opacity: _featureAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                      child: Column(
                        children: [
                          const Text(
                            AppLocalizations.of(context)!.worldWasMachtWeltenwind,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.uiErlebeGamingAuf,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[300],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                          
                          // Feature Grid
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 800 ? 3 : 
                                                    constraints.maxWidth > 500 ? 2 : 1;
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 1.2,
                                children: [
                                  _buildFeatureCard(
                                    icon: Icons.public,
                                    title: AppLocalizations.of(context)!.worldUnendlicheWelten,
                                    description: AppLocalizations.of(context)!.worldErkundeHunderteEinzigartige,
                                    color: Colors.blue,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.group,
                                    title: '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
width: 1,
                                              color: Colors.grey[700],
                                            ),
                                            _buildStatItem('24/7', 'OnlineAppLocalizations.of(context)!.uiScrollIndicatorIfEntdecke mehr',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
```

**uiDescriptionApplocalizationsofcontextuioptimierteserverfürColor** 🔥 (Confidence: 0.9)
- 📁 `lib\features\landing\landing_page.dart:265:57`
- 📝 Original: `',
                                    description: AppLocalizations.of(context)!.uiOptimierteServerFür,
                                    color: Colors.purple,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.devices,
                                    title: AppLocalizations.of(context)!.uiÜberallSpielen,
                                    description: AppLocalizations.of(context)!.uiAufPcTablet,
                                    color: Colors.red,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.star,
                                    title: '`
- 🎯 Widget: Widget: Card
- 🔧 Context:
```dart
),
                                  _buildFeatureCard(
                                    icon: Icons.speed,
                                    title: 'Blitzschnell',
                                    description: AppLocalizations.of(context)!.uiOptimierteServerFür,
                                    color: Colors.purple,
                                  ),
```

**uiStyleTextstylefontsize16** 🔥 (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:831:24`
- 📝 Original: `',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // FALLBACK: Normale World-Join-Buttons wenn keine spezifischen Buttons
    if (buttons.isEmpty) {
      // **NORMALE WORLD-JOIN LOGIC** (wenn kein Invite-Token)
      if (widget.inviteToken == null && _world != null) {
        final world = _world!;
        
        // **STATUS-BASIERTE INTELLIGENTE BUTTON-LOGIK**
        switch (world.status) {
          case WorldStatus.upcoming:
            // Vorregistrierung oder Zurückziehen
            if (_isPreRegistered) {
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                    icon: const Icon(Icons.cancel),
                    label: Text(_isPreRegistering ? '`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
),
            ),
            child: const Text(
              'Abmelden',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
```

### 🏷️ BUTTON

**buttonZurück** 🔥 (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:518:47`
- 📝 Original: `"Zurück"`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
// **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "Zurück"-Link (User kommt von externem Link)**
                      if (widget.inviteToken == null) ...[
                        const SizedBox(height: 16),
                        TextButton(
```

### 🏷️ AUTH

**authServicelocatorImportFür** 🔥 (Confidence: 0.9)
- 📁 `lib\features\auth\register_page.dart:7:43`
- 📝 Original: `';

// ServiceLocator Import für DI
import '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import '../../core/services/auth_service.dart';
import '../../core/services/world_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';

// ServiceLocator Import für DI
import '../../main.dart';
```

### 🏷️ BUTTON

**buttonWeltVerlassen** 🔥 (Confidence: 0.9)
- 📁 `lib\features\world\world_list_page.dart:252:27`
- 📝 Original: `'Welt verlassen?'`
- 🎯 Widget: Widget: AlertDialog
- 🔧 Context:
```dart
final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
```

### 🏷️ AUTH

**authInitialisiereApp** 🔥 (Confidence: 0.8)
- 📁 `lib\app.dart:20:9`
- 📝 Original: `'Initialisiere App...'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
timeout: const Duration(seconds: 8),
      onTimeout: _onTimeout,
      initSteps: const [
        'Initialisiere App...',
        'Lade Konfiguration...',
        'Starte Services...',
        'Prüfe Authentifizierung...',
```

**authReturnServiceAs** 🔥 (Confidence: 0.8)
- 📁 `lib\main.dart:6:125`
- 📝 Original: `');
    }
    return service as T;
  }

  static bool has<T>() {
    return _services.containsKey(T);
  }

  static void clear() {
    _services.clear();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere das Logging-System
  AppLogger.initialize();
  AppLogger.app.i(AppLocalizations.of(context)!.errorWeltenwindappWirdGestartet);

  // Flutter Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.logError(
      '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import 'package:flutter/foundation.dart';
import 'app.dart';
import 'config/logger.dart';
import '../l10n/app_localizations.dartAppLocalizations.of(context)!.uiServicecontainerFürDependencyService $T not registered');
    }
    return service as T;
  }
```

### 🏷️ BUTTON

**buttonWirdZurückgezogen** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:857:53`
- 📝 Original: `'Wird zurückgezogen...'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                    icon: const Icon(Icons.cancel),
                    label: Text(_isPreRegistering ? 'Wird zurückgezogen...' : AppLocalizations.of(context)!.buttonVorregistrierungZurückziehen),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
```

**buttonWirdVerlassen** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:925:46`
- 📝 Original: `'Wird verlassen...'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _leaveWorld,
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(_isJoining ? 'Wird verlassen...' : 'Welt verlassen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
```

**buttonWirdBeigetreten** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:946:46`
- 📝 Original: `'Wird beigetreten...'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _joinWorld,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_isJoining ? 'Wird beigetreten...' : AppLocalizations.of(context)!.buttonJetztBeitreten),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
```

### 🏷️ ERROR

**errorInitialisierungAbgeschlossen** 🔥 (Confidence: 0.8)
- 📁 `lib\app.dart:77:23`
- 📝 Original: `'✅ Initialisierung abgeschlossen'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
// Auth-Cache beim App-Start invalidieren
      AppRouter.invalidateCacheOnStart();
      
      AppLogger.app.i('✅ Initialisierung abgeschlossen');
    } catch (e) {
      AppLogger.app.e('❌ Service-Initialisierung fehlgeschlagen', error: e);
      // Bei Auth-Service-Fehlern einfach weitermachen
```

### 🏷️ UI

**uiHeaders_headersReturn** 🔥 (Confidence: 0.8)
- 📁 `lib\core\services\api_service.dart:65:62`
- 📝 Original: `'),
          headers: _headers,
        );
    }
    return http.Response(AppLocalizations.of(context)!.uiRequestRetryFailed, 500);
  }

  Future<http.Response> deleteWithBody(String endpoint, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    // Erweiterte Request-Kontext-Verwaltung für parallele Requests
    _requestBodies[endpoint] = data;
    
    // Automatische Token-Validierung für geschützte Endpoints
    if (!endpoint.startsWith('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
return await http.put(
            Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpointAppLocalizations.of(context)!.uiHeaders_headersBodyDELETE':
        return await http.delete(
          Uri.parse('${Env.apiUrl}${Env.apiBasePath}$endpoint'),
          headers: _headers,
        );
    }
```

**uiStyleThemeofcontexttextthemeheadlinemediumcopywithColor** 🔥 (Confidence: 0.8)
- 📁 `lib\features\auth\reset_password_page.dart:106:133`
- 📝 Original: `',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              Text(
                                _isSuccess 
                                  ? AppLocalizations.of(context)!.uiDuWirstAutomatisch
                                  : AppLocalizations.of(context)!.uiBitteGibDein,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              
                              // Success Animation
                              if (_isSuccess)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 64,
                                    color: Colors.green,
                                  ),
                                ),
                              
                              // Password fields
                              if (!_isSuccess) ...[
                                // New Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  autofillHints: const [AutofillHints.newPassword],
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (!_hasInteractedWithPassword) {
                                      setState(() {
                                        _hasInteractedWithPassword = true;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
const SizedBox(height: 20),
                              
                              Text(
                                _isSuccess ? AppLocalizations.of(context)!.uiPasswortErfolgreichGeändert : 'Neues Passwort festlegen',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
```

**uiDescriptionApplocalizationsofcontextuisammleerfolgeundColor** 🔥 (Confidence: 0.8)
- 📁 `lib\features\landing\landing_page.dart:277:56`
- 📝 Original: `',
                                    description: AppLocalizations.of(context)!.uiSammleErfolgeUnd,
                                    color: Colors.amber,
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 80),
                          
                          // Final CTA
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  AppTheme.primaryColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  AppLocalizations.of(context)!.uiBereitFürDein,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.worldSchließeDichTausenden,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[300],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () => context.goNamed('`
- 🎯 Widget: Widget: Card
- 🔧 Context:
```dart
),
                                  _buildFeatureCard(
                                    icon: Icons.star,
                                    title: 'Belohnungen',
                                    description: AppLocalizations.of(context)!.uiSammleErfolgeUnd,
                                    color: Colors.amber,
                                  ),
```

**uiStyleTextstyleColor** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\widgets\world_card.dart:34:79`
- 📝 Original: `',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final List<Widget> buttons = [];
    
    // Status-basierte Button-Logik
    switch (world.status) {
      case WorldStatus.upcoming:
        // Vorregistrierung oder Zurückziehen
        if (isPreRegistered) {
          if (onCancelPreRegistration != null) {
            buttons.add(_buildButton(
              onPressed: onCancelPreRegistration,
              icon: Icons.cancel,
              label: '`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      const SizedBox(width: 4),
                      Text(
                        'Ende: ${endDate.day}.${endDate.month}.${endDate.year}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
```

### 🏷️ WORLD

**worldDieAngeforderteWelt** 🔥 (Confidence: 0.8)
- 📁 `lib\routing\app_router.dart:282:21`
- 📝 Original: `'Die angeforderte Welt existiert nicht oder wurde entfernt.'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                  const SizedBox(height: 16),
                  Text(
                    'Die angeforderte Welt existiert nicht oder wurde entfernt.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
```

**worldSplashscreenInitialisierungTimeout** 🔥 (Confidence: 0.8)
- 📁 `lib\shared\widgets\splash_screen.dart:5:29`
- 📝 Original: `'⏰ SplashScreen Initialisierung timeout'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import '../../config/logger.dart';
import '../l10n/app_localizations.dartAppLocalizations.of(context)!.uiClassSplashscreenExtendsWeltenwindAppLocalizations.of(context)!.worldThislogoOverrideStatesplashscreensuccess'),
          Future.delayed(timeout).then((_) {
            AppLogger.app.w('⏰ SplashScreen Initialisierung timeout');
            return 'timeout';
          }),
        ]);
```

### 🏷️ BUTTON

**buttonWirdZurückgezogen** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:857:53`
- 📝 Original: `'Wird zurückgezogen...'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                    icon: const Icon(Icons.cancel),
                    label: Text(_isPreRegistering ? 'Wird zurückgezogen...' : AppLocalizations.of(context)!.buttonVorregistrierungZurückziehen),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
```

**buttonWirdVerlassen** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:925:46`
- 📝 Original: `'Wird verlassen...'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _leaveWorld,
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(_isJoining ? 'Wird verlassen...' : 'Welt verlassen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
```

**buttonWirdBeigetreten** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:946:46`
- 📝 Original: `'Wird beigetreten...'`
- 🎯 Widget: Widget: ElevatedButton
- 🔧 Context:
```dart
child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _joinWorld,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_isJoining ? 'Wird beigetreten...' : AppLocalizations.of(context)!.buttonJetztBeitreten),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
```

### 🏷️ NAVIGATION

**navigationServicelocatorImportFür** 🔥 (Confidence: 0.8)
- 📁 `lib\features\world\world_list_page.dart:17:37`
- 📝 Original: `';

// ServiceLocator Import für DI
import '`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import './widgets/world_card.dart';
import './widgets/world_filters.dart';

// ServiceLocator Import für DI
import '../../main.dart';
```

### 🏷️ ERROR

**errorBeitrittFehlgeschlagenVersuche** ⚠️ (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:235:24`
- 📝 Original: `'Beitritt fehlgeschlagen. Versuche es erneut.'`
- 🎯 Widget: Widget: Scaffold
- 🔧 Context:
```dart
}
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
```

**errorDieseEinladungIst** ⚠️ (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:249:24`
- 📝 Original: `'Diese Einladung ist abgelaufen.'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
} else if (e.toString().contains(AppLocalizations.of(context)!.errorNichtFürDeine)) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = AppLocalizations.of(context)!.errorEinFehlerIstException: ', '')}AppLocalizations.of(context)!.errorFinallySetstate_isjoiningErfolgreich für ${world.name} vorregistriert!AppLocalizations.of(context)!.worldBackgroundcolorColorsgreenElseFehler bei der Vorregistrierung';
        });
```

### 🏷️ UI

**ui1EnvironmentInitialisieren** ⚠️ (Confidence: 0.8)
- 📁 `lib\app.dart:40:38`
- 📝 Original: `');
    
    // 1. Environment initialisieren
    await Env.initialize();
    
    AppLogger.app.i('`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
// Korrekte Initialisierungsfunktion NACH App-Start
  Future<void> _initializeApp() async {
    AppLogger.app.i('🚀 App startet...');
    
    // 1. Environment initialisieren
    await Env.initialize();
```

**uiAnmeldungLäuft** ⚠️ (Confidence: 0.8)
- 📁 `lib\features\auth\login_page.dart:332:25`
- 📝 Original: `'Anmeldung läuft...'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      SizedBox(height: 16),
                      Text(
                        'Anmeldung läuft...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
```

**uiPasswortZurücksetzen** ⚠️ (Confidence: 0.8)
- 📁 `lib\features\auth\reset_password_page.dart:365:45`
- 📝 Original: `'Passwort zurücksetzen'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                                          )
                                        : const Text(
                                            'Passwort zurücksetzen',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
```

**uiDasDashboardBefindet** ⚠️ (Confidence: 0.8)
- 📁 `lib\features\dashboard\dashboard_page.dart:111:39`
- 📝 Original: `'Das Dashboard befindet sich noch im Aufbau.'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Das Dashboard befindet sich noch im Aufbau.',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 16,
```

**uiInitialisierungDauertLänger** ⚠️ (Confidence: 0.8)
- 📁 `lib\shared\widgets\splash_screen.dart:47:19`
- 📝 Original: `'Initialisierung dauert länger als erwartet...'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Text(
                  'Initialisierung dauert länger als erwartet...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
```

### 🏷️ WORLD

**worldNnDieseEinladung** ⚠️ (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:113:24`
- 📝 Original: `'\n\n❌ Diese Einladung ist am $dateStr abgelaufen.'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
if (isAccepted) {
        validityText = AppLocalizations.of(context)!.inviteNnDieseEinladung;
      } else if (isExpired) {
        validityText = '\n\n❌ Diese Einladung ist am $dateStr abgelaufen.';
      } else {
        validityText = '\n\n⏰ Gültig bis: $dateStrAppLocalizations.of(context)!.inviteFinalBaseinfotextDu wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
```

### 🏷️ AUTH

**authInitialisiereApp** ⚠️ (Confidence: 0.7)
- 📁 `lib\app.dart:20:9`
- 📝 Original: `'Initialisiere App...'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
timeout: const Duration(seconds: 8),
      onTimeout: _onTimeout,
      initSteps: const [
        'Initialisiere App...',
        'Lade Konfiguration...',
        'Starte Services...',
        'Prüfe Authentifizierung...',
```

### 🏷️ UI

**uiAnmeldungLäuft** ⚠️ (Confidence: 0.7)
- 📁 `lib\features\auth\login_page.dart:332:25`
- 📝 Original: `'Anmeldung läuft...'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      SizedBox(height: 16),
                      Text(
                        'Anmeldung läuft...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
```

**uiAnmeldungLäuft** ⚠️ (Confidence: 0.7)
- 📁 `lib\features\auth\login_page.dart:332:25`
- 📝 Original: `'Anmeldung läuft...'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                      SizedBox(height: 16),
                      Text(
                        'Anmeldung läuft...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
```

**uiMenüÖffnen** ⚠️ (Confidence: 0.7)
- 📁 `lib\shared\widgets\navigation_widget.dart:41:19`
- 📝 Original: `'Menü öffnen'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                ),
                Text(
                  'Menü öffnen',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
```

**uiInitialisierungDauertLänger** ⚠️ (Confidence: 0.7)
- 📁 `lib\shared\widgets\splash_screen.dart:47:19`
- 📝 Original: `'Initialisierung dauert länger als erwartet...'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Text(
                  'Initialisierung dauert länger als erwartet...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
```

### 🏷️ WORLD

**worldDieAngeforderteWelt** ⚠️ (Confidence: 0.7)
- 📁 `lib\routing\app_router.dart:282:21`
- 📝 Original: `'Die angeforderte Welt existiert nicht oder wurde entfernt.'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
),
                  const SizedBox(height: 16),
                  Text(
                    'Die angeforderte Welt existiert nicht oder wurde entfernt.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
```

### 🏷️ NAVIGATION

**navigationPrüfeAuthentifizierung** ⚠️ (Confidence: 0.6)
- 📁 `lib\app.dart:23:9`
- 📝 Original: `'Prüfe Authentifizierung...'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
'Initialisiere App...',
        'Lade Konfiguration...',
        'Starte Services...',
        'Prüfe Authentifizierung...',
        'Bereit!AppLocalizations.of(context)!.navigationAppnameEnvappnameChildde'), // German
          Locale('en'), // English
        ],
```

**navigationLadeKonfiguration** ⚠️ (Confidence: 0.6)
- 📁 `lib\app.dart:21:9`
- 📝 Original: `'Lade Konfiguration...'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
onTimeout: _onTimeout,
      initSteps: const [
        'Initialisiere App...',
        'Lade Konfiguration...',
        'Starte Services...',
        'Prüfe Authentifizierung...',
        'Bereit!AppLocalizations.of(context)!.navigationAppnameEnvappnameChildde'), // German
```

**navigationStarteServices** ⚠️ (Confidence: 0.6)
- 📁 `lib\app.dart:22:9`
- 📝 Original: `'Starte Services...'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
initSteps: const [
        'Initialisiere App...',
        'Lade Konfiguration...',
        'Starte Services...',
        'Prüfe Authentifizierung...',
        'Bereit!AppLocalizations.of(context)!.navigationAppnameEnvappnameChildde'), // German
          Locale('en'), // English
```

**navigationPrüfeAuthentifizierung** ⚠️ (Confidence: 0.6)
- 📁 `lib\app.dart:23:9`
- 📝 Original: `'Prüfe Authentifizierung...'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
'Initialisiere App...',
        'Lade Konfiguration...',
        'Starte Services...',
        'Prüfe Authentifizierung...',
        'Bereit!AppLocalizations.of(context)!.navigationAppnameEnvappnameChildde'), // German
          Locale('en'), // English
        ],
```

### 🏷️ UI

**uiAppStartet** ❓ (Confidence: 0.6)
- 📁 `lib\app.dart:40:21`
- 📝 Original: `'🚀 App startet...'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
// Korrekte Initialisierungsfunktion NACH App-Start
  Future<void> _initializeApp() async {
    AppLogger.app.i('🚀 App startet...');
    
    // 1. Environment initialisieren
    await Env.initialize();
```

**uiDasDashboardBefindet** ❓ (Confidence: 0.6)
- 📁 `lib\features\dashboard\dashboard_page.dart:111:39`
- 📝 Original: `'Das Dashboard befindet sich noch im Aufbau.'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Das Dashboard befindet sich noch im Aufbau.',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 16,
```

**uiInitialisierungDauertLänger** ❓ (Confidence: 0.6)
- 📁 `lib\shared\widgets\splash_screen.dart:47:19`
- 📝 Original: `'Initialisierung dauert länger als erwartet...'`
- 🎯 Widget: Widget: Text
- 🔧 Context:
```dart
border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Text(
                  'Initialisierung dauert länger als erwartet...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
```

