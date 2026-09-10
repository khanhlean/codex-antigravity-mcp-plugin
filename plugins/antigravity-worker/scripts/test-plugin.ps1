[CmdletBinding()]
param(
    [switch]$Live
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$pluginRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $pluginRoot)
$runtimeEntry = Join-Path $pluginRoot "runtime\antigravity-mcp.mjs"

if (-not (Test-Path -LiteralPath $runtimeEntry -PathType Leaf)) {
    throw "Runtime is missing. Run scripts/build-runtime.ps1 first."
}

Push-Location $repoRoot
try {
    if (-not (Test-Path -LiteralPath "node_modules" -PathType Container)) {
        & npm ci
        if ($LASTEXITCODE -ne 0) { throw "npm ci failed" }
    }

    $env:ANTIGRAVITY_MCP_ENTRY = $runtimeEntry
    try {
        & npm run smoke:mcp
        if ($LASTEXITCODE -ne 0) { throw "Bundled MCP smoke test failed" }

        if ($Live) {
            & npm run smoke:live
            if ($LASTEXITCODE -ne 0) { throw "Live Gemini smoke test failed" }
        }
    }
    finally {
        Remove-Item Env:ANTIGRAVITY_MCP_ENTRY -ErrorAction SilentlyContinue
    }
}
finally {
    Pop-Location
}
