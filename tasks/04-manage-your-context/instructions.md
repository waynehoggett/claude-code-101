# Manage your context

Everything Claude knows about your session lives in its context window: the
conversation so far, the files it has read, the output of every command. It's finite,
and a full or cluttered context makes Claude forget instructions and drift. Start Claude
Code in your ledger project and try the tools that keep it in shape.

## 1 · See what's in your context

Run:

```
/context
```

:::tip[Reading the picture]
Each block is something taking up room: the system prompt, the tool definitions,
your CLAUDE.md files, and the messages so far. The free space is what's left for new
work. When Claude seems to be getting worse at following you, this is the first thing
to run.
:::

## 2 · Fill it, then compact it

- **a. Give Claude something to read.** Ask:

  ```
  Walk me through how a transaction gets from the front end to the summary, file by file.
  ```

- **b. Give it something to write.** Ask:

  ```
  Review every file in this project. For each function, quote it in full and say what you would change and why.
  ```

- **c. See what that cost.** Run `/context` again and compare the **Messages** line
  with the first picture. Watch the token count, not the percentage.

- **d. Compact with a focus.** Run:

  ```
  /compact focus on the features we built and the testing instruction
  ```

- **e. Look one more time.** Run `/context` and see how much came back.

:::note[Small project, small numbers]
This project is a few hundred lines, so even a full review only moves the meter a
few points. A real codebase, a long test log, or an hour of debugging fills the same
window in a morning. The mechanics are identical, only the scale changes.
:::

:::tip[Lost in the middle]
Models pay the most attention to the start and the end of their context and the least
to the middle, so a long conversation degrades before it's full: an instruction from an
hour ago quietly stops being followed. Compact when the work changes shape, not when
the meter turns red. Compaction is lossy, a summary replaces the history, so always say
what to keep.
:::

:::note[What survives a compact]
Your CLAUDE.md files are read again, memory stays on disk, and files you touched
recently stay in view. Details of the earlier conversation are gone unless the focus
named them.
:::

## 3 · Fork for a side question

- **a. Fork with a question.** Hand a side question to a copy of your session and
  keep your own for the main work:

  ```
  /fork Which category names appear in the tests, and are any of them inconsistent?
  ```

  Claude Code confirms with one line naming the fork's row in the agent view.

- **b. Peek at the fork.** Press **←** on an empty prompt to open the agent view,
  move to the fork's row with **↑** and **↓**, and press **Space** to read its latest
  output. You can type a reply there and press **Enter** to send it without leaving
  your own session.

- **c. Switch into it.** With the fork's row selected, press **→** to attach. The
  fork becomes your interactive session and your original moves to the background.

- **d. Come back.** Press **←** on an empty prompt to return to the agent view,
  select your original session's row, and press **→** to attach to it again.

:::tip[If the panel doesn't appear]
Run `/tasks` to list the session's background work. Press **Enter** on a row to read
its latest message, or **a** to attach to it.
:::

:::tip[Fork or branch?]
A fork copies everything in your context into a separate background session and
leaves you where you are, so the side question never clutters the main thread.
`/branch` makes the same copy but switches you into it, for when you want to walk
the side path yourself. Either way the original is untouched.
:::

## 4 · Write a handoff and start clean

- **a. Write it down.** Ask for a :graded[HANDOFF.md]:

  ```
  Write HANDOFF.md for this project: what we built, how it's tested, and what a new session should do next.
  ```

- **b. Start fresh.** Run:

  ```
  /clear
  ```

- **c. Pick it back up.** Ask:

  ```
  Read HANDOFF.md and tell me where this project is up to.
  ```

:::tip[Compact, fork, or hand off?]
Compact to keep going on the same job with less clutter. Fork to try a side path
without disturbing the main thread. Hand off when the job is done or the session has
gone bad: write it down, clear, start fresh. A handoff document outlives the session,
the machine, and the teammate who picks it up.
:::

:::note[Undo a bad step]
Press **Esc** twice, or run `/rewind`, to roll back the conversation, the files, or
both to an earlier point.
:::

Click **Check task** below when you're done.
