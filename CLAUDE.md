# Claude Code 101 content repo

Content for the Claude Community Workshop platform. Everything a learner sees comes
from this repo: `workshop.yaml` lists the tasks, each `tasks/<nn-slug>/` holds
`instructions.md` (learner-facing markdown) and `test.tests.ps1` (Pester, the single
source of grading truth). The full platform contract lives in the platform repo at
`claude-code-workshop/docs/content-repo-spec.md`.

## Instructions style

- Steps state the goal, not the UI mechanics. Write "Select **Sonnet** as the model."
  and "Set the effort to **Medium**.", not "Use the up and down arrow keys to
  highlight Sonnet."
- Keep step bodies to the action itself, in one or two short sentences. Anything
  explanatory (what a feature is, why it matters, what the options mean) goes in a
  collapsed `:::tip` or `:::note` after the step, never inline in the step.
- Step headings are numbered: `## 1 · Title`. Sub-steps within a step are a numbered
  list with a bold lead-in sentence.
- The last line of every task is exactly: `Click **Check task** below when you're done.`
- No em-dashes anywhere, in prose or tests. Use commas or separate sentences.
- One command per fenced block, no `$` prompts, no interleaved output. Every block
  gets Insert and Copy buttons, so write commands exactly as they should be typed.
- Prompts meant for the Claude prompt must be a single line. Insert types the text
  verbatim and a newline would submit an unfinished prompt.
- Use `:::tip[Label]`, `:::note[Label]`, `:::warning[Label]` directives for asides.
  They render as collapsed accordions. Markdown only, raw HTML is stripped.

## Grading style

- `It` names are shown verbatim as the learner's checklist. Write them as polished
  sentences ("The active model is Sonnet"), never test jargon.
- Failure messages are shown verbatim to learners, and Pester wraps `Should`
  assertions in jargon ("Expected a value... but got $null or empty"). So do not use
  `Should` for learner-facing checks: test the condition with plain PowerShell and
  `throw` a friendly sentence when it fails. Shape: what isn't in place yet, then the
  action to take ("No model has been picked yet. Inside Claude Code, run /model and
  select Sonnet."). A test that throws nothing passes.
- Read the workspace via `$env:CW_WORKSPACE` and the learner's Claude config via
  `$env:CW_CLAUDE_HOME` (read-only mount of their config dir).
- Grading has a 75 second budget per check. No long builds or network waits in tests.
- Prefer real checks over proxies: run the learner's tests rather than counting test
  functions, ask git rather than parsing .git files. If the grader image lacks a tool
  a real check needs, request it from the platform repo instead of settling for the
  proxy.

## Environment facts

- Learners work in `/workspace`, which persists across environment restarts. It
  starts empty; there is no starter repo.
- `ANTHROPIC_API_KEY` is already set in the pod. Never tell learners to paste a key.
- The Claude Code CLI version is pinned by the platform (currently 2.1.x). Flag any
  version-sensitive UI wording for the live smoke test.
