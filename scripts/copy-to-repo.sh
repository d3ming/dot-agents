#!/usr/bin/env bash
# copy-to-repo.sh — Copy from archive to repo structure, excluding runtime bloat
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Find latest archive
LATEST_ARCHIVE=$(ls -td "$PROJECT_DIR"/archive/*/ | head -1)
echo "📂 Source: $LATEST_ARCHIVE"

# Copy with exclusions
echo "📋 Copying to repo structure (excluding runtime bloat)..."

# Claude
rsync -av \
  --exclude='.git' \
  --exclude='projects/' \
  --exclude='statsig/' \
  --exclude='plugins/' \
  --exclude='debug/' \
  --exclude='plans/' \
  --exclude='todos/' \
  --exclude='file-history/' \
  --exclude='session-env/' \
  --exclude='shell-snapshots/' \
  --exclude='ide/' \
  --exclude='claude-reference-guide.md' \
  --exclude='*.jsonl' \
  "${LATEST_ARCHIVE}claude/" "$PROJECT_DIR/claude/.claude/"
echo "✅ Claude"

# Codex
rsync -av \
  --exclude='.git' \
  --exclude='sessions/' \
  --exclude='shell_snapshots/' \
  --exclude='log/' \
  --exclude='tmp/' \
  --exclude='policy/' \
  --exclude='internal_storage.json' \
  --exclude='version.json' \
  --exclude='config.toml' \
  --exclude='config.bak.toml' \
  --exclude='auth.json' \
  --exclude='history.jsonl' \
  --exclude='skills/.system/' \
  "${LATEST_ARCHIVE}codex/" "$PROJECT_DIR/codex/.codex/"
echo "✅ Codex"

# Gemini (heavy exclusions)
rsync -av \
  --exclude='.git' \
  --exclude='antigravity/' \
  --exclude='antigravity-browser-profile/' \
  --exclude='history/' \
  --exclude='tmp/' \
  --exclude='extensions/' \
  --exclude='oauth_creds.json' \
  --exclude='google_accounts.json' \
  --exclude='installation_id' \
  --exclude='state.json' \
  --exclude='*.orig' \
  --exclude='*.bak*' \
  "${LATEST_ARCHIVE}gemini/" "$PROJECT_DIR/gemini/.gemini/"
echo "✅ Gemini"

# Create master AGENTS.md
mkdir -p "$PROJECT_DIR/master"
cp "${LATEST_ARCHIVE}codex/AGENTS.md" "$PROJECT_DIR/master/AGENTS.md"
echo "✅ Master AGENTS.md"

echo ""
echo "📊 Repo structure sizes:"
du -sh "$PROJECT_DIR"/claude/.claude "$PROJECT_DIR"/codex/.codex "$PROJECT_DIR"/gemini/.gemini

echo ""
echo "🔗 Next: create internal symlinks for shared docs"
