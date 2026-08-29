# Teach Claude your rules

Claude Code reads a file called `CLAUDE.md` from your project directory at the start of
every session. It's where a project keeps its standing rules: coding conventions,
commands that must (or must never) be run, anything Claude should always know.

## 1 · Ask Claude to write its own rules

Back at the Claude prompt (`claude` if you exited), try:

```
Create a CLAUDE.md for this project with two rules: always write files into /workspace, and always ask before deleting anything.
```

Review the proposal and approve it.

## 2 · Prove the rules stick

Start a **fresh** Claude session so it re-reads the file:

```
/exit
```

```bash
claude
```

Then ask: `What are this project's rules?` Claude should answer from your
`CLAUDE.md` without being told where to look.

:::tip[Rules are code]
Treat `CLAUDE.md` like any other file in the repo: review changes to it, keep it
short, and delete rules that stop being true. A stale rule is worse than no rule.
:::

That's Claude Code 101 done. Click **Check task** below when you're done.
