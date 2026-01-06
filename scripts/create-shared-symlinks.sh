#!/usr/bin/env bash
# create-shared-symlinks.sh — Link CLAUDE.md/AGENTS.md/GEMINI.md to master/AGENTS.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Remove existing files/symlinks
rm -f claude/.claude/CLAUDE.md
rm -f codex/.codex/AGENTS.md

# Create relative symlinks
ln -s ../../master/AGENTS.md claude/.claude/CLAUDE.md
ln -s ../../master/AGENTS.md codex/.codex/AGENTS.md

echo "✅ Created shared doc symlinks:"
ls -la claude/.claude/CLAUDE.md codex/.codex/AGENTS.md
