# Connect an MCP server

MCP servers give Claude tools and data it doesn't have on its own. Context7 serves
current documentation for thousands of libraries, including the Python and Node
standard libraries, with nothing to sign up for. You'll connect it to your ledger
project and use it.

## 1 · Add the server to the project

- **a. Register it.** From your terminal, in the ledger project directory:

  ```bash
  claude mcp add --transport http --scope project context7 https://mcp.context7.com/mcp
  ```

- **b. Approve it.** Start Claude Code and choose to use the project's MCP server
  when asked.

:::tip[Scopes]
- **Local**: only you, only this project. The default.
- **User**: only you, every project.
- **Project**: written to `.mcp.json` in the repo and shared through git. Because
  a cloned repo could point Claude at anything, Claude Code asks you to approve
  project servers the first time.
:::

## 2 · Check it's connected

Run:

```
/mcp
```

## 3 · Use it

Ask:

```
Use Context7 to check the current docs for the test framework this project uses, then add one test that uses a feature we haven't used yet.
```

:::tip[Tools cost context]
Every connected server adds its tool descriptions to your context. Run `/context`
and you'll see them. Connect what you use, and prefer a command-line tool or a skill
when one does the job.
:::

Click **Check task** below when you're done.
