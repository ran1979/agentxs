# agentxs quick start

A short manual. For the full design, read `README.md`.

## 1. You need

- Claude Code
- `git`, `gh` (GitHub CLI, logged in), `jq`
- A project that is a git repo with an `origin` remote

Install the missing ones on a Mac:

```bash
brew install gh jq
gh auth login
```

## 2. Set up (5 minutes)

```bash
git clone https://github.com/ran1979/agentxs.git
cd agentxs
./deploy.sh ~/path/to/your-project
./deploy.sh --check ~/path/to/your-project
```

`--check` must end with **All checks passed**. If a line says `FAIL`, fix that line and run `--check` again.

## 3. Start

```bash
cd ~/path/to/your-project
claude
```

You are now talking to **boss**. Nothing else to type.

## 4. Pick a mode

Say what you want. Boss picks the mode and tells you which one it chose.

| You say | Mode | What happens |
|---------|------|--------------|
| "explain this file" | **explain** | Plain explanation and a diagram. No files changed. |
| "fix this", "add a small…" | **assist** | One small change to your code. |
| "build X" | **ship** | Full team: questions, design, tickets, PRs, review, merge. |

## 5. Useful commands

| Command or words | What it does |
|------------------|--------------|
| `/pm` | Start the requirements questions |
| `/explain <file or function>` | Explain it in three depth levels |
| `/retro` | Look back at how the team worked, propose changes |
| "ralph phase 1" | Run phase 1 of the board in a loop (cap 4) |
| "cancel ralph" | Stop the loop (deletes `.claude/ralph/state.md`) |

## 6. Ship mode, step by step

1. **Describe the idea.** Boss starts `/pm` and asks questions. Answer them.
2. **Read the design.** The architect writes `docs/architecture.md` and tickets in `docs/board.md`. Check the options and pick one. Then tell boss to go ahead.
3. **Let the team work.** Each ticket becomes a branch and a pull request. The reviewer comments `APPROVED` or `CHANGES REQUESTED`.
4. **Approve merges.** Boss asks before each merge. Say yes or no.
5. **Follow along** in `docs/log.md`. Each step has a short plain-language entry.

## 7. When something stops

| You see | What it means | What to do |
|---------|---------------|------------|
| `GUARD: ... found in <file>` | A secret or personal data is in your changes. The commit is blocked. | Remove it or use an env var. Never paste the value anywhere. |
| `CHANGES REQUESTED` on a PR | The reviewer found problems. | Nothing. The builder fixes them. Read the PR comment if you want details. |
| Ralph says `BLOCKED` | The team needs you. | Read the reason boss gives, answer it, then say "ralph phase 1" again. |
| Ralph says cap reached | Four passes ran without finishing. | Check `docs/board.md`. Split the phase if it is too big. |
| `--check` shows `FAIL` | Something is missing in the setup. | Fix the line it names. Re-run `--check`. |
| A project file was replaced | Deploy moved your old copy. | It is in `.agentxs-backup/` in your project. |

## 8. Good habits

- Keep phases small. A phase that needs many passes is too big.
- Restart Claude Code after any change to hooks or settings.
- Try a new setup on a throwaway project first.
- Never commit `.env` files or keys. The guard catches many cases, not all.
- If a secret or personal data gets committed, rotate it. Removing it from git is not enough.

## Where things are

| File | What it holds |
|------|---------------|
| `docs/requirements.md` | What to build |
| `docs/architecture.md` | How it is built |
| `docs/board.md` | Tickets and their status |
| `docs/log.md` | What happened, step by step |
| `docs/retro.md` | What to change next time |
| `.claude/guard-terms.txt` | Your names and IDs for the scan |
