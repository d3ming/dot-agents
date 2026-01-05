#!/usr/bin/env bash
# install.sh — Move existing dirs to archive and install Stow symlinks
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔍 Checking prerequisites..."

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "❌ GNU Stow not found. Install with: brew install stow"
    exit 1
fi

echo "✅ Stow found"
echo ""

# Dry-run first
echo "🧪 Dry-run: checking for conflicts..."
cd "$PROJECT_DIR"
stow -n -v -t ~ claude codex gemini 2>&1 || {
    echo ""
    echo "⚠️  Conflicts detected. Existing dirs need to be moved first."
    echo ""
    read -p "Move ~/.claude, ~/.codex, ~/.gemini to archive? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted"
        exit 1
    fi

    # Move to archive
    ARCHIVE_DIR="$PROJECT_DIR/archive/pre-stow-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$ARCHIVE_DIR"

    if [ -e ~/.claude ]; then
        mv ~/.claude "$ARCHIVE_DIR/claude"
        echo "📦 ~/.claude → $ARCHIVE_DIR/claude"
    fi

    if [ -e ~/.codex ]; then
        mv ~/.codex "$ARCHIVE_DIR/codex"
        echo "📦 ~/.codex → $ARCHIVE_DIR/codex"
    fi

    if [ -e ~/.gemini ]; then
        mv ~/.gemini "$ARCHIVE_DIR/gemini"
        echo "📦 ~/.gemini → $ARCHIVE_DIR/gemini"
    fi

    echo ""
}

# Real stow
echo "🔗 Installing symlinks..."
stow -v -t ~ claude codex gemini

echo ""
echo "📦 Restoring essential runtime state from archive..."

# Find latest archive (the one we just moved current dirs to)
LATEST_ARCHIVE=$(ls -td "$PROJECT_DIR"/archive/*/ | head -1)

# Restore only essential runtime files (skip 6GB+ of cache/recordings)

# Claude - restore runtime state (sessions, shell snapshots, etc.)
if [ -d "${LATEST_ARCHIVE}claude" ]; then
    # Copy everything except tracked files
    for item in "${LATEST_ARCHIVE}claude/"*; do
        name=$(basename "$item")
        case "$name" in
            settings.json|commands|CLAUDE.md|.git|.gitignore) continue ;;
            *) cp -R "$item" ~/.claude/ 2>/dev/null || true ;;
        esac
    done
    echo "  ✅ Claude runtime restored"
fi

# Codex - restore runtime state
if [ -d "${LATEST_ARCHIVE}codex" ]; then
    for item in "${LATEST_ARCHIVE}codex/"*; do
        name=$(basename "$item")
        case "$name" in
            AGENTS.md|prompts|rules|skills|.git|.gitignore) continue ;;
            *) cp -R "$item" ~/.codex/ 2>/dev/null || true ;;
        esac
    done
    echo "  ✅ Codex runtime restored"
fi

# Gemini - SELECTIVE restore (essentials only, skip 6GB bloat)
if [ -d "${LATEST_ARCHIVE}gemini" ]; then
    # Essential auth/identity files
    [ -f "${LATEST_ARCHIVE}gemini/oauth_creds.json" ] && cp "${LATEST_ARCHIVE}gemini/oauth_creds.json" ~/.gemini/
    [ -f "${LATEST_ARCHIVE}gemini/installation_id" ] && cp "${LATEST_ARCHIVE}gemini/installation_id" ~/.gemini/
    [ -f "${LATEST_ARCHIVE}gemini/google_accounts.json" ] && cp "${LATEST_ARCHIVE}gemini/google_accounts.json" ~/.gemini/
    [ -f "${LATEST_ARCHIVE}gemini/state.json" ] && cp "${LATEST_ARCHIVE}gemini/state.json" ~/.gemini/

    # Optional: conversation history (72MB) - uncomment if needed
    # [ -d "${LATEST_ARCHIVE}gemini/history" ] && cp -R "${LATEST_ARCHIVE}gemini/history" ~/.gemini/

    echo "  ✅ Gemini essentials restored (auth, identity)"
    echo "  ℹ️  Skipped 6GB+ (browser-profile, recordings) - will regenerate"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Verify with:"
echo "  ls -la ~/.claude ~/.codex ~/.gemini"
echo "  readlink ~/.claude"
echo ""
echo "Test your CLI tools to ensure settings are picked up."
