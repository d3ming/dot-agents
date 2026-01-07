# dot-agents

Consolidated agent configs for Claude, Codex, and Gemini with master `AGENTS.md` protocol.

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

All symlink to `master/AGENTS.md` (single protocol source).

## Shared Skills Pattern

Canonical skill lives in `master/skills/<name>/SKILL.md`. Then:

```
codex/.codex/skills/<name>  -> ../../../master/skills/<name>
claude/.claude/skills/<name> -> ../../../master/skills/<name>
gemini/.gemini/commands/<name>.toml  (wrapper, injects shared SKILL.md)
```

## What's Tracked / Ignored

**Tracked**: settings, commands, prompts, skills, rules
**Ignored**: runtime (history, cache), secrets (OAuth), browser profiles

See `.gitignore` for details.

## Installation

One-time setup for a new machine:

```bash
brew install stow gitleaks
make setup
```

## Workflows

### Maintenance
When you add or update shared skills or modify templates in `gemini/templates/`, rebuild Gemini configs (also relinks Codex+Claude skills):

```bash
make build
```

If you need to refresh Gemini’s symlinked files in `~/.gemini/`, rerun:

```bash
make setup
```

### Gemini refresh flow
To keep Gemini in sync with repo changes, run:

```bash
make build
make setup
```

At the start of a Gemini session, run the `init-gemini` command to load Gemini-specific instructions.

### Security
A pre-commit hook is installed automatically during `make setup`. To run a manual scan:

```bash
make lint
```

### Cleaning
To remove generated artifacts:

```bash
make clean
```
