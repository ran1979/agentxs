#!/usr/bin/env bash
# Install agentxs into a project, or check an existing install.
# Usage:
#   ./deploy.sh <project-path> [--symlink]   install (default: copy)
#   ./deploy.sh --check <project-path>       verify an install, change nothing
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"

# ---- check mode -------------------------------------------------------------
if [ "${1:-}" = "--check" ]; then
  TARGET="${2:?usage: deploy.sh --check <project-path>}"
  fail=0
  ok()   { echo "  ok    $1"; }
  bad()  { echo "  FAIL  $1"; fail=1; }

  echo "Tools"
  for tool in git gh jq; do
    command -v "$tool" >/dev/null && ok "$tool installed" || bad "$tool missing"
  done
  gh auth status >/dev/null 2>&1 && ok "gh logged in" || bad "gh not logged in (run: gh auth login)"
  command -v gitleaks >/dev/null && ok "gitleaks installed (optional, stronger scan)" || echo "  note  gitleaks not installed (optional)"

  echo "Project: $TARGET"
  git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 && ok "git repo" || bad "not a git repo (run: git init)"
  git -C "$TARGET" remote get-url origin >/dev/null 2>&1 && ok "origin remote set" || bad "no origin remote"
  [ -f "$TARGET/CLAUDE.md" ] && ok "CLAUDE.md present" || bad "CLAUDE.md missing"
  for h in guard-commit.sh scan.sh ralph-stop.sh; do
    [ -x "$TARGET/.claude/hooks/$h" ] && ok "hook $h executable" || bad "hook $h missing or not executable"
  done
  if [ -f "$TARGET/.claude/settings.json" ]; then
    grep -q 'guard-commit.sh' "$TARGET/.claude/settings.json" && ok "settings wire the commit guard" || bad "settings.json lacks the commit guard (merge it from agentxs)"
    grep -q 'ralph-stop.sh' "$TARGET/.claude/settings.json" && ok "settings wire the ralph stop hook" || bad "settings.json lacks the ralph stop hook"
  else
    bad "settings.json missing"
  fi
  [ -f "$TARGET/.claude/guard-terms.txt" ] && ok "guard-terms.txt present" || bad "guard-terms.txt missing"
  for a in architect builder reviewer; do
    [ -f "$TARGET/.claude/agents/$a.md" ] && ok "agent $a" || bad "agent $a missing"
  done
  for s in pm retro explain ralph overview; do
    [ -f "$TARGET/.claude/skills/$s/SKILL.md" ] && ok "skill $s" || bad "skill $s missing"
  done
  [ "$fail" -eq 0 ] && echo "All checks passed. Start with: cd \"$TARGET\" && claude" || echo "Fix the FAIL lines, then re-run --check."
  exit "$fail"
fi

# ---- install mode -----------------------------------------------------------
TARGET="${1:?usage: deploy.sh <project-path> [--symlink]  |  deploy.sh --check <project-path>}"
MODE=copy
[ "${2:-}" = "--symlink" ] && MODE=symlink

# Preflight: required tools.
for tool in git gh jq; do
  command -v "$tool" >/dev/null || { echo "missing: $tool (install it, then re-run)"; exit 1; }
done
gh auth status >/dev/null 2>&1 || echo "warning: gh is not logged in. Run: gh auth login (needed for PRs)"

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/skills" "$TARGET/.claude/hooks" "$TARGET/docs"

# Preflight: target should be a git repo with a remote (builder opens PRs).
if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  echo "warning: $TARGET is not a git repo. Run: git init (builder needs it)"
elif ! git -C "$TARGET" remote get-url origin >/dev/null 2>&1; then
  echo "warning: $TARGET has no 'origin' remote. Add one before the builder runs."
fi

if [ "$MODE" = symlink ]; then
  echo "warning: symlink mode is for your own machine only. Do not commit the project with symlinks."
fi

# place <source> <destination>: put an agentxs file or folder in the project.
# If the project already has a different copy, keep it as <destination>.bak first.
place() {
  if [ -e "$2" ] && [ ! -L "$2" ] && ! diff -rq "$1" "$2" >/dev/null 2>&1; then
    # Backups live outside .claude/ so Claude Code never loads them as agents or skills.
    bak="$TARGET/.agentxs-backup/$(basename "$2")"
    mkdir -p "$TARGET/.agentxs-backup"
    rm -rf "$bak"
    mv "$2" "$bak"
    echo "kept your version of $(basename "$2") in .agentxs-backup/"
  fi
  rm -rf "$2"
  if [ "$MODE" = symlink ]; then ln -s "$1" "$2"; else cp -R "$1" "$2"; fi
}

# agentxs owns these: refresh on every run.
for f in "$SRC"/.claude/agents/*.md; do
  place "$f" "$TARGET/.claude/agents/$(basename "$f")"
done
for d in "$SRC"/.claude/skills/*/; do
  place "${d%/}" "$TARGET/.claude/skills/$(basename "$d")"
done
for h in "$SRC"/.claude/hooks/*.sh; do
  place "$h" "$TARGET/.claude/hooks/$(basename "$h")"
done

# The project owns these after first install: never overwrite.
if [ ! -e "$TARGET/.claude/guard-terms.txt" ]; then
  cp "$SRC/templates/guard-terms.txt" "$TARGET/.claude/guard-terms.txt"
fi
touch "$TARGET/.gitignore"
for ignore in '.claude/ralph/' '.agentxs-backup/'; do
  grep -qxF "$ignore" "$TARGET/.gitignore" || echo "$ignore" >> "$TARGET/.gitignore"
done
if [ ! -e "$TARGET/CLAUDE.md" ]; then
  if [ "$MODE" = symlink ]; then ln -s "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"; else cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"; fi
else
  echo "CLAUDE.md exists: merge boss rules from $SRC/CLAUDE.md by hand."
fi
if [ ! -e "$TARGET/.claude/settings.json" ]; then
  if [ "$MODE" = symlink ]; then ln -s "$SRC/.claude/settings.json" "$TARGET/.claude/settings.json"; else cp "$SRC/.claude/settings.json" "$TARGET/.claude/settings.json"; fi
else
  echo "settings.json exists: merge permissions and hooks from $SRC/.claude/settings.json by hand (guards and ralph stay off until you do)."
fi
for t in "$SRC"/templates/docs/*.md; do
  dst="$TARGET/docs/$(basename "$t")"
  [ -e "$dst" ] || cp "$t" "$dst"
done

echo "agentxs installed ($MODE) into $TARGET"
echo "Next: ./deploy.sh --check \"$TARGET\"   then   cd \"$TARGET\" && claude"
