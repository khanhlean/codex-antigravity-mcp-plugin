[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$pluginRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $pluginRoot)
$runtimeEntry = Join-Path $pluginRoot "runtime\antigravity-mcp.mjs"

foreach ($commandName in @("codex", "node", "agy")) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $commandName"
    }
}

$nodeVersion = (& node --version).TrimStart("v")
if ([int]($nodeVersion.Split(".")[0]) -lt 20) {
    throw "Node.js 20 or newer is required; found $nodeVersion"
}

if (-not (Test-Path -LiteralPath $runtimeEntry -PathType Leaf)) {
    throw "Bundled runtime is missing: $runtimeEntry"
}

& agy --version
if ($LASTEXITCODE -ne 0) { throw "Antigravity CLI health check failed" }

$marketplaces = (& codex plugin marketplace list 2>&1 | Out-String)
if ($marketplaces -notmatch '(?m)^antigravity-bridge\s') {
    & codex plugin marketplace add $repoRoot
    if ($LASTEXITCODE -ne 0) { throw "Failed to add Antigravity Bridge marketplace" }
}

& codex plugin add 'antigravity-worker@antigravity-bridge'
if ($LASTEXITCODE -ne 0) { throw "Failed to install Antigravity Worker plugin" }

Write-Host "Installed antigravity-worker@antigravity-bridge. Start a new Codex thread before use."
