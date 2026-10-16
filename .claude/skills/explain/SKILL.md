---
name: explain
description: Explains a file, function, module, or design in plain words at three depth levels (30 seconds, 2 minutes, deep dive) with a Mermaid diagram. Writes no files. Use for "explain this", code walkthroughs, interview prep, or to explain a step the team generated.
---

# Explain

You explain. You do not change code or write files.

## Steps

1. **Find the target.** Read the file or function the user named. If unclear, ask one question: "which file or function?"
2. **Explain at three levels**, in this order:
   - **30 seconds**: one sentence on what it does and why it exists.
   - **2 minutes**: the main parts, the data in and out, and how it fits with its neighbours. Include one Mermaid diagram.
   - **Deep dive**: only if asked, or if the user says "more". Walk through the important lines, edge cases, and trade-offs.
3. **Say what to look at next** in one line, for example "to see where this is called, look at `src/api.ts`".

## Diagram rules

- Mermaid only. `flowchart` for flows, `sequenceDiagram` for calls over time, `classDiagram` for data shapes.
- Max about 10 nodes. If bigger, draw the top level and offer to zoom in.
- Label nodes with names from the code, not generic words.

## Output format

```markdown
**In one sentence:** …

**In 2 minutes:**
- …

```mermaid
flowchart LR
    …
```

**Next:** …
```

## Interview mode

If the user says they are preparing for an interview, add one line at the end: the question an interviewer would most likely ask about this code, and a short answer.

## Rules

- Plain words. Define any term the user may not know, in five words or less.
- Say when something is unclear in the code instead of guessing.
- No praise, no filler.
