Describe "Your workspace" {
    It "hello.txt exists in your workspace" {
        Test-Path "$env:CW_WORKSPACE/hello.txt" | Should -BeTrue -Because "create it with: echo `"Your Name`" > hello.txt"
    }

    It "hello.txt has your name in it" {
        (Get-Content "$env:CW_WORKSPACE/hello.txt" -Raw -ErrorAction SilentlyContinue).Trim() |
            Should -Not -BeNullOrEmpty -Because "the file should contain your name, not be empty"
    }
}
