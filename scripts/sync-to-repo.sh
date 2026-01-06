#!/usr/bin/env bash
# sync-to-repo.sh — Preview and sync live Gemini configs back to the repository
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -t 0 ]; then
    echo "❌ Not running in a terminal. Skipping interactive sync."
    exit 0
fi

echo "🔍 Comparing ~/.gemini with repository..."
echo ""

# GEMINI.md is a build artifact, so we warn if it differs but DO NOT sync it back directly.
if [ -f ~/.gemini/GEMINI.md ] && [ -f "$PROJECT_DIR/gemini/.gemini/GEMINI.md" ]; then
    if ! diff -q ~/.gemini/GEMINI.md "$PROJECT_DIR/gemini/.gemini/GEMINI.md" > /dev/null; then
        echo "⚠️  ~/.gemini/GEMINI.md differs from repo!"
        echo "   NOTE: This file is AUTO-GENERATED from master/AGENTS.md and master/gemini-extra.md."
        echo "   Please edit those files in the repo instead. Changes here will NOT be synced."
        echo ""
    fi
fi

FILES_TO_SYNC=("settings.json")
HAS_CHANGES=false

for file in "${FILES_TO_SYNC[@]}"; do
    if [ -f ~/.gemini/"$file" ] && [ -f "$PROJECT_DIR/gemini/.gemini/$file" ]; then
        if ! diff -q ~/.gemini/"$file" "$PROJECT_DIR/gemini/.gemini/$file" > /dev/null; then
            echo "📄 Diff for $file:"
            diff -u "$PROJECT_DIR/gemini/.gemini/$file" ~/.gemini/"$file" || true
            echo ""
            HAS_CHANGES=true
        fi
    fi
done

# Check commands directory
if [ -d ~/.gemini/commands ] && [ -d "$PROJECT_DIR/gemini/.gemini/commands" ]; then
    if ! diff -rq "$PROJECT_DIR/gemini/.gemini/commands" ~/.gemini/commands > /dev/null; then
        echo "📁 Changes detected in commands/:"
        diff -ru "$PROJECT_DIR/gemini/.gemini/commands" ~/.gemini/commands || true
        echo ""
        HAS_CHANGES=true
    fi
fi

if [ "$HAS_CHANGES" = false ]; then
    echo "✅ No syncable changes detected (settings.json, commands/)."
    exit 0
fi

echo "⚠️  Found differences between ~/.gemini and the repository."
read -p "Do you want to sync these changes back to the repository? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Sync aborted."
    exit 0
fi

echo "🔄 Syncing..."
cp ~/.gemini/settings.json "$PROJECT_DIR/gemini/.gemini/settings.json"

# Safe sync for commands
if [ -d ~/.gemini/commands ]; then
    rm -rf "$PROJECT_DIR/gemini/.gemini/commands"
    cp -R ~/.gemini/commands "$PROJECT_DIR/gemini/.gemini/"
fi

echo "✨ Sync complete."
