#!/usr/bin/env bash
# migrate-skills.sh — Clean up broken symlinks and migrate skills to master/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🧹 Step 1: Removing broken symlinks..."

# Remove broken symlinks pointing to non-existent .agents/
for skill in find-skills vercel-react-best-practices web-design-guidelines; do
  for dir in master/skills claude/.claude/skills codex/.codex/skills; do
    if [ -L "$dir/$skill" ]; then
      rm "$dir/$skill"
      echo "  ✅ Removed $dir/$skill"
    fi
  done
done

echo ""
echo "📦 Step 2: Migrating skills to master/skills/..."

# Move gh-address-comments to master
if [ -d "codex/.codex/skills/gh-address-comments" ] && [ ! -L "codex/.codex/skills/gh-address-comments" ]; then
  mv codex/.codex/skills/gh-address-comments master/skills/
  echo "  ✅ Moved gh-address-comments to master/skills/"
else
  echo "  ⏭️  gh-address-comments already migrated or is a symlink"
fi

# Move pdf to master
if [ -d "codex/.codex/skills/pdf" ] && [ ! -L "codex/.codex/skills/pdf" ]; then
  mv codex/.codex/skills/pdf master/skills/
  echo "  ✅ Moved pdf to master/skills/"
else
  echo "  ⏭️  pdf already migrated or is a symlink"
fi

echo ""
echo "🔗 Step 3: Creating symlinks..."

# Use existing link-skill.sh to create symlinks
./scripts/link-skill.sh gh-address-comments
./scripts/link-skill.sh pdf

echo ""
echo "✅ Migration complete!"
echo ""
echo "📊 Verify with:"
echo "  ls -la master/skills/{gh-address-comments,pdf}"
echo "  ls -la claude/.claude/skills/{gh-address-comments,pdf}"
echo "  ls -la codex/.codex/skills/{gh-address-comments,pdf}"
echo ""
echo "📝 Next: git status to see changes"
