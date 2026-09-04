# An .mcp.json exists, but it points at a different server than the task asked for.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
$config = @{ mcpServers = @{ docs = @{ type = 'http'; url = 'https://example.com/mcp' } } }
[IO.File]::WriteAllText("$Workspace/ledger-$Language/.mcp.json", ($config | ConvertTo-Json -Depth 5) + "`n")
