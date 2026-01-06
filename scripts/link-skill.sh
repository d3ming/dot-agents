#!/usr/bin/env bash
# link-skill.sh — Create Codex/Claude skill symlinks to master/skills/<name>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SKILL_NAME="${1:-}"

cd "$PROJECT_DIR"

mkdir -p codex/.codex/skills claude/.claude/skills

link_one() {
  local name="$1"
  local master_dir="$PROJECT_DIR/master/skills/$name"
  local codex_dest="codex/.codex/skills/$name"
  local claude_dest="claude/.claude/skills/$name"

  if [ ! -d "$master_dir" ]; then
    echo "❌ Skill not found: $master_dir" >&2
    return 1
  fi

  if [ -e "$codex_dest" ] && [ ! -L "$codex_dest" ]; then
    echo "⚠️  Skip non-symlink: $codex_dest"
  else
    ln -sfn "../../../master/skills/$name" "$codex_dest"
  fi

  if [ -e "$claude_dest" ] && [ ! -L "$claude_dest" ]; then
    echo "⚠️  Skip non-symlink: $claude_dest"
  else
    ln -sfn "../../../master/skills/$name" "$claude_dest"
  fi

  echo "✅ Linked skill '$name' for Codex and Claude"
}

if [ "$SKILL_NAME" != "" ]; then
  link_one "$SKILL_NAME"
  ls -la "codex/.codex/skills/$SKILL_NAME" "claude/.claude/skills/$SKILL_NAME"
  exit 0
fi

count=0
for dir in "$PROJECT_DIR"/master/skills/*; do
  if [ -d "$dir" ]; then
    name="$(basename "$dir")"
    link_one "$name"
    count=$((count + 1))
  fi
done

echo "✅ Linked $count skill(s)"
