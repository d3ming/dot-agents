# dot-agents

Consolidated agent configs for Claude, Codex, and Gemini with master `AGENTS.md` protocol.

## Structure

**Home-level dotfiles** (GNU Stow):
```
~/.claude.json → dot-agents/home/.claude.json (preferences: autoCompactEnabled, etc.)
```

**Claude & Codex** (GNU Stow):
```
~/.claude  → dot-agents/claude/.claude (settings, commands, skills)
~/.codex   → dot-agents/codex/.codex   (rules, prompts, skills)
```

**Gemini** (real dir + selective symlinks; CLI needs writable runtime):
```
~/.gemini/              = real directory (history/, cache/, etc.)
~/.gemini/GEMINI.md, settings.json, commands/, skills/ = symlinked to repo
~/.gemini/settings.json → dot-agents/gemini/.gemini/settings.json (canonical)
~/.gemini/GEMINI.md → dot-agents/master/GEMINI.md (Gemini-writable extras)
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

**Tracked**:
- Settings files (`.claude/settings.json`, `.codex/rules/`, `.gemini/settings.json`)
- Preferences (`home/.claude.json` - cached feature flags removed)
- Commands, prompts, skills, rules
- Shared protocols (`master/AGENTS.md`)

**Ignored**:
- Runtime state (history.jsonl, cache/, debug/, session-env/)
- Secrets (OAuth, auth tokens)
- Browser profiles, telemetry
- Large cached data (Statsig gates, GrowthBook features)

See `.gitignore` for details.

### How GNU Stow Works

Stow creates symlinks by mirroring directory structure:
```bash
# Package structure:
dot-agents/home/.claude.json    # Package dir "home/" is stripped
# Result: ~/.claude.json → /full/path/to/dot-agents/home/.claude.json

# Installation:
cd dot-agents && stow -t ~ home   # Symlinks everything in home/ to ~/
```

The package directory name is removed, and contents are symlinked to target.

## Installation

One-time setup for a new machine:

```bash
brew install stow gitleaks
make setup
```

## Workflows

### Maintenance
When you add or update shared skills or modify templates in `gemini/templates/`, rebuild Gemini commands (also relinks Codex+Claude skills):

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

At the start of a Gemini session, run `init-agent` to load shared agent rules.

Notes:
- Handcrafted Gemini commands live in `gemini/templates/commands/`.
- Skill-based Gemini commands are generated into `gemini/.gemini/commands/`.

### Security
A pre-commit hook is installed automatically during `make setup`. To run a manual scan:

```bash
make lint
```

### Permission Management
All agents use a **hybrid allowlist + denylist approach** for command permissions:
- **Allowlist**: Common safe commands (make, git, language runtimes) run without prompting
- **Denylist**: Dangerous commands (rm -rf, git reset, sudo) are blocked entirely
- **Prompt zone**: Everything else requires user confirmation

See [`master/PERMISSIONS.md`](master/PERMISSIONS.md) for the canonical permission reference.

**Configuration files**:
- Claude: `claude/.claude/settings.json`
- Codex: `codex/.codex/rules/default.rules`
- Gemini: `gemini/.gemini/settings.json`

For implementation details, see [`docs/permission-defaults-plan.md`](docs/permission-defaults-plan.md).


### Cleaning
To remove generated artifacts:

```bash
make clean
```
