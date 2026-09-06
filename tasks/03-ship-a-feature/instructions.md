# Ship a feature

Time to use Claude Code the way you will at work: explore a codebase, plan a change,
build it, and commit. You'll do it on a small sample project.

## 1 · Clone the repository

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

:::tip[Bash mode]
You don't need to leave Claude Code to run a command. Prefix it with `!` at the
Claude prompt, like `!npm test`, and it runs straight in your shell with the output
visible to both you and Claude.
:::

- **b. Start Claude Code in the project.** Change into the cloned directory and
  start Claude Code.

## 2 · Plan the feature

Switch to **Plan mode**, then ask:

```
Add support for deleting a transaction to this project.
```

:::tip[Why plan first?]
In Plan mode Claude can read the codebase and run read-only commands, but it can't
edit anything. It explores, works out an approach, and presents it as a plan for you
to approve before a single file changes.
:::

:::tip[Actually read the plan]
The plan is the cheapest place to catch a wrong turn, but only if you read it rather
than skim to the approve button. Check which files it will touch, whether it adds
tests, whether it changes anything you didn't ask for, and whether it pulls in a new
dependency. If any of that looks off, reply with what you want changed and Claude
will rework the plan before it writes a line of code.
:::

## 3 · Build the feature

- **a. Build it.** Review the plan Claude presents, then approve it and watch the
  work happen.

- **b. Commit.** Ask Claude:

  ```
  Commit the change with a clear message.
  ```

## 4 · Make tests the default

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

- **b. Give Claude a standing instruction.** Ask Claude:

  ```
  Create a CLAUDE.md for this project with one instruction: every code change must include tests that prove it works.
  ```

- **c. Prove it sticks.** Ask for one more feature, and watch tests arrive without
  being asked for:

  ```
  Add support for renaming a category, then commit the change.
  ```

:::note[What belongs in CLAUDE.md]
Claude reads CLAUDE.md at the start of every session. Keep it for things Claude
can't work out by reading the code: your preferences, the way you want work done,
the commands to run. Anything about how the code works, Claude can rediscover
itself. Treat what you write there as instructions Claude follows, not rules it
can't break: Claude reads them as context and does its best with them, and short,
specific instructions are followed more reliably than long or vague ones.
:::

:::warning[About /init]
You may see the /init command suggested for generating a CLAUDE.md from your
codebase. Skip it. It fills the file with facts Claude can find out on its own, and
the noise buries the instructions that actually change Claude's behaviour.
:::

Click **Check task** below when you're done.
