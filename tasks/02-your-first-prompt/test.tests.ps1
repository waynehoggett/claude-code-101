Describe "Claude's first file" {
    It "greeting.md exists in your workspace" {
        Test-Path "$env:CW_WORKSPACE/greeting.md" | Should -BeTrue -Because "ask Claude to create greeting.md with a haiku about Kubernetes"
    }

    It "greeting.md contains a haiku (at least three lines of text)" {
        $lines = @(Get-Content "$env:CW_WORKSPACE/greeting.md" -ErrorAction SilentlyContinue |
            Where-Object { $_.Trim().Length -gt 0 })
        $lines.Count | Should -BeGreaterOrEqual 3 -Because "a haiku has three lines"
    }
}
