# AGENTS.md for dot-agents project

## Purpose
Store and optimize configurations for Claude, Codex, and Gemini. Focused on skill/prompt reuse across agents.

## Architecture
- **Claude & Codex**: Full stow symlinks (`~/.claude`, `~/.codex` → repo)
- **Gemini**: Real directory with selective symlinks (CLI needs writable runtime dirs)
  - `~/.gemini/` = real directory (history/, cache/, etc.)
  - `~/.gemini/GEMINI.md`, `settings.json`, `commands/` → symlinked to repo
- **Shared logic**: `shared/MASTER-AGENTS.md` is the source of truth for all agent protocols.
- **Internal Memory**: `.docs/` directory for markdown plans and documentation (AI-visible, Git-ignored).
- **Operations**:
  - `./scripts/install.sh`: Setup symlinks.
  - `./scripts/stage-configs.sh`: Backup current state.

## Workflows
- Update `shared/MASTER-AGENTS.md` for cross-agent rule changes.
- Optimize and share skills/prompts across the subdirectories.
- Prefer shared skills: canonical `shared/skills/<name>/SKILL.md`, then symlink into `codex/.codex/skills/` and `claude/.claude/skills/`. Use a Gemini wrapper command that injects the shared SKILL.md.

## Git
- Automatically commit changes once complete.
- Keep commits atomic and small (OK to have multiple commits per task in this repo).
