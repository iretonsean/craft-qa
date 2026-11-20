# Expected-behavior checklist template

Output: `qa/expected-behavior.md`. One agent per main reference product reads its how-to docs (about 20-40
articles) and lists the behaviors its users expect. Then merge the lists into one file. These are the behaviors
your users will try first, with the habits they bring from the other product.

## Rules

- One testable line per behavior: the action and the visible result. "Shift+click adds an item to the selection; a
  Shift+click on a selected item removes it." Not "selection works well".
- A source tag per line: the short name of the article, expanded in the Sources section. A line from use, not from
  an article, is marked **(not in docs)**.
- Group by area (selection, editing, navigation, save and sync, sharing, settings ...).
- **[TOP]** marks the behaviors a user notices in the first minutes when they're missing. Aim for 15-30. Count them
  and write the real count at the top; reviews check it.
- For each TOP item, the owner decides: copy it, or not and why (one row in `qa/decisions.md`). A copied TOP item
  gets one test row. A "not" keeps its reason, so later reviews don't ask again.

## Format

```markdown
# Expected behavior (<date>)

From: <product A> (<n> articles), <product B> (<n> articles). <n> behaviors, <n> marked TOP.

## <Area>
1. **[TOP]** <action> -> <visible result>. [<source>]
2. <action> -> <visible result>. [<source>]
3. <action> -> <visible result>. **(not in docs)**

## TOP list

| # | Behavior | Our decision (D<n>) | Test |
|---|---|---|---|
| 1 | <short name> | copy / not: <reason> / open | T<id> |

## Sources
- [<short name>] <title>, <link>
```
