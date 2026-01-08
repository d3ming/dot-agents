# Gemini Config: Current Model + Differences

## Why Gemini is different
Gemini writes to its instruction file (`GEMINI.md`) during use. If that file is shared with other agents, Gemini “memory” updates will pollute shared rules. To isolate those writes, Gemini uses a Gemini-specific file and loads shared rules at session start.

## Current layout (source of truth)
- Shared rules: `master/AGENTS.md`
- Gemini-specific additions (writable): `master/GEMINI.md`
- Handcrafted command templates: `gemini/templates/commands/*.toml`
- Generated commands (handcrafted + skills): `gemini/.gemini/commands/*.toml`
- Shared skills: `master/skills/` (Gemini uses `~/.gemini/skills` symlink)

## Home directory mapping
- `~/.gemini/` is a real directory (history, cache, etc.)
- `~/.gemini/GEMINI.md` → symlink to `master/GEMINI.md`
- `~/.gemini/settings.json` → symlink to `gemini/.gemini/settings.json` (canonical)
- `~/.gemini/commands/` → symlink to `gemini/.gemini/commands/`
- `~/.gemini/skills/` → symlink to `master/skills/`

## Build + install flow
1) `make build`
   - Expands `@{...}` includes in `gemini/templates/commands/`
   - Generates skill-based commands from `master/skills/`
   - Writes all commands into `gemini/.gemini/commands/`
2) `make setup`
   - Runs `scripts/install.sh`
   - Ensures symlinks in `~/.gemini/` and preserves runtime dirs
3) Start Gemini session:
   - Run `init-agent` to load shared rules (`master/AGENTS.md`)

## Known sharp edges
- Gemini writes to `~/.gemini/GEMINI.md`, which is a symlink to `master/GEMINI.md`.
  - Keep shared rules in `master/AGENTS.md`; `master/GEMINI.md` is for Gemini-only additions.

## Differences vs Claude/Codex
- Claude/Codex are fully stowed (`~/.claude`, `~/.codex` → repo).
- Gemini keeps runtime dirs writable and uses a dedicated GEMINI.md copy to isolate writes.

## Ideas to simplify (brainstorm)
- Single “sync” helper: a `make gemini-sync` target that adds a short reminder in `master/GEMINI.md`.
- Optional “init” automation: add a shell alias to run `init-agent` on session start.
- Explore if Gemini supports a separate memory file; if yes, redirect writes and remove the GEMINI.md duplicate.
