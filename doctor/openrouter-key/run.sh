#!/usr/bin/env bash
# Pack doctor check: GASCITY_OPENROUTER_API_KEY, referenced by
# [upstreams.openrouter] in city.toml, must be present in the environment
# gc agents run with.
#
# Exit codes: 0=OK, 1=Warning, 2=Error
# stdout: first line=message, rest=details

if [ -n "${GASCITY_OPENROUTER_API_KEY:-}" ]; then
    echo "GASCITY_OPENROUTER_API_KEY is set"
    exit 0
fi

echo "GASCITY_OPENROUTER_API_KEY is not set"
echo ""
echo "city.toml [upstreams.openrouter] references \$GASCITY_OPENROUTER_API_KEY."
echo "Any agent that sets upstream = \"openrouter\" will fail authentication"
echo "until the key is exported in the environment the controller runs from."
exit 1
