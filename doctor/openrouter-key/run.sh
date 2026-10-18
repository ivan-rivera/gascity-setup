#!/usr/bin/env bash
# Pack doctor check: OPENROUTER_API_KEY must be present in the environment
# gc runs with. It backs two consumers: the [upstreams.openrouter] block in
# city.toml (GasCity-served harnesses such as codex/opencode) and the
# reviewer agent's `ocr` runs (open-code-review, provider openrouter).
#
# Exit codes: 0=OK, 1=Warning, 2=Error
# stdout: first line=message, rest=details

if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    echo "OPENROUTER_API_KEY is set"
    exit 0
fi

echo "OPENROUTER_API_KEY is not set"
echo ""
echo "city.toml [upstreams.openrouter] references \$OPENROUTER_API_KEY, and"
echo "the reviewer agent's ocr runs authenticate with it too. Export it in"
echo "the environment the controller runs from — the supervisor's launchd"
echo "environment, which spawned agent sessions inherit."
exit 1
