# Produces what a learner leaves behind after task 6: a project changelog skill, the
# CHANGELOG.md it generated from the real git history, both committed.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
$repo = "$Workspace/ledger-$Language"

function Write-Text([string]$path, [string]$text) {
    New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null
    [IO.File]::WriteAllText($path, $text.Replace("`r`n", "`n"))
}

Write-Text "$repo/.claude/skills/changelog/SKILL.md" @'
---
name: changelog
description: Update CHANGELOG.md from the git history in Keep a Changelog format
---

Bring CHANGELOG.md up to date with the commits made in this repository.

1. Run `git log --date=short --format='%ad %s' origin/main..HEAD` to list the commits
   that are not yet released.
2. If CHANGELOG.md does not exist, create it with a title, the standard Keep a Changelog
   preamble, and an `## [Unreleased]` section.
3. Under `## [Unreleased]`, add one line per commit that is not already listed, in the
   form `- YYYY-MM-DD Commit subject`, grouped under `### Added`, `### Changed`, or
   `### Fixed` by reading the subject.
4. Do not rewrite existing entries. Show the resulting file when done.
'@

$entries = @(git -C $repo log --date=short --format='%ad %s' origin/main..HEAD)
$lines = $entries | ForEach-Object { "- $_" }
$changelog = "# Changelog`n`nAll notable changes to this project will be documented in this file.`n`n## [Unreleased]`n`n### Added`n`n" + ($lines -join "`n") + "`n"
Write-Text "$repo/CHANGELOG.md" $changelog

git -C $repo add -A
git -C $repo commit --quiet -m "Add a changelog skill and the first changelog"
if ($LASTEXITCODE -ne 0) { throw "Commit failed." }
