Describe "A feature, the Claude Code way" {
    BeforeAll {
        # The grader has no git binary, so read .git internals directly. Every
        # local commit appends a "commit" line to .git/logs/HEAD; the clone itself
        # only writes a "clone" line, so this counts the learner's own commits.
        function Get-RepoFacts($path) {
            if (-not (Test-Path "$path/.git")) { return $null }
            $commits = 0
            $reflog = "$path/.git/logs/HEAD"
            if (Test-Path $reflog) {
                $commits = @(Select-String -Path $reflog -Pattern "`tcommit").Count
            }

            $tests = 0
            if (Test-Path "$path/tests") {
                $tests += @(Get-ChildItem -Recurse "$path/tests" -Filter *.py |
                    Select-String -Pattern 'def test_').Count
            }
            $tests += @(Get-ChildItem -Recurse $path -Filter *.test.js |
                Where-Object { $_.FullName -notmatch 'node_modules' } |
                Select-String -Pattern '^\s*(test|it)\(').Count

            [pscustomobject]@{
                Path = $path
                Commits = $commits
                Tests = $tests
                ClaudeMd = (Test-Path "$path/CLAUDE.md")
            }
        }

        $candidates = @('ledger-py', 'ledger-js') |
            ForEach-Object { Get-RepoFacts "$env:CW_WORKSPACE/$_" } |
            Where-Object { $null -ne $_ }
        # If both repos were cloned, grade the one that was worked in.
        $script:repo = $candidates | Sort-Object Commits, Tests -Descending | Select-Object -First 1
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

    It "CLAUDE.md makes tests the rule" {
        if ($null -eq $repo -or -not $repo.ClaudeMd) {
            throw "There's no CLAUDE.md in your ledger project yet. Ask Claude to create one with your testing rule, as in step 2."
        }
        $content = Get-Content "$($repo.Path)/CLAUDE.md" -Raw
        if ($content -notmatch 'test') {
            throw "Your CLAUDE.md doesn't mention tests yet. Ask Claude to add the rule that every code change must include tests."
        }
    }

    It "The test suite grew with your features" {
        # Both sample repos start with 17 tests.
        if ($null -eq $repo -or $repo.Tests -le 17) {
            throw "The project still has its original 17 tests. Ask Claude to add tests for your features, then commit them."
        }
    }
}
