#Requires -Version 7
<#
.SYNOPSIS
    Proves every task's grader works in both directions without Claude.

.DESCRIPTION
    For each task (in workshop.yaml order) and each sample-repo language:
      1. Build the state a learner has when they START the task, by running the
         solve.ps1 of every earlier task into a fresh workspace and Claude home.
      2. Grade. Every check must fail (except names listed in the task's
         verify.psd1 under PassesBeforeStart), and every failure message must be a
         plain learner-facing sentence.
      3. Run the task's own solve.ps1, then grade again. Every check must pass.
      4. If the task ships sabotage.ps1, run it against the solved state and grade
         once more. At least one check must fail, which proves the grader notices
         broken work rather than just the presence of files.
    Exit code is 1 if anything above didn't hold.

.EXAMPLE
    ./verify/Invoke-TaskVerification.ps1
    ./verify/Invoke-TaskVerification.ps1 -Task 03-ship-a-feature -Language py -KeepTemp
#>
[CmdletBinding()]
param(
    [string[]]$Task,
    [ValidateSet('py', 'js')]
    [string[]]$Language = @('py', 'js'),
    [switch]$KeepTemp
)

$ErrorActionPreference = 'Stop'
Import-Module Pester -MinimumVersion 5.5

$root = Split-Path $PSScriptRoot -Parent
$allTasks = @(Get-Content "$root/workshop.yaml" |
    Select-String -Pattern '^\s+-\s+(\S+)\s*$' |
    ForEach-Object { $_.Matches[0].Groups[1].Value })
if ($allTasks.Count -eq 0) { throw "No tasks found in workshop.yaml." }
$selected = if ($Task) { $allTasks | Where-Object { $Task -contains $_ } } else { $allTasks }

$runRoot = Join-Path ([IO.Path]::GetTempPath()) "cw-verify/$([guid]::NewGuid().ToString('N').Substring(0, 8))"
New-Item -ItemType Directory -Path $runRoot -Force | Out-Null

# The sample repos are cloned once per run; solve scripts clone from this cache so a
# full run doesn't hit GitHub once per task.
$repoCache = @{}
foreach ($lang in $Language) {
    $cache = Join-Path $runRoot "cache/ledger-$lang"
    git clone --quiet "https://github.com/waynehoggett/ledger-$lang" $cache
    if ($LASTEXITCODE -ne 0) { throw "Could not clone ledger-$lang." }
    $repoCache[$lang] = $cache
}

function Invoke-Grade([string]$spec, [string]$workspace, [string]$claudeHome) {
    $env:CW_WORKSPACE = $workspace
    $env:CW_CLAUDE_HOME = $claudeHome
    $cfg = New-PesterConfiguration
    $cfg.Run.Path = $spec
    $cfg.Run.PassThru = $true
    $cfg.Output.Verbosity = 'None'
    $result = Invoke-Pester -Configuration $cfg

    $blockError = $result.Containers |
        ForEach-Object { $_.Blocks } |
        ForEach-Object { $_.ErrorRecord } |
        Select-Object -First 1

    foreach ($t in $result.Tests) {
        $message = ($t.ErrorRecord | ForEach-Object { $_.Exception.Message }) -join ' '
        if ($t.Result -notin 'Passed', 'Failed' -and $blockError) {
            $message = "Setup failed: " + $blockError.Exception.Message
        }
        [pscustomobject]@{ Name = $t.Name; Passed = $t.Passed; Message = $message }
    }
}

function Invoke-Solve([string]$taskDir, [string]$workspace, [string]$claudeHome, [string]$lang) {
    $solve = "$taskDir/solve.ps1"
    if (-not (Test-Path $solve)) { throw "$taskDir has no solve.ps1." }
    $params = @{ Workspace = $workspace; ClaudeHome = $claudeHome }
    $declared = (Get-Command $solve).Parameters
    if ($declared.ContainsKey('Language')) { $params.Language = $lang }
    if ($declared.ContainsKey('SourceRepo')) { $params.SourceRepo = $repoCache[$lang] }
    & $solve @params
}

function Test-MessageIsFriendly([string]$message) {
    if ([string]::IsNullOrWhiteSpace($message)) { return "empty failure message" }
    if ($message -match 'Should|Expected|\$null|Exception|—') { return "jargon in message: $message" }
    if ($message -notmatch '\.$') { return "message doesn't end with a full stop: $message" }
    return $null
}

$problems = [System.Collections.Generic.List[string]]::new()

foreach ($lang in $Language) {
    foreach ($taskName in $selected) {
        $taskDir = "$root/tasks/$taskName"
        $index = $allTasks.IndexOf($taskName)

        # Tasks that don't take a language are identical across languages, so run once.
        $solveParams = (Get-Command "$taskDir/solve.ps1").Parameters
        if (-not $solveParams.ContainsKey('Language') -and $lang -ne $Language[0]) { continue }

        $label = if ($solveParams.ContainsKey('Language')) { "$taskName ($lang)" } else { $taskName }
        Write-Host "`n== $label ==" -ForegroundColor Cyan

        $ws = Join-Path $runRoot "$taskName-$lang/workspace"
        $claudeHome = Join-Path $runRoot "$taskName-$lang/claude-home"
        New-Item -ItemType Directory -Path $ws, $claudeHome -Force | Out-Null

        foreach ($earlier in $allTasks[0..$index] | Select-Object -SkipLast 1) {
            Invoke-Solve "$root/tasks/$earlier" $ws $claudeHome $lang
        }

        $expectedEarly = @()
        if (Test-Path "$taskDir/verify.psd1") {
            $expectedEarly = @((Import-PowerShellDataFile "$taskDir/verify.psd1").PassesBeforeStart)
        }

        $spec = "$taskDir/test.tests.ps1"
        $fresh = @(Invoke-Grade $spec $ws $claudeHome)
        if ($fresh.Count -eq 0) { $problems.Add("${label}: grader ran no checks at all") }

        Invoke-Solve $taskDir $ws $claudeHome $lang
        $solved = @(Invoke-Grade $spec $ws $claudeHome)

        $sabotaged = $null
        if (Test-Path "$taskDir/sabotage.ps1") {
            $params = @{ Workspace = $ws; ClaudeHome = $claudeHome }
            if ((Get-Command "$taskDir/sabotage.ps1").Parameters.ContainsKey('Language')) { $params.Language = $lang }
            & "$taskDir/sabotage.ps1" @params
            $sabotaged = @(Invoke-Grade $spec $ws $claudeHome)
        }

        $rows = foreach ($check in $fresh) {
            $after = $solved | Where-Object Name -eq $check.Name
            $broken = if ($sabotaged) { $sabotaged | Where-Object Name -eq $check.Name } else { $null }

            $freshOk = if ($expectedEarly -contains $check.Name) { $check.Passed } else { -not $check.Passed }
            if (-not $freshOk) {
                $problems.Add("${label}: '$($check.Name)' $(if ($check.Passed) { 'passed' } else { 'failed' }) before the learner did anything")
            }
            if (-not $check.Passed) {
                $lint = Test-MessageIsFriendly $check.Message
                if ($lint) { $problems.Add("${label}: '$($check.Name)': $lint") }
            }
            if (-not $after.Passed) {
                $problems.Add("${label}: '$($check.Name)' still fails after solve.ps1: $($after.Message)")
            }
            if ($check.Name -match '—') { $problems.Add("${label}: check name contains an em-dash: $($check.Name)") }

            [pscustomobject]@{
                Check     = $check.Name
                Fresh     = if ($check.Passed) { 'pass' } else { 'fail' }
                Solved    = if ($after.Passed) { 'pass' } else { 'FAIL' }
                Sabotaged = if ($null -eq $broken) { '' } elseif ($broken.Passed) { 'pass' } else { 'fail' }
                Message   = $check.Message
            }
        }
        $rows | Format-Table -AutoSize -Wrap | Out-String -Width 200 | Write-Host

        if ($sabotaged -and -not ($sabotaged | Where-Object { -not $_.Passed })) {
            $problems.Add("${label}: sabotage.ps1 broke the work but every check still passed")
        }
    }
}

if (-not $KeepTemp) { Remove-Item $runRoot -Recurse -Force -ErrorAction SilentlyContinue }
else { Write-Host "Temp state kept at $runRoot" }

if ($problems.Count -gt 0) {
    Write-Host "`nProblems:" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "`nEvery grader fails fresh and passes solved." -ForegroundColor Green
exit 0
