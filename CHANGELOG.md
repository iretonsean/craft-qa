# Changelog

## 0.2.0 (2026-11-20)

The skill now builds the test suite too, not only the find-and-fix loop.

- **Step 0, intake interview.** Before any research, the skill asks what you're building, for whom, platforms, the
  competitors you replace or sit next to, products you're inspired by, workflows that must never break, known past
  bugs, out-of-scope areas, risk areas, where tests run, the budget and who approves exceptions. It uses
  `AskUserQuestion` when available (at most 3 forms), else plain chat. Answers go to `qa/intake.md` and are reused.
- **How to build the test suite.** One failure report per reference product from help docs, release notes, forums,
  issue trackers and reviews, with a link per row; a merged expected-behavior checklist with a TOP list; a
  past-failures list; a spec with edge cases, owner decisions, infrastructure, agent audit prompts, smoke set, CI
  tiers and build order; spec reviews in lenses with a red team against past failures every round.
- **New templates:** `intake-questions.md`, `failure-research-brief.md`, `expected-behavior-checklist.md`,
  `edge-cases.md`, `owner-decisions.md`, `audit-prompt.md`, `review-lenses.md`. `spec-row.md` now holds the whole spec
  layout and a Tag column (`auto`, `scripted`, `manual`).
- **Config:** new `[intake]`, `[research]`, `[suite]` and `[ci]` tables, and `research` and `spec_review` model roles.
  The spec path moved from `[project] spec` to `[suite] spec` (default `qa/spec.md`).
- More anti-trivial rules: no test that passes on an empty screen, file or list; expected results are written before
  the test runs, never copied from the app's output; untested rows show as "not tested", never green.

## 0.1.0

- First release: the six-step loop (research, spec, spec review, build per item, exceptions, honest progress),
  `progress.py`, `kf-guard.sh`, `canary-run.sh`, and templates for briefs, reviews and the known-failures file.
