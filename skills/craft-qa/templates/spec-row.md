# Spec row template

Copy one block per test. Put the table rows in the spec, and the edge cases in a separate section with the same ID.

## Table columns

| ID | Check | Pass when | Where | Kind | Needs | Dec | From | Fix budget |
|---|---|---|---|---|---|---|---|---|
| T3.2 | Hover outline on canvas objects | Outline pixels sit on the object bounds within the *Alignment* constant, contrast ≥ *Outline contrast* against fill and background, and clear within *One frame* when the pointer leaves | headless | golden + assert | screenshot harness, fixtures | D4 | bug #812; similar product's forum thread | M |

- **ID:** stable. Never reuse or renumber. A retired ID keeps a stub row: "merged into T3.3".
- **Check:** what the test does, in a few words.
- **Pass when:** a rule a machine can decide. Numbers come from the Constants table, by name.
- **Where:** headless, real window in an isolated session, device lab, or manual checklist (with an owner and date).
- **Kind:** assert, golden (compared with an approved image or snapshot), or audit (an agent's judgment).
- **Needs:** infrastructure that must be merged first.
- **Dec:** the product decisions the row depends on. A row with an open decision can't be done.
- **From:** the real failure it comes from (bug ID, report, review round).
- **Fix budget:** the expected size of the fix work for the bugs this row will find (XS-XL or tokens).

## Edge cases (one section per ID)

### T3.2
- Object smaller than the handle size.
- Object under another object; alpha 0; half pixel at scale 2.
- Pointer leaves the window, not only the object.
- Hover vs selection: the two outlines look different.

## Definition of done (top of the spec, word for word)

> A test is done when it passes on main with its fix merged. A found bug is fixed in the same item.
> A known-failures row needs the owner's approval and is allowed only when the fix is above the threshold.
