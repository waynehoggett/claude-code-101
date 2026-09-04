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

- **b. Compact with a focus.** Run:

  ```
  /compact focus on the features we built and the testing instruction
  ```

- **c. Look again.** Run `/context` and compare it with the first picture.

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

Hand a side question to a fork and keep your own session for the main work:

```
/fork Which category names appear in the tests, and are any of them inconsistent?
```

When the fork's row in the agent view below the prompt shows it has finished, select
it and press **Space** to read its answer. If you don't see the panel, run `/tasks`.

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
