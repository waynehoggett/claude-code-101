# Memory and where instructions live

In the last two tasks you put one instruction in a project CLAUDE.md. Instructions can
live at several levels, from your whole machine down to a single folder, and Claude
also keeps notes of its own. Start Claude Code in your ledger project.

## 1 · Make verification a habit, everywhere

- **a. See what Claude loads.** Run:

  ```
  /memory
  ```

- **b. Add an instruction to your :graded[user-level CLAUDE.md].** Ask:

  ```
  Create my user-level CLAUDE.md with one instruction: after changing any code, run the project's test suite and show me the result before reporting back.
  ```

- **c. Prove it.** Ask for a small change and watch the suite run without being asked:

  ```
  Reject descriptions longer than 80 characters.
  ```

:::tip[The hierarchy]
Claude reads every one of these it finds, top to bottom:

- **Managed**: set by your organisation, applies to everyone on the machine.
- **User** (`~/.claude/CLAUDE.md`): your habits, every project. A verification habit
  belongs here.
- **Project** (`CLAUDE.md` in the repo): the team's instructions, shared through git.
- **Local** (`CLAUDE.local.md`): your own tweaks for one project, kept out of git.
- **Subfolder** (`CLAUDE.md` deeper in the tree): loaded only when Claude works in
  that folder.
- **Rules** (`.claude/rules/*.md`): the same idea, keyed to file patterns instead of
  folders.

Any of them can pull in another file with `@path/to/file`. Whatever the level, these
are preferences Claude follows, not rules it can't break, so keep them short and
specific.
:::

## 2 · Add an instruction that only applies to the tests

Ask for a CLAUDE.md in the :graded[tests folder]:

```
Add a CLAUDE.md inside the folder that holds the tests with one instruction: every test sets up its own data and never depends on another test.
```

:::tip[Instructions that load on demand]
A subfolder CLAUDE.md costs nothing until Claude reads or edits something in that
folder, so the root file stays short and the details live where they apply. For
instructions that follow a file pattern rather than a folder, put a markdown file in
`.claude/rules/` with a `paths:` list in its frontmatter.
:::

## 3 · Let Claude remember something

Ask:

```
Remember that I want one feature per commit, with a one-line commit message.
```

Then run `/memory` again and look for the memory directory in the list.

:::tip[Instructions versus memory]
CLAUDE.md is what you decide; memory is what Claude learns. Memory is kept per project
in your Claude config directory, it's plain markdown you can read and edit, and Claude
saves to it on its own when it notices something worth keeping. If it forgets something
you told it, tell it to remember, as you just did.
:::

:::warning[About /init]
The `/memory` menu offers `/init` to generate a CLAUDE.md. Skip it, for the reason from
task 3: it fills the file with facts Claude can find out on its own, and the noise
buries the instructions that actually change Claude's behaviour.
:::

Click **Check task** below when you're done.
