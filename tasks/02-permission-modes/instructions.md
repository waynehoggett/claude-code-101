# Permission modes

By default, Claude Code asks before it runs commands or edits files. Permission modes
control how much it asks, and permission rules let you pre-approve the things you
trust. In this task you'll try both.

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
deny rules in its settings. Open the permission rules screen:

```
/permissions
```

Add a new **allow** rule in your **User settings** with this exact rule text, which
pre-approves running the harmless `date` command:

```
Bash(date:*)
```

:::tip[Reading the rule]
`Bash(date:*)` means the Bash tool may run `date` with any arguments, without asking.
The same shape works for anything you trust, for example `Bash(npm run test:*)`.
:::

## 3 · Explore auto mode

Auto mode cuts down permission prompts a different way: a safety classifier reviews
each action Claude wants to take and blocks the risky ones, so routine work flows
without asking. Run the setup and follow it through:

```
/auto-mode-setup
```

The setup scans your project and recent activity, then proposes rules for what auto
mode may do here. Read through what it found before you decide what to keep.

Click **Check task** below when you're done.
