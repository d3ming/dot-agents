#!/usr/bin/env bash
# create-shared-symlinks.sh — Link CLAUDE.md/AGENTS.md/GEMINI.md to shared/AGENTS.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Remove existing files/symlinks
rm -f claude/.claude/CLAUDE.md
rm -f codex/.codex/AGENTS.md
rm -f gemini/.gemini/GEMINI.md

# Create relative symlinks
ln -s ../../shared/AGENTS.md claude/.claude/CLAUDE.md
ln -s ../../shared/AGENTS.md codex/.codex/AGENTS.md
ln -s ../../shared/AGENTS.md gemini/.gemini/GEMINI.md

echo "✅ Created shared doc symlinks:"
ls -la claude/.claude/CLAUDE.md codex/.codex/AGENTS.md gemini/.gemini/GEMINI.md
