---
name: craft-qa
description: Run a project's bug finding, recording and fixing as one loop, so every bug a test finds is fixed in the same item and progress never hides open bugs. Use it when the person plans or runs a test suite, a QA phase, a bug hunt, a test plan, regression tests or a "find and fix bugs" round; when they ask about known failures, a known-failures list, a skip list or an allow-list for failing tests; or when a progress number looks high while bugs stay open. Use it even if the person doesn't name the skill.
---

# Craft QA

**One rule carries this skill: a bug that a test finds is fixed in the same item that found it.** A test isn't done
when it's written. It's done when it passes on main with its fix merged. Progress counts open bugs as unfinished
work. A failing test may go on the known-failures list only when the fix is big, and only with the owner's approval.
CI enforces that.

Why: a team built a large test suite and filed every failing test as a "known failure" plus a backlog bug. The
dashboard said "98.9 % done" while 249 found bugs were open. The suite found the bugs. Nobody fixed them. This skill
makes "find" and "fix" one step.

## Setup

1. Copy `config.example.toml` to the project (default `.craft-qa.toml` at the repo root) and fill it in.
   The project's own rules files win over this file.
2. Read the config before each step. Use its model per role, its threshold and its budget cap. Don't hard-code them.
3. Put `scripts/kf-guard.sh` in CI (step 5). Put `scripts/progress.py` in every status report (step 6).

`S` below means this skill's `scripts/` folder. `T` means its `templates/` folder.

## Words

| Word | Meaning |
|---|---|
| Item | One unit of work: one spec row (or a small group of rows), its tests, and the fixes for every bug they find. |
| Done | The item's tests pass on main, with the fixes merged, and the canary for each test was run. Nothing less. |
| Open bug | A bug that a test, a review, a coder or a manual run found and that isn't fixed on main. A known-failures row is an open bug. |
| Known-failures row | A failing test that CI lets through. It's an exception, not a parking place (step 5). |
| Canary | One seeded bug that must make the test fail. It proves the test can fail (`S/canary-check.md`). |
| Owner | The person who decides product questions and approves exceptions. Agents are never the owner. |

## The loop

Run the six steps in order. Steps 1-3 run once per phase. Step 4 runs per item. Steps 5-6 run all the time.

### 1. Research failure modes

Find out how products like this one fail before you write tests.

- Collect real failures: the project's bug history, past regressions, support tickets, and public bug reports,
  release notes and forum threads of similar products.
- Group them by theme (input, data safety, output, platform, performance, security, first run).
- For each group, write what the user sees when it fails. Tests come from these, not from what is easy to assert.
- Keep the sources. Every spec row cites the failure it comes from.

### 2. Write the spec

The spec says what each test checks and what counts as a pass. It isn't code. Use `T/spec-row.md` for each row.
The config's `spec` model writes it, once per phase.

Each row has:

- A stable ID. IDs never change. A retired ID keeps a stub row ("merged into X").
- **Check:** what the test does, in a few words.
- **Pass when:** a criterion a machine can decide. Put numbers in one Constants table and cite them by name.
- **Edge cases:** listed per ID. Empty input, huge input, bad input, interrupt mid-action, second window, slow
  machine, other locale, other scale.
- **Needs:** the test infrastructure that must exist first (fixtures, fake clock, fake services, screenshot harness).
- **Decisions:** the product questions the row depends on.
- **From:** the failure it comes from (step 1).
- **Fix budget:** the expected fix work for the bugs this row will find. The item estimate includes it.

Rules for the spec:

- **Ask the owner the product questions up front**, as one numbered list, before any test is built. A test that
  depends on an open decision can only check "the same every time", and that passes wrong behavior. Mark each row
  with the decisions it waits for. A release gate fails while a needed decision is open.
- **Definition of done** goes at the top of the spec, in these words: "A test is done when it passes on main with its
  fix merged. A found bug is fixed in the same item."
- Anti-trivial rules (copy them into the spec):
  - Every test has a canary.
  - Registry and catalog tests assert a minimum count and a hand-written list of known items.
  - Every allow-list entry has an owner and an expiry date. A new entry fails CI until it's approved.
  - A golden image or snapshot is approved by the owner the first time and on every change. An agent never approves
    its own golden.
  - A failure message names the thing that failed (command, widget, file, field), not "assertion failed".
  - A fix adds a test for the bug and a test for the behavior next to it.
- Order the build: infrastructure first, then a small first milestone that proves the pipeline end to end.

### 3. Review the spec

Before any build, run independent reviews of the spec. Use 2-3 lenses. Each reviewer gets the spec, not your
opinion of it. Good lenses:

- **Coverage:** which features, platforms and user journeys have no row.
- **Test quality:** which rows pass when the feature is broken (pixels "differ" but are wrong, a registry entry
  exists but does nothing, a field works alone but not in a form).
- **Red team (always):** take the project's past failures and the worst bugs from step 1. For each one, say which
  row catches it, and if none does, what change would. List the most likely escapes first.

Merge the findings into the spec as a new revision. Log each revision (date, review files, what changed). Ask the
owner any new product questions now, not during the build.

### 4. Build each item

The lead splits the spec into items and writes one brief per item from `T/coder-brief.md`. The brief always says:
**"Fix every bug your tests find. The item isn't built until they pass."**

Per item:

1. **Estimate** the item including its fix work (the config's estimate command, if set). An estimate without fix
   work is wrong.
2. **Write the tests** for the row and its edge cases. Run them. Expect failures: that's the suite working.
3. **Run the canary** for each new or changed test (`S/canary-check.md`, `S/canary-run.sh`). Record the seeded bug
   and the failing log line in the PR body. A test whose canary doesn't fail is rewritten.
4. **Fix every bug** the tests found, in the same branch. Each fix gets a test for the bug and one for the behavior
   next to it. If a fix looks bigger than the config's `exception_threshold_tokens`, stop and go to step 5. Don't
   file it and move on.
5. **One review** by the config's `reviewer` model (a stronger model than the coder). Use `T/review-checklist.md`.
   The reviewer runs at least one canary again and checks that no known-failures row was added without approval.
6. **One fix round** by the same coder (its context holds the code). Then merge on green CI.
7. **Lock the test.** Once merged, the test is part of the baseline. Later branches may not remove it, skip it,
   loosen its tolerance or add it to known-failures without the owner's approval (step 5).

A bug that a review, another coder or a manual run finds goes to the item that owns that code, now. It isn't a
"later" ticket.

### 5. Exceptions: the known-failures list

The list exists for fixes that are too big for the item. It isn't a way to make CI green.

- A row is allowed only when the fix estimate is above `exception_threshold_tokens` (config).
- The lead asks the owner first, with the estimate, the test, what the user sees, and the plan to fix it.
- Only after the owner says yes, add the row (`T/known-failures.example.toml`). The commit that adds it carries the
  trailer `Approved-by: <owner name>` (the name from the config's `approvers`).
- `S/kf-guard.sh` runs in CI. It fails when a branch adds a row in a commit without that trailer.
- A row whose test passes now is removed in the same branch. Make the test runner flag such rows.
- Every row is an open bug in the progress count (step 6).

### 6. Honest progress, phase review, post-mortem

**Status lines.** Every status line, report and handoff gives done % and the open-bug count together:

```
Phase 2  46.0 % done | 17 open bugs (-6 today)
```

Make it with `python3 S/progress.py --tests <index> --known-failures <file> [--bugs <file>]`. An item with an open
bug doesn't count as done. Never report a % without the bug count.

**Phase end.**

1. Main is green. No known-failures row whose test passes now.
2. Tag main `baseline-<phase>`. Write the baseline: test count per area, known-failures count, approved goldens,
   commit and CI run. Later runs compare with the newest baseline tag; a lower count is a failure.
3. One review of the whole phase by the config's `phase_review` model, against the spec and the definition of done
   (`T/phase-review.md`). Its findings go to the lead, who turns them into items. Bugs it finds are fixed in this
   phase, not the next.

**Post-mortem.** After each phase, write a short note: estimate vs actual tokens and time, bugs found, bugs fixed
in the item that found them, known-failures rows added (should be close to 0), review findings, failed CI runs. Name
one or two changes for the next phase. Change one thing at a time.

## Model roles

Roles come from the config (`[models]`). Typical shape:

| Role | Job | Runs |
|---|---|---|
| `spec` | Research, spec, definition of done | Once per phase |
| `lead` | Splits the spec into items, writes briefs, decides, merges | Whole phase |
| `coder` | Writes tests, runs canaries, fixes bugs | Per item |
| `reviewer` | One review per item; stronger than `coder` | Per item |
| `phase_review` | One review of the whole phase | Once per phase |

Use the strongest model where one call has the most leverage (spec, phase review), not per item.
Respect `budget_cap` in the config: plan the phase under it and stop to ask the owner before you pass it.

## Hard rules

- A found bug is fixed in the same item. No "bug-fix round later".
- No known-failures row without the owner's approval, and only above the threshold.
- No % without the open-bug count.
- An agent never approves its own golden, its own exception or its own review.
- Ask product questions before the build, not during it.
- Tests that need a real display or device run in an isolated session, never on the owner's own desktop.

## Optional adapters

The loop doesn't need any of these. Plug them in through the config when the project has them:

- An estimate tool that turns measured past work into ranges (`estimate_command`).
- A terminal multiplexer or agent runner to start coder and reviewer agents in their own panes.
- A backlog tool for items and bug IDs.
- A CI provider. `kf-guard.sh` and `progress.py` only need git, bash and Python 3.11+.
