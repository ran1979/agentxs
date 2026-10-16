#!/usr/bin/env bash
# Ralph loop, Stop hook. While .claude/ralph/state.md exists, feed the phase prompt
# back after every turn. Stop when the agent prints <promise>PHASE_DONE</promise>
# or <promise>BLOCKED</promise>, or when the iteration cap is reached.
set -euo pipefail

STATE="${CLAUDE_PROJECT_DIR:-.}/.claude/ralph/state.md"
[ -f "$STATE" ] || exit 0

input=$(cat)
iter=$(sed -n 's/^iteration: //p' "$STATE")
max=$(sed -n 's/^max_iterations: //p' "$STATE")
if ! [[ "$iter" =~ ^[0-9]+$ && "$max" =~ ^[0-9]+$ ]]; then
  echo "ralph: state file is bad, stopping" >&2
  rm -f "$STATE"
  exit 0
fi

# Last assistant text from the transcript (JSONL).
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
last=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  last=$(jq -rs '[.[] | select(.type == "assistant")] | last
    | .message.content // [] | map(select(.type == "text") | .text) | join("\n")' "$transcript" 2>/dev/null || true)
fi

if printf '%s' "$last" | grep -qE '<promise>(PHASE_DONE|BLOCKED)</promise>'; then
  echo "ralph: finished at iteration $iter" >&2
  rm -f "$STATE"
  exit 0
fi

if [ "$iter" -ge "$max" ]; then
  echo "ralph: cap of $max iterations reached, stopping" >&2
  rm -f "$STATE"
  exit 0
fi

next=$((iter + 1))
awk -v n="$next" '/^iteration: /{ print "iteration: " n; next } { print }' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"

prompt=$(awk '/^---$/{ i++; next } i >= 2' "$STATE")
msg="[Ralph loop iteration $next of $max. Print <promise>PHASE_DONE</promise> or <promise>BLOCKED</promise> only when that is true.]

$prompt"

jq -n --arg r "$msg" '{decision: "block", reason: $r}'
