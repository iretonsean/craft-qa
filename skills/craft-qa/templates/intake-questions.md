# Intake questions

Ask these before any research (SKILL.md step 0). Read the repo first and offer your guesses as options, so the
person confirms instead of typing. Skip a question the repo or an existing `qa/intake.md` already answers; show the
answer and ask "still true?" in one line instead.

## How to ask

- **With `AskUserQuestion`:** one call per form, 1-4 questions per call, at most 3 forms. Each question gets 2-4
  options (your guesses, or common answers). The tool adds "Other" for a free answer. Use `multiSelect: true` where
  more than one answer fits (platforms, risk areas, where tests run).
- **Without it:** post each form as a numbered list in chat and wait for the answers before the next form.
- Keep the wording plain. Don't explain the method in the question. One short line of why is enough.

## Form 1: the product

| # | Question | Header | Options to offer | multiSelect |
|---|---|---|---|---|
| 1 | What are you building, in one line? | Product | Your guess from the README; "a web app", "a desktop app", "a mobile app", "an API or library" | no |
| 2 | Who uses it? | Users | Guesses: "professionals in <field>", "first-time users", "developers", "internal team" | yes |
| 3 | Which platforms must work? | Platforms | Web (which browsers), macOS, Windows, Linux, iOS, Android, server/CLI | yes |
| 4 | Where can tests run? | Test places | CI (which provider), local machine, real devices or a device lab, a manual checklist | yes |

## Form 2: references and history

| # | Question | Header | Options to offer | multiSelect |
|---|---|---|---|---|
| 5 | Which products do you replace or sit next to? (competitors) | Competitors | 2-4 products from a web search for the category; "none" | yes |
| 6 | Which products inspire you, even outside your category? | Inspired by | Products the README or docs name; "same as competitors" | yes |
| 7 | Which workflows must never break? | Must work | Guesses from the main features: "sign up and first use", "save and reopen", "pay", "export or share" | yes |
| 8 | Which bugs or embarrassments do you already know about? | Past bugs | "I'll list them", "see the issue tracker", "none yet" | no |

## Form 3: limits

| # | Question | Header | Options to offer | multiSelect |
|---|---|---|---|---|
| 9 | Which areas are the biggest risk? | Risks | Data loss, security and privacy, money and payments, accessibility, performance, first run | yes |
| 10 | What is out of scope for now? | Out of scope | Guesses: "localization", "old OS versions", "offline", "nothing" | yes |
| 11 | What budget does the suite have? | Budget | "N % of the weekly token limit", "N CI minutes a month", "free CI minutes only", "no cap, ask me" | no |
| 12 | Who approves exceptions and product decisions? | Owner | "me", a name from the git log, "a team lead" | no |

If a form would leave a question out, ask it in the next form. Never more than 3 forms; ask what's left in chat.

## `qa/intake.md` format

```markdown
# Intake (<date>)

| # | Question | Answer | Source |
|---|---|---|---|
| 1 | Building | <one line> | owner, <date> |
| 2 | Users | ... | owner / repo README |
| 3 | Platforms | ... | |
| 4 | Test places | ... | |
| 5 | Competitors | Product A, Product B | |
| 6 | Inspired by | Product C | |
| 7 | Must never break | 1. ... 2. ... | |
| 8 | Past bugs | see qa/past-failures.md | |
| 9 | Risk areas | ... | |
| 10 | Out of scope | ... | |
| 11 | Budget | ... | |
| 12 | Owner | <name> | |

## Reference products

| Product | Role | Why it matters | Sources to read first |
|---|---|---|---|
| Product A | competitor | users switch from it | help center, release notes, forum |
| Product C | inspiration | the feel the owner wants | how-to docs |

## Changes
- <date>: <what changed and why>
```

On later runs, read this file, show a 3-line summary, and ask only about gaps or changes. Log each change.
