#!/usr/bin/env bash
# Pack doctor check: GASCITY_OPENROUTER_API_KEY — the dedicated OpenRouter
# key for GasCity spend (cost-isolated from OMP's OPENROUTER_API_KEY) — must
# be provisioned. It backs [upstreams.openrouter] in city.toml and the
# oracle/reviewer agents' key overrides. The controller expands $VAR refs
# from its own environment, so the key must live there (or in the secrets
# file the supervisor install reads).
#
# Exit codes: 0=OK, 1=Warning, 2=Error
# stdout: first line=message, rest=details

if [ -n "${GASCITY_OPENROUTER_API_KEY:-}" ]; then
    echo "GASCITY_OPENROUTER_API_KEY is set"
    exit 0
fi

SECRETS="${GC_HOME:-$HOME/.gc}/secrets.env"
if [ -f "$SECRETS" ] && grep -q '^GASCITY_OPENROUTER_API_KEY=..*' "$SECRETS" 2>/dev/null; then
    echo "GASCITY_OPENROUTER_API_KEY present in $SECRETS (picked up by supervisor install)"
    exit 0
fi

echo "GASCITY_OPENROUTER_API_KEY is not provisioned"
echo ""
echo "This is the dedicated GasCity OpenRouter key (cost tracking), separate"
echo "from OMP's OPENROUTER_API_KEY. Store it in ~/.gc/secrets.env (KEY=value,"
echo "mode 600) and/or export it in your shell, then persist it into the"
echo "supervisor environment:"
echo "  GC_SUPERVISOR_ENV=GASCITY_OPENROUTER_API_KEY gc supervisor install --force"
echo "followed by a supervisor restart. The oracle and reviewer agents bill"
echo "their model spend through this key."
exit 1
