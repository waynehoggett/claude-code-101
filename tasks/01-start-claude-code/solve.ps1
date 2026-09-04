# Produces what a learner leaves behind after task 1: Claude Code started, the
# workspace trusted, Sonnet selected, effort set to Medium.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $ClaudeHome -Force | Out-Null

$state = @{
    hasCompletedOnboarding = $true
    projects = @{
        $Workspace = @{ hasTrustDialogAccepted = $true }
    }
}
$state | ConvertTo-Json -Depth 10 | Set-Content "$ClaudeHome/.claude.json"

$settings = @{
    model = 'sonnet'
    modelSettings = @{
        'claude-sonnet-5' = @{ effortLevel = 'medium' }
    }
}
$settings | ConvertTo-Json -Depth 10 | Set-Content "$ClaudeHome/settings.json"
