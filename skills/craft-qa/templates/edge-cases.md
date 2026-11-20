# Edge cases template

Output: `qa/edge-cases.md`. A companion to `qa/spec.md`. One section per test ID, in the same order as the spec.
Each section lists the cases a test must cover beyond its plain path.

A test is done when its plain path and every case here pass. A case that needs infrastructure the row doesn't list
starts as `known-gap` with that infrastructure item's ID. A `known-gap` case isn't done, and it isn't a failing test.

## Head of the file

```markdown
# Edge cases per test (revision <n>, <date>)

- Marks: **(<platform>)** = that platform only; no mark = every platform.
- "None beyond the row" means the spec row holds every case.
- Where a case depends on a decision, the D-ID from `qa/decisions.md` is given.
- Cases of retired IDs are under the ID they merged into. The retired ID keeps a one-line section.
```

## One section per ID

```markdown
## <Theme letter>. <Theme name>

### T1.1 <row title>
- <empty>; <one of each type>; <mixed>; <a thousand of them>.
- <run twice in a row>; <run while another input has focus>; <undo, then redo>.
- <case> (D<n>).
- <case> **(<platform>)**.

### T1.2 Merged into T1.1
- Cases are under T1.1.
```

## Cases to consider for every row

- **Size:** empty, one, many, huge (10x the largest real case), one over each limit.
- **Input:** bad, partial, pasted, very long, other script or direction (CJK, RTL, emoji), other locale (decimal
  comma, date order).
- **Timing:** interrupted mid-action, fast repeat, two actions at once, slow machine, slow or no network, sleep and
  wake.
- **State:** first run, after relaunch, after a crash, second window or tab, signed out, read-only, out of disk.
- **Display:** smallest supported window, other scale (1.25, 1.5, 2), dark and light, reduced motion, high contrast.
- **People:** keyboard only, screen reader, touch, a second user on the same data.
- **History:** undo and redo across the action, files from every shipped version, files from a newer version.
