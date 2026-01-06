# dot-agents

Consolidated agent configs for Claude, Codex, and Gemini with shared `MASTER-AGENTS.md` protocol.

## Structure

**Claude & Codex** (GNU Stow):
```
~/.claude  → dot-agents/claude/.claude
~/.codex   → dot-agents/codex/.codex
```

**Gemini** (real dir + selective symlinks; CLI needs writable runtime):
```
~/.gemini/              = real directory
~/.gemini/GEMINI.md, settings.json, commands/ = symlinked to repo
```

All symlink to `shared/MASTER-AGENTS.md` (single protocol source).

## What's Tracked / Ignored

**Tracked**: settings, commands, prompts, skills, rules
**Ignored**: runtime (history, cache), secrets (OAuth), browser profiles

See `.gitignore` for details.

## Installation

```bash
brew install stow
./scripts/install.sh
```

Backs up existing dirs → archives, installs symlinks, restores essentials.

## Rollback

```bash
stow -D claude codex
LATEST=$(ls -td archive/*/ | head -1)
cp -R "${LATEST}"* ~
```
