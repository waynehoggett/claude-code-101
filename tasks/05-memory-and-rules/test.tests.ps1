Describe "Instructions and memory in place" {
    BeforeAll {
        function Invoke-Suite($path) {
            $isJs = Test-Path "$path/package.json"
            $exe = if ($isJs) { 'node' } else { 'python3' }
            $arguments = if ($isJs) { @('--test') } else { @('-m', 'unittest') }
            $outFile = [IO.Path]::GetTempFileName()
            $errFile = [IO.Path]::GetTempFileName()
            $proc = Start-Process -FilePath $exe -ArgumentList $arguments -WorkingDirectory $path `
                -RedirectStandardOutput $outFile -RedirectStandardError $errFile -PassThru -NoNewWindow
            $timedOut = -not $proc.WaitForExit(60000)
            if ($timedOut) { $proc.Kill() }
            Remove-Item $outFile, $errFile -ErrorAction SilentlyContinue
            [pscustomobject]@{
                ExitCode = if ($timedOut) { -1 } else { $proc.ExitCode }
                TimedOut = $timedOut
            }
        }

        function Get-RepoFacts($path) {
            if (-not (Test-Path "$path/.git")) { return $null }
            $commits = 0
            $count = git -C $path rev-list --count HEAD --not --remotes 2>$null
            if ($LASTEXITCODE -eq 0 -and $count) { $commits = [int]$count }
            [pscustomobject]@{ Path = $path; Commits = $commits }
        }
        $candidates = @('ledger-py', 'ledger-js') |
            ForEach-Object { Get-RepoFacts "$env:CW_WORKSPACE/$_" } |
            Where-Object { $null -ne $_ }
        $script:repo = $candidates | Sort-Object Commits -Descending | Select-Object -First 1

        # Auto memory lives under <config dir>/projects/<slug>/memory/.
        $script:memoryFiles = @(Get-ChildItem "$env:CW_CLAUDE_HOME/projects" -Recurse -Filter *.md -ErrorAction SilentlyContinue |
            Where-Object { $_.DirectoryName -match '[\\/]memory$' })
    }

    It "Your user-level CLAUDE.md runs the tests after every change" {
        $path = "$env:CW_CLAUDE_HOME/CLAUDE.md"
        if (-not (Test-Path $path)) {
            throw "There's no user-level CLAUDE.md yet. Ask Claude to create one with the instruction from step 1."
        }
        if ((Get-Content $path -Raw) -notmatch 'test') {
            throw "Your user-level CLAUDE.md doesn't mention running the tests yet. Ask Claude to add the instruction from step 1."
        }
    }

    It "The tests folder has its own CLAUDE.md" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier tasks first, then come back to this one."
        }
        $found = @(@('tests', 'test') | ForEach-Object { "$($repo.Path)/$_/CLAUDE.md" } | Where-Object { Test-Path $_ })
        if ($found.Count -eq 0) {
            throw "There's no CLAUDE.md inside the tests folder yet. Ask Claude to add one with the instruction from step 2."
        }
        if ([string]::IsNullOrWhiteSpace((Get-Content $found[0] -Raw))) {
            throw "The CLAUDE.md in the tests folder is empty. Ask Claude to put the instruction from step 2 in it."
        }
    }

    It "Claude saved your commit preference to memory" {
        if ($memoryFiles.Count -eq 0) {
            throw "Claude hasn't saved any memory for this project yet. Ask it to remember your commit preference, as in step 3."
        }
        $remembered = $memoryFiles | Where-Object { (Get-Content $_.FullName -Raw) -match 'commit' }
        if (-not $remembered) {
            throw "Claude's memory doesn't mention commits yet. Ask it to remember that you want one feature per commit."
        }
    }

    It "The test suite still passes" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier tasks first, then come back to this one."
        }
        $run = Invoke-Suite $repo.Path
        if ($run.TimedOut) {
            throw "The test suite didn't finish within a minute. Ask Claude to find out what is hanging and fix it."
        }
        if ($run.ExitCode -ne 0) {
            throw "The test suite is failing after your latest change. Ask Claude to run the tests and fix the failures."
        }
    }
}
