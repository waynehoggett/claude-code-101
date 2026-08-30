# Start and configure Claude Code

The terminal on the right is a real Linux environment that belongs to you for this
workshop. Everything in `/workspace` is saved: you can stop the environment, come back
tomorrow, and pick up where you left off. Let's get Claude Code running in it.

## 1 · Start Claude Code

Your terminal starts in `/workspace`, your home for the whole workshop. Start Claude
Code there:

```bash
claude
```

The first run walks you through a couple of setup questions:

- **a. Choose a theme.** Pick whichever matches this page (there's a light/dark
  toggle in the top bar).
- **b. Choose how to sign in.** This environment already has your API key
  configured, so select the option to use the `ANTHROPIC_API_KEY` when asked.

## 2 · Trust the folder

Claude Code asks whether you trust the files in this folder before it will work here.
Your workspace is yours, so choose **Yes, proceed**.

:::note[Why Claude Code asks this]
Claude reads project files to understand your code. The trust prompt is your chance to
stop it from reading a folder you didn't mean to open, for example a repo you just
downloaded but haven't reviewed.
:::

## 3 · Pick your model

Select **Sonnet** as the model. The model decides how capable Claude is.

:::tip[The /model command]
Run `/model` at the Claude prompt to open the model picker any time.
:::

## 4 · Set the effort

Set the effort to **Medium**, then press **Enter** to confirm. The effort decides how
long Claude thinks before answering.

:::tip[The /effort command]
Run `/effort` at the Claude prompt to change the effort without opening the model
picker.
:::

Click **Check task** below when you're done.
