Describe "Project memory" {
    It "CLAUDE.md exists in your workspace" {
        Test-Path "$env:CW_WORKSPACE/CLAUDE.md" | Should -BeTrue -Because "ask Claude to create a CLAUDE.md with your project rules"
    }

    It "CLAUDE.md contains at least one rule" {
        (Get-Content "$env:CW_WORKSPACE/CLAUDE.md" -Raw -ErrorAction SilentlyContinue).Length |
            Should -BeGreaterThan 20 -Because "it should describe your project's rules, not be empty"
    }
}
