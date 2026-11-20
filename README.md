# craft-qa

A Claude Code skill that runs bug finding, recording and fixing as one loop. A bug that a test finds is fixed in
the same item. Progress counts open bugs. A failing test goes on the known-failures list only when the fix is big and
the owner approved it, and CI checks that.

## Why

- A team wrote a large test suite before a testing round.
- Each failing test was filed as a "known failure" and a backlog bug, so CI stayed green.
- The progress report said 98.9 % done. 249 found bugs were open.
- The suite did its job. The process didn't: finding and fixing were two steps, and the second one waited.
- This skill joins them: an item isn't done until its tests pass on main with the fixes merged.

## What's in it

| Path | What it does |
|---|---|
| `SKILL.md` | The 6-step loop the agent follows: research, spec, spec review, build per item, exceptions, honest progress |
| `skills/craft-qa/config.example.toml` | Repo, commands, known-failures file, exception threshold, model per role, budget cap |
| `skills/craft-qa/templates/spec-row.md` | Spec columns, an example row, edge cases, the definition of done |
| `skills/craft-qa/templates/known-failures.example.toml` | The exceptions file, with estimate and approval fields |
| `skills/craft-qa/templates/coder-brief.md` | Brief for the agent that builds an item ("fix every bug your tests find") |
| `skills/craft-qa/templates/review-checklist.md` | Per-item review: done means done, tests can fail, code |
| `skills/craft-qa/templates/phase-review.md` | One review of the whole phase against the spec |
| `skills/craft-qa/scripts/progress.py` | Prints `46.0 % done \| 17 open bugs` from the test index and the known-failures file |
| `skills/craft-qa/scripts/kf-guard.sh` | CI check: fails when a commit adds a known-failures row without an `Approved-by:` trailer |
| `skills/craft-qa/scripts/canary-run.sh` | Applies a seeded-bug patch, runs a test, expects a failure, reverts |
| `skills/craft-qa/scripts/canary-check.md` | The canary rule and what a reviewer checks |

## Quick start

1. Copy the folder to `~/.claude/skills/craft-qa/` (or a project's `.claude/skills/`).
2. Copy `skills/craft-qa/config.example.toml` to your repo as `.craft-qa.toml` and fill it in.
3. Add the guard to CI, after a full-depth checkout:

   ```
   ~/.claude/skills/craft-qa/scripts/kf-guard.sh --base origin/main --file known-failures.toml --approvers "Your Name"
   ```

4. Ask Claude: "Plan a test suite for this app with craft-qa" or "Start the bug hunt."
5. Put the progress line in every status report:

   ```
   python3 ~/.claude/skills/craft-qa/scripts/progress.py --tests tests/index.toml --known-failures known-failures.toml
   ```

Needs git 2.22+, bash and Python 3.11+. No other packages.

## How to adapt

- **Models:** set one model per role in `[models]`. Put the strongest model on the spec and the phase review, a
  stronger model than the coder on reviews.
- **Threshold:** `exceptions.threshold_tokens` is the fix size above which a known-failures row may be asked for.
  Use tokens, hours or story points; keep one unit.
- **Test index:** `progress.py` reads TOML (`[[test]] id, status`) or a plain text list. Generate it from your test
  runner if you like.
- **Trailer:** change `exceptions.trailer` and pass `--trailer` to the guard if your team uses another key.
- **Optional adapters:** an estimate tool built on measured past work, an agent runner with panes, a backlog tool.
  The loop works without them.
- **Trailer strength:** anyone who can commit can type the trailer, an agent too. For a stronger check, require signed
  commits from the approvers, or a protected-branch review by the owner on any change to the known-failures file.

## Install

In Claude Code:

```
/plugin marketplace add iretonsean/craft-qa
/plugin install craft-qa@craft-qa
```

Or copy `skills/craft-qa/` into `~/.claude/skills/` (all projects) or `.claude/skills/` (one project).

## License

MIT. See `LICENSE`.
