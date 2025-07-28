# Weltenwind als systemd Services

Diese Anleitung erklärt, wie alle Weltenwind Services (Backend, Docs, Studio) als systemd Services eingerichtet werden.

## Übersicht

Das Weltenwind-Projekt besteht aus drei Services:
- **Backend API** - Die Hauptanwendung (Port 3000)
- **Swagger Docs** - API-Dokumentation (Port 3001)
- **Prisma Studio** - Datenbank-Admin-Tool (Port 5555)

## Vorteile eines systemd Services

- Automatischer Start beim Booten
- Automatischer Neustart bei Abstürzen
- Einfaches Management mit `systemctl`
- Zentrale Log-Verwaltung
- Bessere Security durch dedizierte User/Gruppe

## Service-Dateien

Alle Service-Dateien befinden sich im Ordner `backend/services/`:

1. **weltenwind-backend.service** - Backend API Service
2. **weltenwind-docs.service** - Swagger Editor Service
3. **weltenwind-studio.service** - Prisma Studio Service
4. **weltenwind.target** - Target-Unit die alle Services gruppiert
5. **setup-systemd-service.sh** - Automatisches Setup-Script

## Installation

### 1. Pfade prüfen

Die Services sind konfiguriert für:
- Backend-Verzeichnis: `/srv/weltenwind/backend`
- Services-Verzeichnis: `/srv/weltenwind/backend/services`
- Log-Verzeichnis: `/var/log/weltenwind`
- Service-User: `weltenwind`

Falls deine Pfade anders sind, passe die Service-Dateien entsprechend an.

### 2. Setup-Script ausführen

```bash
cd /srv/weltenwind/backend/services
chmod +x setup-systemd-service.sh
sudo ./setup-systemd-service.sh
```

## Verwendung

### Alle Services gemeinsam verwalten

```bash
# Alle Services starten
sudo systemctl start weltenwind.target

# Alle Services stoppen
sudo systemctl stop weltenwind.target

# Alle Services neu starten
sudo systemctl restart weltenwind.target

# Status aller Services
sudo systemctl status weltenwind.target
```

### Einzelne Services verwalten

```bash
# Nur Backend neu starten
sudo systemctl restart weltenwind-backend

# Nur Docs neu starten
sudo systemctl restart weltenwind-docs

# Nur Studio neu starten
sudo systemctl restart weltenwind-studio
```

### Logs anzeigen

```bash
# systemd Journal (live)
sudo journalctl -u weltenwind-backend -f
sudo journalctl -u weltenwind-docs -f
sudo journalctl -u weltenwind-studio -f

# Application Logs
tail -f /var/log/weltenwind/backend.log
tail -f /var/log/weltenwind/docs.log
tail -f /var/log/weltenwind/studio.log
```

### Service beim Boot aktivieren/deaktivieren

```bash
# Alle Services beim Boot starten
sudo systemctl enable weltenwind.target

# Einzelnen Service deaktivieren
sudo systemctl disable weltenwind-studio
```

## Service-URLs

Nach dem Start sind die Services erreichbar unter:

- Backend API: http://192.168.2.168:3000
- Swagger Docs: http://192.168.2.168:3001
- Prisma Studio: http://192.168.2.168:5555

## Troubleshooting

### Service startet nicht

1. Prüfe die Logs:
   ```bash
   sudo journalctl -u weltenwind-backend -n 50
   ```

2. Prüfe Berechtigungen:
   ```bash
   ls -la /srv/weltenwind/backend
   ls -la /srv/weltenwind/node_modules
   ```

3. Prüfe ob .env existiert:
   ```bash
   ls -la /srv/weltenwind/backend/.env
   ```

### Permission Denied Fehler

```bash
# Backend-Verzeichnis
sudo chown -R weltenwind:weltenwind /srv/weltenwind/backend

# Wichtig: auch node_modules!
sudo chown -R weltenwind:weltenwind /srv/weltenwind/node_modules
```

### Port bereits belegt

```bash
# Prüfe welcher Prozess den Port belegt
sudo lsof -i :3000
sudo lsof -i :3001
sudo lsof -i :5555

# Alte Prozesse beenden
sudo pkill -f "npm run dev"
sudo pkill -f "npx serve"
sudo pkill -f "prisma studio"
```

## Migration von den alten Start-Scripts

Falls du vorher die `start-*.sh` Scripts verwendet hast:

1. **Stoppe alle laufenden Prozesse**:
   ```bash
   cd /srv/weltenwind/backend/services
   chmod +x stop-old-services.sh
   sudo ./stop-old-services.sh
   ```

2. **Führe das Setup-Script aus**:
   ```bash
   sudo ./setup-systemd-service.sh
   ```

3. **Starte die neuen systemd Services**:
   ```bash
   sudo systemctl start weltenwind.target
   ```

Die alten Start-Scripts (`start-api.sh`, `start-docs.sh`, `start-studio.sh`) wurden bereits entfernt

## Sicherheitshinweise

- Die Services laufen mit eingeschränkten Rechten (dedizierter User)
- Sensible Daten gehören in die .env Datei
- Logs werden zentral in `/var/log/weltenwind/` gespeichert
- Services haben nur Zugriff auf notwendige Verzeichnisse 