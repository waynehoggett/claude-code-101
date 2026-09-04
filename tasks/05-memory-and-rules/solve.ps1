# Produces what a learner leaves behind after task 5: a user-level CLAUDE.md, a
# CLAUDE.md in the tests folder, an auto-memory entry, and the small step 1 change
# (description length limit) implemented with a test so the suite stays green.
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

Write-Text "$ClaudeHome/CLAUDE.md" "# My rules`n`nAfter changing any code, run the project's test suite and show me the result before reporting back.`n"

$memoryDir = "$ClaudeHome/projects/-workspace-ledger-$Language/memory"
Write-Text "$memoryDir/feedback_commits.md" @"
---
name: feedback-commits
description: One feature per commit with a one-line message
metadata:
  type: feedback
---

Wayne wants one feature per commit, with a one-line commit message.
"@
Write-Text "$memoryDir/MEMORY.md" "# Memory index`n`n- [Commit preference](feedback_commits.md) - one feature per commit, one-line message`n"

if ($Language -eq 'py') {
    Write-Text "$repo/tests/CLAUDE.md" "# Test rules`n`nEvery test sets up its own data and never depends on another test.`n"

    $store = "$repo/src/ledger/store.py"
    $src = (Get-Content $store -Raw).Replace(
        "        if not description:`n            return err(`"description must not be empty`")",
        "        if not description:`n            return err(`"description must not be empty`")`n        if len(description) > 80:`n            return err(`"description must be 80 characters or fewer`")")
    if ($src -notmatch '80 characters') { throw "Could not insert the description length rule into store.py." }
    Write-Text $store $src

    $tests = "$repo/tests/test_store_features.py"
    Write-Text $tests ((Get-Content $tests -Raw).TrimEnd() + @'


class StoreDescriptionLengthTests(unittest.TestCase):
    def test_long_description_is_err(self):
        result = Store().add("x" * 81, "food", 1)
        self.assertTrue(result.is_err)
        self.assertIn("80", result.error)
'@ + "`n")
}
else {
    Write-Text "$repo/test/CLAUDE.md" "# Test rules`n`nEvery test sets up its own data and never depends on another test.`n"

    $store = "$repo/src/ledger/store.js"
    $src = (Get-Content $store -Raw).Replace(
        "      if (typeof category !== 'string' || category.trim() === '') {",
        "      if (description.trim().length > 80) {`n        throw new ValidationError('description must be 80 characters or fewer');`n      }`n      if (typeof category !== 'string' || category.trim() === '') {")
    if ($src -notmatch '80 characters') { throw "Could not insert the description length rule into store.js." }
    Write-Text $store $src

    $tests = "$repo/test/store-features.test.js"
    Write-Text $tests ((Get-Content $tests -Raw).TrimEnd() + @'


describe('store.add description length', () => {
  test('rejects descriptions longer than 80 characters', () => {
    const store = createStore();
    assert.throws(() => store.add('x'.repeat(81), 'food', 1), /80/);
  });
});
'@ + "`n")
}

git -C $repo add -A
git -C $repo commit --quiet -m "Reject descriptions longer than 80 characters"
if ($LASTEXITCODE -ne 0) { throw "Commit failed." }
