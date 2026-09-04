# A HANDOFF.md that exists but hands nothing off. The grader must not accept it.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
[IO.File]::WriteAllText("$Workspace/ledger-$Language/HANDOFF.md", "# Handoff`n`nTODO`n")
