#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $Path).Path
$textExtensions = @(
    '.md', '.txt', '.ps1', '.psm1', '.psd1', '.ps1xml', '.yml', '.yaml',
    '.json', '.xml', '.html', '.css', '.js', '.ts', '.toml'
)
$patterns = [ordered]@{
    AwsAccessKey       = '\b(?:AKIA|ASIA)[0-9A-Z]{16}\b'
    GitHubClassicToken = '\bgh[pousr]_[A-Za-z0-9]{36,}\b'
    GitHubFineToken    = '\bgithub_pat_[A-Za-z0-9_]{60,}\b'
    SlackToken         = '\bxox[baprs]-[A-Za-z0-9-]{20,}\b'
    PrivateKey         = '-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'
}
$matches = [System.Collections.Generic.List[object]]::new()

$files = @(
    Get-ChildItem -LiteralPath $root -Recurse -File -Force |
        Where-Object -FilterScript {
            $textExtensions -contains $_.Extension.ToLowerInvariant()
        }
)

foreach ($file in $files) {
    $relativePath = [System.IO.Path]::GetRelativePath($root, $file.FullName).Replace('\', '/')
    if (
        $relativePath.StartsWith('.git/', [System.StringComparison]::Ordinal) -or
        $relativePath.StartsWith('artifacts/', [System.StringComparison]::Ordinal)
    ) {
        continue
    }
    if ($relativePath.StartsWith('LICENSES/', [System.StringComparison]::Ordinal)) {
        continue
    }

    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
        $lineNumber++
        foreach ($patternName in $patterns.Keys) {
            if ($line -match $patterns[$patternName]) {
                $matches.Add([pscustomobject]@{
                    Path    = $relativePath
                    Line    = $lineNumber
                    Pattern = $patternName
                })
            }
        }
    }
}

if ($matches.Count -gt 0) {
    $matches | Sort-Object -Property Path, Line, Pattern | Format-Table -AutoSize | Out-Host
    throw "Found $($matches.Count) possible credential or private-key occurrence(s)."
}

[pscustomobject]@{
    Path         = $root
    FilesScanned = $files.Count
    Matches      = 0
    Passed       = $true
}
