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
- Add: ETag-Policy (weak vs strong) dokumentiert; 429-Response standardisiert (inkl. `Retry-After`).
- Tools: Express (beibehalten), Winston (beibehalten), Prometheus `prom-client` (Basis-Metriken vorbereiten)

### WP2: Routing & Slugs
- Ziel: Saubere Navigation inkl. Deep-Links
- Umfang: `/worlds`, `/worlds/:idOrSlug`, `/worlds/:idOrSlug/chat`, `/w/:slug → 301`, `/me` Alias; GoRouter ShellRoute; RBAC/Scope Guards
- API/DB: `worlds.slug` + `world_slug_history` (optional) für Canonicals
- Client: Tabs ↔ URL Sync; Guards via AccessControlService
- Security/Ops: Open-Redirects vermeiden; Canonical 301 serverseitig
- DoD: Navigationsfluss inkl. Guards und Redirects funktioniert

- DoD+: Slug-Uniqueness + `world_slug_history` → canonical resolver getestet.
- Add: Guard-Contract: `AccessControlService.hasPermission(user, perm, scopeCtx)` als Middleware für Pages & WS‑Join.

### WP3: Realtime Foundation
- Ziel: Stabiler WS‑Layer als Basis für Chat/Notifications
- Umfang: Namespace `/realtime/v1`, JWT‑Handshake, Rooms (global/world), Heartbeat/Presence, Backpressure, Metrics
- API/DB: keine Schema‑Änderungen; WS‑Gateway + Middleware
- Client: `RealtimeService` mit Reconnect/Backoff; Room‑Join API
- Security/Ops: Rate‑Limits, Auth‑Gate, Monitoring (connections, drop rates); Socket.IO + `socket.io-redis-adapter`; Redis mit AOF `everysec`
- DoD: Connect/Join/Presence/Heartbeat laufen stabil; Metriken sichtbar

- DoD+: Replay‑Contract (`sinceId`/cursor) + Max‑Backlog‑Window (z. B. 10k msgs/Kanal).
- Add: JWT‑Claims enthalten `scope={global|world:<id>}`; Rate‑Limit pro Room; Backpressure‑Metrik.
- Tools: Socket.IO, Redis (apt), Prometheus (WS-Kennzahlen), Nginx WS‑Upgrade korrekt

### WP4: ChatWorld v1
- Ziel: Minimale Chat‑Funktion je Welt
- Umfang: `chat_channels`, `chat_messages`, REST History (cursor), WS Broadcast, Moderation‑Flags basic
- API/DB: Tabellen + Indexe `(channelId, id)`; Soft‑Delete
- Client: ChatPanel in World‑Hub; History‑Load; Send/Receive
- Security/Ops: Rate‑Limit (`rate-limiter-flexible` mit Redis‑Store), Content‑Filter placeholder, Audit‑Logs, Max‑Message‑Size
- DoD: Chat nutzbar; History performant; Limits greifen

- DoD+: Tombstone‑Felder (`deletedBy`, `reason`, `deletedAt`) + GDPR‑Purge‑Job.
- Add: Report‑API (Stub) + Moderation‑Audit‑Log (Korrelation mit Session/Device).
- Tools: Postgres (Speicher), Redis Pub/Sub via Adapter, Prometheus Metriken

### WP5: Announcements/Notifications v1
- Ziel: Feed + Echtzeit‑Hinweise
- Umfang: `announcements`, `user_notifications`, Outbox `dispatchedAt`, ETag/Cache‑Control, Client Feed + Dedupe
- API/DB: CRUD + List (paginate/sort); mark‑as‑read; Suche v1 über Postgres FTS/`pg_trgm` (Meilisearch optional später)
- Client: Feed‑Widget global/world; Toasts optional WS
- Security/Ops: Retention; RBAC; Rate‑Limits für Broadcasts; BullMQ Outbox‑Worker als eigener systemd‑Dienst
- DoD: Feed performant; 304/ETag funktioniert; Dedupe ok

- DoD+: Outbox‑Worker (Retry, DLQ), `dedupeKey` auf `user_notifications`.
- Add: `audience` (global/world/role/group), Index auf `readAt`; WS‑Toast nur bei Foreground.
- Tools: BullMQ (Redis), systemd `weltenwind-worker.service` (Jobs)

### WP6: World Ranking v1
- Ziel: Hall of Fame
- Umfang: Daily Aggregation (Materialized Views/CRON), API (sort/paginate), UI Ranking
- API/DB: `world_rankings` + MVs; systemd Timer/`cron` für Refresh
- Client: Ranking‑Tab mit Filter/Period
- Security/Ops: Cache‑Headers; ETag; Monitoring Abfragezeit
- DoD: Rankings <200ms, 304/ETag, UI ok

- DoD+: Feste Metrik‑Definitionen (z. B. `activity_score`, `wins_day`, `progress_delta`), MV‑Refresh SLO definiert.
- Add: Index‑Plan `(worldId, period, metric, rank)` + ETag by `(metric, period, updatedAt)`.

### WP7: World Invite UI komplett
- Ziel: Einladungen produktionsreif nutzen
- Umfang: Multi‑Invite, Status‑Tracker, Idempotency, E‑Mail optional stabilisieren
- API/DB: bestehend; Idempotency‑Store
- Client: Form, Bulk, Status‑Liste
- Security/Ops: Rate‑Limits; Audit für Bulk; Mail: Dev via Mailpit (Binary, systemd), Prod via externer Mail‑Provider (Postmark/SendGrid)
- DoD: End‑to‑end inkl. Errors robust

- DoD+: Idempotency‑Store + Nonce; Abuse‑Signals (fail2ban‑ähnlich) an Behavior‑Engine.
- Add: Bulk‑Audit (wer/wie viele/wann), Rate‑Limit pro Issuer/Tag.
- Tools: Mailpit (Dev), externer Mail‑Dienst (Prod), Redis für Abuse‑Limits

### WP8: Account/Settings v1
- Ziel: Solider Benutzerbereich
- Umfang: `/api/v1/users/me`, Preferences (L10n/Theme/Notifications), Devices‑Liste, 2FA Stub
- API/DB: `user_devices` optional; `user_preferences`
- Client: Seiten Account/Settings; Save/Load
- Security/Ops: RBAC, CSRF, Session‑Rotation bei Security‑Änderungen
- DoD: /me liefert; UI persistiert Einstellungen

- DoD+: Session‑Rotation nach Security‑Änderungen, Device‑Revoke schließt Sessions/WS.
- Add: `user_devices(fingerprint, lastSeen, ipHash)` – integriert mit DeviceFingerprintService.
- Tools: FingerprintJS OSS (Client), Server‑Side DeviceFingerprintService, Postgres‑Speicherung

### WP9: Telemetry Ingest v1
- Ziel: Ereignisse sammeln
- Umfang: Client Events (UI/Perf minimal), `/api/v1/telemetry` (Batch), Storage, Sampling/PII‑Policy
- API/DB: `telemetry_events` partitioniert
- Client: `TelemetryService` mit Queue
- Security/Ops: PII‑Filterung; Rate‑Limit; Sampling; Prometheus + `node_exporter` für System‑Metriken; Winston Logs bleiben (Log‑Viewer); Loki/promtail optional später
- DoD: Events landen; einfache Auswertung möglich

- DoD+: `schemaVersion`, PII‑Policy (drop/hash), Sampling‑Config serverseitig.
- Add: `tenant/worldId` im Event‑Key; Backfill‑Pipeline (optional).
- Tools: Prometheus, Grafana (Dashboards), Winston (bestehend)

### WP10: Feature Flags v1
- Ziel: Remote Rollouts/A/B
- Umfang: `feature_flags`, `flag_assignments`, `GET /api/v1/flags/effective`, Client Cache (DB‑basiert jetzt; Unleash OSS optional später)
- API/DB: Tabellen + Indizes; Evaluierungslogik
- Client: Gate in UI (z. B. Chat/HOF)
- Security/Ops: Audit bei Zuweisungen; Cache TTL
- DoD: Flag steuert Feature sichtbar

- DoD+: Sticky Bucketing (userId), Server‑Side Eval; Kill‑Switch.
- Add: Exposure‑Log (Auswertung), Cache‑TTL & ETag.

### WP11: Groups/Clans v1
- Ziel: Welt‑Communities
- Umfang: `groups`, `group_members`, `group_applications` (TTL), CRUD + Join/Apply
- API/DB: Tabellen + Indizes; Soft‑Delete
- Client: Tabs + Forms
- Security/Ops: RBAC; Moderation Hooks
- DoD: Gruppen nutzbar inkl. Bewerbungen

- DoD+: `unique(worldId, name)`, Applications TTL, Rollen in Gruppe (owner/mod/member).
- Add: Join‑Policy (open/approve/invite‑only) + Moderation‑Hooks.
- Tools: Postgres (Kern), Suche optional später via Meilisearch (systemd)

### WP12: Moderation Panel v1
- Ziel: Governance & Sicherheit
- Umfang: report‑list, ban‑list, audit‑log; Chat‑Moderation (delete/tombstone)
- API/DB: `reports`, `bans`, `audits`
- Client: Admin‑UI unter `/admin/`
- Security/Ops: Strikte RBAC; Logging in `logs/security`; Fail2ban (nginx jail); WAF/ModSecurity optional später (WS‑Pfade ausnehmen); Dashboards in Grafana
- DoD: Moderationsaktionen auditierbar, wirksam

- DoD+: RBAC/SCOPE strikt (global vs world), Audit‑Trail vollständig, Mask vs Purge unterscheidbar.
- Add: Evidence‑Retention (30–90 Tage) & Export für Abuse‑Review.

### Cross‑Cutting Guardrails
- UTC‑only Backend; Cursor‑Pagination überall; konsistente 304/ETag + Cache‑Control Richtlinien.
- Rate‑Limits getrennt für auth/invite/chat/notifications; 429 mit `Retry-After`.
- Observability: WS connect p95, publish→deliver p95, drop‑rate, backlog depth, MV‑Refresh‑Zeiten; Prometheus + Grafana.
- Threat‑Mitigation: Captcha/Behavior‑Engine/Device‑FP für Login, Invites, Chat‑Flood.

### Operative Basis (Tooling)
- Postgres 16 (apt), Redis (AOF `everysec`), Nginx (TLS/Redirects)
- Systemd Dienste: `weltenwind-backend.service`, `weltenwind-backend-dev.service`, `weltenwind-worker.service` (BullMQ)
- Optional später: Meilisearch, Unleash OSS, Loki/promtail, Jaeger (Single‑Binary/systemd)

### Abhängigkeiten (kritisch)
- WP3 ← WP1 (Trace/Log Contracts)
- WP4/5 ← WP3 (WS Infrastruktur)
- WP6 ← WP9 (optional, für tiefe Metriken)
- WP12 ← WP4/5/11 (Moderationsdaten & Scopes)


