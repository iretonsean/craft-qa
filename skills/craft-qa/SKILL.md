---
name: craft-qa
description: Build a product's test suite from research on how similar products fail, then run bug finding, recording and fixing as one loop, so every bug a test finds is fixed in the same item and progress never hides open bugs. It starts with a short intake interview (what you're building, for whom, competitors, products you're inspired by, workflows that must never break, past bugs, risks), researches each named product's failures, and turns them into a spec, edge cases, owner decisions, agent audit prompts, review lenses, milestones and CI tiers. Use it when the person plans or runs a test suite, a QA phase, a bug hunt, a test plan, regression tests or a "find and fix bugs" round; when they want tests based on competitors' bugs; when they ask about known failures, a skip list or an allow-list for failing tests; or when a progress number looks high while bugs stay open. Use it even if the person doesn't name the skill.
---

# Craft QA

**One rule carries this skill: a bug that a test finds is fixed in the same item that found it.** A test isn't done
when it's written. It's done when it passes on main with its fix merged. Progress counts open bugs as unfinished
work. A failing test may go on the known-failures list only when the fix is big, and only with the owner's approval.
CI enforces that.

Why: a team built a large test suite and filed every failing test as a "known failure" plus a backlog bug. The
dashboard said "98.9 % done" while 249 found bugs were open. The suite found the bugs. Nobody fixed them. This skill
makes "find" and "fix" one step.

The suite itself comes from evidence, not from what is easy to assert: the products the team replaces or admires,
how those products failed in public, and the team's own past bugs. Steps 0-3 build it. Steps 4-6 build the tests,
fix the bugs and keep the numbers honest.

## Setup

1. Copy `config.example.toml` to the project (default `.craft-qa.toml` at the repo root) and fill it in.
   The project's own rules files win over this file.
2. Read the config before each step. Use its model per role, its paths, its threshold and its budget cap. Don't
   hard-code them.
3. Put `scripts/kf-guard.sh` in CI (step 5). Put `scripts/progress.py` in every status report (step 6).

`S` below means this skill's `scripts/` folder. `T` means its `templates/` folder. Every file the skill writes goes
under `qa/` in the project, unless the config says otherwise.

## Words

| Word | Meaning |
|---|---|
| Item | One unit of work: one spec row (or a small group of rows), its tests, and the fixes for every bug they find. |
| Done | The item's tests pass on main, with the fixes merged, and the canary for each test was run. Nothing less. |
| Open bug | A bug that a test, a review, a coder or a manual run found and that isn't fixed on main. A known-failures row is an open bug. |
| Known-failures row | A failing test that CI lets through. It's an exception, not a parking place (step 5). |
| Canary | One seeded bug that must make the test fail. It proves the test can fail (`S/canary-check.md`). |
| Owner | The person who decides product questions and approves exceptions. Agents are never the owner. |
| Reference product | A competitor the product replaces or sits next to, or a product the team is inspired by. Named in the intake. |
| TOP item | A behavior from a reference product that users notice first when it's missing. The owner decides each one. |
| Lens | One point of view for a spec review (coverage, security, red team ...). One reviewer per lens. |

## Files

| Step | File | What it holds |
|---|---|---|
| 0 | `qa/intake.md` | The intake answers. Every later step reads it. |
| 1 | `qa/research/<product>.md` | One failure report per reference product, with a link per row |
| 1 | `qa/research/README.md` | Index: file, sources read, size of evidence, what each report turned into |
| 1 | `qa/expected-behavior.md` | Merged checklist of testable behaviors, with the TOP list |
| 1 | `qa/past-failures.md` | The team's own past bugs and embarrassments |
| 2 | `qa/spec.md` | Definition of done, rules, Constants, infrastructure, test rows by theme, smoke set, CI tiers, build order, revision log |
| 2 | `qa/edge-cases.md` | One section per test ID |
| 2 | `qa/decisions.md` | The owner decisions the tests depend on |
| 2 | `qa/audit-prompts.md` | Agent audit prompts (bug hunts) for what a pass/fail test can't judge |
| 3 | `qa/reviews/r<round>-<lens>.md` | One file per review lens per round |

## How to build the test suite

### 0. Intake interview

Ask before any research. The research is only as good as the list of products and risks it starts from.

1. If `qa/intake.md` exists, read it. Show a short summary, and ask only what's missing or may have changed.
2. Else read the repo first (README, package files, docs, issue tracker if there is one) and guess what you can.
   Offer the guesses as answer options, so the person confirms instead of typing.
3. Ask the questions in `T/intake-questions.md`:
   - With the `AskUserQuestion` tool when it's available: 1-4 questions per form, at most 3 forms. Put your guesses
     as options. The person types free answers through "Other".
   - Without it: ask in plain chat, one numbered list per form, and wait for the answers.
4. Write the answers to `qa/intake.md` (format in the template). Put the reference products in the config's
   `[research] products` list too.
5. Don't start step 1 while "what you're building", "reference products" and "workflows that must never break" are
   empty. If the person names no product, propose 3-5 from a web search and ask them to pick.

### 1. Research how the reference products fail

**1a. One failure report per product.** Start one research agent per reference product, in parallel, with
`T/failure-research-brief.md`. Each agent uses web search and web fetch (a headless browser where pages need
JavaScript) on:

- help center and troubleshooting articles,
- release notes and changelogs (the "fixed" lines are a free bug list),
- the public forum, issue tracker, status page or bug board,
- app store and review-site complaints.

Each row in a report is a failure a user saw, its rough count, an example, and a link. A row without a link is
marked "(not in sources)". The agent says which sources it couldn't read. Output: `qa/research/<product>.md`.
A product that already has a report is skipped, unless the owner asks for a refresh.

**1b. Expected-behavior checklist.** For the 1-2 products users will compare with first, an agent reads the how-to
docs and lists the behaviors users expect, as testable lines. Merge them into `qa/expected-behavior.md` with
`T/expected-behavior-checklist.md`. Mark the TOP items: the ones a user notices in the first minutes when they're
missing. Each TOP item becomes an owner decision ("copy it, or not and why") and, when copied, one test.

**1c. Past failures.** Collect the team's own bugs: the intake's "past bugs" answer, the bug history, regressions,
support tickets, the owner's own reports. One table row each: what the user saw, when, source. Output:
`qa/past-failures.md`. The red-team review (step 3) maps each row to the test that catches it.

**1d. Index.** Write `qa/research/README.md`: one row per report (file, sources read, size of evidence). Group the
failures by theme (input, data safety, output, platform, performance, security, first run, plus any the intake's risk
areas add). For each theme, say what the user sees when it fails. Tests come from these.

### 2. Write the spec

The spec says what each test checks and what counts as a pass. It isn't code. The config's `spec` model writes it,
once per phase. Layout and columns: `T/spec-row.md`.

**Rows.** Group rows under theme headings. Each row has a stable ID, **Check** (what the test does), **Pass when** (a
rule a machine can decide; numbers come from one Constants table, by name), **Where** it runs, **Tag** (`auto`,
`scripted`, `manual`), **Kind** (`assert`, `golden`, `audit`), **Needs** (infrastructure), **Dec** (decisions),
**From** (the research row, past failure or review it comes from) and **Fix budget** (the expected fix work for the
bugs this row will find; the item estimate includes it). IDs never change. A retired ID keeps a stub ("merged into X").

**Edge cases.** `qa/edge-cases.md`, one section per ID, same order as the spec (`T/edge-cases.md`). A test is done
when its plain path and every case pass. A case that needs infrastructure the row doesn't list starts as `known-gap`
with that item's ID. A `known-gap` case isn't done, and it isn't a failing test either.

**Owner decisions.** `qa/decisions.md` (`T/owner-decisions.md`). Every product question a test depends on, with a
proposal, the tests, the status, and what the test checks while the decision is open. Ask the owner the questions
for the first milestone up front, as one numbered list, before any test is built. A test that waits on a decision
can only check "the same every time", and that passes wrong behavior. While open, the test is `blocked-D<n>`: it
runs, its failure is reported, it doesn't block a merge, and it isn't done. A release gate fails while a key decision
is open.

**Infrastructure.** A table in the spec: ID, what it is (fakes, validators, fixtures, harnesses), and the tests that
wait for it. Typical items: a fake clock, a file layer with fault injection, a data validator and a canonical hash,
fixture corpus with a manifest, seeded random and property runs, a fake network or service, a scripted fake agent or
user, a screenshot harness with approved goldens, an isolated display session, a perf baseline, structured logs,
a clean-profile machine. Each one is its own backlog item. No test item starts before its infrastructure merges.

**Agent audits.** `qa/audit-prompts.md` (`T/audit-prompt.md`). Prompts that make an agent hunt for what pass/fail
tests can't judge: controls that do nothing, missing states, losing work, claims that aren't true. Each prompt says
which test rows it feeds and whether it runs before each testing round. Each finding becomes a test row or a bug.

**Rules for the spec** (copy them in):

- **Definition of done** at the top, word for word: "A test is done when it passes on main with its fix merged. A
  found bug is fixed in the same item."
- A failure message names the thing that failed (command, widget, file, field), not "assertion failed".
- A fix adds a test for the bug and a test for the behavior next to it.
- A report shows a skipped, not-built or substitute-hardware test as "not tested", never as green.
- Tests that need a real display or device run in an isolated session, never on the owner's own machine session.
- Anti-trivial rules:
  - Every test has a canary: one seeded bug that must make it fail. The reviewer runs it.
  - No test that passes on an empty screen, empty file or empty list. A test that only asserts existence ("widget
    found", "file exists"), or that touches no fixture, is rejected in review.
  - Registry and catalog tests assert a minimum count and a hand-written list of known items. When the registry is
    built in the same item, the lead writes the count and the list before the coder starts.
  - An expected result (manifest, state table, snapshot) is written from the row and its edge cases before the test
    runs, never copied from the app's output.
  - Every allow-list entry has an owner and an expiry date. A new entry fails CI until it's approved.
  - A golden image or snapshot is approved by the owner the first time and on every change, from a before/after
    sheet. An agent never approves its own golden.

**Smoke set.** A short list of rows that tells, on a real build, whether it works at all on a platform. One list per
platform. It's the first thing Milestone 1 makes green.

**CI tiers.** A table in the spec: which rows run where and when.

| Tier | Runs | Typical rows |
|---|---|---|
| Every merge | Headless, under the config's `per_merge_minutes` | Fast asserts, a few property seeds, static checks |
| Every merge once built | Per merge if each test takes under 30 s, else nightly | Slower fixture and journey rows |
| Nightly | Long seeds, fuzzing, perf, real kills, long sessions | Only when the owner approved the cost (`[ci] nightly`) |
| Before a testing round | Devices, lab machines, the agent audits marked "yes" | The smoke sets, scripted rows |
| Manual | A printed checklist with an owner and a date | Screen readers, real hardware gestures |
| Release gate | The exact commit handed to users | Every tier green on that commit, or the build label lists what wasn't tested |

**Build order.** Infrastructure first. Then a small Milestone 1 that proves the pipeline end to end and aims at the
bugs the owner sees by hand (`qa/past-failures.md`) and at the smoke set. A backlog item holds at most the config's
`max_rows_per_item` rows. Each milestone is a table: ID, title, contents, depends on, size. Name the riskiest item
(often the one that moves production code behind a fake).

**Product lessons.** Research findings that aren't tests (a missing feature, a better default) go in a short section
of the spec for the backlog. Don't make them test rows.

### 3. Review the spec

Before any build, run independent reviews. Each reviewer gets the intake, the research, the spec, the edge cases and
the decisions. Not your opinion of them. Pick 3-5 lenses per round from `T/review-lenses.md`:

- feature coverage, security, test quality, user journeys, platform, reliability,
- **red team vs past failures (always):** for each row in `qa/past-failures.md` and the worst research rows, which
  test catches it, and if none does, what change would; then the likely escapes, most likely first,
- structure and build order, code (does the spec match the codebase), numbers (Constants, estimates, CI minutes).

Output: `qa/reviews/r<round>-<lens>.md`. Merge the findings into the spec as a new revision. Log each revision (date,
review files, what changed). Ask the owner new decisions now, not during the build. Run a second round when the first
one changed many rows; the structure, code and numbers lenses fit a later round.

## Build and keep it honest

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
   next to it. If a fix looks bigger than the config's `threshold_tokens`, stop and go to step 5. Don't file it and
   move on.
5. **One review** by the config's `reviewer` model (a stronger model than the coder). Use `T/review-checklist.md`.
   The reviewer runs at least one canary again and checks that no known-failures row was added without approval.
6. **One fix round** by the same coder (its context holds the code). Then merge on green CI.
7. **Lock the test.** Once merged, the test is part of the baseline. Later branches may not remove it, skip it,
   loosen its tolerance or add it to known-failures without the owner's approval (step 5).

A bug that a review, another coder, an audit prompt or a manual run finds goes to the item that owns that code, now.
It isn't a "later" ticket.

### 5. Exceptions: the known-failures list

The list exists for fixes that are too big for the item. It isn't a way to make CI green.

- A row is allowed only when the fix estimate is above `threshold_tokens` (config).
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
bug doesn't count as done. Blocked and `known-gap` rows aren't done. Never report a % without the bug count.

**Phase end.**

1. Main is green. No known-failures row whose test passes now.
2. Tag main `baseline-<phase>`. Write the baseline: test count per area, known-failures count, approved goldens,
   commit and CI run. Later runs compare with the newest baseline tag; a lower count is a failure.
3. One review of the whole phase by the config's `phase_review` model, against the spec and the definition of done
   (`T/phase-review.md`). Its findings go to the lead, who turns them into items. Bugs it finds are fixed in this
   phase, not the next.

**Post-mortem.** After each phase, write a short note: estimate vs actual tokens and time, bugs found, bugs fixed
in the item that found them, known-failures rows added (should be close to 0), review findings, failed CI runs,
escapes (bugs users found that no test caught; add each to `qa/past-failures.md`). Name one or two changes for the
next phase. Change one thing at a time.

## Model roles

Roles come from the config (`[models]`). Typical shape:

| Role | Job | Runs |
|---|---|---|
| `research` | One failure report per reference product, the expected-behavior checklist | Once per phase, in parallel |
| `spec` | Spec, edge cases, decisions, audit prompts, definition of done | Once per phase |
| `spec_review` | One review per lens | Once per review round |
| `lead` | Splits the spec into items, writes briefs, decides, merges | Whole phase |
| `coder` | Writes tests, runs canaries, fixes bugs | Per item |
| `reviewer` | One review per item; stronger than `coder` | Per item |
| `phase_review` | One review of the whole phase | Once per phase |

Use the strongest model where one call has the most leverage (spec, red team, phase review), not per item. A faster
model can do the research reports, because every row carries a link a reviewer can check.
Respect `budget_cap` in the config: plan the phase under it and stop to ask the owner before you pass it.

## Hard rules

- Ask the intake questions before any research. Reuse `qa/intake.md` after that.
- Every research row has a link. Nothing invented.
- A found bug is fixed in the same item. No "bug-fix round later".
- No known-failures row without the owner's approval, and only above the threshold.
- No % without the open-bug count.
- An agent never approves its own golden, its own exception or its own review.
- Ask product questions before the build, not during it.
- Tests that need a real display or device run in an isolated session, never on the owner's own desktop.

## Optional adapters

The loop doesn't need any of these. Plug them in through the config when the project has them:

- An estimate tool that turns measured past work into ranges (`estimate`).
- A terminal multiplexer or agent runner to start research, coder and reviewer agents in their own panes.
- A headless browser for help pages and forums that need JavaScript.
- A backlog tool for items and bug IDs.
- A CI provider. `kf-guard.sh` and `progress.py` only need git, bash and Python 3.11+.
