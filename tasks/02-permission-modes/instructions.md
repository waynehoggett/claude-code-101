# Permission modes

Permission modes control how much Claude Code asks before it acts, and permission
rules let you decide what's always allowed and what never is. In this task you'll
try both.

## 1 · Switch permission modes

At the Claude prompt, press **Shift+Tab** to switch permission modes. Watch the
indicator above the prompt change as you cycle through them:

- **Manual.** Claude asks before running commands or editing files. This is the mode
  your session starts in here.
- **Auto.** Claude works without asking for each step. A safety classifier reviews
  every action and stops the risky ones. You'll set it up in step 3.
- **Accept edits.** File edits are approved automatically, commands still ask.
- **Plan mode.** Claude only reads and researches, then presents a plan for approval.

Cycle back to **Manual** when you've seen them all.

:::note[Which mode should you use?]
Manual is the right home base while you're learning. Plan mode is great for letting
Claude explore a question safely, accept edits suits work where you review changes in
git afterwards instead of one at a time, and auto is the mode most day-to-day work
happens in once you trust its guardrails.
:::

## 2 · Configure a persistent permission

Modes are per session. For permissions that stick, Claude Code keeps allow, ask, and
deny rules in its settings. The most common rule of all is a deny rule that keeps
Claude away from secrets. Open the permission rules screen:

```
/permissions
```

Add a new **deny** rule in your **User settings** with this exact rule text, which
stops Claude reading `.env` files:

```
Read(./.env*)
```

:::tip[Reading the rule]
The trailing `*` is doing the work: `Read(./.env*)` covers `.env` itself and every
variant like `.env.local` or `.env.production`. Allow rules use the same shape for
the opposite purpose, for example `Bash(npm run test:*)` pre-approves running your
test suite without asking.
:::

:::tip[Choosing a scope]
When you add a rule, Claude Code asks where to save it:

- **User settings** apply to you in every project on this machine. Use them for
  rules you want everywhere, like protecting secrets here.
- **Project settings** live in the repo and are shared with everyone who works on
  it. Use them for rules the whole team agrees on, like running the test suite.
- **Local settings** stay in the project but out of git, so they apply only to you,
  only here. Use them for personal exceptions you don't want to share.
:::

## 3 · Explore auto mode

Auto mode needs no setup: a built-in safety classifier judges each action Claude
wants to take, and you can read and extend the guidance it works from.

1. Run `/permissions` again and open the **Auto mode** tab.
2. Add a new **Soft allow** rule:

```
Running the date command is always safe
```

:::note[The rule types]
- **Soft allow**: fine to do without asking.
- **Soft deny**: stop and check with you first.
- **Hard deny**: never do it.
- **Environment**: a plain-language description of your setup that gives the
  classifier context.
:::

:::tip[Auto mode rules are prose]
Rules are plain sentences, not patterns. The classifier reads them the way a new
teammate would, so write them like you'd brief a person: name what's trusted and
why. "Pushing to staging is safe, it resets nightly" is a perfectly good rule.
:::

Click **Check task** below when you're done.
