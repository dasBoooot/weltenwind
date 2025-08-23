# Development Troubleshooting Guide

## Swagger UI & Flutter Web App zeigen weiße Seite

### Problem
Die Swagger UI und die Flutter Web App (`/game`) zeigen nur eine weiße Seite. Browser-Konsole zeigt Fehler wie:
- `ERR_SSL_PROTOCOL_ERROR`
- Cross-Origin-Opener-Policy Warnungen
- Upgrade-Insecure-Requests Probleme

### Ursache
Die Security Headers sind für Production konfiguriert und zu strikt für Development:
- `upgrade-insecure-requests` zwingt Browser HTTPS zu verwenden
- HSTS ist aktiv
- Strikte COOP/COEP Policies

### Lösung

1. **NODE_ENV auf development setzen**
   ```bash
   # In der .env Datei:
   NODE_ENV=development
   ```

2. **Server neu starten**
   ```bash
   # In der VM:
   sudo systemctl restart weltenwind-backend
   
   # Oder für Development:
   npm run dev
   ```

3. **Verifizieren**
   - Die Security Headers sind in Development weniger strikt
   - CSP ist deaktiviert
   - HSTS ist deaktiviert
   - CORS erlaubt alle lokalen IPs

## CORS-Fehler bei lokalen IPs

### Problem
Zugriff von `192.168.x.x` wird von CORS blockiert.

### Lösung
Die neue CORS-Konfiguration erlaubt automatisch:
- `localhost` (alle Ports)
- `127.0.0.1` (alle Ports)
- `192.168.x.x` (alle lokalen IPs)
- `[::1]` (IPv6 localhost)

## Flutter Web App Build

### Build-Befehl
```bash
cd client
flutter build web --base-href /game/
```

### Deployment
Die gebauten Dateien werden automatisch von Express aus `client/build/web/` serviert.

## Security Headers in Production

In Production (`NODE_ENV=production`) werden alle Security Headers aktiviert:
- Content-Security-Policy
- Strict-Transport-Security (HSTS)
- X-Frame-Options
- Cross-Origin Policies
- Und weitere...

Stelle sicher, dass in Production:
1. HTTPS verwendet wird
2. `ALLOWED_ORIGINS` korrekt konfiguriert ist
3. JWT_SECRET sicher generiert wurde