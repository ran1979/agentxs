# Example: todo-api

An illustrative example of the agentxs `ship` mode output, so you can see what the files look like before you install anything. It was written by hand to show the format: the PR numbers, timestamps, and review outcomes are invented, and the project has no code. It is not a real run and not code you can run.

Read in this order:

1. [`docs/requirements.md`](docs/requirements.md) — what the PM wrote after asking questions
2. [`docs/architecture.md`](docs/architecture.md) — the architect's options, pick, and phases
3. [`docs/board.md`](docs/board.md) — tickets and their status
4. [`docs/log.md`](docs/log.md) — the plain-language record of each step

```mermaid
flowchart LR
    PM[PM] --> R[requirements.md]
    R --> A[Architect] --> AR[architecture.md + board.md]
    AR --> B[Builder: T-001, T-002] --> PR[PR] --> RV[Reviewer] --> M[Merge]
    M --> LOG[log.md]
```
