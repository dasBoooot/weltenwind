## Weltenwind Roadmap (Arbeitsplan)

Ziel: Aufbau der Multiplayer-/World‑Plattform entlang vertikaler Slices (stabil, messbar, iterierbar).

Status: WP1 abgeschlossen (API v1 Grundgerüst live: Versionierung, RFC7807, X-Request-Id/traceId, ETag, Idempotency)

### Phase 0 – Querschnitt (früh)
- WP1: API v1 Grundgerüst (Versionierung, RFC7807, X-Request-Id/traceId, ETag/If-None-Match, Idempotency-Key)
- WP2: Routing & Slugs (GoRouter ShellRoute, /worlds/:idOrSlug, /w/:slug → 301, /me Alias, Guards via RBAC/Scope)

### Phase 1 – Realtime & Chat (MVP)
- WP3: Realtime Foundation (WS /realtime/v1, JWT-Handshake, Räume global/world, Heartbeat/Presence, Backpressure, Metrics)
- WP4: ChatWorld v1 (chat_channels, chat_messages, History (cursor), WS broadcast, Moderation-Flags basic)

### Phase 2 – Announcements & Notifications
- WP5: Announcements/Notifications v1 (announcements, user_notifications, Outbox, ETag/Cache, Client-Feed + Dedupe)

### Phase 3 – World Hub Tiefe
- WP6: World Ranking v1 (daily Aggregation + Materialized Views, API mit sort/paginate, HallOfFame UI)
- WP7: World Invite UI komplett (Multi‑Invite, Status‑Tracker, Idempotency, E‑Mail optional stabilisiert)

### Phase 4 – Account & Settings
- WP8: Account/Settings v1 (/api/v1/users/me, Preferences, Devices‑Liste, 2FA Stub)

### Phase 5 – Telemetry & Flags
- WP9: Telemetry Ingest v1 (Client Events minimal, /api/v1/telemetry Batch, Storage, Sampling/PII‑Policy)
- WP10: Feature Flags v1 (flags, assignments, GET /api/v1/flags/effective, Client Cache)

### Phase 6 – Social & Moderation
- WP11: Groups/Clans v1 (groups, members, applications mit TTL, CRUD/Join/Apply, UI Tabs)
- WP12: Moderation Panel v1 (report-list, ban-list, audit-log; Chat‑Moderation Soft‑Delete/Tombstone)

### Reihenfolge (Vorschlag, iterativ lieferbar)
- Woche 1: WP1, WP2, WP3
- Woche 2: WP4, WP5
- Woche 3: WP6, WP7
- Woche 4: WP8, WP9
- Woche 5: WP10, WP11
- Woche 6: WP12

### Leitplanken
- UTC‑only im Backend; Client lokalisiert.
- Cursor‑Pagination; Soft‑Delete + Retention Policy.
- Rate‑Limits speziell für Invite/Chat/Notifications.
- Canonical Redirects; Open‑Redirects vermeiden.
- Monitoring: WS‑Metriken, Drop‑Rates, Queue‑Längen, Replay‑Volumen.


