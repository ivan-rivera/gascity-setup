# gascity-setup

Versioned configuration for my GasCity city. The city itself lives at
`~/Documents/dev/gascity`; its pack content is symlinked from here (same
convention as `~/.omp/agent -> ~/Documents/dev/omp-setup/harness`).
Runtime state (`.gc/`, `.beads/`, `.dolt-backup/`, `Library/`, …) stays in
the city dir and is never committed.

## The city

- **City:** `gascity` at `~/Documents/dev/gascity`, supervisor-managed.
- **Rig:** `omp-setup` → `~/Documents/dev/omp-setup`, imports the 12 `gc.*` role agents (triager, decomposer, workers, reviewers, publisher, run-operator).
- **Local agents:** `mayor` (always-on coordinator), `omp-worker` (rig worker).
- **From imports:** the pinned `core` / `bd` / `gc` packs supply pool workers, `bd.dog`, control dispatchers, and the bundled formulas, orders, and housekeeping.

## Layout

| Path | What it is |
|---|---|
| `city.toml` | Deployment layer: providers (`omp`, `claude`), OpenRouter upstream, rig imports, `[agent_defaults]`. |
| `pack.toml` | City-pack manifest: identity, pinned imports, the always-on `mayor` named session. |
| `packs.lock` | Resolved import pins. |
| `agents/<name>/` | Local agents — `agent.toml` + `prompt.template.md`, discovered by convention. |
| `formulas/` | Local formulas, v2 contract — `city-errand` (do → verify on the `omp` pool). |
| `orders/` | Local orders — `session-crash-notify` (event trigger: mails + nudges the mayor on crashes). |
| `commands/<path>/` | Pack commands, surface as `gc gascity <words>` — `report`. |
| `doctor/<name>/` | Pack doctor checks — `openrouter-key`. |
| `template-fragments/` | Prompt fragments attached via `append_fragments` — `owner-conventions`, city-wide. |
| `assets/` | Private support files — the crash-notify script. |
| `overlay/` | Pack overlay files, collected as the base overlay layer. |

## Workflow

1. Edit here — the city reads through the symlinks.
2. Validate: `gc lint ~/Documents/dev/gascity`.
3. Apply: `gc reload` from the city dir (the controller's watcher usually picks changes up on its own).
4. Verify: `gc prime mayor`, `gc formula catalog`, `gc order list`, `gc doctor`, `gc gascity report`.
5. Commit.

## Restore on a new machine

After `gc init <city-dir>`, point the city at this repo:

```sh
cd <city-dir>
ITEMS="city.toml pack.toml packs.lock .gitignore agents assets commands \
doctor formulas orders overlay template-fragments"
rm -rf $ITEMS
for f in $ITEMS; do ln -s ~/Documents/dev/gascity-setup/$f $f; done
```

Specs are the source of truth: https://docs.gascityhall.com.
