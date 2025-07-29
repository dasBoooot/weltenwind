# JWT Security Konfiguration

## Übersicht

Die Weltenwind API verwendet JSON Web Tokens (JWT) für die Authentifizierung. Die Sicherheit dieser Tokens hängt maßgeblich vom verwendeten Secret ab.

## JWT Secret Generierung

### Automatische Generierung

```bash
npm run generate-jwt-secret
```

Dieses Script:
- Generiert ein kryptografisch sicheres 512-Bit Secret
- Fügt es automatisch zur `.env` Datei hinzu
- Warnt bei bestehendem Secret (um versehentliches Überschreiben zu verhindern)

### Manuelle Generierung

Falls du das Secret manuell generieren möchtest:

```bash
# Linux/Mac
openssl rand -base64 64

# Node.js
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
```

## Sicherheitsanforderungen

Das JWT Secret muss:
- **Mindestens 32 Zeichen lang sein** (256-Bit Sicherheit)
- **Zufällig generiert sein** (keine Wörter oder Phrasen)
- **Geheim bleiben** (niemals in Git committen)
- **Umgebungsspezifisch sein** (unterschiedlich für Dev/Staging/Prod)

## Konfiguration

In der `.env` Datei:

```env
JWT_SECRET="dein-sehr-langes-und-sicheres-secret-hier"
```

## Sicherheitsprüfungen

Die Anwendung prüft beim Start automatisch:
1. **Existenz**: JWT_SECRET muss definiert sein
2. **Länge**: Mindestens 32 Zeichen
3. **Unsichere Werte**: Verhindert bekannte Test-Secrets wie "dev-secret"

Bei Fehlern wird die Anwendung nicht gestartet.

## Token-Lebensdauer

- **Access Token**: 15 Minuten
- **Refresh Token**: 7 Tage

## Wichtige Hinweise

### Bei Secret-Änderung

⚠️ **WARNUNG**: Wenn das JWT_SECRET geändert wird:
- Alle bestehenden Sessions werden ungültig
- Alle User müssen sich neu einloggen
- API-Integrationen müssen neue Tokens anfordern

### Backup

- Sichere das JWT_SECRET in einem Passwort-Manager
- Dokumentiere es sicher für das Operations-Team
- Halte ein Backup für Notfälle bereit

### Rotation

Empfohlene Secret-Rotation:
- **Produktion**: Alle 90 Tage
- **Nach Sicherheitsvorfällen**: Sofort
- **Bei Mitarbeiterwechsel**: Nach Bedarf

## Fehlerbehebung

### "JWT_SECRET ist nicht definiert"

```bash
# Secret generieren
npm run generate-jwt-secret

# Oder manuell zur .env hinzufügen
echo 'JWT_SECRET="your-secure-secret"' >> .env
```

### "JWT_SECRET ist zu kurz"

Das Secret muss mindestens 32 Zeichen lang sein. Generiere ein neues:

```bash
npm run generate-jwt-secret
```

### "JWT_SECRET ist unsicher"

Verwende niemals Standard-Secrets wie "dev-secret" oder "changeme". Diese werden automatisch abgelehnt.

## Best Practices

1. **Verwende Environment-Variablen** - Niemals Secrets im Code
2. **Rotiere regelmäßig** - Besonders nach Personal-Änderungen
3. **Überwache Zugriff** - Logge wer Zugriff auf Secrets hat
4. **Verwende sichere Übertragung** - Nur über verschlüsselte Kanäle teilen
5. **Dokumentiere Änderungen** - Wann und warum wurde rotiert?