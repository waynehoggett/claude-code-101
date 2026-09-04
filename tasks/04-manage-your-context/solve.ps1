# Produces what a learner leaves behind after task 4: a session transcript with a
# compact and a fork in it, and a HANDOFF.md in the ledger project. The transcript
# lines copy the shapes Claude Code 2.1.x writes.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
$repo = "$Workspace/ledger-$Language"
$cwd = "/workspace/ledger-$Language"
$sessionId = [guid]::NewGuid().ToString()
$projectDir = "$ClaudeHome/projects/-workspace-ledger-$Language"
New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

$stamp = (Get-Date).ToUniversalTime().ToString('o')
$lines = @(
    @{
        parentUuid = $null; isSidechain = $false; type = 'user'; isCompactSummary = $true
        isVisibleInTranscriptOnly = $true
        message = @{ role = 'user'; content = 'This session is being continued from a previous conversation that ran out of context.' }
        uuid = [guid]::NewGuid().ToString(); timestamp = $stamp; sessionId = $sessionId
        cwd = $cwd; version = '2.1.251'; gitBranch = 'main'
    },
    @{
        parentUuid = [guid]::NewGuid().ToString(); isSidechain = $false; type = 'system'; subtype = 'local_command'
        content = "<command-name>/fork</command-name>`n<command-message>fork</command-message>`n<command-args></command-args>"
        level = 'info'; timestamp = $stamp; uuid = [guid]::NewGuid().ToString(); isMeta = $false
        sessionId = $sessionId; cwd = $cwd; version = '2.1.251'; gitBranch = 'main'
    }
) | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 5 }
[IO.File]::WriteAllText("$projectDir/$sessionId.jsonl", ($lines -join "`n") + "`n")

$handoff = @"
# Handoff

## What we built
- Deleting a transaction by id.
- Renaming a category across every transaction that uses it.

## How it's tested
Both features have unit tests next to the existing store tests. Run the full suite from
the repo root; every code change must include tests, as CLAUDE.md requires.

## What a new session should do next
Read this file, run the test suite to confirm it's green, then pick up the next feature.
"@
[IO.File]::WriteAllText("$repo/HANDOFF.md", $handoff.Replace("`r`n", "`n"))
