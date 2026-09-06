# Notes for an advanced Claude Code workshop

Topics the Anthropic Academy "Claude Code 101" course covers that this workshop
deliberately leaves out. Each one needs the learner to have finished Claude Code 101,
since they all build on the ledger project, the CLAUDE.md from task 3, and the
changelog skill from task 6. Written 2026-09-06 from a comparison of the two courses.

## Code review in a clean context

Claude Code 101 task 3 has the learner read the diff with `/diff` before committing.
The academy's code review lesson goes one step further: a second reviewer that has
none of the session's history.

- **The exercise.** After building a feature, run `/code-review` and wait for the
  findings to arrive in the conversation. Then sort each finding into fix now, ask why,
  or leave it. For an "ask why", quote the finding back and ask Claude to check again.
  For a fix, ask for evidence with it ("then run the tests and show me the output").
- **Effort levels.** `/code-review low` reports only the findings it's most confident
  about, `/code-review high` casts a wider net. The level is remembered until you type
  a different one.
- **Plain words work too.** "Review the changes you just made. Report problems; don't
  fix anything yet." starts the same review. If Claude answers inline instead, run the
  command.
- **A seeded bug makes it real.** Ask Claude to add a feature with a deliberately
  vague prompt, or ship a sabotaged commit that skips a test, so the review has
  something to find.
- **Grading ideas.** A `<command-name>/code-review` local_command line in the
  transcript. The project must be a git repository, which the ledger repo is.
- **Watch out.** The review runs in the background for anywhere from seconds to a few
  minutes and costs like any other task, so it needs its own time budget. Confirm the
  command exists in the pinned CLI version before the live run.

## Subagents

The academy gives subagents their own lesson and a follow-on course. Claude Code 101
teaches `/fork` for side questions instead; the two solve the same problem, keeping
the main context clean, by different means.

- **The exercise, part one.** Run `/context`, then ask a question that needs a lot of
  reading and tell Claude to use a subagent for it: "Use a subagent to find every place
  a category name is validated and report back in five lines." Run `/context` again and
  compare with the same question asked directly. The subagent's reading never lands in
  the main context, only its answer does.
- **The exercise, part two.** Run `/agents`, choose to create a new agent, and walk
  through scope, purpose, tools, and colour. A good candidate for the ledger project is
  a test reviewer that only reads and reports. Then ask a question that matches its
  description and watch Claude delegate to it.
- **Further customisation worth a tip.** Persistent memory for a subagent that is used
  on the same project repeatedly, and preloading skills with the `skills` key, noting
  that the whole skill loads into the subagent's context.
- **Grading ideas.** An assistant tool_use named Agent in the transcript for part one.
  A markdown file with YAML frontmatter under `.claude/agents/` for part two, committed
  if the scope was project.
- **Watch out.** Subagent edits are not restored by `/rewind`; that is a good moment to
  reinforce git as the real safety net.

## Hooks

Nothing in Claude Code 101 is deterministic. Everything the learner writes, CLAUDE.md,
memory, and skills, is context Claude does its best with. Hooks are the one mechanism
that always runs.

- **The narrative.** Task 5 asks Claude, through a user-level CLAUDE.md, to run the
  test suite after every change. It usually does. A PostToolUse hook makes it happen
  every time, no exceptions. Open with that contrast.
- **The exercise, part one.** Add a PostToolUse hook matched to `Edit|Write` that runs
  the project's test suite and prints the result. Make a change and watch the suite run
  without Claude deciding to run it. Configure it through `/hooks` or by editing
  `.claude/settings.json` directly.
- **The exercise, part two.** Add a PreToolUse hook on Bash that reads the tool input
  from stdin and exits with code 2 when the command contains `git push`, with a message
  on stderr. Ask Claude to push and watch the block, then read the reason Claude gets
  back. Exit code 0 proceeds, exit code 2 blocks and feeds stderr to Claude as feedback,
  any other code shows a non-blocking error.
- **Sharing.** Hooks in `.claude/settings.json` travel with the repo, so the team gets
  them. Use `CLAUDE_PROJECT_DIR` in commands that call scripts stored in the project.
- **Grading ideas.** Parse `.claude/settings.json` in the ledger repo for a `hooks`
  block with a PostToolUse entry whose command mentions the test runner, and a
  PreToolUse entry. A sabotage script can delete the hooks block. For a real check,
  run the hook command itself with a sample stdin payload and assert the exit code.
- **Watch out.** Hook events and the JSON shape on stdin are version-sensitive; verify
  against the pinned CLI's hooks reference before writing the checks.

## Ordering

Code review first, since it extends task 3 directly and needs nothing new on disk.
Then hooks, which pay off the CLAUDE.md work from task 5. Subagents last, because
the context argument lands best after the learner has felt a full context window.
