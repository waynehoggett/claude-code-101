Describe "Claude Code is set up" {
    BeforeAll {
        function Read-JsonFile($path) {
            if (Test-Path $path) { Get-Content $path -Raw | ConvertFrom-Json } else { $null }
        }

        # Model, effort, and trust live in settings.json and .claude.json inside the
        # learner's Claude config dir; exact placement varies by CLI version, so read both.
        $script:state = Read-JsonFile "$env:CW_CLAUDE_HOME/.claude.json"
        $script:settings = Read-JsonFile "$env:CW_CLAUDE_HOME/settings.json"

        $script:models = @()
        $script:efforts = @()
        foreach ($cfg in @($script:settings, $script:state)) {
            if ($null -eq $cfg) { continue }
            if ($cfg.model) { $script:models += $cfg.model }
            if ($cfg.effortLevel) { $script:efforts += $cfg.effortLevel }
            if ($cfg.modelSettings) {
                foreach ($prop in $cfg.modelSettings.PSObject.Properties) {
                    if ($prop.Value.effortLevel) { $script:efforts += $prop.Value.effortLevel }
                }
            }
        }
    }

    It "You started Claude Code and trusted your workspace folder" {
        $state | Should -Not -BeNullOrEmpty -Because "run claude in your terminal to start Claude Code for the first time"
        $trusted = @()
        if ($state.projects) {
            $trusted = @($state.projects.PSObject.Properties.Value |
                Where-Object { $_.hasTrustDialogAccepted -eq $true })
        }
        $trusted.Count | Should -BeGreaterThan 0 -Because "when Claude Code asks whether you trust the files in this folder, choose Yes, proceed"
    }

    It "The active model is Sonnet" {
        $models.Count | Should -BeGreaterThan 0 -Because "run /model inside Claude Code and pick a model with the arrow keys"
        ($models -match 'sonnet').Count | Should -BeGreaterThan 0 -Because "run /model and select Sonnet as the model"
    }

    It "Reasoning effort is set to Medium" {
        ($efforts -contains 'medium') | Should -BeTrue -Because "run /model and set the effort to Medium"
    }
}
