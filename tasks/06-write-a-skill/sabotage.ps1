# The skill ran and everything looks right on disk, but nothing was committed.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
$repo = "$Workspace/ledger-$Language"
git -C $repo reset --quiet --soft HEAD~1
git -C $repo reset --quiet
