# Spec template

Output: `qa/spec.md`. The spec says what each test checks, what counts as a pass, where it runs, and which real
failure it comes from. It isn't code. A lead turns its rows into backlog items.

## Layout of `qa/spec.md`

```markdown
# <Product> test suite (revision <n>, <date>)

> A test is done when it passes on main with its fix merged. A found bug is fixed in the same item.
> A known-failures row needs the owner's approval and is allowed only when the fix is above the threshold.

- Intake: qa/intake.md. Evidence: qa/research/ (<n> reports). Checklist: qa/expected-behavior.md (<n> TOP items).
- Edge cases: qa/edge-cases.md. Decisions: qa/decisions.md. Audit prompts: qa/audit-prompts.md.

0. How to read: columns, tags, places tests run, rules for every test, Constants, smoke set, conventions,
   anti-trivial rules
1. Infrastructure
2. Decisions (link to qa/decisions.md, and which ones block the release gate)
3. Tests by theme (A. <theme>, B. <theme> ...)
4. Agent audits (the prompt index from qa/audit-prompts.md)
5. CI tiers
6. Build order and Milestone 1
7. Product lessons (not tests; for the backlog)
8. Revision log
```

## Table columns (section 3)

Put the rows under theme headings (for example A. Input and commands, B. Data safety, C. Output, D. Platform and
performance, E. Security and privacy, F. First run). The theme comes from the research grouping.

| ID | Check | Pass when | Where | Tag | Kind | Needs | Dec | From | Fix budget |
|---|---|---|---|---|---|---|---|---|---|
| T3.2 | Hover outline on items | Outline pixels sit on the item bounds within the *Alignment* constant, contrast ≥ *Outline contrast* against fill and background, and clear within *One frame* when the pointer leaves | headless | auto | golden + assert | I3, I4 | D4 | past-failures #3; research/product-a.md row 12 | M |

- **ID:** stable. Never reuse or renumber. A retired ID keeps a stub row: "merged into T3.3".
- **Check:** what the test does, in a few words.
- **Pass when:** a rule a machine can decide. Numbers come from the Constants table, by name.
- **Where:** a place from the "Places tests run" table (headless, isolated real window, device lab, manual).
- **Tag:** `auto` (runs with no person), `scripted` (a script on a lab machine or device; a person starts it and
  records the result), `manual` (a checklist with an owner and a date each round). Add `hardware-required` when a
  run on a substitute (a software renderer, an emulator) counts as "not tested". A row with two tags says which part
  has which tag.
- **Kind:** `assert` (a computed check), `golden` (compared with an approved image or snapshot), `audit` (an agent's
  judgment, listed in section 4).
- **Needs:** infrastructure items (section 1) that must be merged first.
- **Dec:** the decisions in qa/decisions.md the row depends on. A row with an open decision can't be done.
- **From:** the real failure it comes from (a research row, a past failure, a bug ID, a review round).
- **Fix budget:** the expected size of the fix work for the bugs this row will find (XS-XL or tokens).

## Section 0 tables

**Places tests run**

| Place | What runs there | Cost |
|---|---|---|
| Headless CI | Most `auto` rows | CI minutes per merge |
| Isolated real window (a private display session, a test browser profile) | Rows that need a real window, input method or clipboard | Same |
| Device lab / other OS runner | Platform rows and that platform's golden set | Paid minutes; before a testing round |
| Agent audit | Judgment checks (section 4) | Tokens; before each testing round |

**Constants** (rows cite these by name; a value marked "proposal" waits for the owner under a decision)

| Name | Value | Used by | Source |
|---|---|---|---|
| One frame | The next presented frame after the event | T3.2 | review r1 |
| Pixel tolerance | ≤ 0.5 % of pixels differ by more than 8 per channel | T10.1 | proposal |

**Conventions for builders:** where test files go, how test functions are named (they start with the row ID), how to
run one group, the test index (every ID with status `spec`, `built`, `done`, `known-gap` or `blocked-D<n>`, its tag
and its test name), and the known-failures file.

## Infrastructure table (section 1)

| ID | Infrastructure | Tests that wait for it |
|---|---|---|
| I1 | Data validator and canonical hash (unique IDs, parents exist, no cycles, finite numbers, refs resolve) | T1.1, T9.1 |
| I2 | Fake clock (wall and monotonic) and a file layer with fault injection (fail the k-th write, torn write, disk full, read-only) | T9.4, T9.5 |

## Build order (section 6)

| ID | Title | Contents | Depends on | Size |
|---|---|---|---|---|
| M1-01 | Conventions, index, report | Test index, known-failures file and its CI check, the progress line, the canary rule in the review checklist | none | M |
| M1-02 | Validator | I1 | none | M |
| M1-03 | Smoke set, platform 1 | T1.1, T3.2, T9.1 (3 fixtures) | M1-01, M1-02 | M |

## Edge cases

In `qa/edge-cases.md`, one section per ID (`T/edge-cases.md`).

## Revision log (section 8)

| Revision | Date | Reviews | What changed |
|---|---|---|---|
| 1 | <date> | none | First draft from the research |
| 2 | <date> | reviews/r1-coverage.md, r1-test-quality.md, r1-red-team.md | <n> rows added, <n> pass rules made stricter, D<n>-D<n> added |
