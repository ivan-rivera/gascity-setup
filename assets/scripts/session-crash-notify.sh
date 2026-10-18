#!/usr/bin/env bash
# session-crash-notify — mail + nudge the mayor when a session crashes.
#
# Subscribes to session.crashed events. For each crash not yet notified,
# sends mail to the mayor (recipient configurable via
# GC_SESSION_CRASH_RECIPIENT). Idempotent: a given session_id is notified at
# most once; dedup state lives in $GC_PACK_STATE_DIR so it is both city- and
# pack-scoped. Loud-fail: undeliverable sends exit non-zero so the
# controller logs the output (same contract as core's
# notify-on-human-gate-creation).
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
    echo "session-crash-notify: jq is required to decode the event stream" >&2
    exit 2
fi

CITY="${GC_CITY:-.}"
# Event lookback window. Must exceed the controller's event-trigger eval
# cadence so no session.crashed event is missed between runs.
LOOKBACK="${GC_SESSION_CRASH_LOOKBACK:-10m}"
# Dedup entries older than this are pruned so the state file stays bounded.
RETENTION="${GC_SESSION_CRASH_RETENTION:-1h}"
RECIPIENT="${GC_SESSION_CRASH_RECIPIENT:-mayor}"

PACK_STATE_DIR="${GC_PACK_STATE_DIR:-${GC_CITY_RUNTIME_DIR:-$CITY/.gc/runtime}/packs/gascity}"
STATE_FILE="$PACK_STATE_DIR/session-crash-notify-state.json"
mkdir -p "$PACK_STATE_DIR"

# Best-effort: a read failure (API down) must not crash the order loop.
EVENTS="$(gc events --type session.crashed --since "$LOOKBACK" 2>/dev/null)" || exit 0
[ -n "$EVENTS" ] || exit 0

# Event lines carry session_id / subject / ts at the top level; the payload
# reason is read defensively (string, object field, or absent).
CRASHES="$(printf '%s\n' "$EVENTS" \
    | jq -r 'select(.type == "session.crashed")
             | [.session_id, (.subject // "?"), (.ts // "?"),
                (.payload | if type == "object" then (.reason // .error // "") else (if type == "string" then . else "" end) end)]
             | @tsv' 2>/dev/null)" || CRASHES=""
[ -n "$CRASHES" ] || exit 0

# Load dedup state (object mapping "<session-id>" -> ISO timestamp). A
# missing or corrupt file resets to empty rather than failing.
STATE="$(cat "$STATE_FILE" 2>/dev/null || true)"
echo "$STATE" | jq -e 'type == "object"' >/dev/null 2>&1 || STATE='{}'

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
NOTIFIED=0
FAILED=0
while IFS=$'\t' read -r sid subject ts reason; do
    [ -n "$sid" ] || continue
    if [ "$(echo "$STATE" | jq --arg k "$sid" 'has($k)')" = "true" ]; then
        continue
    fi
    BODY="Session ${subject} (${sid}) crashed at ${ts}. Reason: ${reason:-none recorded}. Inspect with: gc events --type session.crashed"
    if gc mail send "$RECIPIENT" --notify \
        -s "SESSION CRASHED: ${subject} (${sid})" \
        -m "$BODY" >/dev/null 2>&1; then
        STATE="$(echo "$STATE" | jq --arg k "$sid" --arg t "$NOW" '.[$k] = $t')"
        NOTIFIED=$((NOTIFIED + 1))
    else
        echo "session-crash-notify: mail send failed for $sid ($subject)" >&2
        FAILED=$((FAILED + 1))
    fi
done <<EOF
$CRASHES
EOF

# Convert a simple Ns/Nm/Nh duration to whole seconds.
duration_to_seconds() {
    case "$1" in
        *h) echo $((${1%h} * 3600)) ;;
        *m) echo $((${1%m} * 60)) ;;
        *s) echo $((${1%s})) ;;
        *) echo 3600 ;;
    esac
}

# Prune entries older than RETENTION so the state file stays bounded.
RETENTION_S="$(duration_to_seconds "$RETENTION")"
STATE="$(echo "$STATE" | jq --argjson keep "$RETENTION_S" \
    'with_entries(select((now - (.value | fromdateiso8601)) <= $keep))')" || true

# Atomic write: temp file in the same dir, then rename.
TMP="$(mktemp "$PACK_STATE_DIR/.session-crash-notify-state.XXXXXX")"
printf '%s\n' "$STATE" > "$TMP"
mv -f "$TMP" "$STATE_FILE"

if [ "$NOTIFIED" -gt 0 ]; then
    echo "session-crash-notify: notified $NOTIFIED crash(es)"
fi

# Loud-fail: successes are already deduped in state; a non-zero exit now
# surfaces the per-crash failure lines above in the controller log.
if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
exit 0
