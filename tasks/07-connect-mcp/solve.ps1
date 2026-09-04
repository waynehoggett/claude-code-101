# Produces what a learner leaves behind after task 7: a project-scoped .mcp.json
# pointing at Context7, in the shape `claude mcp add --scope project` writes.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
$repo = "$Workspace/ledger-$Language"

$config = @{
    mcpServers = @{
        context7 = @{ type = 'http'; url = 'https://mcp.context7.com/mcp' }
    }
}
[IO.File]::WriteAllText("$repo/.mcp.json", ($config | ConvertTo-Json -Depth 5) + "`n")
