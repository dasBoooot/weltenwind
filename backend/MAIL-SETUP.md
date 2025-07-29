# 📧 Microsoft Mail-Konfiguration für Weltenwind

## 🎯 Übersicht

Weltenwind kann automatisch E-Mails versenden für:
- **🎫 Welt-Einladungen** mit direkten Join-Links
- **🔒 Passwort-Reset** mit sicheren Reset-Links

## 🔧 Setup-Schritte

### 1. App-Passwort erstellen (Microsoft/Outlook)

Da Microsoft 2FA erfordert, musst du ein App-Passwort erstellen:

1. **Gehe zu:** https://account.microsoft.com/security
2. **Klicke auf:** "Erweiterte Sicherheitsoptionen" 
3. **Wähle:** "App-Passwort erstellen"
4. **App-Typ:** "E-Mail" auswählen
5. **Generieren:** 16-stelliges Passwort kopieren
6. **Wichtig:** Verwende dieses App-Passwort, NICHT dein normales Passwort!

### 2. .env Datei konfigurieren

Kopiere diese Werte in deine `backend/.env` Datei:

```bash
# Microsoft/Outlook SMTP
MAIL_HOST="smtp-mail.outlook.com"
MAIL_PORT="587"
MAIL_SECURE="false"
MAIL_USER="deine-email@outlook.com"
MAIL_PASS="dein-16-stelliges-app-passwort"
MAIL_FROM="deine-email@outlook.com"
MAIL_FROM_NAME="Weltenwind"

# URL für Links in E-Mails
BASE_URL="http://192.168.2.168:3000"
```

### 3. Konfiguration testen

```bash
cd backend
node test-mail-config.js
```

**Erwartete Ausgabe:**
```
📧 Teste Mail-Konfiguration...
✅ SMTP-Verbindung erfolgreich!
✅ Test-E-Mail erfolgreich versendet!
🎯 ERFOLGREICH! Deine Mail-Konfiguration funktioniert!
```

## 📧 Alternative: Gmail

Für Gmail verwende diese Einstellungen:

```bash
MAIL_HOST="smtp.gmail.com"
MAIL_PORT="587"
MAIL_SECURE="false"
MAIL_USER="deine-email@gmail.com"
MAIL_PASS="dein-gmail-app-passwort"
```

**Gmail App-Passwort erstellen:**
1. Google Account → Sicherheit
2. 2-Schritt-Bestätigung aktivieren
3. App-Passwörter → "E-Mail" auswählen
4. Generiertes Passwort verwenden

## 🎨 E-Mail Templates

### Invite-Mail Features:
- 🌍 Gradient-Header mit Welt-Info
- 🚀 Direkter "Welt beitreten" Button
- 👤 Einlader-Name (falls vorhanden)
- 📱 Responsive Design
- ⚡ Deep-Link ins Game

### Password-Reset Features:
- 🔒 Security-Fokussiertes Design
- ⚠️ Sicherheitshinweise prominent
- 🔑 Direkter Reset-Button
- ⏰ Token-Gültigkeit (24h)
- 🛡️ Anti-Phishing Infos

## 🧪 Testing

### Invite-Mail testen:
1. Als normaler User anmelden
2. Welt auswählen → "Einladen" Button
3. E-Mail eingeben → Senden
4. Postfach prüfen

### Password-Reset testen:
1. Auf Login-Seite: "Passwort vergessen?"
2. E-Mail eingeben → Reset anfordern
3. Postfach prüfen
4. Reset-Link klicken

## ⚠️ Troubleshooting

### Häufige Probleme:

**"Invalid login"**
- ✅ App-Passwort verwenden (nicht normales Passwort)
- ✅ E-Mail-Adresse korrekt schreiben
- ✅ 2FA aktiviert?

**"Connection refused"**
- ✅ Internet-Verbindung prüfen
- ✅ Firewall-Einstellungen (Port 587)
- ✅ VPN aus?

**"Authentication failed"**
- ✅ Microsoft-Konto entsperrt?
- ✅ App-Passwort abgelaufen?
- ✅ Outlook.com vs Hotmail.com?

### Debug-Tipps:

```bash
# Detaillierte Logs anzeigen
tail -f logs/app.log | grep "Mail"

# Test-Script mit Debug-Info
DEBUG=* node test-mail-config.js
```

## 🚀 Production Setup

Für Production empfohlene Änderungen:

```bash
# Professional Mail Service
MAIL_HOST="smtp.office365.com"  # Business-Accounts
MAIL_FROM_NAME="Dein Spielename"
BASE_URL="https://deine-domain.com"

# Security
MAIL_SECURE="true"  # Nur für Port 465
MAIL_PORT="465"     # Für SSL
```

## 📊 Mail-Statistiken

Das System loggt automatisch:
- ✅ Erfolgreich versendete Mails
- ❌ Fehlgeschlagene Versuche
- 📊 Mail-Types (Invite/Reset)
- 🕐 Timestamps und Empfänger

**Logs einsehen:**
```bash
# Web-Interface
http://192.168.2.168:3000/api/logs/viewer

# CLI
grep "Mail" logs/app.log
```

## 🎉 Fertig!

Nach erfolgreicher Konfiguration:
- **Invites** werden automatisch per Mail versendet
- **Password-Resets** funktionieren ohne weitere Aktion
- **Professionelle E-Mails** mit Weltenwind-Branding
- **Sichere Token-Links** mit Ablaufzeit

**Viel Spaß beim Testen!** 🚀