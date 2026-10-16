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

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/skills" "$TARGET/docs"

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
for t in "$SRC"/templates/docs/*.md; do
  dst="$TARGET/docs/$(basename "$t")"
  [ -e "$dst" ] || cp "$t" "$dst"
done

echo "agentxs installed ($MODE) into $TARGET"
echo "Next: cd \"$TARGET\" && claude"
