#!/usr/bin/env bash
# Install agentxs into a project.
# Usage: ./deploy.sh <project-path> [--symlink]
#   default    copy files (snapshot, works anywhere)
#   --symlink  link to this checkout (edits here show up in the project)
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?usage: deploy.sh <project-path> [--symlink]}"
MODE=copy
[ "${2:-}" = "--symlink" ] && MODE=symlink

# Preflight: required tools.
for tool in git gh; do
  command -v "$tool" >/dev/null || { echo "missing: $tool (install it, then re-run)"; exit 1; }
done
gh auth status >/dev/null 2>&1 || echo "warning: gh is not logged in. Run: gh auth login (needed for PRs)"

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/skills" "$TARGET/docs"

# Preflight: target should be a git repo with a remote (builder opens PRs).
if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  echo "warning: $TARGET is not a git repo. Run: git init (builder needs it)"
elif ! git -C "$TARGET" remote get-url origin >/dev/null 2>&1; then
  echo "warning: $TARGET has no 'origin' remote. Add one before the builder runs."
fi

# Symlinks point at this checkout. Other people who clone the project get dead links.
if [ "$MODE" = symlink ]; then
  echo "warning: symlink mode is for your own machine only. Do not commit the project with symlinks."
fi

# agentxs owns agents and skills: always refresh them.
for f in "$SRC"/.claude/agents/*.md; do
  dst="$TARGET/.claude/agents/$(basename "$f")"
  rm -rf "$dst"
  if [ "$MODE" = symlink ]; then ln -s "$f" "$dst"; else cp "$f" "$dst"; fi
done
for d in "$SRC"/.claude/skills/*/; do
  dst="$TARGET/.claude/skills/$(basename "$d")"
  rm -rf "$dst"
  if [ "$MODE" = symlink ]; then ln -s "${d%/}" "$dst"; else cp -R "${d%/}" "$dst"; fi
done

# The project owns these after first install: never overwrite.
if [ ! -e "$TARGET/CLAUDE.md" ]; then
  if [ "$MODE" = symlink ]; then ln -s "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"; else cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"; fi
else
  echo "CLAUDE.md exists: merge boss rules from $SRC/CLAUDE.md by hand."
fi
if [ ! -e "$TARGET/.claude/settings.json" ]; then
  if [ "$MODE" = symlink ]; then ln -s "$SRC/.claude/settings.json" "$TARGET/.claude/settings.json"; else cp "$SRC/.claude/settings.json" "$TARGET/.claude/settings.json"; fi
else
  echo "settings.json exists: merge permissions from $SRC/.claude/settings.json by hand."
fi
for t in "$SRC"/templates/docs/*.md; do
  dst="$TARGET/docs/$(basename "$t")"
  [ -e "$dst" ] || cp "$t" "$dst"
done

echo "agentxs installed ($MODE) into $TARGET"
echo "Next: cd \"$TARGET\" && claude"
