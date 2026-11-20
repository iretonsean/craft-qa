ITEM: <ID>
ROLE: review

# Review checklist: <ID>

Review the branch against its spec rows. Report findings as a numbered list: severity (blocker, should fix, nit),
file and line, what's wrong, and the fix.

## Done means done
- [ ] Every test in the item passes on the branch. No test is skipped, ignored or marked flaky in this branch.
- [ ] No known-failures row was added. If one was, the commit has `Approved-by:` with an approver from the config,
      and the fix estimate is above the threshold.
- [ ] No tolerance was loosened, no test removed, no golden changed without the owner's approval.
- [ ] Every bug the tests found is fixed here. Each fix has a test for the bug and for the behavior next to it.

## Tests can fail
- [ ] The PR body has a canary row for every new or changed test (seeded bug + failing log line).
- [ ] Run at least one canary yourself. It must fail. Say which one.
- [ ] The "Pass when" rule from the spec is what the test asserts, not a weaker form ("pixels differ" is not
      "the outline is drawn in the right place").
- [ ] Each edge case in the spec for these IDs has a test, or a note with the reason.
- [ ] Failure messages name the thing that failed.

## Code
- [ ] Fixes address the cause, not the test.
- [ ] No errors are swallowed. No new hard-coded values where the project uses tokens or constants.
- [ ] Tests are deterministic: fixed seeds, fake time, pinned fonts or data where needed.

## Out of scope
- Add follow-ups for unrelated problems to the lead's list. Bugs in this item's code are not follow-ups: they're
  blockers.
