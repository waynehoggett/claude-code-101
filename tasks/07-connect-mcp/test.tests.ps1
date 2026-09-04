Describe "An MCP server in your project" {
    BeforeAll {
        function Get-RepoFacts($path) {
            if (-not (Test-Path "$path/.git")) { return $null }
            $commits = 0
            $count = git -C $path rev-list --count HEAD --not --remotes 2>$null
            if ($LASTEXITCODE -eq 0 -and $count) { $commits = [int]$count }
            [pscustomobject]@{ Path = $path; Commits = $commits }
        }
        $candidates = @('ledger-py', 'ledger-js') |
            ForEach-Object { Get-RepoFacts "$env:CW_WORKSPACE/$_" } |
            Where-Object { $null -ne $_ }
        $script:repo = $candidates | Sort-Object Commits -Descending | Select-Object -First 1
    }

    It "Context7 is configured for the project" {
        if ($null -eq $repo) {
            throw "Your ledger project wasn't found in the workspace. Finish the earlier tasks first, then come back to this one."
        }
        $path = "$($repo.Path)/.mcp.json"
        if (-not (Test-Path $path)) {
            throw "There's no .mcp.json in your ledger project yet. Run the claude mcp add command from step 1 inside the project directory."
        }
        try { $config = Get-Content $path -Raw | ConvertFrom-Json }
        catch { throw "Your .mcp.json isn't valid JSON. Remove it and run the claude mcp add command from step 1 again." }

        $servers = @()
        if ($config.mcpServers) { $servers = @($config.mcpServers.PSObject.Properties.Value) }
        $context7 = $servers | Where-Object { $_.url -match 'context7\.com' }
        if (-not $context7) {
            throw "Your .mcp.json doesn't include the Context7 server yet. Run the claude mcp add command from step 1 with the project scope."
        }
    }
}
