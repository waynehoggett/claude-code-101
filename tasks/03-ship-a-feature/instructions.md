# Ship a feature

Time to use Claude Code the way you will at work: explore a codebase, plan a change,
build it, and commit. You'll do it on a small sample project.

## 1 · Plan and build a feature

- **a. Clone a sample project.** Two versions of the same small project are
  available, choose whichever language you prefer, you only need one.

  Python (`ledger-py`):

  ```bash
  git clone https://github.com/waynehoggett/ledger-py
  ```

  JavaScript (`ledger-js`):

  ```bash
  git clone https://github.com/waynehoggett/ledger-js
  ```

- **b. Start Claude Code in the project.** Change into the cloned directory and
  start Claude Code.

- **c. Plan the feature.** Switch to **Plan mode**, then ask:

  ```
  Add support for deleting a transaction to this project.
  ```

- **d. Build it.** Review the plan Claude presents, then approve it and watch the
  work happen.

- **e. Commit.** Ask Claude:

  ```
  Commit the change with a clear message.
  ```

:::tip[Why plan first?]
In Plan mode Claude reads the codebase and proposes an approach before touching any
file. Reviewing the plan is much cheaper than reviewing a pile of wrong edits, and
if the plan misses something, say so and Claude will revise it before building.
:::

## 2 · Make tests non-negotiable

- **a. Check the tests.** Did Claude add tests for the new feature? Run the suite
  and look.

  Python:

  ```bash
  python -m unittest
  ```

  JavaScript:

  ```bash
  npm test
  ```

:::tip[Bash mode]
You don't need to leave Claude Code to run a command. Prefix it with `!` at the
Claude prompt, like `!npm test`, and it runs straight in your shell with the output
visible to both you and Claude.
:::

- **b. Set a rule.** Ask Claude:

  ```
  Create a CLAUDE.md for this project with one rule: every code change must include tests that prove it works.
  ```

- **c. Prove it sticks.** Ask for one more feature, and watch tests arrive without
  being asked for:

  ```
  Add support for renaming a category, then commit the change.
  ```

:::note[What belongs in CLAUDE.md]
Claude reads CLAUDE.md at the start of every session. Keep it for things Claude
can't work out by reading the code: your rules, your preferences, the commands that
must or must never run. Anything about how the code works, Claude can rediscover
itself.
:::

:::warning[About /init]
You may see the /init command suggested for generating a CLAUDE.md from your
codebase. Skip it. It fills the file with facts Claude can find out on its own, and
the noise buries the rules that actually change Claude's behaviour.
:::

Click **Check task** below when you're done.
