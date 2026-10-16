#!/usr/bin/env bash
# Scan changes for secrets and personal data. Reports file and type only,
# never the matched text. Exit 2 when something is found.
#   scan.sh                  staged changes (before a commit)
#   scan.sh origin/main...HEAD   a branch or PR range (used by the reviewer)
set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

range="${1:-}"
if [ -n "$range" ]; then
  added=$(git diff -U0 --no-color "$range" || true)
else
  added=$(git diff --cached -U0 --no-color || true)
fi
[ -n "$added" ] || exit 0

fail=0

# check <type> <ERE>: lists files whose added lines match. Placeholders are skipped.
check() {
  local hits
  hits=$(printf '%s\n' "$added" | RE="$2" awk '
    /^\+\+\+ /  { f = substr($0, 7); next }
    /^\+/ && $0 ~ ENVIRON["RE"] && $0 !~ /example\.(com|org)|placeholder|your[-_]/ { print f }
  ' | sort -u)
  if [ -n "$hits" ]; then
    while IFS= read -r f; do echo "GUARD: $1 found in $f" >&2; done <<<"$hits"
    fail=1
  fi
}

# Secrets
check "private key"      '-----BEGIN ([A-Z]+ )?PRIVATE KEY-----'
check "AWS access key"   'AKIA[0-9A-Z]{16}'
check "GitHub token"     'gh[pousr]_[A-Za-z0-9]{30,}'
check "Slack token"      'xox[baprs]-[A-Za-z0-9-]{10,}'
check "Google API key"   'AIza[0-9A-Za-z_-]{35}'
check "hard-coded secret" '(password|passwd|secret|api_?key|token)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_/+=.-]{12,}["'"'"']'

# Personal data
check "email address"    '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
check "phone number"     '\+[0-9]{1,3}[ -]?[0-9]{2,4}[ -]?[0-9]{3}[ -]?[0-9]{3,4}'
check "card-like number" '(^|[^0-9])[0-9]{4}[ -][0-9]{4}[ -][0-9]{4}[ -][0-9]{4}([^0-9]|$)'

# Your own terms (names, usernames, IDs): one per line in .claude/guard-terms.txt
if [ -f .claude/guard-terms.txt ]; then
  while IFS= read -r term; do
    [ -z "$term" ] || [[ "$term" == \#* ]] && continue
    if printf '%s\n' "$added" | TERM_TO_FIND="$term" awk '
      /^\+\+\+ /  { f = substr($0, 7); next }
      /^\+/ && index(tolower($0), tolower(ENVIRON["TERM_TO_FIND"])) > 0 { print f }
    ' | grep -q .; then
      echo "GUARD: personal term from guard-terms.txt found in changes" >&2
      fail=1
    fi
  done < .claude/guard-terms.txt
fi

# Real secret scanner, if installed (staged changes only)
if [ -z "$range" ] && command -v gitleaks >/dev/null 2>&1; then
  if ! gitleaks protect --staged --redact -q; then
    echo "GUARD: gitleaks found secrets (values redacted above)" >&2
    fail=1
  fi
fi

if [ "$fail" -ne 0 ]; then
  echo "Blocked. Remove or rotate the item, then retry. Tell the user the file and type." >&2
  exit 2
fi
