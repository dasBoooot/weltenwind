# Weltenwind PVE Infrastructure Documentation

## Aktueller Stand (Januar 2025)

### Network Architecture
```
Proxmox VE Network Setup:
- Internal: 10.10.10.0/24 (VM-zu-VM Kommunikation)
- LAN: 192.168.2.0/24 (Zugriff von Workstation)

VMs:
- pve (Host): 10.10.10.10 / 192.168.2.10
- pg-primary: 10.10.10.11 / 192.168.2.11 (PostgreSQL Primary)
- pg-replica: 10.10.10.12 / 192.168.2.12 (PostgreSQL Replica) [TODO]
- vm-proxy: 10.10.10.13 / 192.168.2.13 (Nginx Reverse Proxy) [TODO]
- vm-app: 10.10.10.14 / 192.168.2.14 (Application Server) ✅
- vm-assets: 10.10.10.15 / 192.168.2.15 (Static Assets Server) [TODO]
- vm-grafana: 10.10.10.16 / 192.168.2.16 (Monitoring) [TODO]
- pbs: 10.10.10.20 / 192.168.2.20 (Proxmox Backup Server) [TODO]
```

### ✅ Bereits aufgebaut & funktionierend

#### PostgreSQL (pg-primary)
- Läuft als eigenständige VM
- `listen_addresses = '*'` → DB lauscht auf allen Interfaces
- `pg_hba.conf` angepasst: 
  - Zugriffe von 192.168.2.0/24 erlaubt
  - Zugriffe von App-VM (10.10.10.14) erlaubt
- User: `ww_app` mit Passwort `AAbb1234!!`
- Datenbanken:
  - `postgres` (Default)
  - `weltenwind` (Hauptdatenbank)
  - `weltenwind_shadow` (Shadow DB für Prisma)
- **Status**: Von App-VM erreichbar ✅

#### App-VM (vm-app, 10.10.10.14)
- Docker Compose Setup läuft
- Container:
  - `weltenwind-app` (Node/Express/Prisma Backend)
  - `weltenwind-redis` (Session Cache)
  - `weltenwind-pgbouncer` (Connection Pooling)
- Volumes:
  - `./src` → `/usr/src/app` (Code & Prisma-Schema)
  - `/srv/weltenwind/logs` (Logs)
  - `/srv/weltenwind/backups` (Backups)
- `.env` in `/src/.env` korrekt geladen
- Prisma:
  - **migrate**: läuft erfolgreich ✅
  - **seed**: schlägt fehl ❌ (Schema-Abweichungen)
- API Status:
  - `/api/health`: HTTP 500 ❌ (DB-Connection Issues)

### ⚠️ Offene Baustellen

#### 1. DB-Schema Inkonsistenz
**Problem**: Alte DB-Struktur vs. neue Prisma-Schema
- Alte Spalten vorhanden: `parent_theme`, `theme_bundle`, etc.
- Neue Spalten fehlen: `assets`
- **Lösung**: DB reset + frische Migration

#### 2. Workstation → DB Zugriff
**Problem**: Timeout von 192.168.2.x zu pg-primary
- pg_hba.conf ist konfiguriert ✅
- Vermutlich Proxmox Firewall oder NAT blockiert
- **Lösung**: PVE Firewall Rules prüfen

#### 3. Seed-Prozess
**Problem**: Bricht bei `prisma.world.upsert()` ab
- Ursache: Schema-Inkonsistenz
- **Lösung**: Nach DB-Reset erneut versuchen

#### 4. Health-Check API
**Problem**: `/api/health` liefert HTTP 500
- PagePermission Query schlägt fehl
- Connection zu pgbouncer instabil
- **Lösung**: Nach Migration/Seed erneut testen

## Migration Plan

### Phase 1: Arbeitsumgebung (JETZT)
1. SMB/SSHFS Mount einrichten (vm-app → Win11 Workstation)
2. SSH-Verbindung testen und optimieren
3. Entwicklungsworkflow etablieren

### Phase 2: DB Stabilisierung
1. Workstation-DB-Zugriff debuggen
2. DB komplett zurücksetzen
3. Aktuelle Migrationen anwenden
4. Seed-Daten erfolgreich einspielen

### Phase 3: Backend Stabilisierung
1. Health-Check zum Laufen bringen
2. Alle API-Endpoints testen
3. Logging & Monitoring aktivieren

### Phase 4: Frontend Integration
1. Frontend an neue Backend-URL anpassen
2. Asset-Handling über vm-assets
3. Nginx Reverse Proxy konfigurieren

### Phase 5: Production Ready
1. pg-replica Setup
2. Grafana Monitoring
3. Backup-Strategie mit PBS
4. SSL/TLS Zertifikate

## Credentials & Configs

### PostgreSQL
- Host: 10.10.10.11 (intern) / 192.168.2.11 (LAN)
- Port: 5432
- User: ww_app
- Password: AAbb1234!!
- Databases: weltenwind, weltenwind_shadow

### App-VM Docker
- Location: /srv/weltenwind/docker-compose.yml
- Env File: /src/.env
- Logs: /srv/weltenwind/logs
- Backups: /srv/weltenwind/backups

## Commands Cheatsheet

```bash
# SSH zur App-VM
ssh user@10.10.10.14

# Docker Status
docker-compose -f /srv/weltenwind/docker-compose.yml ps

# Prisma Migrations
docker exec weltenwind-app npx prisma migrate deploy

# DB Zugriff testen
psql -h 10.10.10.11 -U ww_app -d weltenwind

# Logs
docker logs weltenwind-app -f
```
