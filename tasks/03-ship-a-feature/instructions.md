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

- **b. Read the change.** Claude's summary is true, but it isn't the whole change.
  Open the diff and read every file it touched before you keep any of it:

  ```
  /diff
  ```

:::tip[What to look for]
Three things deserve a second look every time:

- **Changes you didn't ask for.** A config value edited while Claude was in the
  file, or a helper rewritten that you never mentioned.
- **Tests that got weaker.** Any test skipped, deleted, or loosened until it passed.
- **New packages and hard-coded values.** A dependency added for one function, or a
  URL or key written straight into the code.

Use **↑** and **↓** to move between files and **Enter** to open one. If the whole
change is wrong, press **Esc** twice to open the rewind menu and restore the code
and the conversation to before the prompt that produced it.
:::

- **c. Commit.** Ask Claude:

  ```
  Commit the change with a clear message.
  ```

## 4 · Teach Claude the project's conventions

- **a. Check Claude's work.** Run the suite, then look at the code Claude wrote.
  Did it add tests? Does the new code fail the way the rest of the store does, with
  a `Result` in Python or a `ValidationError` in JavaScript, or did it invent its
  own way?

  Python:

  ```bash
  python -m unittest
  ```

  JavaScript:

  ```bash
  npm test
  ```

- **b. Add a CLAUDE.md.** Copy the block for your language, then ask Claude to
  create `CLAUDE.md` in the project root with that content, pasting it into the
  prompt.

  Python (`ledger-py`):

  ```markdown
  # Project

  A tiny personal ledger: core library in src/ledger/, argparse CLI in src/cli/,
  unittest tests in tests/. Standard library only.

  # Commands

  - Run tests: `python -m unittest`
  - Try the CLI: `PYTHONPATH=src python -m cli.main --help`

  # Code style

  - Operations that can fail return a Result (src/ledger/result.py); never raise for expected failures
  - Every code change includes tests that prove it works
  - Standard library only, no new dependencies
  ```

  JavaScript (`ledger-js`):

  ```markdown
  # Project

  A tiny personal ledger with an HTTP front end: core library in src/ledger/,
  node:http API in src/api/, node:test tests in test/. No dependencies.

  # Commands

  - Run tests: `npm test`
  - Start the API: `npm start`

  # Code style

  - Named exports only, no default exports
  - Validation lives in the store and throws ValidationError; handlers turn it into a 400
  - Every code change includes tests that prove it works
  - No dependencies
  ```

- **c. Prove it sticks.** Ask for one more feature, then check the new code follows
  the conventions and arrives with tests, without you asking for either:

  ```
  Add support for renaming a category, then commit the change.
  ```

:::tip[Why these lines]
Each line is something Claude can't safely infer: the exact test command, a
convention the codebase follows that a newcomer might break, a dependency policy.
Compare it with the facts left out, like what a store is or how the CLI is wired,
which Claude reads from the code in seconds anyway.
:::

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
