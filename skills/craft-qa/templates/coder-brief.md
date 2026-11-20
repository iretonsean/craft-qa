ITEM: <ID>
ROLE: build

# Brief: <ID> <short name>

**Fix every bug your tests find. The item isn't built until they pass.**

## Goal
Build the tests for spec rows <IDs> and fix every bug they find, in this branch.

## Read first
- Spec rows: <spec path>#<IDs> and their edge cases.
- Project rules: <rules file>.
- Definition of done: the tests pass on main with their fixes merged.

## Steps
1. Write the tests for each row and each edge case. Run them. Failures are expected: they're the bugs you fix next.
2. For each new or changed test, run a canary: seed one bug that the test must catch (stub the function, remove the
   draw call, flip the check). The test must fail. Revert the seed. Record it in the PR body:
   | test | seeded bug | failing log line |
3. Fix every bug the tests found. Each fix gets a test for the bug and a test for the behavior next to it.
4. If one fix looks bigger than <threshold> tokens, stop. Tell the lead with your estimate and what the user sees.
   Don't add a known-failures row yourself. Only the owner can approve one.
5. Run the full suite locally. Then start CI once (<ci command>).

## Not allowed
- A new known-failures row, skip marker, ignore flag, looser tolerance or removed test to make CI green.
- Approving your own golden or snapshot.
- Opening windows on the owner's desktop. Real-display tests run in an isolated session.

## Estimate
<range from the estimate command, including fix work>

## Report (end of your work)
- Tests added (count), bugs found, bugs fixed, bugs sent to the lead (with estimates).
- Canary table.
- CI run link and result.
