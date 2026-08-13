#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path = (Split-Path -Parent $PSScriptRoot),

    [Parameter()]
    [string[]]$IncludeExtension = @(
        '.md', '.txt', '.ps1', '.psm1', '.psd1', '.ps1xml', '.yml', '.yaml',
        '.json', '.xml', '.html', '.css', '.js', '.ts', '.toml'
    ),

    [Parameter()]
    [string[]]$IncludeFileName = @(
        '.editorconfig', '.gitattributes', '.gitignore', 'CODEOWNERS'
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$forbidden = [char]0x2014
$matches = [System.Collections.Generic.List[object]]::new()

$files = @(
    Get-ChildItem -LiteralPath $resolvedPath -Recurse -File -Force |
        Where-Object -FilterScript {
            $IncludeExtension -contains $_.Extension.ToLowerInvariant() -or
            $IncludeFileName -contains $_.Name
        }
)

foreach ($file in $files) {
    $relativePath = [System.IO.Path]::GetRelativePath($resolvedPath, $file.FullName).Replace('\', '/')
    if (
        $relativePath.StartsWith('.git/', [System.StringComparison]::Ordinal) -or
        $relativePath.StartsWith('artifacts/', [System.StringComparison]::Ordinal)
    ) {
        continue
    }

    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
        $lineNumber++
        $index = $line.IndexOf($forbidden)

        while ($index -ge 0) {
            $matches.Add([pscustomobject]@{
                Path      = $relativePath
                Line      = $lineNumber
                Column    = $index + 1
                CodePoint = 'U+2014'
            })

            $index = $line.IndexOf($forbidden, $index + 1)
        }
    }
}

if ($matches.Count -gt 0) {
    $matches | Sort-Object -Property Path, Line, Column | Format-Table -AutoSize | Out-Host
    throw "Found $($matches.Count) prohibited U+2014 character occurrence(s)."
}

[pscustomobject]@{
    Path         = $resolvedPath
    FilesScanned = $files.Count
    Prohibited   = 'U+2014'
    Matches      = 0
    Passed       = $true
}
