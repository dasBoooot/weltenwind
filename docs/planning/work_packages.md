## Arbeitspakete (Details, DoD, Dependencies)

Format je WP: Ziel • Umfang • API/DB • Client • Security/Ops • DoD

### WP1: API v1 Grundgerüst
- Ziel: Konsistente, versionierte API mit stabilen Cross-Cutting Concerns
- Umfang: `/api/v1` Prefix, RFC7807 Fehlerformat, `X-Request-Id/traceId`, ETag/If-None-Match, Idempotency-Key Middleware
- API/DB: keine Schema-Änderung; Middleware + Response-Wrapper
- Client: Basis-Adapter akzeptiert 304, propagiert traceId in Logs
- Security/Ops: Winston korreliert traceId; Logs JSON; Tests: 200/304/4xx; Nginx TLS/Redirects
- DoD: Alle Endpoints über `/api/v1` erreichbar; 304 bei ETag; Fehler sind RFC7807

- DoD+: OpenAPI/Schema linted (CI prüft Breaking Changes); Problem+JSON enthält `type`, `instance`, `correlationId`.
- Add: ETag-Policy (weak vs strong) dokumentiert; 429-Response standardisiert (inkl. `Retry-After` in Sekunden); `X-Request-Id` immer setzen (auch 304/4xx); OpenAPI Diff in CI (z. B. `oasdiff`).
- Tools: Express (beibehalten), Winston (beibehalten), Prometheus `prom-client` (Basis-Metriken vorbereiten)
 - Express-Setup: `helmet`, `cors` (Whitelist), `compression`, zentrale Schema-Validation (z. B. `zod`) vor Controllern
 - Config: `.env` hierarchisch (default/prod/local) + Schema-Validation beim Boot (z. B. `zod`)

Status: Implementiert
- Server: Middlewares `request-context` (X-Request-Id), `versioning` (/api/v1→/api), `etag` (starkes ETag + 304), `idempotency` (In-Memory TTL), `problem-details` (RFC7807), `response-headers` (standard Headers). Eingehängt in `src/server.ts` vor Routen und als Fehler-Handler.
- Logging: `logging.middleware` erweitert um `requestId`; Winston bleibt JSON-fähig; Request/Trace-ID in Headers.
- Client: `Env.apiBasePath` → `/api/v1`; `ApiService` übernimmt `X-Request-Id` in Logs und sendet es weiter; verarbeitet 304 sauber.
- Next: OpenAPI anpassen (Base URL /api/v1), CI-Linting ergänzen; Idempotency-Store später auf DB/Redis heben.

### WP2: Routing & Slugs
- Ziel: Saubere Navigation inkl. Deep-Links
- Umfang: `/worlds`, `/worlds/:idOrSlug`, `/worlds/:idOrSlug/chat`, `/w/:slug → 301`, `/me` Alias; GoRouter ShellRoute; RBAC/Scope Guards
- API/DB: `worlds.slug` + `world_slug_history` (optional) für Canonicals
- Client: Tabs ↔ URL Sync; Guards via AccessControlService
- Security/Ops: Open-Redirects vermeiden; Canonical 301 serverseitig
- DoD: Navigationsfluss inkl. Guards und Redirects funktioniert

- DoD+: Slug-Uniqueness + `world_slug_history` → canonical resolver getestet.
- Add: Guard-Contract: `AccessControlService.hasPermission(user, perm, scopeCtx)` als Middleware für Pages & WS‑Join; `world_slug_history` mit `UNIQUE(oldSlug)` und „last wins“ Canonical-Regel; `/me` Alias später erweitern (`/users/me/sessions`, `/users/me/devices`).

### WP2.5: World Structure v1 (Regions, Places, Portals)
- Ziel: Spielwelt-Struktur für Hub/Matrix (Welt → Regionen → Orte/Places; Portale als Kanten)
- Umfang: `regions(worldId, key, name, biome, difficulty, graphPos)`, `places(regionId, key, name, type city|dungeon|event, pos)`, `portals(worldId, fromRegionId, toRegionId, cost, requirements)`
- API/DB: Tabellen + Indizes (z. B. `regions(worldId,key)` unique, `places(regionId,key)` unique); RBAC/Scopes für Zugriff; `places.type` strikter Enum; minimale Render/Pathing‑Attribute (z. B. walkable, elevation)
- Client: World‑Detail nutzt Regions/Places für Preview/Graph; zukünftige Routen (region/place)
- Security/Ops: Read‑Caching (ETag), Limits auf Graph‑Writes; Migrations smoke‑test
- DoD: Listen/Details für Regionen/Places verfügbar; Portale auslesbar; Manifest‐Teaser kann Graph rendern

### WP2.6: Story/Quest/Event – Core & Binding
- Ziel: Zentrale Inhalte (Stories, Quests, Events) verwalten und per Binding in Welten/Regionen ausspielen
- Umfang: zentrale Services + Binding‑Layer (weltagnostisch, kontextualisiert per world/region)
- API/DB: `stories(id, type main|sub, arcs json, status)`, `quests(id, objectives json, rewards json, stateMachine json)`, `events(id, triggerType time|questComplete|regionState|manual|randomWeighted, window json{start,end}, payload json)`, `world_bindings(id, serviceType story|quest|event, serviceId, worldId, regionId?, startAt, endAt, conditions json)`
- Endpunkte: `GET /api/v1/worlds/:id/active-content?regionId&playerId` (aggregiert Inhalte via Binding, RBAC‑gefiltert), `POST /api/v1/bindings` (RBAC story.manage|event.manage|quest.manage)
- Client: Pre‑Game Teaser/Preview; Game konsumiert identische IDs zur Laufzeit
- Security/Ops: RBAC/Scopes für Zugriffe; Audit‑Log bei Binding‑Änderungen; ETag weak für active‑content
- DoD: Gleiches Objekt (z. B. quest Q‑4711) erscheint in unterschiedlichen Welten nur via Binding – kein Duplikat, Preview und Runtime nutzen dieselben IDs

### WP2.7: Module Registry & Content Packs (Defs)
- Ziel: Modularisierung von Ressourcen/Items/Gebäuden/Units etc. als versionierte Pakete
- Umfang: globale Registry mit SemVer/Deps; Content‑Defs paketiert; CI‑Validation (Schema)
- API/DB: `modules(key, latestVersion, capabilities json)`, `module_versions(moduleKey, version, dependencies json, migrations json)`, `content_packs(id, moduleKey, version, type resources|items|buildings|units|…, def json, schemaVersion)`
- Client: nutzt Defs indirekt (über Merge‑Engine/Precompile Cache)
- Security/Ops: Validation via JSON‑Schema/Zod; OpenAPI/Schema‑Checks in CI; Audit bei Publishes
- DoD: Registry listet Module/Versionen; Content‑Packs validiert; Abhängigkeiten auflösbar

### WP3: Realtime Foundation
- Ziel: Stabiler WS‑Layer als Basis für Chat/Notifications
- Umfang: Namespace `/realtime/v1`, JWT‑Handshake, Rooms (global/world/region), Heartbeat/Presence, Backpressure, Metrics; Tick‑Scheduler
- API/DB: keine Schema‑Änderungen; WS‑Gateway + Middleware
- Client: `RealtimeService` mit Reconnect/Backoff; Room‑Join API
- Security/Ops: Rate‑Limits, Auth‑Gate, Monitoring (connections, drop rates); Socket.IO + `socket.io-redis-adapter`; Redis mit AOF `everysec`
- DoD: Connect/Join/Presence/Heartbeat laufen stabil; Metriken sichtbar

- DoD+: Replay‑Contract (`sinceId`/cursor) + Max‑Backlog‑Window (z. B. 10k msgs/Kanal).
- Add: JWT‑Claims enthalten `scope={global|world:<id>}`; Rate‑Limit pro Room; Backpressure‑Metrik; `messageId`-Format definieren (64‑bit Snowflake/BigInt), max. WS‑Payload begrenzen; deterministische RNG‑Seeds pro Welt/Region; Property‑Tests für Idempotenz pro Tick
- Tick: Globaler Tick‑Controller (overall tick) + per‑World Tick‑Schedule (z. B. 5s, 20s, Minutenfälle). Konfigurierbar via DB/Flags; Apply‑Loop auf Worker; nur Diffs broadcasten
- Tools: Socket.IO, Redis (apt), Prometheus (WS-Kennzahlen), Nginx WS‑Upgrade korrekt

### WP3.1: Tick Scheduler v1
- Ziel: Variable Ticks (global + pro Welt) server‑authoritativ
- Umfang: Tick‑Konfiguration (`tick_schedules`: worldId|global, intervalSec, enabled, mode pause|normal|boost, updatedAt), Intent‑Queue (Redis Streams mit Consumer‑Gruppen), Worker verarbeitet batchweise, erzeugt Diffs
- API/DB: `tick_schedules` Tabelle; optional `snapshots` (region/world) für spätere Restores
- Client: Keine UI‑Änderung; erhält Diffs im jeweiligen Room; Optimistic Intents mit Server‑Korrektur
- Security/Ops: systemd `weltenwind-scheduler.service`; Prometheus Counter (ticks_run, intents_applied), p95 tick_duration; Backpressure‑Handling; PostgreSQL Advisory Locks pro world/region tick; NTP/chrony Pflicht
- DoD: Unterschiedliche Welt‑Tickraten wirksam; Pausieren/Ändern zur Laufzeit möglich; Metriken sichtbar; Idempotency‑Keys + TTL für Intents; Snapshots periodisch; Replay‑Fenster begrenzt; Diff‑Pruning nach Snapshot

### WP3.2: Realtime Diff‑Channel & Replay
- Ziel: Stabiler Transport der Zustandsänderungen pro Welt/Region mit verlustfreiem Replay
- Umfang: Diff‑Envelope `{ worldId, regionId, tick, changes[], messageId }`; `sinceId` Cursor; maxBacklog (z. B. 10k)
- API/WS: WS Topic `world:<id>:region:<id>`; Fallback `GET /api/v1/diff?regionId&sinceId=` (Cursor‑Pagination)
- Client: Silent Resync bei WS‑Drop (Replay bis latest)
- Security/Ops: Envelope‑Budget (max bytes/items); Graceful Degrade (statt großem Replay → leichter Snapshot Push); Monitoring diff_bytes_p95, replay_count, backlog_depth
- DoD: Client kann Verbindungsabrisse verlustfrei schließen; Budget/Backpressure greift

### WP3.3: Module Runtime Hooks & Merge‑Engine
- Ziel: Einheitliche Modul‑Schnittstellen und performantes Regeln‑Merging je Welt/Region
- Umfang: Hooks `onIntent(ctx, command)`, `onTick(ctx)`, `onEvent(ctx, event)`; Merge‑Engine: global Def → Feature‑Flags → WorldBinding.config → finale Regeln; Precompile Cache pro Welt/Region
- API/DB: keine neuen Tabellen; optional `compiled_rules(worldId, regionId?, moduleKey, version, compiled json, updatedAt)`
- Client: keine UI‑Änderung; profitiert von stabilen Regeln
- Security/Ops: Hook‑SLOs (p95 Dauer); Test‑Harness mit Property‑Tests (Idempotenz pro Tick); Hot‑Reload „apply at tick N“
- DoD: Hooks implementiert, Merge deterministisch, Precompile Cache aktiv; SLOs grün

### WP3.4: World Module Binding UI/API
- Ziel: Module je Welt/Region aktivieren/konfigurieren (Overrides) und auditieren
- Umfang: Endpunkte & einfache UI für Enable/Disable/Config (RBAC module.manage); Versionswechsel mit Zeitsteuerung
- API/DB: nutzt Registry/Bindings; Audit‑Logs für Änderungen
- Client: Admin‑UI (Settings) im World‑Hub
- Security/Ops: RBAC/Scope‑Guard; Hot‑Reload mit „apply at tick N“; Rollback per Version
- DoD: Module pro Welt/Region steuerbar, Änderungen auditierbar, ohne Service‑Restart wirksam

### WP4: ChatWorld v1
- Ziel: Minimale Chat‑Funktion je Welt
- Umfang: `chat_channels`, `chat_messages`, REST History (cursor), WS Broadcast, Moderation‑Flags basic
- API/DB: Tabellen + Indexe `(channelId, id)`; Soft‑Delete
- Client: ChatPanel in World‑Hub; History‑Load; Send/Receive
- Security/Ops: Rate‑Limit (`rate-limiter-flexible` mit Redis‑Store), Content‑Filter placeholder, Audit‑Logs, Max‑Message‑Size
- DoD: Chat nutzbar; History performant; Limits greifen

- DoD+: Tombstone‑Felder (`deletedBy`, `reason`, `deletedAt`) + GDPR‑Purge‑Job.
- Add: Report‑API (Stub) + Moderation‑Audit‑Log (Korrelation mit Session/Device); Hard‑Limit Nachrichtengröße 1–2 KB; einfacher Profanity‑Filter‑Hook; Tombstone‑Typen unterscheiden (`USER_DELETED` vs `MOD_HIDDEN`).
- Tools: Postgres (Speicher), Redis Pub/Sub via Adapter, Prometheus Metriken

### WP5: Announcements/Notifications v1
- Ziel: Feed + Echtzeit‑Hinweise
- Umfang: `announcements`, `user_notifications`, Outbox `dispatchedAt`, ETag/Cache‑Control, Client Feed + Dedupe
- API/DB: CRUD + List (paginate/sort); mark‑as‑read; Suche v1 über Postgres FTS/`pg_trgm` (Meilisearch optional später)
- Client: Feed‑Widget global/world; Toasts optional WS
- Security/Ops: Retention; RBAC; Rate‑Limits für Broadcasts; BullMQ Outbox‑Worker als eigener systemd‑Dienst
- DoD: Feed performant; 304/ETag funktioniert; Dedupe ok

- DoD+: Outbox‑Worker (Retry, DLQ Tabelle), Backoff‑Strategie; `dedupeKey` auf `user_notifications`.
- Add: `audience` (global/world/role/group) mit RBAC‑Abfrage; Index auf `readAt`; WS‑Toast nur im Foreground.
- Tools: BullMQ (Redis), systemd `weltenwind-worker.service` (Jobs)

### WP6: World Ranking v1
- Ziel: Hall of Fame
- Umfang: Daily Aggregation (Materialized Views/CRON), API (sort/paginate), UI Ranking
- API/DB: `world_rankings` + MVs; systemd Timer/`cron` für Refresh
- Client: Ranking‑Tab mit Filter/Period
- Security/Ops: Cache‑Headers; ETag; Monitoring Abfragezeit
- DoD: Rankings <200ms, 304/ETag, UI ok

- DoD+: Feste Metrik‑Definitionen (z. B. `activity_score`, `wins_day`, `progress_delta`), MV‑Refresh SLO (z. B. p95 < 2 s) definiert und überwacht.
- Add: Index‑Plan `(worldId, period, metric, rank)` + ETag by `(metric, period, updatedAt)`.

### WP7: World Invite UI komplett
- Ziel: Einladungen produktionsreif nutzen
- Umfang: Multi‑Invite, Status‑Tracker, Idempotency, E‑Mail optional stabilisieren
- API/DB: bestehend; Idempotency‑Store
- Client: Form, Bulk, Status‑Liste
- Security/Ops: Rate‑Limits; Audit für Bulk; Mail: Dev via Mailpit (Binary, systemd), Prod via externer Mail‑Provider (Postmark/SendGrid)
- DoD: End‑to‑end inkl. Errors robust

- DoD+: Idempotency‑Store + Nonce; Abuse‑Signals (fail2ban‑ähnlich) an Behavior‑Engine.
- Add: Bulk‑Audit (wer/wie viele/wann), Rate‑Limit/Quota pro Issuer/Tag (pro Tag), Bounce‑Tracking.
- Tools: Mailpit (Dev), externer Mail‑Dienst (Prod), Redis für Abuse‑Limits

### WP8: Account/Settings v1
- Ziel: Solider Benutzerbereich
- Umfang: `/api/v1/users/me`, Preferences (L10n/Theme/Notifications), Devices‑Liste, 2FA Stub
- API/DB: `user_devices` optional; `user_preferences`
- Client: Seiten Account/Settings; Save/Load
- Security/Ops: RBAC, CSRF, Session‑Rotation bei Security‑Änderungen
- DoD: /me liefert; UI persistiert Einstellungen

- DoD+: Session‑Rotation nach Security‑Änderungen, Device‑Revoke schließt Sessions/WS.
- Add: `user_devices(fingerprint, lastSeen, ipHash)` – integriert mit DeviceFingerprintService; Security‑Änderungen triggern WS‑Disconnect.
- Tools: FingerprintJS OSS (Client), Server‑Side DeviceFingerprintService, Postgres‑Speicherung

### WP9: Telemetry Ingest v1
- Ziel: Ereignisse sammeln
- Umfang: Client Events (UI/Perf minimal), `/api/v1/telemetry` (Batch), Storage, Sampling/PII‑Policy
- API/DB: `telemetry_events` partitioniert
- Client: `TelemetryService` mit Queue
- Security/Ops: PII‑Filterung; Rate‑Limit; Sampling; Prometheus + `node_exporter` für System‑Metriken; Winston Logs bleiben (Log‑Viewer); Loki/promtail optional später
- DoD: Events landen; einfache Auswertung möglich

- DoD+: `schemaVersion`, PII‑Policy (drop/hash), Sampling‑Config serverseitig.
- Add: Pflichtfelder `tenant/worldId`; Sampling togglebar via Feature‑Flag; Backfill‑Pipeline (optional).
- Tools: Prometheus, Grafana (Dashboards), Winston (bestehend)

### WP10: Feature Flags v1
- Ziel: Remote Rollouts/A/B
- Umfang: `feature_flags`, `flag_assignments`, `GET /api/v1/flags/effective`, Client Cache (DB‑basiert jetzt; Unleash OSS optional später)
- API/DB: Tabellen + Indizes; Evaluierungslogik
- Client: Gate in UI (z. B. Chat/HOF)
- Security/Ops: Audit bei Zuweisungen; Cache TTL
- DoD: Flag steuert Feature sichtbar

- DoD+: Sticky Bucketing (userId), Server‑Side Eval; Kill‑Switch.
- Add: Exposure‑Log (Auswertung), Cache‑TTL & ETag; ETag explizit auf `/flags/effective`.

### WP11: Groups/Clans v1
- Ziel: Welt‑Communities
- Umfang: `groups`, `group_members`, `group_applications` (TTL), CRUD + Join/Apply; `guild_professions`, `guild_skills` (Progress & Boni auf Gilden‑Ebene, Buff‑Scopes: world|region|place)
- API/DB: Tabellen + Indizes; Soft‑Delete
- Client: Tabs + Forms
- Security/Ops: RBAC; Moderation Hooks
- DoD: Gruppen nutzbar inkl. Bewerbungen

- DoD+: `unique(worldId, name)`, Applications TTL, Rollen in Gruppe (owner/mod/member).
- Add: Join‑Policy (open/approve/invite‑only) + Moderation‑Hooks; Gilden‑Berufe/Skills verwaltbar (Zuweisung, Level, Effekte)
- Tools: Postgres (Kern), Suche optional später via Meilisearch (systemd)

### WP12: Moderation Panel v1
- Ziel: Governance & Sicherheit
- Umfang: report‑list, ban‑list, audit‑log; Chat‑Moderation (delete/tombstone)
- API/DB: `reports`, `bans`, `audits`
- Client: Admin‑UI unter `/admin/`
- Security/Ops: Strikte RBAC; Logging in `logs/security`; Fail2ban (nginx jail); WAF/ModSecurity optional später (WS‑Pfade ausnehmen); Dashboards in Grafana
- DoD: Moderationsaktionen auditierbar, wirksam

- DoD+: RBAC/SCOPE strikt (global vs world), Audit‑Trail vollständig, Mask vs Purge unterscheidbar; Ban‑Scope `global` | `world:<id>`; Audit‑Korrelation mit Session/Device.
- Add: Evidence‑Retention (30–90 Tage) & Export für Abuse‑Review.

### Cross‑Cutting Guardrails
- UTC‑only Backend; Cursor‑Pagination überall; konsistente 304/ETag + Cache‑Control Richtlinien.
- Rate‑Limits getrennt für auth/invite/chat/notifications; 429 mit `Retry-After`.
- Observability: WS connect p95, publish→deliver p95, drop‑rate, backlog depth, MV‑Refresh‑Zeiten; Prometheus + Grafana.
- Threat‑Mitigation: Captcha/Behavior‑Engine/Device‑FP für Login, Invites, Chat‑Flood.
 - RBAC/Scopes zentral: API & WS‑Join nutzen denselben `AccessControlService.hasPermission` (global/world)
 - Healthchecks: `/healthz` (DB/Redis/PubSub), `/readyz` (Worker/Outbox aktiv)
 - Backups/Recovery: Postgres PITR (WAL), Redis RDB+AOF (everysec); Restore‑Playbook + Smoke‑Test
- Permission‑Refresh: Rollenwechsel aktualisiert WS‑Rooms (Subscribe/Unsubscribe)
- Anti‑Abuse: Kanal‑spezifische Limits (chat vs intents); Schwellenwert→Captcha Re‑Challenge; Device‑Revoke beendet WS + invalidiert Tokens
- Shard‑Moves: Hot‑Shard‑Handover (Region wechselt Worker) mit sauberem Room‑Rejoin
- Balancing: Flags für Formeln/Parameter; KPI‑Kanon: tick_duration_p95, diff_bytes_p95, backlog_depth, intent_rate
- Zeit/IDs: Snowflake BigInt; NTP/chrony überwachen; Zeitdrift‑Guards beim Start

### Operative Basis (Tooling)
- Postgres 16 (apt), Redis (AOF `everysec`), Nginx (TLS/Redirects)
- Systemd Dienste: `weltenwind-backend.service`, `weltenwind-backend-dev.service`, `weltenwind-worker.service` (BullMQ), `weltenwind-scheduler.service` (Tick)
- Optional später: Meilisearch, Unleash OSS, Loki/promtail, Jaeger (Single‑Binary/systemd)
 - Nginx: WS‑Upgrade (Upgrade/Connection Header), HTTP/2, TLS korrekt; Fail2ban nginx‑jail
 - systemd: `Restart=always`, `EnvironmentFile=`, `LimitNOFILE=`, separate Worker/Scheduler Units

### Migrationsplan (Reihenfolge)
- WP2: `world.slug`, `world_slug_history`
- WP2.5: `regions`, `places`, `portals`
- WP4: `chat_channels`, `chat_messages` (+ Indexe, Tombstones)
- WP5: `announcements`, `user_notifications`, `outbox`
- WP6: `world_rankings` (+ MVs/Tables)
- WP7: `invites`, `idempotency`
- WP8: `user_preferences`, `user_devices`
- WP10: `feature_flags`, `flag_assignments`
- WP11: `groups`, `group_members`, `group_applications`, `guild_professions`, `guild_skills`
- WP12: `reports`, `bans`, `audits`

### Abhängigkeiten (kritisch)
- WP3 ← WP1 (Trace/Log Contracts)
- WP4/5 ← WP3 (WS Infrastruktur)
- WP6 ← WP9 (optional, für tiefe Metriken)
- WP12 ← WP4/5/11 (Moderationsdaten & Scopes)


