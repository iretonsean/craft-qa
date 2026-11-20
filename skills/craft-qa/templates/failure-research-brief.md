ITEM: process:research-<product>
ROLE: build

# Brief: failure research for <product>

Start one agent per reference product, in parallel. Fill the `<...>` fields from `qa/intake.md`.

## Goal

Find how <product> fails for its users, from public sources, so our tests catch the same classes of bugs before our
users do. We're building <one line from the intake>, for <users>, on <platforms>. <product> is a <competitor |
inspiration> for us.

## Read

Use web search and web fetch. Use a headless browser when a page needs JavaScript. Read, in this order:

1. Help center and troubleshooting articles ("not working", "missing", "lost", "crash", "slow", "sync").
2. Release notes and changelogs. The "fixed" lines are a bug list. Read as many versions as you can reach.
3. The public forum, issue tracker, bug board or status page: thread titles first, then the 20-30 threads with the
   most replies or votes.
4. App store and review-site complaints (1-2 star reviews), when the product has them.

Focus on our risk areas: <risk areas>. Skip: <out of scope>.

## Rules

- Every row has a link to the page you read. A row you know from use, not from a source, is marked
  "(not in sources)". Don't invent failures, counts or versions.
- Say which sources you couldn't read (404, sign-in, needs JavaScript) and what you tried.
- Counts are rough ("~40 fixes"). Say when they run low.
- Write what the user saw, not the internal cause. "Fields lost their content while typing" beats "state bug".
- Don't copy long passages. Quote one short line at most per row.

## Output: `qa/research/<product>.md`

```markdown
# <product>: failure modes (<date>)

**Sources read**
- <source>: <what, how many pages or versions> (<link>)
- Not read: <source> (<why>)

## 1. Failure categories

| Category | Count (rough) | What the user saw (examples) | Source |
|---|---|---|---|
| <e.g. fields and forms> | ~70 | <version/date>: <one example>. <second example>. | <link>, <link> |

## 2. Worst failures (top 10)

| # | Failure | What the user lost or saw | Source |
|---|---|---|---|

## 3. Test ideas

| Idea | Pass when (draft) | From row |
|---|---|---|

## 4. Audit prompt ideas
- <a bug hunt an agent can run on our product, for things a pass/fail test can't judge>
```

## Done when

The report has at least 5 categories with links, a top-10 list and test ideas, or it says why the sources were too
thin. Report back in 5 lines: sources read, rows found, the 3 worst failures, gaps.
