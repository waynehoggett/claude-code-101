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
        if ($null -eq $state) {
            throw "Claude Code doesn't seem to have started yet. Run claude in your terminal and work through the setup questions, then check again."
        }
        $trusted = @()
        if ($state.projects) {
            $trusted = @($state.projects.PSObject.Properties.Value |
                Where-Object { $_.hasTrustDialogAccepted -eq $true })
        }
        if ($trusted.Count -eq 0) {
            throw "Claude Code has started, but your workspace folder isn't trusted yet. When Claude Code asks whether you trust the files in this folder, choose Yes, proceed."
        }
    }

    It "The active model is Sonnet" {
        if ($models.Count -eq 0) {
            throw "No model has been picked yet. Inside Claude Code, run /model and select Sonnet."
        }
        if (@($models -match 'sonnet').Count -eq 0) {
            throw "The selected model isn't Sonnet yet. Run /model and select Sonnet as the model."
        }
    }

    It "Reasoning effort is set to Medium" {
        if ($efforts -notcontains 'medium') {
            throw "Reasoning effort isn't set to Medium yet. Run /model and set the effort to Medium."
        }
    }
}
