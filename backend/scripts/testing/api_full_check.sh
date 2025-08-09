#!/usr/bin/env bash
set -euo pipefail

# Weltenwind Full API Endpoint Check
# - Prüft alle Haupt-Endpunkte unter /api/v1 (inkl. RBAC-Szenarien)
# - Liefert humanen Output und optional kompakten JSON-Report
#
# Umgebung (optional):
#   API_BASE=https://192.168.2.168/api/v1
#   USERNAME=admin
#   PASSWORD=******
#   WORLD_ID=1
#   WORLD_SLUG=mittelerde-abenteuer-1
#   THEME_NAME=default
#   REPORT=json|human

API_BASE="${API_BASE:-https://192.168.2.168/api/v1}"
USERNAME="${USERNAME:-admin}"
PASSWORD="${PASSWORD:-AAbb1234!!}"
WORLD_ID="${WORLD_ID:-1}"
WORLD_SLUG="${WORLD_SLUG:-mittelerde-abenteuer-1}"
THEME_NAME="${THEME_NAME:-default}"
REPORT="${REPORT:-human}"
REPORT_LC=${REPORT,,}

cyan()  { printf "\033[36m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
red()   { printf "\033[31m%s\033[0m\n" "$*"; }
ok()    { green "[OK]   $*"; }
fail()  { red   "[FAIL] $*"; }

header() { echo; cyan "=== $* ==="; }

_results=()
record() { _results+=("$1|$2"); }

# Generic request helpers
req() {
  local method="$1"; shift
  local path="$1"; shift
  local data="${1:-}"; shift || true
  local args=( -k -s --max-time 25 -X "$method" "$API_BASE$path" )
  if [ -n "${TOKEN:-}" ]; then args+=( -H "Authorization: Bearer $TOKEN" ); fi
  if [ -n "$data" ]; then args+=( -H "Content-Type: application/json" -d "$data" ); fi
  # pass-through extra curl args (e.g., -H "X-CSRF-Token: ...")
  if [ "$#" -gt 0 ]; then args+=( "$@" ); fi
  curl "${args[@]}"
}

req_status() {
  local method="$1" path="$2"
  shift 2 || true
  local code
  # Wichtig: data-Parameter leer lassen, damit zusätzliche curl-Optionen nicht als Body gesendet werden
  code=$(req "$method" "$path" "" -o /dev/null -w "%{http_code}") || true
  echo "$code"
}

get_csrf() {
  local json
  json=$(req GET "/auth/csrf-token")
  echo "$json" | jq -r .csrfToken
}

# ---------- Auth ----------
header "Login"
TOKEN=$(curl -k -s -X POST "$API_BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" | jq -r .accessToken)
if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then fail "Login fehlgeschlagen"; record auth_login fail; exit 1; fi
ok "Access-Token erhalten"; record auth_login ok

CSRF=$(get_csrf || true)
if [ -n "$CSRF" ] && [ "$CSRF" != "null" ]; then ok "CSRF erhalten"; record auth_csrf ok; else fail "CSRF fehlend"; record auth_csrf fail; fi

# ---------- Health ----------
header "Health"
for p in "/health" "/health/detailed" "/client-config"; do
  code=$(req_status GET "$p")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then ok "$p -> $code"; record "health_$p" ok; else fail "$p -> $code"; record "health_$p" fail; fi
done

# ---------- Auth Suite ----------
header "Auth Suite"
for p in "/auth/me"; do
  code=$(req_status GET "$p")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then ok "$p -> $code"; record "auth_$p" ok; else fail "$p -> $code"; record "auth_$p" fail; fi
done

# permissions (dynamisch, toleriert 200/403)
code=$(req_status GET "/auth/permissions?keys=arb.view,system.logs,world.view")
if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then ok "/auth/permissions -> $code"; record auth_permissions ok; else fail "/auth/permissions -> $code"; record auth_permissions fail; fi

# authorize (resource/action)
code=$(req_status GET "/auth/authorize?resource=world&action=view")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "/auth/authorize world:view -> $code" || fail "/auth/authorize world:view -> $code"; record auth_authorize_view "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"
code=$(req_status GET "/auth/authorize?resource=world&action=edit&worldId=$WORLD_ID")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "/auth/authorize world:edit -> $code" || fail "/auth/authorize world:edit -> $code"; record auth_authorize_edit "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"

# ---------- Worlds ----------
header "Worlds"
worlds_json=$(req GET "/worlds") || true
code=$([[ -n "$worlds_json" ]] && echo 200 || echo 500)
if [ "$code" = "200" ]; then ok "/worlds -> 200"; record worlds_list ok; else fail "/worlds -> $code"; record worlds_list fail; fi

# bestmögliche Welt wählen: open > running > upcoming; sonst erste
pick_field() { echo "$1" | jq -r "$2 // empty" 2>/dev/null || true; }
candidate=$(echo "$worlds_json" | jq -c '[.[] | {id, slug, status}]')
WORLD_ID_SEL=$(echo "$candidate" | jq -r 'map(select(.status=="open")) | .[0].id // empty')
WORLD_SLUG_SEL=$(echo "$candidate" | jq -r 'map(select(.status=="open")) | .[0].slug // empty')
if [ -z "$WORLD_ID_SEL" ] || [ "$WORLD_ID_SEL" = "null" ]; then
  WORLD_ID_SEL=$(echo "$candidate" | jq -r 'map(select(.status=="running")) | .[0].id // empty')
  WORLD_SLUG_SEL=$(echo "$candidate" | jq -r 'map(select(.status=="running")) | .[0].slug // empty')
fi
if [ -z "$WORLD_ID_SEL" ] || [ "$WORLD_ID_SEL" = "null" ]; then
  WORLD_ID_SEL=$(echo "$candidate" | jq -r 'map(select(.status=="upcoming")) | .[0].id // empty')
  WORLD_SLUG_SEL=$(echo "$candidate" | jq -r 'map(select(.status=="upcoming")) | .[0].slug // empty')
fi
if [ -z "$WORLD_ID_SEL" ] || [ "$WORLD_ID_SEL" = "null" ]; then
  WORLD_ID_SEL=$(echo "$candidate" | jq -r '.[0].id // empty')
  WORLD_SLUG_SEL=$(echo "$candidate" | jq -r '.[0].slug // empty')
fi

# Fallback auf gesetzte Umgebungswerte, falls Auswahl leer
WORLD_ID_EFF=${WORLD_ID_SEL:-$WORLD_ID}
WORLD_SLUG_EFF=${WORLD_SLUG_SEL:-$WORLD_SLUG}

code=$(req_status GET "/worlds/$WORLD_SLUG_EFF")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "/worlds/:slug -> $code" || fail "/worlds/:slug -> $code"; record worlds_get_slug "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"

code=$(req_status GET "/worlds/$WORLD_SLUG_EFF/state")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "/worlds/:slug/state -> $code" || fail "/worlds/:slug/state -> $code"; record worlds_state "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"

if [ -n "$CSRF" ] && [ "$CSRF" != "null" ] && [ -n "$WORLD_ID_EFF" ]; then
  code=$(req_status POST "/worlds/$WORLD_ID_EFF/join" "{}" -H "X-CSRF-Token: $CSRF")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "403" ]; then ok "join -> $code"; record worlds_join ok; else fail "join -> $code"; record worlds_join fail; fi

  code=$(req_status GET "/worlds/$WORLD_ID_EFF/players/me")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "404" ]; then ok "players/me -> $code"; record worlds_players_me ok; else fail "players/me -> $code"; record worlds_players_me fail; fi

  code=$(req_status DELETE "/worlds/$WORLD_ID_EFF/players/me" "" -H "X-CSRF-Token: $CSRF")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "404" ]; then ok "leave -> $code"; record worlds_leave ok; else fail "leave -> $code"; record worlds_leave fail; fi
else
  record worlds_join skip
  record worlds_leave skip
fi

# ---------- Invites ----------
header "Invites"
code=$(req_status POST "/invites/public" "{\"worldId\":$WORLD_ID_EFF,\"emails\":[\"api-full-check@example.com\"]}")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "invites/public -> $code" || fail "invites/public -> $code"; record invites_public "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"

code=$(req_status GET "/invites/world/$WORLD_ID")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "invites/world/:id -> $code" || fail "invites/world/:id -> $code"; record invites_world "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"

# ---------- Logs ----------
header "Logs"
for p in "/logs/categories" "/logs/info" "/logs/data?file=app.log" "/logs/stats"; do
  code=$(req_status GET "$p")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "403" ]; then ok "$p -> $code"; record "logs_$p" ok; else fail "$p -> $code"; record "logs_$p" fail; fi
done

# ---------- Themes ----------
header "Themes"
code=$(req_status GET "/themes")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "/themes -> $code" || fail "/themes -> $code"; record themes_list "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"

code=$(req_status GET "/themes/$THEME_NAME")
if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "404" ]; then ok "/themes/$THEME_NAME -> $code"; record themes_get ok; else fail "/themes/$THEME_NAME -> $code"; record themes_get fail; fi

code=$(req_status GET "/themes/named-entrypoints")
[[ "$code" =~ ^2[0-9][0-9]$ ]] && ok "/themes/named-entrypoints -> $code" || fail "/themes/named-entrypoints -> $code"; record themes_entrypoints "$([[ "$code" =~ ^2 ]] && echo ok || echo fail)"

# ---------- Metrics ----------
header "Metrics"
for p in "/metrics" "/metrics/summary" "/metrics/api" "/metrics/users" "/metrics/game" "/metrics/system"; do
  code=$(req_status GET "$p")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "403" ]; then ok "$p -> $code"; record "metrics_$p" ok; else fail "$p -> $code"; record "metrics_$p" fail; fi
done

# ---------- Query Performance ----------
header "Query Performance"
for p in "/query-performance" "/query-performance/health" "/query-performance/recommendations" "/query-performance/slow-queries" "/query-performance/summary"; do
  code=$(req_status GET "$p")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "403" ]; then ok "$p -> $code"; record "qp_$p" ok; else fail "$p -> $code"; record "qp_$p" fail; fi
done

# ---------- Backup Manager ----------
header "Backup"
for p in "/backup" "/backup/health" "/backup/jobs" "/backup/tables" "/backup/stats"; do
  code=$(req_status GET "$p")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "403" ]; then ok "$p -> $code"; record "backup_$p" ok; else fail "$p -> $code"; record "backup_$p" fail; fi
done

# ---------- ARB Manager API ----------
header "ARB"
for p in "/arb/languages" "/arb/compare" "/arb/de"; do
  code=$(req_status GET "$p")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]] || [ "$code" = "403" ]; then ok "$p -> $code"; record "arb_$p" ok; else fail "$p -> $code"; record "arb_$p" fail; fi
done

# ---------- Summary ----------
echo
cyan "=== Done ==="
fails=$(printf '%s\n' "${_results[@]}" | grep -c "|fail" || true)
if [ "$fails" -eq 0 ]; then ok "Full API Check abgeschlossen (keine harten Fehler)"; else fail "$fails harte Fehler gefunden"; fi

if [ "$REPORT_LC" = "json" ]; then
  results_text=$(printf '%s\n' "${_results[@]}")
  jq -n --arg api "$API_BASE" --arg user "$USERNAME" --arg worldId "$WORLD_ID" --arg worldSlug "$WORLD_SLUG" --arg results "$results_text" '
    def parseResults($s): ($s | split("\n") | map(select(length>0) | split("|") | {name: .[0], status: .[1]}));
    def failCount($arr): ($arr | map(select(.status=="fail")) | length);
    (
      parseResults($results) as $r | {
        api: $api,
        username: $user,
        world: { id: $worldId, slug: $worldSlug },
        results: $r,
        summary: { total: ($r|length), failures: failCount($r) },
        timestamp: (now|todate)
      }
    )
  '
fi


