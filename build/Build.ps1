#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath,

    [Parameter()]
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path -Path $repositoryRoot -ChildPath 'artifacts/module'
}

$sourcePath = Join-Path -Path $repositoryRoot -ChildPath 'src/PSFortiCNAPP'
$moduleOutputPath = Join-Path -Path $OutputPath -ChildPath 'PSFortiCNAPP'

if ($Clean -and (Test-Path -LiteralPath $OutputPath)) {
    Remove-Item -LiteralPath $OutputPath -Recurse -Force
}

[void](New-Item -ItemType Directory -Path $moduleOutputPath -Force)
Copy-Item -Path (Join-Path -Path $sourcePath -ChildPath '*') -Destination $moduleOutputPath -Recurse -Force

$manifestPath = Join-Path -Path $moduleOutputPath -ChildPath 'PSFortiCNAPP.psd1'
$manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop

[pscustomobject][ordered]@{
    Name         = $manifest.Name
    Version      = $manifest.Version
    ModulePath   = $moduleOutputPath
    ManifestPath = $manifestPath
    FileCount    = @(Get-ChildItem -LiteralPath $moduleOutputPath -Recurse -File).Count
}
