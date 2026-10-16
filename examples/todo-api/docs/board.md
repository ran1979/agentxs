# Board

Status values: `todo`, `in-progress`, `in-review`, `changes-requested`, `blocked`, `done`.
Priority: `P1` (must) … `P3` (could). IDs never change. New tickets go at the end.

| ID | Title | Phase | Priority | Status | Depends on | Requirements | PR |
|----|-------|-------|----------|--------|------------|--------------|----|
| T-001 | Set up Jest and coverage check | 1 | P1 | done | - | R-001 | #1 |
| T-002 | Create and list to-dos | 1 | P1 | in-review | T-001 | R-001, R-002 | #2 |
| T-003 | Mark a to-do done | 2 | P1 | todo | T-002 | R-003 | |
| T-004 | Load check at 1,000 items | 2 | P2 | todo | T-002 | R-004 | |
