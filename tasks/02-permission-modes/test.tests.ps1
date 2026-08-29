Describe "Permissions and auto mode" {
    BeforeAll {
        function Read-JsonFile($path) {
            if (Test-Path $path) { Get-Content $path -Raw | ConvertFrom-Json } else { $null }
        }

        # Permission rules can land in user settings, project settings, or the
        # legacy per-project allowedTools list depending on the scope chosen.
        $script:allowRules = @()

        foreach ($file in @(
            "$env:CW_CLAUDE_HOME/settings.json",
            "$env:CW_WORKSPACE/.claude/settings.json",
            "$env:CW_WORKSPACE/.claude/settings.local.json"
        )) {
            $cfg = Read-JsonFile $file
            if ($cfg.permissions.allow) { $script:allowRules += @($cfg.permissions.allow) }
        }

        $script:state = Read-JsonFile "$env:CW_CLAUDE_HOME/.claude.json"
        if ($state.projects) {
            foreach ($proj in $state.projects.PSObject.Properties.Value) {
                if ($proj.allowedTools) { $script:allowRules += @($proj.allowedTools) }
            }
        }

        $script:settings = Read-JsonFile "$env:CW_CLAUDE_HOME/settings.json"
    }

    It "An allow rule for the date command is saved in your permissions" {
        if ($allowRules.Count -eq 0) {
            throw "No saved permission rules were found yet. Inside Claude Code, run /permissions and add an allow rule."
        }
        if (@($allowRules -match '^Bash\(date').Count -eq 0) {
            throw "Your saved rules don't include the date rule yet. In /permissions, add an allow rule with the exact text Bash(date:*) to your User settings."
        }
    }

    It "You have explored auto mode with /auto-mode-setup" {
        # Completing the setup writes autoMode rules to settings.json; walking away
        # from it leaves a marker in .claude.json. Either counts as exploring.
        $touched = ($null -ne $settings.autoMode) -or
            ($null -ne $state.autoModeEnvSetup) -or
            ($state.hasSeenAutoModeEntryWarning -eq $true)
        if (-not $touched) {
            throw "There's no sign of auto mode setup yet. Inside Claude Code, run /auto-mode-setup and follow it through."
        }
    }
}
