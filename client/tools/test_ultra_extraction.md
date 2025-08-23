# 🌍 Weltenwind i18n String Extraction Report

**Gesamt gefunden:** 33 Strings
**Neue Strings:** 33 (noch nicht in .arb)
**Bereits vorhanden:** 0

## 📊 Kategorien

- **auth**: 2 Strings
- **button**: 6 Strings
- **error**: 11 Strings
- **navigation**: 3 Strings
- **ui**: 9 Strings
- **world**: 2 Strings

## 🎯 Konfidenz-Verteilung

- **Hoch (≥80%)**: 23 Strings ✅
- **Mittel (60-79%)**: 10 Strings ⚠️
- **Niedrig (<60%)**: 0 Strings ❓

## 📝 Quote-Types

- **'-Quotes**: 33 Strings

## 🔍 Neue Strings (Priorität: Hoch → Niedrig)

### 🏷️ BUTTON

**buttonWirdZurückgezogen** 🔥 (Confidence: 1.0)
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

**buttonWirdZurückgezogen** 🔥 (Confidence: 1.0)
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

### 🏷️ ERROR

**errorÖffentlicheEinladungFehlgeschlagen** 🔥 (Confidence: 1.0)
- 📁 `lib\core\services\invite_service.dart:99:23`
- 📝 Original: `'Öffentliche Einladung fehlgeschlagen: $e'`
- 🎯 Widget: Widget: unknown
- 🔧 Context:
```dart
if (e is Exception) {
        rethrow;
      }
      throw Exception('Öffentliche Einladung fehlgeschlagen: $e');
    }
  }
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

### 🏷️ WORLD

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

### 🏷️ BUTTON

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

### 🏷️ ERROR

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

**uiPasswortZurücksetzen** 🔥 (Confidence: 0.9)
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

### 🏷️ AUTH

**authInitialisiereApp** 🔥 (Confidence: 0.9)
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

**buttonWirdVerlassen** 🔥 (Confidence: 0.9)
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

**buttonWirdBeigetreten** 🔥 (Confidence: 0.9)
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

**errorInitialisierungAbgeschlossen** 🔥 (Confidence: 0.9)
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

### 🏷️ WORLD

**worldSplashscreenInitialisierungTimeout** 🔥 (Confidence: 0.9)
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

### 🏷️ ERROR

**errorBeitrittFehlgeschlagenVersuche** 🔥 (Confidence: 0.9)
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

**errorDieseEinladungIst** 🔥 (Confidence: 0.9)
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

**uiAnmeldungLäuft** 🔥 (Confidence: 0.8)
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

**uiPasswortZurücksetzen** 🔥 (Confidence: 0.8)
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

### 🏷️ AUTH

**authInitialisiereApp** ⚠️ (Confidence: 0.8)
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

**uiMenüÖffnen** ⚠️ (Confidence: 0.8)
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

### 🏷️ NAVIGATION

**navigationLadeKonfiguration** ⚠️ (Confidence: 0.7)
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

**navigationStarteServices** ⚠️ (Confidence: 0.7)
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

**navigationPrüfeAuthentifizierung** ⚠️ (Confidence: 0.7)
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

**uiAppStartet** ⚠️ (Confidence: 0.7)
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

**uiDasDashboardBefindet** ⚠️ (Confidence: 0.7)
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

