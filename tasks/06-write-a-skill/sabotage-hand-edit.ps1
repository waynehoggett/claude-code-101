# Claude brought the changelog up to date and committed it, but by hand: the
# transcript holds no Skill tool_use (#44, the most common way step 4 failed in
# the 21 Oct run-through). The failure message must say so and point to /clear.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
foreach ($file in Get-ChildItem "$ClaudeHome/projects" -Recurse -Filter *.jsonl) {
    $kept = @(Get-Content $file.FullName | Where-Object { $_ -notmatch '"name"\s*:\s*"Skill"' })
    [IO.File]::WriteAllText($file.FullName, (($kept -join "`n") + "`n"))
}
