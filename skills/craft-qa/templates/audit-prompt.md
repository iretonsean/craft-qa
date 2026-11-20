# Agent audit prompts (bug hunts)

Output: `qa/audit-prompts.md`. Prompts that make an agent find what the owner shouldn't have to find: dead controls,
missing feedback, broken flows, visual bugs. An audit isn't pass/fail. Each finding becomes a test row, or a bug that
goes to the item that owns the code.

## Head of the file (copy it)

```markdown
# Audit prompts (<date>)

How to run any of these:
- Run against the build that ships, not a mock. When a prototype or design exists, use it as the spec: "the
  prototype shows how it should work".
- Drive the real product in an isolated session (a headless display, a test browser profile, a test account).
  Never the owner's own desktop or account. Attach cropped screenshots as proof.
- Report first, as a table: item, what happens, what should happen, screenshot, severity. Fix in a second step.
- Severity: blocks a task / wrong result / looks broken / polish.
```

## One prompt

````markdown
### P<n>. <short name>
```
<the prompt, in plain words, as you'd paste it to an agent>
```
Finds: <the past failure or research row it targets>.
Feeds tests: <T-IDs or "none">. Audit before each testing round: <yes | no>.
````

## Index table (end of the file, and in the spec's audit section)

| Prompt | Topic | Feeds tests | Audit before each round |
|---|---|---|---|
| P1 | Controls that do nothing | T1.1 | no |

## Starter prompts

Adapt the words to the product. Drop what doesn't apply. Add one prompt per theme from the research.

- **Implicit state machines.** "Find every implicit state machine in my app. For each, list its states and the actions
  between them, and draw it (states as boxes, actions as arrows). Then list flag combinations that shouldn't be
  possible but are, and states with no designed UI."
- **Controls that do nothing.** "List every menu item, button, toggle and context-menu entry. For each, find the code
  it runs, trigger it in the running app and show what changed. Mark every item that does nothing, only logs, is a
  stub, or changes something you can't see."
- **Shortcuts.** "List every shortcut shown in menus, tooltips, docs and onboarding. Press each one. Report shortcuts
  that are shown but don't work, work but aren't shown, or clash with another shortcut or the OS."
- **Settings that don't stick.** "Change every setting to a non-default value, quit and relaunch. Report settings that
  reset, apply only after a restart without saying so, or change nothing visible."
- **Unfinished code a user can reach.** "Find every TODO, FIXME, stub, placeholder text and hard-coded sample data.
  Keep the ones a user can reach, and show the path to each."
- **Missing interaction states.** "For every interactive element, check hover, pressed, selected, keyboard focus,
  disabled and dragging. One row per element, one column per state. Mark each state with no visible change."
- **Empty, loading and error states.** "Find every view that loads or can be empty or fail. Force each state. Report
  blank screens, spinners that never end and errors that don't say what to do."
- **Losing work.** "Try to lose work: quit mid-edit, kill the process, fill the disk, go offline, open the same item
  twice. Report anything that's gone or changed after reopen."
- **Save, reopen, compare.** "Make a rich document or record, save it, reopen it and compare every field and pixel.
  Report every difference."
- **Claims that aren't true.** "List every claim in the docs, onboarding, store page and marketing site. Check each
  one in the running product. Report the false ones."
- **Worked yesterday.** "Compare this build with the last release on the must-never-break workflows. Report every
  change a user would notice."
- **Keyboard only, screen reader, contrast.** "Do the main workflows with the keyboard only, then with a screen
  reader. Measure text and focus contrast. Report every dead end."
- **Odd content and sizes.** "Use very long names, other scripts, emoji, empty values, huge files, the smallest
  window and other display scales. Report clipping, overlap and layout jumps."
- **Compared with the reference product.** "Do the TOP items from qa/expected-behavior.md in our product and in
  <product>. Report every difference a user of <product> would notice."
