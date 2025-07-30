# 🎯 Manueller i18n-Umsetzungsplan (Phase 1)

## Problem-Analyse
- ❌ 415 chaotische AppLocalizations-Keys im Code
- ✅ ~30-50 echte deutsche UI-Strings identifiziert
- 🎯 Ziel: Saubere, lesbare Keys + echte Übersetzungen

## Phase 1: Core UI-Strings (Top Priority)

### 🚪 Auth/Login-Bereich
| Deutscher String | Sauberer Key | Englische Übersetzung |
|------------------|--------------|----------------------|
| `'Anmelden'` | `authLoginButton` | `'Login'` |
| `'Registrieren'` | `authRegisterButton` | `'Register'` |
| `'E-Mail'` | `authEmailLabel` | `'Email'` |
| `'Passwort'` | `authPasswordLabel` | `'Password'` |
| `'Neues Passwort'` | `authNewPasswordLabel` | `'New Password'` |
| `'Passwort zurücksetzen'` | `authResetPasswordButton` | `'Reset Password'` |

### 🌍 World/Gaming-Bereich
| Deutscher String | Sauberer Key | Englische Übersetzung |
|------------------|--------------|----------------------|
| `'Vorregistrieren'` | `worldPreRegisterButton` | `'Pre-register'` |
| `'Beitreten'` | `worldJoinButton` | `'Join'` |
| `'Zurückziehen'` | `worldCancelButton` | `'Cancel'` |
| `'Welt verlassen'` | `worldLeaveButton` | `'Leave World'` |
| `'Einladung senden'` | `worldSendInviteButton` | `'Send Invite'` |

### 🚨 Error/Status-Bereich  
| Deutscher String | Sauberer Key | Englische Übersetzung |
|------------------|--------------|----------------------|
| `'Fehler beim Laden'` | `errorLoadingFailed` | `'Loading failed'` |
| `'Wird geladen...'` | `loadingText` | `'Loading...'` |
| `'Unbekannter Fehler'` | `errorUnknown` | `'Unknown error'` |
| `'Netzwerkfehler'` | `errorNetwork` | `'Network error'` |

### 🔘 Universal-Buttons
| Deutscher String | Sauberer Key | Englische Übersetzung |
|------------------|--------------|----------------------|
| `'Abbrechen'` | `buttonCancel` | `'Cancel'` |
| `'OK'` | `buttonOk` | `'OK'` |
| `'Speichern'` | `buttonSave` | `'Save'` |
| `'Zurück'` | `buttonBack` | `'Back'` |
| `'Weiter'` | `buttonNext` | `'Next'` |

## Phase 1 Umsetzung (Schrittweise):

### Schritt 1: Core .arb-Keys hinzufügen ✅
- Die 25-30 wichtigsten Keys zu `app_de.arb` und `app_en.arb` hinzufügen
- Saubere, konsistente Namenskonvention: `kategorie` + `Zweck`

### Schritt 2: Code schrittweise umstellen
- **NICHT** alle 415 Keys auf einmal!
- Datei für Datei vorgehen, beginnend mit:
  1. `login_page.dart` (5-8 Strings)
  2. `register_page.dart` (5-8 Strings)  
  3. `world_join_page.dart` (10-15 Strings)
  4. `world_list_page.dart` (8-12 Strings)

### Schritt 3: Testen & Validieren
- Nach jeder Datei: `flutter gen-l10n` + Test
- Sicherstellen dass UI funktioniert
- Keine Bulk-Changes!

## Vorteile dieses Ansatzes:
- ✅ **Lesbare Keys**: `authLoginButton` statt `authPasswordIfResponsestatuscodeaccessToken`
- ✅ **Kontrolliert**: Datei für Datei, kein Chaos
- ✅ **Testbar**: Nach jedem Schritt funktionsfähig
- ✅ **Qualität**: Echte Übersetzungen statt Auto-Generated

## Anti-Pattern vermeiden:
- ❌ Bulk-Regex-Replacement 
- ❌ Auto-Generated Keys
- ❌ 415 Keys auf einmal
- ❌ Code-Fragmente als Keys