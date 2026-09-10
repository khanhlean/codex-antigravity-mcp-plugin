[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$pluginRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $pluginRoot)
$runtimeRoot = Join-Path $pluginRoot "runtime"
$runtimeEntry = Join-Path $runtimeRoot "antigravity-mcp.mjs"

foreach ($commandName in @("node", "npm")) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $commandName"
    }
}

$nodeVersion = (& node --version).TrimStart("v")
if ([int]($nodeVersion.Split(".")[0]) -lt 20) {
    throw "Node.js 20 or newer is required; found $nodeVersion"
}

Push-Location $repoRoot
try {
    & npm ci
    if ($LASTEXITCODE -ne 0) { throw "npm ci failed" }

    & npm test
    if ($LASTEXITCODE -ne 0) { throw "Unit tests failed" }

    & npm run smoke:mcp
    if ($LASTEXITCODE -ne 0) { throw "Source MCP smoke test failed" }

    New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
    & npm exec --yes '--package=esbuild@0.25.9' -- esbuild src/index.js --bundle --platform=node --format=esm --target=node20 --legal-comments=eof --outfile=$runtimeEntry
    if ($LASTEXITCODE -ne 0) { throw "Runtime bundle failed" }

    # esbuild preserves a few whitespace-only lines from dependencies; normalize the generated file
    # so `git diff --check` stays clean and repeated builds remain reviewable.
    $runtimeLines = [System.IO.File]::ReadAllLines($runtimeEntry)
    $normalizedLines = $runtimeLines | ForEach-Object { $_.TrimEnd() }
    [System.IO.File]::WriteAllLines(
        $runtimeEntry,
        $normalizedLines,
        [System.Text.UTF8Encoding]::new($false)
    )

    $env:ANTIGRAVITY_MCP_ENTRY = $runtimeEntry
    try {
        & npm run smoke:mcp
        if ($LASTEXITCODE -ne 0) { throw "Bundled MCP smoke test failed" }
    }
    finally {
        Remove-Item Env:ANTIGRAVITY_MCP_ENTRY -ErrorAction SilentlyContinue
    }
}
finally {
    Pop-Location
}

Write-Host "Runtime ready: $runtimeEntry"
