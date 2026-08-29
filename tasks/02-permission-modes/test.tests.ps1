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

    It "You added an auto mode rule of your own" {
        # The Auto mode tab in /permissions saves classifier rules to settings.json
        # under the autoMode key.
        if ($null -eq $settings.autoMode) {
            throw "No auto mode rules of your own were found yet. Run /permissions, open the Auto mode tab, and add the allow rule from the instructions."
        }
    }
}
