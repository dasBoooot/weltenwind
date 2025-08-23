# 🤝 Contribution Guide

Richtlinien für Beiträge zu Weltenwind.

---

## 🔄 Workflow

1. Issue oder Task definieren (Ziel, Akzeptanzkriterien).
2. Branch erstellen (`feature/<topic>` oder `fix/<topic>`).
3. Kleine, fokussierte Edits (ein Thema pro PR, < 400 Zeilen Diff wenn möglich).
4. Selbst-Checkliste vor PR:
   - `flutter analyze` sauber (Client)
   - Build getestet (falls relevant)
   - Manuelle Tests dokumentiert
   - Keine hardcodierten UI-Texte (l10n)
   - API/Schema-Doku aktualisiert (OpenAPI)

---

## 📝 Commit-Konventionen

Conventional Commits mit Scope:

- `feat/world: ...`
- `fix/auth: ...`
- `docs/rules: ...`
- `refactor(client): ...`
- `chore(openapi): ...`

Beispiele:
- `feat/world: Join-Flow mit Invite-Token vereinheitlicht`
- `fix/auth: CSRF-Token-Header bei Logout ergänzt`

---

## 🔐 Regeln & Policies (Kurzfassung)

- Keine unangeforderten großen Rewrites.
- Keine neuen Dependencies ohne Freigabe.
- PowerShell-Umgebung respektieren (Windows).
- API-Tests gegen `https://<VM-IP>/api`.
- OpenAPI generieren: `cd docs/openapi && npm install && node generate-openapi.js`.

---

## 🧪 Tests & Reviews

- Änderungen an Logik: Unit/Widget/Integrationstests ausführen.
- Cross-Platform checken (Web/iOS/Android).
- PR-Review: klare Beschreibung (Was/Warum), Risiken, Testnotizen.

---

## 📚 Dokumentation

- Relevante Docs aktualisieren (`docs/`), insbesondere API und Setup.
- Bei Multi-File-Änderungen vollständigen Diff im Review zeigen.

---

Letzte Aktualisierung: Januar 2025

