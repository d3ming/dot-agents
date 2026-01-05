# dot-agents

Consolidated agent configuration for Claude, Codex, and Gemini—managed via GNU Stow with a shared `AGENTS.md` source of truth.

## Structure

```
~/.claude  → dot-agents/claude/.claude
~/.codex   → dot-agents/codex/.codex
~/.gemini  → dot-agents/gemini/.gemini

# Inside each:
CLAUDE.md/AGENTS.md/GEMINI.md → ../../shared/AGENTS.md
```

## What's Tracked

- **Claude**: `settings.json`, `commands/`
- **Codex**: `AGENTS.md`, `prompts/`, `skills/`, `rules/`
- **Gemini**: `settings.json`, `commands/`
- **Shared**: `AGENTS.md` (single source of truth)

## What's Excluded (gitignored)

- Runtime state (sessions, history, snapshots)
- Secrets (OAuth creds, tokens, API keys)
- Cache (browser profiles, recordings)
- See `.gitignore` for full list

## Installation

**Prerequisites**: GNU Stow (`brew install stow`)

```bash
./scripts/install.sh
```

This will:
1. Back up existing `~/.claude`, `~/.codex`, `~/.gemini` to `archive/`
2. Create Stow symlinks
3. Restore essential runtime state (auth, identity)
4. Skip 6GB+ of cache/recordings

## Scripts

- `stage-configs.sh` — Full backup to `archive/`
- `copy-to-repo.sh` — Copy trackable files from archive to repo (excludes runtime)
- `create-shared-symlinks.sh` — Link AGENTS.md variants to shared source
- `install.sh` — Main installation (backup + Stow + restore essentials)

## Rollback

```bash
# Uninstall symlinks
cd ~/projects/dot-agents
stow -D claude codex gemini

# Restore from latest archive
LATEST=$(ls -td archive/*/ | head -1)
mv "${LATEST}claude" ~/.claude
mv "${LATEST}codex" ~/.codex
mv "${LATEST}gemini" ~/.gemini
```

## Publishing

`archive/` is gitignored. Before pushing to remote:

```bash
# Final secret scan
rg -i '(api[_-]?key|secret|token|oauth)' claude codex gemini shared

# If clean, push
git remote add origin <repo-url>
git push -u origin main
```

## Philosophy

**Option B**: Full directory symlinks + strict gitignore. Runtime state lives in repo working tree but is never committed. This gives single-location simplicity while maintaining security.

See `PLAN.md` for migration details and decisions.
