Describe "Context under control" {
    BeforeAll {
        # Claude Code writes each session's transcript under
        # <config dir>/projects/<slug>/<session>.jsonl. A /compact leaves a line
        # flagged isCompactSummary, and a slash command the learner ran leaves a
        # local_command line naming it. Both are internal to the pinned CLI version.
        $transcripts = @(Get-ChildItem "$env:CW_CLAUDE_HOME/projects" -Recurse -Filter *.jsonl -ErrorAction SilentlyContinue)

        function Test-TranscriptMarker([string]$pattern) {
            foreach ($file in $transcripts) {
                if (Select-String -Path $file.FullName -Pattern $pattern -Quiet) { return $true }
            }
            return $false
        }
        $script:compacted = Test-TranscriptMarker '"isCompactSummary"\s*:\s*true'
        $script:forked = Test-TranscriptMarker '<command-name>/(fork|branch)'

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
    }

    It "You compacted a session" {
        if (-not $compacted) {
            throw "No compacted session was found yet. Inside Claude Code, run /compact with a focus, as in step 2."
        }
    }

    It "You forked a session" {
        if (-not $forked) {
            throw "No forked session was found yet. Inside Claude Code, run /fork and ask your side question there."
        }
    }

    It "HANDOFF.md describes the project" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier task first, then come back to this one."
        }
        $path = "$($repo.Path)/HANDOFF.md"
        if (-not (Test-Path $path)) {
            throw "There's no HANDOFF.md in your ledger project yet. Ask Claude to write one, as in step 4."
        }
        $content = Get-Content $path -Raw
        if ($content.Length -lt 200 -or $content -notmatch 'test') {
            throw "HANDOFF.md is too thin to hand anything off. Ask Claude to cover what was built, how it's tested, and what to do next."
        }
    }
}
