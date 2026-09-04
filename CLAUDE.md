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
- Step headings are numbered: `## 1 · Title`. Sub-steps are a bulleted list with a
  lettered bold lead-in (`- **a. Clone a sample project.**`), since the headings own
  the numbers. Letters are written by hand, so tips between sub-steps don't break
  the sequence.
- Indent everything belonging to a sub-step (labels, code fences) to the list's
  continuation level, so blocks render nested under the sub-step instead of
  snapping back to full width.
- The last line of every task is exactly: `Click **Check task** below when you're done.`
- No em-dashes anywhere, in prose or tests. Use commas or separate sentences.
- One command per fenced block, no `$` prompts, no interleaved output. Every block
  gets Insert and Copy buttons, so write commands exactly as they should be typed.
- Prompts meant for the Claude prompt must be a single line. Insert types the text
  verbatim and a newline would submit an unfinished prompt.
- Use `:::tip[Label]`, `:::note[Label]`, `:::warning[Label]` directives for asides.
  They render as collapsed accordions. Markdown only, raw HTML is stripped.
- Mark a term the checks assert on exactly with the inline directive `:graded[...]`,
  for example `:graded[deny]` or `:graded[User settings]`. It renders as an accent
  pill with a "This exact value is graded" tooltip. Use it only for the handful of
  terms where precision decides pass or fail (a setting, a scope, a required
  filename), never for emphasis, which stays bold. A value the learner types
  verbatim into the terminal stays in a fenced or inline code block, since those
  carry the Insert and Copy buttons; `:graded[...]` suits terms they act on in a
  menu, a settings screen, or a prompt to Claude.
- Call CLAUDE.md content "instructions" or "preferences", never "rules", and never
  say it is enforced or non-negotiable. The docs say Claude treats CLAUDE.md as
  context, not enforced configuration. "Rules" is reserved for the `.claude/rules/`
  feature, which is its official name.

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
  functions, ask git rather than parsing .git files. The grader image has pwsh, Pester,
  git, python3, Node 22 and npm (`safe.directory *` is set). If a real check needs
  something else, suggest it to Wayne for the platform repo instead of settling for the
  proxy.
- Checks that read session transcripts look under
  `$env:CW_CLAUDE_HOME/projects/<slug>/*.jsonl` (slug is the cwd with every
  non-alphanumeric character replaced by `-`). The markers in those files are internal
  to the pinned CLI version, so re-verify them whenever the platform bumps the CLI.

## Verifying graders

- Every task ships `solve.ps1` (`-Workspace`, `-ClaudeHome`, and `-Language py|js`
  plus `-SourceRepo` for tasks that touch the ledger repo). It produces, without
  Claude, exactly the files a passing learner leaves behind. It is the executable spec
  of the task: when a live run passes grading but looks different from solve.ps1, one
  of them is wrong.
- Optional `sabotage.ps1` breaks the solved state in a way the grader must catch (a
  failing test, for example). Optional `verify.psd1` lists `PassesBeforeStart` check
  names that legitimately pass before the learner starts the task.
- Run `./verify/Invoke-TaskVerification.ps1` before every push. It proves each grader
  fails on the starting state, passes on the solved state, notices sabotage, and throws
  only plain sentences. CI runs the same script on every push.

## Environment facts

- Learners work in `/workspace`, which persists across environment restarts. It
  starts empty; there is no starter repo.
- `ANTHROPIC_API_KEY` is already set in the pod. Never tell learners to paste a key.
- The Claude Code CLI version is pinned by the platform (currently 2.1.x). Flag any
  version-sensitive UI wording for the live smoke test.
