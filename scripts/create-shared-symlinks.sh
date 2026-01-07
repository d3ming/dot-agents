#!/usr/bin/env bash
# create-shared-symlinks.sh — Link CLAUDE.md/AGENTS.md to master/AGENTS.md and GEMINI.md to master/GEMINI.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Remove existing files/symlinks
rm -f claude/.claude/CLAUDE.md
rm -f codex/.codex/AGENTS.md
rm -f gemini/.gemini/GEMINI.md
rm -f gemini/.gemini/skills

# Create relative symlinks
ln -s ../../master/AGENTS.md claude/.claude/CLAUDE.md
ln -s ../../master/AGENTS.md codex/.codex/AGENTS.md
ln -s ../../master/GEMINI.md gemini/.gemini/GEMINI.md
ln -s ../../master/skills gemini/.gemini/skills

echo "✅ Created shared doc symlinks:"
ls -la claude/.claude/CLAUDE.md codex/.codex/AGENTS.md gemini/.gemini/GEMINI.md gemini/.gemini/skills
