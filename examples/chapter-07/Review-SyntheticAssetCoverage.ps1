#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (
    Resolve-Path -LiteralPath (
        Join-Path -Path $PSScriptRoot -ChildPath '../..'
    )
).Path

if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path `
        -Path $repositoryRoot `
        -ChildPath 'tests/Fixtures/Synthetic/chapter-07-asset-coverage.json'
}

$manifestPath = Join-Path `
    -Path $repositoryRoot `
    -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
Import-Module -Name $manifestPath -Force -ErrorAction Stop

$fixture = Get-Content `
    -LiteralPath $Path `
    -Raw `
    -Encoding utf8 |
    ConvertFrom-Json -Depth 30

if ($fixture.dataClassification -ne 'Synthetic') {
    throw 'This example accepts only a fixture explicitly classified as Synthetic.'
}

$result = Measure-FortiCNAPPAssetCoverage `
    -ScopeRegister $fixture.scopeRegister `
    -ObservedAsset $fixture.observedAssets `
    -AsOfUtc ([DateTimeOffset]$fixture.asOfUtc) `
    -FreshnessThresholdHours $fixture.freshnessThresholdHours `
    -DataClassification SYNTHETIC

return $result
