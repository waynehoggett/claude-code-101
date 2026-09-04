# Produces what a learner leaves behind after task 2: a deny rule for .env files in
# User settings and an auto mode rule of their own.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $ClaudeHome -Force | Out-Null

$path = "$ClaudeHome/settings.json"
$settings = if (Test-Path $path) { Get-Content $path -Raw | ConvertFrom-Json -AsHashtable } else { @{} }

$settings.permissions = @{ deny = @('Read(./.env*)') }

# The Auto mode tab of /permissions saves classifier rules under autoMode. The
# grader only requires the key to exist; the exact shape below is a stand-in until
# a live run captures the real one.
$settings.autoMode = @{
    rules = @(
        @{ type = 'softAllow'; text = 'Running the date command is always safe' }
    )
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $path
