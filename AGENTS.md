# GEMINI.md

## Purpose
Store and optimize configurations for Claude, Codex, and Gemini. Focused on skill/prompt reuse across agents.

## Architecture
- **Stow-managed**: `claude/`, `codex/`, `gemini/` map to `~/.*`
- **Shared logic**: `shared/AGENTS.md` is the source of truth for all agent protocols.
- **Operations**:
  - `./scripts/install.sh`: Setup symlinks.
  - `./scripts/stage-configs.sh`: Backup current state.

## Workflows
- Update `shared/AGENTS.md` for cross-agent rule changes.
- Optimize and share skills/prompts across the subdirectories.
