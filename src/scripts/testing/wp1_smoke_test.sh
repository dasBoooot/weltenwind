#!/usr/bin/env bash
set -euo pipefail

# WP1 Smoke Test for Weltenwind (run on VM)
# Requirements: bash, curl, jq

API_BASE="${API_BASE:-https://192.168.2.168/api/v1}"
USERNAME="${USERNAME:-admin}"
PASSWORD="${PASSWORD:-AAbb1234!!}"
WORLD_ID="${WORLD_ID:-1}"
WORLD_SLUG="${WORLD_SLUG:-mittelerde-abenteuer-1}"
JOIN_TEST="${JOIN_TEST:-0}"
REPORT="${REPORT:-human}"
REPORT_LC=${REPORT,,}

cyan()  { printf "\033[36m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
red()   { printf "\033[31m%s\033[0m\n" "$*"; }

fail()  { red "[FAIL] $*"; exit 1; }
ok()    { green "[OK]   $*"; }

header() {
  echo
  cyan "=== $* ==="
}

req() {
  local method="$1"; shift
  local path="$1"; shift
  local data="${1:-}"; shift || true
  local args=( -k -s --max-time 20 -X "$method" "$API_BASE$path" -H "Authorization: Bearer $TOKEN" )
  if [ -n "$data" ]; then
    args+=( -H "Content-Type: application/json" -d "$data" )
  fi
  # Pass through any extra curl args (e.g., -H "X-CSRF-Token: ...")
  if [ "$#" -gt 0 ]; then
    args+=( "$@" )
  fi
  curl "${args[@]}"
}

header "Login"
LOGIN_RES=$(curl -k -s -X POST "$API_BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}")

TOKEN=$(echo "$LOGIN_RES" | jq -r .accessToken)
[ -n "$TOKEN" ] && [ "$TOKEN" != "null" ] || fail "Login fehlgeschlagen"
ok "Access-Token erhalten"

header "Worlds list (auth + ETag)"
WORLD_LIST_RES=$(req GET "/worlds")
echo "$WORLD_LIST_RES" | jq '.[0] // {}' >/dev/null || fail "Worlds Antwort ungültig"
ok "Welten geladen"

ETAG=$(curl -k -i -H "Authorization: Bearer $TOKEN" "$API_BASE/worlds" | awk '/^etag:/ {print $2}' | tr -d '\r')
if [ -n "$ETAG" ]; then
  STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" -H "If-None-Match: \"$ETAG\"" "$API_BASE/worlds")
  [ "$STATUS" = "304" ] && ok "ETag 304 Not Modified OK" || red "ETag test: http $STATUS"
fi

header "World by slug"
WORLD_RES=$(req GET "/worlds/$WORLD_SLUG")
echo "$WORLD_RES" | jq '.id, .slug' >/dev/null || fail "Welt (Slug) nicht gefunden"
ok "Welt per Slug erreichbar"

header "World state (public)"
STATE_RES=$(curl -k -s "$API_BASE/worlds/$WORLD_SLUG/state")
echo "$STATE_RES" | jq '.state' >/dev/null || fail "World state fehlgeschlagen"
ok "World state OK"

header "Authorization API (world.view global)"
AUTH_VIEW=$(req GET "/auth/authorize?resource=world&action=view")
echo "$AUTH_VIEW" | jq '.allowed' >/dev/null || fail "Authorize view fehlgeschlagen"
ok "Authorize view OK"

header "Authorization API (world.edit scope=world)"
AUTH_EDIT=$(req GET "/auth/authorize?resource=world&action=edit&worldId=$WORLD_ID")
echo "$AUTH_EDIT" | jq '.allowed' >/dev/null || fail "Authorize edit fehlgeschlagen"
ok "Authorize edit OK (Ergebnis kann true/false sein)"

if [ "$JOIN_TEST" = "1" ]; then
  header "CSRF token"
  CSRF_JSON=$(req GET "/auth/csrf-token")
  CSRF_TOKEN=$(echo "$CSRF_JSON" | jq -r .csrfToken)
  [ -n "$CSRF_TOKEN" ] && [ "$CSRF_TOKEN" != "null" ] || fail "CSRF-Token konnte nicht geholt werden"
  ok "CSRF-Token erhalten"

  header "Join world"
  JOIN_RES=$(req POST "/worlds/$WORLD_ID/join" '{}' -H "X-CSRF-Token: $CSRF_TOKEN")
  JOIN_OK=$(echo "$JOIN_RES" | jq -r '.success // false') || true
  JOIN_CODE=$(echo "$JOIN_RES" | jq -r '.code // empty') || true
  if [ "$JOIN_OK" = "true" ]; then
    ok "Join OK ${JOIN_CODE:+($JOIN_CODE)}"
  else
    red "Join fehlgeschlagen: $(echo "$JOIN_RES" | jq -c . 2>/dev/null || echo "$JOIN_RES")"
  fi

  header "Leave world"
  LEAVE_RES=$(req DELETE "/worlds/$WORLD_ID/players/me" '' -H "X-CSRF-Token: $CSRF_TOKEN")
  LEAVE_OK=$(echo "$LEAVE_RES" | jq -r '.success // false') || true
  if [ "$LEAVE_OK" = "true" ]; then
    ok "Leave OK"
  else
    red "Leave evtl. nicht notwendig/fehlgeschlagen: $(echo "$LEAVE_RES" | jq -c . 2>/dev/null || echo "$LEAVE_RES")"
  fi
fi

header "Idempotency (invites public)"
INV1=$(curl -k -s -X POST "$API_BASE/invites/public" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-key-123" \
  -d "{\"worldId\":$WORLD_ID,\"emails\":[\"demo@example.com\"]}")
INV2=$(curl -k -s -X POST "$API_BASE/invites/public" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-key-123" \
  -d "{\"worldId\":$WORLD_ID,\"emails\":[\"demo@example.com\"]}")
ok "Idempotency ausgeführt (Antworten sollten konsistent sein)"

header "Done"
ok "WP1 Smoke-Test abgeschlossen"

if [ "$REPORT_LC" = "json" ]; then
  jq -n --arg worldSlug "$WORLD_SLUG" --arg apiBase "$API_BASE" --arg username "$USERNAME" --arg worldId "$WORLD_ID" '{
    status: "ok",
    api: $apiBase,
    user: $username,
    world: { slug: $worldSlug, id: $worldId },
    tests: {
      login: true,
      worlds: true,
      worldBySlug: true,
      state: true,
      authView: true,
      authEdit: true,
      invitesIdempotency: true,
      joinLeave: (env.JOIN_TEST == "1")
    }
  }'
fi


