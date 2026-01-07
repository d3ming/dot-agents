#!/usr/bin/env bash
# install.sh — Move existing dirs to archive and install Stow symlinks
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

GEMINI_BACKUP_DIR=""

create_gemini_backup_dir() {
    if [ -z "$GEMINI_BACKUP_DIR" ]; then
        GEMINI_BACKUP_DIR="$PROJECT_DIR/archive/gemini-preinstall-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$GEMINI_BACKUP_DIR"
        echo "📦 Backing up existing Gemini files to $GEMINI_BACKUP_DIR"
    fi
}

backup_gemini_path() {
    local src="$1"
    if [ -e "$src" ] || [ -L "$src" ]; then
        create_gemini_backup_dir
        mv "$src" "$GEMINI_BACKUP_DIR/"
    fi
}

echo "🔍 Checking prerequisites..."

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "❌ GNU Stow not found. Install with: brew install stow"
    exit 1
fi

echo "✅ Stow found"
echo ""

# Idempotency check: See if .claude is already a symlink pointing to this repo
if [ -L ~/.claude ] && [[ $(readlink ~/.claude) == *"/claude/.claude" ]]; then
    echo "✅ ~/.claude is already stowed. Skipping archive & restore steps."
    SKIP_ARCHIVE=true
else
    SKIP_ARCHIVE=false
fi

if [ "$SKIP_ARCHIVE" = false ]; then
    echo "🧪 Dry-run: checking for conflicts..."
    cd "$PROJECT_DIR"
    
    # Try stow in dry-run mode. If it fails, we have conflicts.
    if ! stow -n -v -t ~ claude codex 2>/dev/null; then
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
        
        # We just created an archive, so we should try to restore from it later
        SHOULD_RESTORE=true
    else
        echo "✅ No conflicts detected."
        SHOULD_RESTORE=false
    fi
else
    SHOULD_RESTORE=false
fi

# Real stow (claude & codex only)
echo "🔗 Installing symlinks..."
cd "$PROJECT_DIR"
stow -v -t ~ claude codex

# Gemini setup (symlink core config files; keep runtime dirs writable)
echo "📂 Configuring gemini..."
mkdir -p ~/.gemini
GEMINI_MD_TARGET="$PROJECT_DIR/gemini/.gemini/GEMINI.md"
GEMINI_SETTINGS_TARGET="$PROJECT_DIR/gemini/.gemini/settings.json"
GEMINI_COMMANDS_TARGET="$PROJECT_DIR/gemini/.gemini/commands"

# Ensure GEMINI.md is a symlink to the repo-managed file
if [ -L ~/.gemini/GEMINI.md ] && [ "$(readlink ~/.gemini/GEMINI.md)" = "$GEMINI_MD_TARGET" ]; then
    echo "✅ ~/.gemini/GEMINI.md already linked."
else
    backup_gemini_path ~/.gemini/GEMINI.md
    ln -s "$GEMINI_MD_TARGET" ~/.gemini/GEMINI.md
    echo "🔗 Linked ~/.gemini/GEMINI.md"
fi

# Ensure settings.json is a symlink to the repo-managed file
if [ -L ~/.gemini/settings.json ] && [ "$(readlink ~/.gemini/settings.json)" = "$GEMINI_SETTINGS_TARGET" ]; then
    echo "✅ ~/.gemini/settings.json already linked."
else
    backup_gemini_path ~/.gemini/settings.json
    ln -s "$GEMINI_SETTINGS_TARGET" ~/.gemini/settings.json
    echo "🔗 Linked ~/.gemini/settings.json"
fi

# Commands are generated; symlink to repo for easy updates
if [ -L ~/.gemini/commands ] && [ "$(readlink ~/.gemini/commands)" = "$GEMINI_COMMANDS_TARGET" ]; then
    echo "✅ ~/.gemini/commands already linked."
else
    backup_gemini_path ~/.gemini/commands
    ln -s "$GEMINI_COMMANDS_TARGET" ~/.gemini/commands
    echo "🔗 Linked ~/.gemini/commands"
fi

if [ "$SHOULD_RESTORE" = true ]; then
    echo ""
    echo "📦 Restoring essential runtime state from archive..."
    
    # Find latest archive (the one we just created)
    LATEST_ARCHIVE=$(ls -td "$PROJECT_DIR"/archive/*/ | head -1)

    # Claude - restore runtime state
    if [ -d "${LATEST_ARCHIVE}claude" ]; then
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

    # Gemini - Restore directory content if we moved it
    if [ -d "${LATEST_ARCHIVE}gemini" ]; then
        # Restore contents from archive to the new real directory
        # We carefully copy back history/cache but NOT the tracked files we just copied
        echo "  Restoring Gemini runtime files..."
        rsync -a --exclude='GEMINI.md' --exclude='settings.json' --exclude='commands' "${LATEST_ARCHIVE}gemini/" ~/.gemini/
        echo "  ✅ Gemini runtime restored"
    fi
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Verify with:"
echo "  ls -la ~/.claude ~/.codex ~/.gemini"
echo ""
echo "Note: Gemini uses symlinked GEMINI.md, settings.json, and commands/ with real runtime dirs."
echo "Rebuild configs with: make build (then rerun install if needed)."
echo ""
echo "Test your CLI tools to ensure settings are picked up."
