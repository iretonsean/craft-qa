# The canary rule

A test that can't fail proves nothing. A canary is one seeded bug that must make the test fail.

## Rule

- Every new or changed test has a canary.
- The coder runs it before the PR. The reviewer runs at least one again.
- The PR body has one row per test:

  | test | seeded bug | failing log line |
  |---|---|---|
  | `t3_2_hover_outline_drawn` | removed the `draw_hover()` call | `assert: no outline pixels at layer bounds (0 of 412)` |

- The seed is a real bug a user could meet: stub the command, remove the draw call, flip a condition, return early,
  drop a save. Don't seed a bug in the test itself.
- The seed is reverted before commit. It never lands on main.
- A test whose canary passes is rewritten, not merged.

## Exceptions (no canary needed)

- A change to a test's doc comment, signature only, or message text only. Say so in the row.
- A test on the known-failures list: it already fails on main. Its row gives the failing log line from main.

## Checks a reviewer makes

- Every new or changed test has a row. A row has a seeded bug that isn't "none" and a log line with real text
  (an assert message, "FAIL", a quoted value), not "fails" or "n/a".
- The seeded bug is in the code under test, not in the test.
- The log line names the thing that failed.

## Run one

`canary-run.sh` runs the test clean (it must pass), applies the seed as a patch, runs the test again (it must fail)
and reverts the patch:

```
git diff > ../seed.patch && git checkout -- .       # make the seed, save it, undo it
scripts/canary-run.sh ../seed.patch -- make test-one TEST=t3_2_hover_outline_drawn
```

Output: `CANARY OK` with the failing log line (paste it in the PR table), or `CANARY FAIL` (exit 1).

A project can add an automatic check that parses the PR table and lists tests with no row. That parser depends on
the test framework, so it isn't part of this skill.

Watch for build caches that key on file time and size. The seed and its revert can land in the same second with the
same size, so a cache can run old code (Python bytecode does this: set `PYTHONDONTWRITEBYTECODE=1` for canary runs).
