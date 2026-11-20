# craft-qa

A Claude Code skill that builds a product's test suite from evidence, then runs bug finding, recording and fixing as
one loop.

- It starts with a short interview: what you're building, for whom, the competitors you replace, the products you're
  inspired by, the workflows that must never break, the bugs you already know, your risks and your budget.
- It researches how each of those products fails, from their help docs, release notes, forums and reviews, with a
  link per finding.
- It turns that research into a spec, edge cases, owner decisions, agent audit prompts, spec reviews by lens,
  milestones and CI tiers.
- Then it builds the tests. A bug that a test finds is fixed in the same item. Progress counts open bugs. A failing
  test goes on the known-failures list only when the fix is big and the owner approved it, and CI checks that.

It works for any product: web, desktop, mobile, API. Use it as a base for real production code.

## Why

Two lessons from building one real suite with agents.

**Tests need evidence.** Tests written from "what's easy to assert" pass while users hit bugs. The suite this skill
comes from started from the products its users switch from: one research report per product, read from help
centers, release notes (the "fixed" lines are a free bug list), forums and issue trackers. Next to that: one checklist
of the behaviors users expect from those products, with a TOP list the owner decides on, and a list of the team's own
past embarrassments. Then several review rounds checked every row, with one reviewer per lens. The red-team lens took
each past embarrassment and asked "which test catches this?". Several answers were "none".

**Finding isn't fixing.**

- The team wrote the large suite before a testing round.
- Each failing test was filed as a "known failure" and a backlog bug, so CI stayed green.
- The progress report said 98.9 % done. 249 found bugs were open.
- The suite did its job. The process didn't: finding and fixing were two steps, and the second one waited.
- This skill joins them: an item isn't done until its tests pass on main with the fixes merged.

## How it works

| Step | What happens | Output |
|---|---|---|
| 0. Intake | 12 questions in at most 3 short forms (multiple choice with your repo's answers guessed) | `qa/intake.md` |
| 1. Research | One agent per competitor or inspiration reads its public failures; an expected-behavior checklist with a TOP list; your own past failures | `qa/research/`, `qa/expected-behavior.md`, `qa/past-failures.md` |
| 2. Spec | Test rows (ID, check, pass rule, where, auto/scripted/manual, source), edge cases, owner decisions, infrastructure, audit prompts, smoke set, CI tiers, build order | `qa/spec.md`, `qa/edge-cases.md`, `qa/decisions.md`, `qa/audit-prompts.md` |
| 3. Review | 3-5 lenses per round; red team against past failures every round | `qa/reviews/` |
| 4. Build | Per item: tests, a canary per test, fix every bug found, one review, one fix round | branches, PRs |
| 5. Exceptions | Known-failures rows only above a fix-size threshold, with an `Approved-by:` trailer CI checks | `known-failures.toml` |
| 6. Progress | Done % always next to the open-bug count; phase review; post-mortem | status lines |

## What's in it

| Path | What it does |
|---|---|
| `skills/craft-qa/SKILL.md` | The steps the agent follows: intake, research, spec, spec review, build per item, exceptions, honest progress |
| `skills/craft-qa/config.example.toml` | Paths, reference products, review lenses, CI tiers, exception threshold, model per role, budget cap |
| `skills/craft-qa/templates/intake-questions.md` | The 12 intake questions in 3 forms, and the `qa/intake.md` format |
| `skills/craft-qa/templates/failure-research-brief.md` | Brief for one research agent per product: sources to read, a link per row, report format |
| `skills/craft-qa/templates/expected-behavior-checklist.md` | Testable behaviors users expect from a reference product, with the TOP list |
| `skills/craft-qa/templates/spec-row.md` | Spec layout, columns and tags, Constants, infrastructure, build order, revision log |
| `skills/craft-qa/templates/edge-cases.md` | One section per test ID, and the cases to consider for every row |
| `skills/craft-qa/templates/owner-decisions.md` | Product questions the tests depend on, and what a test checks while one is open |
| `skills/craft-qa/templates/audit-prompt.md` | Format and starter set of agent bug-hunt prompts |
| `skills/craft-qa/templates/review-lenses.md` | The spec review lenses and the red-team table (past failure, caught by, gap and fix) |
| `skills/craft-qa/templates/known-failures.example.toml` | The exceptions file, with estimate and approval fields |
| `skills/craft-qa/templates/coder-brief.md` | Brief for the agent that builds an item ("fix every bug your tests find") |
| `skills/craft-qa/templates/review-checklist.md` | Per-item review: done means done, tests can fail, code |
| `skills/craft-qa/templates/phase-review.md` | One review of the whole phase against the spec |
| `skills/craft-qa/scripts/progress.py` | Prints `46.0 % done \| 17 open bugs` from the test index and the known-failures file |
| `skills/craft-qa/scripts/kf-guard.sh` | CI check: fails when a commit adds a known-failures row without an `Approved-by:` trailer |
| `skills/craft-qa/scripts/canary-run.sh` | Applies a seeded-bug patch, runs a test, expects a failure, reverts |
| `skills/craft-qa/scripts/canary-check.md` | The canary rule and what a reviewer checks |
| `CHANGELOG.md` | What changed per version |

## Quick start

1. Copy the folder to `~/.claude/skills/craft-qa/` (or a project's `.claude/skills/`).
2. Copy `skills/craft-qa/config.example.toml` to your repo as `.craft-qa.toml` and fill it in.
3. Add the guard to CI, after a full-depth checkout:

   ```
   ~/.claude/skills/craft-qa/scripts/kf-guard.sh --base origin/main --file known-failures.toml --approvers "Your Name"
   ```

4. Ask Claude: "Build a test suite for this app with craft-qa". It asks the intake questions first, then
   researches the products you name. Later: "Start the bug hunt" or "Build Milestone 1".
5. Put the progress line in every status report:

   ```
   python3 ~/.claude/skills/craft-qa/scripts/progress.py --tests tests/index.toml --known-failures known-failures.toml
   ```

Needs git 2.22+, bash and Python 3.11+. No other packages.

## How to adapt

- **Reference products:** the intake fills `[research] products`. Add products there any time; the next run
  researches only the new ones.
- **Review lenses:** set `[suite] review_lenses`. Keep `red-team` in every round.
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
