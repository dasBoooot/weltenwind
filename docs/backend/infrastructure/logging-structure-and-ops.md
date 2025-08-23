## Weltenwind Logging – Struktur, Betrieb und Troubleshooting

### Ziel
Robustes, strukturiertes Logging mit Winston, klare Ordnerstruktur (Subfolder je Kategorie), optionale Multi-World/Module-Logs, Log-Viewer-Unterstützung, und stabile Dev-/Prod-Betriebsvarianten.

### Ordnerstruktur (Logs)
```
logs/
  system/
    app.log
    error.log
    startup.log
    uncaught-exceptions.log
    unhandled-rejections.log
  api/
    requests.log
    errors.log
  auth/
    login.log
    logout.log
    register.log
    tokens.log
    password-reset.log
  security/
    events.log
    csrf.log
    rate-limit.log
    sessions.log
  worlds/<worldId>/
    app.log
    error.log
  modules/<moduleName>/
    events.log
    errors.log
```

### Kern-Dateien
- `backend/src/config/logger.config.ts`: Winston-Setup inkl. Subfolder-Transports, Log-Rotation, Exception/Rejection-Handler, Multi-World/Module-Logger, ENV-Sanitizing und (Dev-)Smoketests.
- `backend/src/middleware/logging.middleware.ts`: Request-Logging via `res.on('finish')` (robust) + optionaler Trace über `LOG_TRACE_REQUESTS=true`.
- `backend/src/routes/logs.ts` und `backend/tools/log-viewer/*`: Log-Viewer, der JSON-Logs aus Subordnern liest und rendert.

### Environment Variablen (Auszug)
- `NODE_ENV` (development|production)
- `LOG_LEVEL` (z. B. debug, info)
- `LOG_TO_FILE` (true|false)
- `LOG_TO_CONSOLE` (true|false)
- `LOG_DIR` (z. B. `/srv/weltenwind/logs` oder Projekt-root `./logs`)
- `LOG_FILE_MAX_SIZE` (z. B. `10m`, `100m`)
- `LOG_FILE_MAX_FILES` (z. B. `5`)
- `ERROR_LOG_MAX_FILES` (z. B. `10`)
- `LOG_TRACE_REQUESTS` (true|false – aktiviert TRACE start/finish im System-Log)

Hinweise:
- `.env` wird per `dotenv.config()` ganz oben in `logger.config.ts` geladen.
- `LOG_DIR` wird sanitisiert (Anführungszeichen/Inline-Kommentare entfernt). Keine Kommentare direkt in ENV-Werten einfügen.
- Dateien/Ordner werden vor der Benutzung erzeugt; neue Logdateien werden permissiv (`0666`) erstellt, um HGFS/VMware-Mounts zu unterstützen.

### Request-Logging (Ablauf)
- `server.ts`: `app.use(requestLoggingMiddleware)` VOR den `/api`-Routen.
- Middleware erfasst Methode, URL, Status, Dauer, IP, User-Agent und schreibt nach `logs/api/requests.log`.
- Fehler aus dem Logging selbst werden nach `logs/system/error.log` gemeldet.

### Log Viewer
- UI unter `/log-viewer/` (statische Dateien); API-Routen in `backend/src/routes/logs.ts` lesen Subfolder.
- JSON-Logs werden geparst und inklusive Meta-Daten angezeigt.

### Betrieb: Services
Prod-nah (Build benötigt):
- `backend/services/weltenwind-backend.service`
- Empfohlen: `ExecStart=/usr/bin/npm start` und vor Restart `npm ci && npx prisma generate && npm run build` ausführen.

Dev (watch-basiert):
- `backend/services/weltenwind-backend-dev.service`
- Läuft mit `npm run dev`, aktiviert `LOG_TRACE_REQUESTS=true`, nutzt HGFS-freundliche Watcher-ENV (`CHOKIDAR_USEPOLLING=true`, `TS_NODE_TRANSPILE_ONLY=true`) und schreibt in Subfolder.

Systemd Kommandos (Beispiele):
```
sudo systemctl daemon-reload
sudo systemctl enable --now weltenwind-backend-dev
sudo systemctl restart weltenwind-backend-dev
journalctl -u weltenwind-backend-dev -n 100 | cat
```

### HGFS/VMware: Prisma & node_modules Workaround
Atomare `rename()`-Operationen in HGFS können fehlschlagen (z. B. `libquery_engine...tmpXXXX -> ...`). Lösung:
```
sudo systemctl stop weltenwind-backend weltenwind-backend-dev || true
sudo mkdir -p /srv/weltenwind/backend_node_modules
sudo chown -R weltenwind:weltenwind /srv/weltenwind/backend_node_modules
sudo rm -rf /mnt/hgfs/sharedFolder_weltenwind/backend/node_modules
sudo ln -s /srv/weltenwind/backend_node_modules /mnt/hgfs/sharedFolder_weltenwind/backend/node_modules

sudo -u weltenwind bash -lc 'cd /srv/weltenwind/backend && npm ci && npx prisma generate && npm run build'
```

### Troubleshooting Checkliste (kurz)
- Logs fehlen? Prüfe: Richtiger Zielpfad (`logRoot` im Startup-Log), Rechte/Ownership im Zielordner, `system/error.log` für „API logging failed“.
- Keine TRACE-Zeilen? `LOG_TRACE_REQUESTS=true` setzen und Dienst neu starten.
- systemd schreibt nicht? Prüfe `ExecStart`, `WorkingDirectory`, `EnvironmentFile`, Build (bei Prod), und ob der Dienst auf denselben Pfad wie die dev-Shell zeigt.

### Konsistenz der Logger-Aufrufe
- Alle Logger nutzen die vorgesehenen Subfolder-Transports.
- Einheitliche Signaturen: z. B. `loggers.api.request(method, url, status, ip, userAgent, duration, meta)`.
- Multi-World/Module: `loggers.worlds.for(worldId)` und `loggers.modules.for(name)` erzeugen dedizierte Dateien on-demand.

Diese Dokumentation spiegelt die aktuelle, stabile Implementierung wider und deckt die relevanten Betriebs- und Debug-Aspekte ab.


