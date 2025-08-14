# 🌐 Internationalization (i18n)

Kurzanleitung für Internationalisierung im Flutter-Client.

---

## 📦 Setup

- ARB-Dateien unter `client/lib/l10n/`:
  - `app_de.arb`, `app_en.arb`
- Generator:
  - `flutter gen-l10n`

---

## 🔧 Nutzung im Code

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.buttonLogin);
Text(l10n.welcomeMessage(userName));
```

Parameter/Plural-Beispiele in den ARB-Kommentaren dokumentieren.

---

## 🔑 Keys & Konventionen

- Keine hardcodierten UI-Texte im Code.
- Keys nach Kontext gruppieren (auth.*, world.*, common.*).
- Beschreibungen (`@key`) für Übersetzer pflegen.

---

## 🧪 Checks

- `flutter gen-l10n` ohne Fehler.
- UI manuell mit DE/EN prüfen.

---

Letzte Aktualisierung: Januar 2025

