# Owner decisions template

Output: `qa/decisions.md`. Some tests can't pass or fail until the owner decides how the product should behave. Each
row is a proposal from the research, the reviews or the lead. The owner marks it **Yes**, **No**, or writes the
choice, and the status becomes `decided`.

## Rules (copy into the head of the file)

- While a decision is `open`, each test that depends on it is `blocked-D<n>` in the test index. It runs, and it does
  what the "Test behavior while open" column says. A blocked failure is reported, but it doesn't block a merge, and
  the test isn't done.
- A blocked test gets no known-failures row. It counts as listed.
- **A release gate fails while <key decision IDs> are open.**
- The lead asks the owner the decisions for the next milestone up front, as one numbered list, before any test of
  that milestone is built. Each question says what the user sees under each choice.
- Write the owner's answer in their words, with the date. When an answer replaces an older decision, keep the old
  text in the row ("Replaced by D<n>").

## Format

```markdown
# Decisions the tests depend on (revision <n>, <date>)

| # | Decision | Proposal | Test(s) | Status | Test behavior while open | Owner |
|---|---|---|---|---|---|---|
| D1 | Where we copy <reference product> and where we don't | Copy the TOP items in qa/expected-behavior.md, except <list> | T3.1-T3.28 | open | Each test checks the proposal. The release gate fails. | |
| D2 | <minimum value of a field> | <0 allowed, never negative> | T6.4 | decided | T6.4 checks only that the value never goes negative. | Yes (<date>) |
| D3 | <timeouts, caps and budgets> | The values marked "proposal" in the spec's Constants table | rows that cite D3 | open | Tests use the proposal values; a failure is reported as blocked-D3. | |
```

## Good decision questions

- Copy or not, for each TOP item from the expected-behavior checklist.
- Limits: minimum and maximum values, timeouts, retry rules, caps, budgets.
- What happens on conflict: two windows, two users, a file changed outside the app, a newer file format.
- Defaults: first window size, where a new item goes, what opens at launch.
- What the product never does: telemetry, network calls, destructive writes without a confirm.
- The supported matrix: OS versions, browsers, devices, hardware.
