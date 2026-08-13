# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path = (Split-Path -Parent $PSScriptRoot),

    [Parameter()]
    [string[]]$IncludeExtension = @(
        '.md', '.txt', '.ps1', '.psm1', '.psd1', '.yml', '.yaml',
        '.json', '.xml', '.html', '.css', '.js', '.ts', '.toml'
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$forbidden = [char]0x2014
$matches = [System.Collections.Generic.List[object]]::new()

$files = Get-ChildItem -LiteralPath $resolvedPath -Recurse -File | Where-Object {
    $IncludeExtension -contains $_.Extension.ToLowerInvariant()
}

foreach ($file in $files) {
    $lineNumber = 0

    foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
        $lineNumber++
        $index = $line.IndexOf($forbidden)

        while ($index -ge 0) {
            $matches.Add([pscustomobject]@{
                Path       = $file.FullName
                Line       = $lineNumber
                Column     = $index + 1
                CodePoint  = 'U+2014'
            })

            $index = $line.IndexOf($forbidden, $index + 1)
        }
    }
}

if ($matches.Count -gt 0) {
    $matches | Sort-Object Path, Line, Column | Format-Table -AutoSize
    throw "Found $($matches.Count) prohibited U+2014 character occurrence(s)."
}

[pscustomobject]@{
    Path          = $resolvedPath
    FilesScanned  = $files.Count
    Prohibited    = 'U+2014'
    Matches       = 0
    Passed        = $true
}
