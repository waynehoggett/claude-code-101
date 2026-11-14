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
      4. For each sabotage script the task ships (sabotage.ps1, sabotage-*.ps1), run
         it against a freshly solved state and grade once more. At least one check
         must fail, which proves the grader notices broken work rather than just the
         presence of files. verify.psd1 can also pin, under SabotageMessages, the
         message a named check must fail with for a given script, so a learner who
         goes wrong in that way is told how to recover.
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

# The platform gives a grade 75 seconds and pods are slower than CI, so a grade that
# needs more than this here is too close to the limit for a learner.
$GradeBudgetSeconds = 30

function Invoke-Grade([string]$spec, [string]$workspace, [string]$claudeHome, [string]$what) {
    $env:CW_WORKSPACE = $workspace
    $env:CW_CLAUDE_HOME = $claudeHome
    $cfg = New-PesterConfiguration
    $cfg.Run.Path = $spec
    $cfg.Run.PassThru = $true
    $cfg.Output.Verbosity = 'None'
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $result = Invoke-Pester -Configuration $cfg
    $seconds = [int]$timer.Elapsed.TotalSeconds
    if ($seconds -gt $GradeBudgetSeconds) {
        $problems.Add("${what}: grading took $seconds seconds, over the $GradeBudgetSeconds second budget")
    }

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
        $expectedMessages = @{}
        if (Test-Path "$taskDir/verify.psd1") {
            $verifyData = Import-PowerShellDataFile "$taskDir/verify.psd1"
            $expectedEarly = @($verifyData.PassesBeforeStart | Where-Object { $_ })
            if ($verifyData.SabotageMessages) { $expectedMessages = $verifyData.SabotageMessages }
        }

        $spec = "$taskDir/test.tests.ps1"
        $fresh = @(Invoke-Grade $spec $ws $claudeHome "$label fresh")
        if ($fresh.Count -eq 0) { $problems.Add("${label}: grader ran no checks at all") }

        Invoke-Solve $taskDir $ws $claudeHome $lang
        $solved = @(Invoke-Grade $spec $ws $claudeHome "$label solved")

        # Each sabotage script gets its own freshly solved state, so scripts never
        # see each other's damage. sabotage.ps1 first, then sabotage-*.ps1 by name.
        $sabotageRuns = [ordered]@{}
        $scripts = @(Get-ChildItem $taskDir -Filter 'sabotage*.ps1' | Sort-Object { $_.Name -ne 'sabotage.ps1' }, Name)
        foreach ($script in $scripts) {
            $sws = Join-Path $runRoot "$taskName-$lang-$($script.BaseName)/workspace"
            $shome = Join-Path $runRoot "$taskName-$lang-$($script.BaseName)/claude-home"
            New-Item -ItemType Directory -Path $sws, $shome -Force | Out-Null
            foreach ($t in $allTasks[0..$index]) { Invoke-Solve "$root/tasks/$t" $sws $shome $lang }
            $params = @{ Workspace = $sws; ClaudeHome = $shome }
            if ((Get-Command $script.FullName).Parameters.ContainsKey('Language')) { $params.Language = $lang }
            & $script.FullName @params
            $sabotageRuns[$script.Name] = @(Invoke-Grade $spec $sws $shome "$label $($script.BaseName)")
        }
        foreach ($name in $expectedMessages.Keys) {
            if (-not $sabotageRuns.Contains($name)) { $problems.Add("${label}: verify.psd1 names $name, which doesn't exist") }
        }

        $rows = foreach ($check in $fresh) {
            $after = $solved | Where-Object Name -eq $check.Name
            $broken = @(foreach ($run in $sabotageRuns.Values) { $run | Where-Object Name -eq $check.Name })

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
                Sabotaged = ($broken | ForEach-Object { if ($_.Passed) { 'pass' } else { 'fail' } }) -join ' '
                Message   = $check.Message
            }
        }
        $rows | Format-Table -AutoSize -Wrap | Out-String -Width 200 | Write-Host

        foreach ($name in $sabotageRuns.Keys) {
            $run = $sabotageRuns[$name]
            if (-not ($run | Where-Object { -not $_.Passed })) {
                $problems.Add("${label}: $name broke the work but every check still passed")
            }
            foreach ($bad in $run | Where-Object { -not $_.Passed }) {
                $lint = Test-MessageIsFriendly $bad.Message
                if ($lint) { $problems.Add("${label} ${name}: '$($bad.Name)': $lint") }
            }
            if (-not $expectedMessages.Contains($name)) { continue }
            foreach ($checkName in $expectedMessages[$name].Keys) {
                $pattern = $expectedMessages[$name][$checkName]
                $got = $run | Where-Object Name -eq $checkName
                if (-not $got) { $problems.Add("${label} ${name}: no check named '$checkName'") }
                elseif ($got.Passed) { $problems.Add("${label} ${name}: '$checkName' passed but should fail") }
                elseif ($got.Message -notmatch $pattern) {
                    $problems.Add("${label} ${name}: '$checkName' failed with the wrong message (wanted /$pattern/): $($got.Message)")
                }
            }
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
