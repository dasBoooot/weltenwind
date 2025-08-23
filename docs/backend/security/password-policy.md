# Passwort-Policy

## Übersicht

Weltenwind verwendet eine erweiterte Passwort-Validierung basierend auf **zxcvbn** (entwickelt von Dropbox), die intelligenter ist als traditionelle Komplexitätsregeln.

## Mindestanforderungen

Ein Passwort muss:
- **Mindestens 8 Zeichen** lang sein
- **Mindestens Score 2** (Fair) auf der zxcvbn-Skala erreichen
- **Keine häufigen Passwörter** verwenden
- **Keinen Benutzernamen oder E-Mail** enthalten
- **Keine sehr offensichtlichen Tastaturmuster** (qwerty, 123456) enthalten
- **Keine übermäßigen Zeichenwiederholungen** (aaa, 111) haben
- **Keine aufeinanderfolgenden Zeichen** (abc, 123) - **ENTFERNT** (auf Benutzerwunsch)

## Passwort-Stärke-Skala

| Score | Stärke | Beschreibung | UI-Farbe |
|-------|--------|--------------|----------|
| 0 | Sehr schwach | Sofort knackbar | 🔴 Rot (#dc2626) |
| 1 | Schwach | Minuten bis Stunden | 🟠 Orange (#f59e0b) |
| 2 | Fair | Stunden bis Tage | 🟡 Gelb (#eab308) |
| 3 | Gut | Wochen bis Monate | 🟢 Hellgrün (#22c55e) |
| 4 | Stark | Jahre bis Jahrhunderte | 🟢 Dunkelgrün (#16a34a) |

## Intelligente Analyse

Die Passwort-Validierung erkennt:

### 🚫 Häufige Muster
- Top 10.000 häufigste Passwörter
- Wörterbuch-Wörter
- Namen und Nachnamen
- Sehr offensichtliche Tastaturmuster (qwerty, 123456)
- Wiederholungen (aaa, abcabc)
- Sequenzen (123, abc) - **ENTFERNT** (auf Benutzerwunsch)
- Jahreszahlen und Daten

### 🎯 Projekt-spezifische Wörter
- weltenwind
- mmorpg
- rollenspiel
- fantasy
- admin123, user123, test123

### 🔍 Persönliche Informationen
- Benutzername (und Teilstrings > 4 Zeichen)
- E-Mail-Adresse
- Variationen davon

## API-Endpoint

### Passwort-Stärke prüfen

```
POST /api/auth/check-password-strength
```

**Request:**
```json
{
  "password": "MyP@ssw0rd",
  "username": "john_doe",    // optional
  "email": "john@example.com" // optional
}
```

**Response:**
```json
{
  "valid": false,
  "score": 1,
  "feedback": [
    "Passwort ist zu schwach",
    "Dies ähnelt einem häufig verwendeten Passwort"
  ],
  "suggestions": [
    "Füge ein oder zwei weitere Wörter hinzu",
    "Vermeide häufige Passwörter"
  ],
  "estimatedCrackTime": "6 Stunden",
  "strengthText": "Schwach",
  "strengthPercentage": 40,
  "strengthColor": "#f59e0b"
}
```

## Best Practices für User

### ✅ Empfohlene Passwort-Strategien

1. **Passphrasen** (Beste Option)
   - Beispiel: `Korrekt-Pferd-Batterie-Klammer`
   - Leicht zu merken, sehr sicher

2. **Persönliche Sätze**
   - Beispiel: `IchKaufeJedenMorgen2Kaffee!`
   - Einzigartig und merkbar

3. **Zufällig generiert**
   - Beispiel: `xJ9#mK2$vL5!qR8&`
   - Sehr sicher, aber Passwort-Manager nötig

### ❌ Zu vermeiden

- `password123` - Zu häufig
- `qwerty123` - Tastaturmuster
- `JohnDoe2024` - Enthält Username
- `Welcome1!` - Zu vorhersehbar
- `aaaabbbb` - Wiederholungen
- `12345678` - Nur Zahlen

## Integration im Frontend

### Flutter/Web Client

Das Frontend sollte:
1. **Live-Validierung** während der Eingabe
2. **Visuelles Feedback** (Fortschrittsbalken mit Farbe)
3. **Konkrete Hinweise** aus der API anzeigen
4. **Positive Verstärkung** bei starken Passwörtern

### Beispiel-UI-Elemente

```dart
// Stärke-Anzeige
LinearProgressIndicator(
  value: strengthPercentage / 100,
  color: Color(int.parse(strengthColor.substring(1), radix: 16) + 0xFF000000),
)

// Feedback-Liste
Column(
  children: feedback.map((text) => 
    ListTile(
      leading: Icon(Icons.warning, color: Colors.orange),
      title: Text(text),
    )
  ).toList(),
)
```

## Entwickler-Hinweise

### Test-Script

```bash
node test-password-validation.js
```

Testet verschiedene Passwort-Szenarien und zeigt die Validierungs-Ergebnisse.

### Anpassungen

Die Konfiguration kann in `password-validation.service.ts` angepasst werden:
- `MIN_LENGTH`: Mindestlänge (Standard: 8)
- `MIN_SCORE`: Mindest-Score (Standard: 2)
- `ADDITIONAL_COMMON_PASSWORDS`: Projekt-spezifische häufige Passwörter

## Sicherheitsvorteile

1. **Intelligenter als Regex-Regeln**: Erkennt echte Schwächen statt formaler Regeln
2. **Benutzerfreundlich**: Gibt konkrete Verbesserungsvorschläge
3. **Mehrsprachig**: Feedback auf Deutsch übersetzt
4. **Kontext-bewusst**: Berücksichtigt Username/Email
5. **Wissenschaftlich fundiert**: Basiert auf Passwort-Cracking-Forschung