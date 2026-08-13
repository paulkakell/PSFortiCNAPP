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
$failures = [System.Collections.Generic.List[object]]::new()
$textExtensions = @('.md', '.txt', '.ps1', '.psm1', '.psd1', '.ps1xml', '.yml', '.yaml', '.json')
$exemptPaths = @('LICENSE', 'NOTICE')

$files = @(
    Get-ChildItem -LiteralPath $root -Recurse -File -Force |
        Where-Object -FilterScript {
            $textExtensions -contains $_.Extension.ToLowerInvariant() -or
            $_.Name -in @('.editorconfig', '.gitattributes', '.gitignore', 'CODEOWNERS')
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
    if ($relativePath -in $exemptPaths -or $relativePath.StartsWith('LICENSES/', [System.StringComparison]::Ordinal)) {
        continue
    }

    $expectedLicense = if (
        $relativePath -match '^(src|tests|build|tools|examples)/' -or
        $relativePath -match '^\.github/workflows/' -or
        $relativePath -eq '.github/dependabot.yml' -or
        $relativePath -in @('.editorconfig', '.gitattributes', '.gitignore', 'PSScriptAnalyzerSettings.psd1')
    ) {
        'Apache-2.0'
    }
    elseif ($relativePath -match '^manuscript/') {
        'LicenseRef-Paul-Kell-Manuscript'
    }
    elseif (
        $relativePath -match '^docs/' -or
        $relativePath -match '^\.github/' -or
        $relativePath -match '^(README|CHANGELOG|CONTRIBUTING|CODE_OF_CONDUCT|SECURITY|SUPPORT|LICENSE-SCOPE)\.md$'
    ) {
        'CC-BY-4.0'
    }
    else {
        $null
    }

    if ($null -eq $expectedLicense) {
        continue
    }

    $head = ([System.IO.File]::ReadLines($file.FullName) | Select-Object -First 12) -join "`n"
    $commentPattern = [regex]::Escape("SPDX-License-Identifier: $expectedLicense")
    $jsonPattern = '"spdxLicenseIdentifier"\s*:\s*"' + [regex]::Escape($expectedLicense) + '"'
    if ($head -notmatch $commentPattern -and $head -notmatch $jsonPattern) {
        $failures.Add([pscustomobject]@{
            Path            = $relativePath
            ExpectedLicense = $expectedLicense
        })
    }
}

if ($failures.Count -gt 0) {
    $failures | Sort-Object -Property Path | Format-Table -AutoSize | Out-Host
    throw "Found $($failures.Count) file(s) without the expected SPDX license identifier."
}

[pscustomobject]@{
    Path         = $root
    FilesScanned = $files.Count
    Failures     = 0
    Passed       = $true
}
