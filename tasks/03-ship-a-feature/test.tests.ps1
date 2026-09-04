Describe "A feature, the Claude Code way" {
    BeforeAll {
        # Runs the project's own test suite (python3 -m unittest or node --test) and
        # reports the exit code plus the number of tests the runner counted.
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
            $text = (Get-Content $outFile -Raw) + "`n" + (Get-Content $errFile -Raw)
            Remove-Item $outFile, $errFile -ErrorAction SilentlyContinue

            # unittest prints "Ran 21 tests in 0.01s"; node --test prints "# tests 21"
            # (TAP, when piped) or "ℹ tests 21" (spec reporter, on a terminal).
            $count = 0
            if ($text -match 'Ran (\d+) tests?') { $count = [int]$Matches[1] }
            elseif ($text -match '(?m)^\s*\S{0,2}\s*tests\s+(\d+)\s*$') { $count = [int]$Matches[1] }

            [pscustomobject]@{
                ExitCode = if ($timedOut) { -1 } else { $proc.ExitCode }
                Count    = $count
                TimedOut = $timedOut
            }
        }

        function Get-RepoFacts($path) {
            if (-not (Test-Path "$path/.git")) { return $null }
            # Commits that exist locally but on no remote branch are the learner's own.
            $commits = 0
            $count = git -C $path rev-list --count HEAD --not --remotes 2>$null
            if ($LASTEXITCODE -eq 0 -and $count) { $commits = [int]$count }
            [pscustomobject]@{
                Path     = $path
                Commits  = $commits
                ClaudeMd = (Test-Path "$path/CLAUDE.md")
            }
        }

        $candidates = @('ledger-py', 'ledger-js') |
            ForEach-Object { Get-RepoFacts "$env:CW_WORKSPACE/$_" } |
            Where-Object { $null -ne $_ }
        # If both repos were cloned, grade the one that was worked in.
        $script:repo = $candidates | Sort-Object Commits, ClaudeMd -Descending | Select-Object -First 1
    }

    It "A ledger project is cloned in your workspace" {
        if ($null -eq $repo) {
            throw "Neither ledger-py nor ledger-js was found in your workspace yet. Clone one with the git clone command in the instructions."
        }
    }

    It "Claude committed at least one new change" {
        if ($null -eq $repo -or $repo.Commits -eq 0) {
            throw "No new commits were found in your ledger project yet. Once Claude has built the feature, ask it to commit the change."
        }
    }

    It "CLAUDE.md asks for tests with every change" {
        if ($null -eq $repo -or -not $repo.ClaudeMd) {
            throw "There's no CLAUDE.md in your ledger project yet. Ask Claude to create one with your testing instruction, as in step 2."
        }
        $content = Get-Content "$($repo.Path)/CLAUDE.md" -Raw
        if ($content -notmatch 'test') {
            throw "Your CLAUDE.md doesn't mention tests yet. Ask Claude to add the instruction that every code change must include tests."
        }
    }

    It "The test suite passes with more tests than it started with" {
        if ($null -eq $repo) {
            throw "There's no ledger project to test yet. Clone one with the git clone command in the instructions."
        }
        $run = Invoke-Suite $repo.Path
        if ($run.TimedOut) {
            throw "The test suite didn't finish within a minute. Ask Claude to find out what is hanging and fix it."
        }
        if ($run.ExitCode -ne 0) {
            throw "The test suite is failing right now. Ask Claude to run the tests, fix the failures, and commit."
        }
        # Both sample repos start with 17 passing tests.
        if ($run.Count -le 17) {
            throw "The project still has its original 17 tests. Ask Claude to add tests for your features, then commit them."
        }
    }
}
