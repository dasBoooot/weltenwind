# Weltenwind systemd Services

Dieser Ordner enthält alle systemd Service-Definitionen für das Weltenwind-Projekt.

## Inhalt

- `weltenwind-backend.service` - Backend API Service
- `weltenwind-docs.service` - Swagger Dokumentation Service  
- `weltenwind-studio.service` - Prisma Studio Service
- `weltenwind.target` - Gruppiert alle Services
- `setup-systemd-service.sh` - Installations-Script
- `SYSTEMD-SERVICE.md` - Ausführliche Dokumentation

## Quick Start

```bash
cd /srv/weltenwind/backend/services
chmod +x setup-systemd-service.sh
sudo ./setup-systemd-service.sh
sudo systemctl start weltenwind.target
```

## Wichtige Befehle

```bash
# Alle Services neu starten
sudo systemctl restart weltenwind.target

# Nur Backend neu starten  
sudo systemctl restart weltenwind-backend

# Status prüfen
sudo systemctl status weltenwind.target

# Logs anzeigen
sudo journalctl -u weltenwind-backend -f
```

Für detaillierte Informationen siehe [SYSTEMD-SERVICE.md](./SYSTEMD-SERVICE.md) 