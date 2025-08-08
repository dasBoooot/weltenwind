## Dev-Service und HGFS Hinweise

### Dev-Systemd-Service
Datei: `backend/services/weltenwind-backend-dev.service`

Eigenschaften:
- Läuft mit `NODE_ENV=development`, `LOG_TO_FILE=true`, `LOG_TO_CONSOLE=true`, `LOG_TRACE_REQUESTS=true`.
- Nutzt `LOG_DIR=/srv/weltenwind/logs` (Symlink auf Shared-Folder möglich).
- Watcher stabilisiert für HGFS/VMware via `CHOKIDAR_USEPOLLING=true`, `TS_NODE_TRANSPILE_ONLY=true`.
- Ignoriert große/veränderliche Verzeichnisse beim Watchen.

Aktivierung/Start:
```
sudo cp backend/services/weltenwind-backend-dev.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now weltenwind-backend-dev
journalctl -u weltenwind-backend-dev -n 100 | cat
```

Stop/Switch:
```
sudo systemctl disable --now weltenwind-backend-dev
sudo systemctl enable --now weltenwind-backend
```

### HGFS/VMware – node_modules & Prisma
Problem: Atomare Dateioperationen (rename) schlagen auf HGFS fehl, insbesondere bei `npx prisma generate` in `node_modules/.prisma/client`.

Empfohlene Lösung:
```
sudo mkdir -p /srv/weltenwind/backend_node_modules
sudo chown -R weltenwind:weltenwind /srv/weltenwind/backend_node_modules
sudo rm -rf /mnt/hgfs/sharedFolder_weltenwind/backend/node_modules
sudo ln -s /srv/weltenwind/backend_node_modules /mnt/hgfs/sharedFolder_weltenwind/backend/node_modules
```
Danach als Benutzer `weltenwind`:
```
cd /srv/weltenwind/backend
npm ci
npx prisma generate
npm run build
```

### Logging-Hinweise
- Logdateien werden automatisch mit `0666` angelegt, Ordner mit `0777` (sofern vom Mount unterstützt).
- Bei fehlenden API-Logs: `LOG_TRACE_REQUESTS=true` setzen und Neustart; TRACE-Zeilen in `logs/system/app.log` prüfen.


