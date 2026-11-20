ITEM: process:phase-review
ROLE: review

# Phase review: <phase name>

One review of the whole phase, by the config's `phase_review` model. Input: the spec, the definition of done, the
baseline file, `progress.py` output, the known-failures file and the merged PRs of the phase.

## 1. Answer first
In 3-5 lines: is the phase done by the definition of done? If not, what's missing, as a count.

## 2. Numbers
| Measure | Value |
|---|---|
| Spec rows | |
| Rows done (pass on main, fix merged) | |
| Open bugs (known-failures + other open) | |
| Known-failures rows added this phase (with approvals) | |
| Bugs found / fixed in the same item | |
| Tests with a recorded canary | |
| Estimate vs actual (tokens, time) | |
| Failed CI runs | |

## 3. Gaps against the spec
- Rows with no test, rows whose test asserts less than "Pass when", edge cases with no test.
- Open decisions that block rows.

## 4. Escapes
Take the red-team list from the spec review. For each item: caught now, yes or no, and by which test.

## 5. Findings for the lead
Numbered. Each finding: what, where, why it matters to the user, and a suggested item. Bugs found here are fixed in
this phase.

## 6. Post-mortem notes
What worked, what didn't, and one or two changes for the next phase.
