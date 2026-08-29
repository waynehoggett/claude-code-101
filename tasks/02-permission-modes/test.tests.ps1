Describe "Permissions and auto mode" {
    BeforeAll {
        function Read-JsonFile($path) {
            if (Test-Path $path) { Get-Content $path -Raw | ConvertFrom-Json } else { $null }
        }

        # Rules can land in user, project, or local settings depending on the
        # scope chosen in /permissions, so search all three.
        $script:denyRules = @()

        foreach ($file in @(
            "$env:CW_CLAUDE_HOME/settings.json",
            "$env:CW_WORKSPACE/.claude/settings.json",
            "$env:CW_WORKSPACE/.claude/settings.local.json"
        )) {
            $cfg = Read-JsonFile $file
            if ($cfg.permissions.deny) { $script:denyRules += @($cfg.permissions.deny) }
        }

        $script:settings = Read-JsonFile "$env:CW_CLAUDE_HOME/settings.json"
    }

    It "A deny rule protecting .env files is saved in your permissions" {
        if ($denyRules.Count -eq 0) {
            throw "No saved deny rules were found yet. Inside Claude Code, run /permissions and add a deny rule."
        }
        if (@($denyRules -match '\.env').Count -eq 0) {
            throw "Your deny rules don't cover .env files yet. In /permissions, add a deny rule with the exact text Read(./.env*) to your User settings."
        }
    }

    It "You added an auto mode rule of your own" {
        # The Auto mode tab in /permissions saves classifier rules to settings.json
        # under the autoMode key.
        if ($null -eq $settings.autoMode) {
            throw "No auto mode rules of your own were found yet. Run /permissions, open the Auto mode tab, and add the Soft allow rule from the instructions."
        }
    }
}
