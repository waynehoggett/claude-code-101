Describe "A reusable skill" {
    BeforeAll {
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

        $script:skills = @()
        if ($repo -and (Test-Path "$($repo.Path)/.claude/skills")) {
            $script:skills = @(Get-ChildItem "$($repo.Path)/.claude/skills" -Recurse -Filter SKILL.md)
        }
        $script:changelogSkill = $skills | Where-Object {
            $_.Directory.Name -match 'changelog' -or (Get-Content $_.FullName -Raw) -match 'changelog'
        } | Select-Object -First 1

        # When Claude picks a skill itself, the transcript holds an assistant tool_use
        # named Skill with the skill's name in its input. A skill the learner typed as a
        # slash command leaves a local_command line instead, so this marker only appears
        # for step 4. Internal to the pinned CLI version.
        $transcripts = @(Get-ChildItem "$env:CW_CLAUDE_HOME/projects" -Recurse -Filter *.jsonl -ErrorAction SilentlyContinue)
        $script:autoInvoked = $false
        foreach ($file in $transcripts) {
            if (Select-String -Path $file.FullName -Pattern '(?=.*"name"\s*:\s*"Skill")(?=.*"skill"\s*:\s*"[^"]*changelog")' -Quiet) {
                $script:autoInvoked = $true
                break
            }
        }
    }

    It "A changelog skill exists in the project" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier tasks first, then come back to this one."
        }
        if ($skills.Count -eq 0) {
            throw "There are no skills in the project yet. Ask Claude to create the changelog skill, as in step 1."
        }
        if ($null -eq $changelogSkill) {
            throw "A skill exists, but none of them is about the changelog. Ask Claude to create a project skill called changelog."
        }
    }

    It "Running the skill produced a changelog" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier tasks first, then come back to this one."
        }
        $path = "$($repo.Path)/CHANGELOG.md"
        if (-not (Test-Path $path)) {
            throw "There's no CHANGELOG.md yet. Run /changelog inside Claude Code, as in step 2."
        }
        $content = Get-Content $path -Raw
        if ($content -notmatch 'delet' -or $content -notmatch 'renam') {
            throw "CHANGELOG.md doesn't list both features from task 3 yet. Run /changelog again and check the entries for deleting a transaction and renaming a category."
        }
    }

    It "The skill and the changelog are committed" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier tasks first, then come back to this one."
        }
        $tracked = @(git -C $repo.Path ls-files .claude/skills CHANGELOG.md 2>$null)
        $dirty = @(git -C $repo.Path status --porcelain .claude/skills CHANGELOG.md 2>$null)
        if ($tracked.Count -lt 2 -or $dirty.Count -gt 0) {
            throw "The skill and CHANGELOG.md aren't committed yet. Ask Claude to commit the skill and the changelog."
        }
    }

    It "Claude picked the skill itself from a plain request" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier tasks first, then come back to this one."
        }
        if (-not $autoInvoked) {
            throw "Claude hasn't used the changelog skill on its own yet. Without typing /changelog, ask it in plain words to bring the changelog up to date, as in step 4."
        }
        $content = Get-Content "$($repo.Path)/CHANGELOG.md" -Raw -ErrorAction SilentlyContinue
        if ($content -notmatch 'skill') {
            throw "CHANGELOG.md doesn't list the commit that added the skill yet. Ask Claude in plain words to bring the changelog up to date and commit it."
        }
    }
}
