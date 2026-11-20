ITEM: process:review
ROLE: review

# Spec review lenses

One reviewer per lens. Pick 3-5 lenses per round. Red team is in every round. Each reviewer reads `qa/intake.md`,
`qa/research/`, `qa/expected-behavior.md`, `qa/past-failures.md`, `qa/spec.md`, `qa/edge-cases.md` and
`qa/decisions.md`. Don't give a reviewer your opinion of the spec. Output: `qa/reviews/r<round>-<lens>.md`.

Every review ends with a numbered list of findings: severity (blocker, should fix, nit), the row or section, what's
wrong, the fix (a new row, a changed "Pass when", a new edge case, a new decision, a new infrastructure item).

## Lenses

| Lens | Asks | Good round |
|---|---|---|
| Feature coverage | Which features, screens and settings have no row? Which research categories turned into no test? | 1 |
| Security | Which inputs, files, network calls, secrets, permissions and logs have no row? What would an attacker try first? | 1 |
| Test quality | Which rows pass when the feature is broken? ("pixels differ" but are wrong; an entry exists but does nothing; a field works alone but not in a form; the test passes on an empty screen) | 1 |
| User journeys | Walk 3-5 real users through the must-never-break workflows, minute by minute. Where does the suite stop watching? | 2 |
| Platform | Which OS versions, browsers, devices, scales, input methods and hardware classes does CI never run on? | 2 |
| Reliability | Crashes, kills, power loss, full disk, slow network, long sessions, memory growth: which have a row? | 2 |
| Red team vs past failures | See below. Always. | every round |
| Structure and build order | Can a lead build this? Infrastructure before tests, item size, dependencies, Milestone 1 scope, the smoke set | 3 |
| Code | Does the spec match the codebase? Do the named files, functions and fakes exist? What exists already that the spec rebuilds? | 3-4 |
| Numbers | Are the Constants measured or guessed? Are estimates, CI minutes and costs right? Which numbers wait for the owner? | 3-4 |

## Red team format

Part 1 takes each row of `qa/past-failures.md` and the worst rows from the research.

```markdown
## (1) Past embarrassments

| Embarrassment | Caught by | Gap and fix |
|---|---|---|
| <what the user saw> | **T<id>** (+ T<id> for wiring) | Mostly caught. Gap: <how the test still passes while the bug is there>. Fix: <the stronger pass rule>. |
| <what the user saw> | T<id> checks content only | **Not caught** when <condition>. Fix: <new row or edge case>. |
```

Part 2 lists the bugs most likely to reach users, most likely first.

```markdown
## (2) Escapes, most likely first

1. **<short name>.** Minute <n>: <what the user does and sees>. Why it escapes: <which rule, tag or tier lets it
   through>. Fix: <the change>.
```

Typical escapes to check: tests that wait on open decisions and only check "the same every time"; goldens that keep a
visual bug from the first shot; CI hardware that differs from users' hardware; rows tagged manual that nobody runs;
the build under test isn't the build shipped; a TOP count that doesn't match the checklist.

## After the round

The spec writer merges the findings into a new revision and logs it (date, review files, what changed). New owner
questions go to `qa/decisions.md` and to the owner now. Run another round when this one changed many rows.
