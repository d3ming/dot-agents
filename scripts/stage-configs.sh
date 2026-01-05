#!/usr/bin/env bash
# stage-configs.sh — Full backup of agent config directories
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/archive/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "📦 Backup dir: $BACKUP_DIR"

# Full copy of each config directory
cp -R ~/.claude "$BACKUP_DIR/claude"
echo "✅ ~/.claude → $BACKUP_DIR/claude"

cp -R ~/.codex "$BACKUP_DIR/codex"
echo "✅ ~/.codex → $BACKUP_DIR/codex"

cp -R ~/.gemini "$BACKUP_DIR/gemini"
echo "✅ ~/.gemini → $BACKUP_DIR/gemini"

echo ""
echo "📁 Backup complete: $BACKUP_DIR"
du -sh "$BACKUP_DIR"/*
