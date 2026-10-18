#!/bin/sh
# gascity report — one-shot city digest.
# Invoked as: gc gascity report [args...]
#
# Environment (set by gc):
#   GC_CITY_PATH — absolute city root
#   GC_PACK_DIR  — absolute pack directory
#   GC_CITY_NAME — city workspace name

set -e

GC="${GC_BIN:-gc}"

echo "== status =="
"$GC" status 2>/dev/null || echo "(gc status unavailable)"
echo
echo "== ready (claimable) work =="
"$GC" ready 2>/dev/null || echo "(none / unavailable)"
echo
echo "== orders due =="
OUT="$("$GC" order check 2>/dev/null || true)"
if [ -n "$OUT" ]; then
    echo "$OUT"
else
    echo "(order check unavailable)"
fi
echo
echo "== session crashes (24h) =="
CRASHES="$("$GC" events --type session.crashed --since 24h 2>/dev/null || true)"
if [ -n "$CRASHES" ]; then
    echo "$CRASHES"
else
    echo "(none)"
fi
