# AGENTS.md for dot-agents project

## Purpose
Store and optimize configurations for Claude, Codex, and Gemini. Focused on skill/prompt reuse across agents.

## Architecture
- **Home-level dotfiles**: Stow package for preferences (`~/.claude.json` → `home/.claude.json`)
- **Claude & Codex**: Full stow symlinks (`~/.claude`, `~/.codex` → repo)
- **Gemini**: Real directory with selective symlinks (CLI needs writable runtime dirs)
  - `~/.gemini/` = real directory (history/, cache/, etc.)
  - `~/.gemini/GEMINI.md`, `settings.json`, `commands/`, `skills/` → symlinked to repo
  - `~/.gemini/settings.json` → `gemini/.gemini/settings.json` (canonical)
  - `~/.gemini/GEMINI.md` → `master/GEMINI.md` (Gemini-writable extras; shared rules loaded via `init-agent`)
- **Shared logic**: `master/AGENTS.md` is the source of truth for all agent protocols.
- **Internal Memory**: `.docs/` directory for markdown plans and documentation (AI-visible, Git-ignored).
- **Operations**:
  - `./scripts/install.sh`: Setup symlinks (stow home/ claude/ codex/ + manual Gemini links).

## Workflows
- Use `make` for all routine operations; do not run scripts directly unless explicitly noted as one-time.
- Update `master/AGENTS.md` for cross-agent rule changes.
- Optimize and share skills/prompts across the subdirectories.
- Prefer shared skills: canonical `master/skills/<name>/SKILL.md`, then symlink into `codex/.codex/skills/` and `claude/.claude/skills/`. Use a Gemini wrapper command that injects the shared SKILL.md.
