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
}
