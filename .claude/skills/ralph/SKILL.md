---
name: ralph
description: Start or cancel a Ralph loop that runs one phase of docs/board.md (builder, reviewer, merge per ticket) until the phase is done or blocked. Use for "ralph phase N", "run phase N in a loop", or "cancel ralph".
---

# Ralph

Runs one phase of the board in a loop. Each pass re-reads `docs/board.md`, so progress lives in files, not in the chat. The loop stops by itself. Requires `jq` and the project `settings.json` hooks.

## Start

1. Ask one question if missing: **which phase?** Default cap: **10 iterations**.
2. Check `docs/board.md` has unblocked tickets in that phase. If none, say so and stop.
3. Write `.claude/ralph/state.md` exactly like this (fill in N and the cap):

   ```markdown
   ---
   iteration: 1
   max_iterations: 10
   ---

   Ralph phase N. Run the ship loop for phase N only.
   1. Read docs/board.md. Pick unblocked tickets in phase N with status todo or changes-requested, highest priority first.
   2. For each ticket: builder, then reviewer, then merge only on an APPROVED comment (see CLAUDE.md). Update board.md on main after each step. Add a log entry in docs/log.md.
   3. If a guard blocks something, tell the user the file and type, mark that ticket blocked, and continue with the others.
   4. When every ticket in phase N is done, print <promise>PHASE_DONE</promise>.
   5. If you need the human (a blocked ticket with no other work, an unclear requirement, an approval), print <promise>BLOCKED</promise> and say why in plain words.
   Print a promise only when it is true.
   ```

4. Tell the user: phase, cap, and how to cancel. Then start on the first ticket.

## Cancel

Delete `.claude/ralph/state.md`. Tell the user the loop is off and where it stopped (last log entry).

## Rules

- Never print a promise to escape the loop. A false `PHASE_DONE` skips review.
- Always keep a cap. Ask the user before raising it.
- If the user talks to you mid-loop, answer and keep the loop running unless they say cancel.
