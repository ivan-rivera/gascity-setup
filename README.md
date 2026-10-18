# gascity-setup

GasCity city configuration repo. The city lives at `~/Documents/dev/gascity`, which symlinks its config items (`city.toml`, `pack.toml`, `packs.lock`, `.gitignore`, `agents/`, `assets/`, `commands/`, `doctor/`, `formulas/`, `orders/`, `overlays/`, `template-fragments/`) into this repo — same convention as `~/.omp/agent -> ~/Documents/dev/omp-setup/harness`. Runtime state (`.gc/`, `.beads/`, `.dolt-backup/`, and friends) stays in the city dir and is never committed here. Docs: https://docs.gascityhall.com
