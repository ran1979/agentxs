# Log

Plain-language record of every step. Newest at the bottom.

## 2026-10-16 10:05 — pm — requirements
- What happened: Asked 6 questions. Goal, scope, and the three must-have flows agreed. Load target set to 200 ms.
- What changed (files / tickets): `docs/requirements.md` (R-001 to R-004), status approved.
- Next: architect designs the solution.

## 2026-10-16 10:20 — architect — design and tickets
- What happened: Compared in-memory, SQLite, and Postgres. Picked SQLite: data survives restarts with no server.
- What changed (files / tickets): `docs/architecture.md`, `docs/board.md` (T-001 to T-004).
- Next: build T-001 first. The coverage gate blocks other tickets until it is done.

## 2026-10-16 10:40 — boss — T-001 done
- What happened: Reviewer approved PR #1 (test runner and coverage check, 82%). Boss merged.
- What changed (files / tickets): `package.json`, `jest.config.js`. T-001 set to done.
- Next: T-002 is next. It depends only on T-001.

## 2026-10-16 11:30 — reviewer — T-002 review
- What happened: Reviewer posted CHANGES REQUESTED on PR #2. Empty title returned 500, not 400. Coverage was 71%.
- What changed (files / tickets): T-002 set to changes-requested, then back to in-review after the fix.
- Next: builder fixes the two items and reports again.
