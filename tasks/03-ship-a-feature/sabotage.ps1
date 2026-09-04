# Breaks the solved state in a way the grader must notice: a new test that fails.
# Counting test functions would still pass; running the suite must not.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py'
)
$ErrorActionPreference = 'Stop'
$repo = "$Workspace/ledger-$Language"

if ($Language -eq 'py') {
    $broken = "import unittest`n`n`nclass BrokenTests(unittest.TestCase):`n    def test_that_fails(self):`n        self.assertTrue(False)`n"
    [IO.File]::WriteAllText("$repo/tests/test_broken.py", $broken)
}
else {
    $broken = "import { test } from 'node:test';`nimport assert from 'node:assert/strict';`n`ntest('that fails', () => {`n  assert.ok(false);`n});`n"
    [IO.File]::WriteAllText("$repo/test/broken.test.js", $broken)
}
