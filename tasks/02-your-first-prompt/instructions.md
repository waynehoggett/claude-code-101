# Your first prompt

Time to meet Claude. Claude Code is a coding agent that lives in your terminal — you
describe what you want, it proposes actions, and nothing happens until you approve.

## 1 · Start Claude Code

```bash
claude
```

The first run asks you to pick a theme (choose whichever matches this page — there's a
toggle in the top bar) and to sign in with your API key.

## 2 · Ask for a file

At the Claude prompt, type a request like:

```
Create a file called greeting.md containing a haiku about Kubernetes.
```

Claude will show you the file it wants to write and ask permission. Read what it
proposes — approving thoughtfully is the core skill of this workshop — then accept.

:::tip[If Claude's answer isn't a haiku]
Talk to it! Try: `That's not 5-7-5 — fix the syllables.` Iterating in conversation
beats retyping prompts.
:::

## 3 · Check the result

Exit Claude (Ctrl+C twice or `/exit`) or open a second terminal tab with **＋**, then:

```bash
cat greeting.md
```

Press **Check task** when the haiku is in place.
