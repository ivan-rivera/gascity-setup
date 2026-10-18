# gascity-setup

GasCity city configuration repo. The city lives at `~/Documents/dev/gascity`, which symlinks its config items (`city.toml`, `pack.toml`, `packs.lock`, `.gitignore`, `agents/`, `assets/`, `commands/`, `doctor/`, `formulas/`, `orders/`, `overlay/`, `template-fragments/`) into this repo — same convention as `~/.omp/agent -> ~/Documents/dev/omp-setup/harness`. Runtime state (`.gc/`, `.beads/`, `.dolt-backup/`, and friends) stays in the city dir and is never committed here. Docs: https://docs.gascityhall.com

## Layout

| Path | What it is |
|---|---|
| `city.toml` | Deployment layer: providers, upstreams, rig imports, agent defaults. |
| `pack.toml` | City-pack manifest: identity, pinned imports (`bd`, `core`, `gc`), named sessions. |
| `packs.lock` | Resolved import pins. |
| `agents/<name>/` | Local agents: `agent.toml` + `prompt.template.md`, discovered by convention. |
| `formulas/` | Local formulas (`<name>.toml`, formulas v2 contract). |
| `orders/` | Local orders (`<name>.toml`: cooldown / cron / event triggers). |
| `commands/<path>/` | Pack commands (`run.sh` + optional `command.toml` / `help.md`); surface as `gc gascity <words>`. |
| `doctor/<name>/` | Pack doctor checks (`run.sh` + optional `doctor.toml` / `fix.sh`). |
| `template-fragments/` | Shared prompt fragments (`{{ define }}` blocks), attached via `append_fragments`. |
| `assets/` | Private support files (scripts etc.) referenced by definitions. |
| `overlay/` | Pack overlay files, collected as the base overlay layer. |

The pack spec and formula spec v2 (https://docs.gascityhall.com) are the
source of truth. Validate with `gc lint ~/Documents/dev/gascity`; apply
changes with `gc reload` from the city dir.
