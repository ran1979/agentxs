---
name: retro
description: Short retrospective on the agent team's process. Reads docs/log.md and recent PRs, finds what slowed the team or failed, proposes process changes, and records them in docs/retro.md. Use after each phase or when the user asks for a retro.
---

# Retro

Goal: make the process better, not blame anyone. Keep it to one page.

## Steps

1. Read `docs/log.md` (since the last retro entry), `docs/board.md`, and `docs/retro.md` (last entry).
2. Gather facts: tickets done, tickets sent back by the reviewer and why, blocked items, coverage trend, anything the user had to correct.
3. Answer four questions:
   - What worked and should stay?
   - What wasted time or caused rework?
   - What rule or template is missing or too heavy?
   - What is one change to try next phase?
4. Propose changes as concrete edits to `CLAUDE.md`, an agent file, or a skill. Do not apply them yet.
5. Ask the user which changes to apply. Apply only the approved ones.
6. Append an entry to `docs/retro.md`.

## Entry template

```markdown
## Retro — YYYY-MM-DD (phase N)

**Stayed:** …
**Wasted / reworked:** …
**Missing or too heavy:** …
**Try next:** …
**Applied:** … (or "none yet")
```

## Rules

- Max 15 lines per entry.
- Each proposed change names the file to edit.
- Prefer deleting a rule over adding one.
