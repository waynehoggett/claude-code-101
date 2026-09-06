# Write a skill

CLAUDE.md is for standing instructions, memory is for facts, and skills are for procedures: something
you want Claude to do the same way every time, on demand. You'll write one for this
project. Start Claude Code in your ledger project.

## 1 · Have Claude write the skill

- **a. Describe the procedure.** Ask for a project skill called :graded[changelog]:

  ```
  Create a project skill called changelog that reads the git history and updates CHANGELOG.md with one dated entry per commit in Keep a Changelog format.
  ```

- **b. Read what it wrote.** Run:

  ```
  !cat .claude/skills/changelog/SKILL.md
  ```

:::tip[Anatomy of a skill]
A skill is a folder under `.claude/skills/` holding a `SKILL.md`. The frontmatter
carries a `description`, which is how Claude decides on its own when the skill applies;
add `disable-model-invocation: true` if only you should trigger it. The body is the
procedure in plain words, and `$ARGUMENTS` stands in for anything you type after the
command. Skills you want in every project go in `~/.claude/skills/` instead.
:::

## 2 · Run it

Type:

```
/changelog
```

Then open :graded[CHANGELOG.md] and check it lists the delete and rename work from task 3.

:::note[Skills load when they're needed]
Only a skill's name and description sit in context until it runs, so twenty skills
cost less than one long CLAUDE.md. That is the difference between an instruction
Claude always carries and a procedure it fetches on demand.
:::

## 3 · Commit it for the team

Ask:

```
Commit the skill and the changelog.
```

:::note[Project versus personal]
Project skills travel with git, so everyone who clones the repo gets `/changelog`.
Personal skills in `~/.claude/skills/` follow you from project to project instead.
:::

## 4 · Let Claude pick the skill itself

The commit you just made isn't in the changelog yet. This time don't type the
command. Ask in plain words:

```
Bring the changelog up to date and commit it.
```

Watch Claude reach for the skill on its own, then check that :graded[CHANGELOG.md]
gained an entry for the commit from step 3.

:::tip[The description does the matching]
You never said "changelog skill", yet Claude used it. Before every reply, Claude
compares your request with the description of each skill it can see and loads the
ones that fit. That is why the description matters more than the name: write it as
the situations the skill is for, not a label. If Claude edited the file by hand
instead of using the skill, its description was too vague to match your request.
Ask Claude to rewrite the description to say when the skill applies, then try again.
:::

Click **Check task** below when you're done.
