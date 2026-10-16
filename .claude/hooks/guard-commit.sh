#!/usr/bin/env bash
# PreToolUse hook (Bash). Before any git commit, run the secret and personal-data scan.
# Exit 2 blocks the commit and shows the reason to the agent.
set -euo pipefail

cmd=$(jq -r '.tool_input.command // empty')
case "$cmd" in
  *"git commit"*) exec "$(dirname "$0")/scan.sh" ;;
  *) exit 0 ;;
esac
