# Weltenwind systemd Services

Dieser Ordner enthält alle systemd Service-Definitionen für das Weltenwind-Projekt.

## Inhalt

### Service-Definitionen
- `weltenwind-backend.service` - Backend API Service (mit Health-Checks)
- `weltenwind-docs.service` - Swagger Dokumentation Service  
- `weltenwind-studio.service` - Prisma Studio Service
- `weltenwind.target` - Gruppiert alle Services

### Setup & Management Scripts
- `setup-systemd-service.sh` - Installations-Script
- `setup-logging.sh` - Logging-Setup Script
- `setup-monitoring.sh` - **NEU:** Monitoring-Stack Setup (Uptime Kuma + Netdata)
- `health-check.sh` - **NEU:** Umfassendes Health-Check-Script
- `check-ports.sh` - Port-Status prüfen
- `stop-old-services.sh` - Services sauber stoppen

### Konfigurationsdateien
- `weltenwind-logrotate.conf` - Log-Rotation Konfiguration
- `SYSTEMD-SERVICE.md` - Ausführliche Dokumentation

## Quick Start

```bash
cd /srv/weltenwind/backend/services

# 1. Basis-Services installieren
chmod +x setup-systemd-service.sh
sudo ./setup-systemd-service.sh

# 2. Logging konfigurieren
chmod +x setup-logging.sh
sudo ./setup-logging.sh

# 3. Services starten
sudo systemctl start weltenwind.target
```

## Logging-System

Das Weltenwind-Backend verwendet **duales Logging**:

### systemd Standard-Logs (stdout/stderr):
- `/var/log/weltenwind/backend.log` - Standard-Output
- `/var/log/weltenwind/backend.error.log` - Error-Output

### Winston Structured Logs (JSON):
- `/var/log/weltenwind/app.log` - Alle strukturierten Logs
- `/var/log/weltenwind/auth.log` - Authentifizierung & Authorization
- `/var/log/weltenwind/security.log` - Sicherheitsereignisse
- `/var/log/weltenwind/api.log` - API-Requests & Performance
- `/var/log/weltenwind/error.log` - Nur Fehler

### Log-Rotation:
- **Automatisch täglich** via `logrotate`
- **30 Tage Aufbewahrung**
- **Komprimierung** nach Rotation
- **Konfiguration:** `/etc/logrotate.d/weltenwind`

### Log-Viewer Web-UI:
- **URL:** `http://your-server:3000/log-viewer/`
- **Berechtigung:** Nur Admins (`system.logs` Permission)
- **Features:** Real-time, Filterung, Auto-Refresh

## Wichtige Befehle

```bash
# Alle Services neu starten
sudo systemctl restart weltenwind.target

# Nur Backend neu starten  
sudo systemctl restart weltenwind-backend

# Live-Logs verfolgen
sudo tail -f /var/log/weltenwind/app.log
sudo tail -f /var/log/weltenwind/security.log

# Log-Größen prüfen
sudo du -sh /var/log/weltenwind/*

# Service-Status prüfen
sudo systemctl status weltenwind.target
sudo systemctl status weltenwind-backend

# Logs der letzten Stunde anzeigen
sudo journalctl -u weltenwind-backend --since "1 hour ago"

# Log-Rotation manuell testen
sudo logrotate -f /etc/logrotate.d/weltenwind
```

## Environment-spezifisches Verhalten

### Development (`NODE_ENV=development`):
- ✅ Console-Ausgabe aktiviert
- ✅ Logs nach `./logs/` (lokales Verzeichnis)
- ✅ Debug-Level aktiviert
- ✅ Kleinere Log-Dateien (50MB)

### Production (`NODE_ENV=production`):
- ✅ Keine Console-Ausgabe  
- ✅ Logs nach `/var/log/weltenwind/`
- ✅ Info-Level (konfigurierbar)
- ✅ Größere Log-Dateien (100MB)
- ✅ Automatische Log-Rotation

## Troubleshooting

```bash
# Service funktioniert nicht?
sudo systemctl status weltenwind-backend -l

# Logs nicht sichtbar?
ls -la /var/log/weltenwind/
sudo chown weltenwind:weltenwind /var/log/weltenwind/*.log

# Winston-Fehler?
grep -i winston /var/log/weltenwind/backend.error.log

# Web-UI nicht erreichbar?
curl http://localhost:3000/api/logs/stats
``` 