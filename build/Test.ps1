#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$CI
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
$artifactsPath = Join-Path -Path $repositoryRoot -ChildPath 'artifacts'
[void](New-Item -ItemType Directory -Path $artifactsPath -Force)

Import-Module -Name Pester -RequiredVersion 5.9.0 -Force -ErrorAction Stop

$configuration = New-PesterConfiguration
$configuration.Run.Path = @(Join-Path -Path $repositoryRoot -ChildPath 'tests')
$configuration.Run.PassThru = $true
$configuration.Run.Exit = $false
$configuration.Output.Verbosity = if ($CI) { 'Detailed' } else { 'Normal' }
$configuration.TestResult.Enabled = $true
$configuration.TestResult.OutputFormat = 'NUnitXml'
$configuration.TestResult.OutputPath = Join-Path -Path $artifactsPath -ChildPath 'test-results.xml'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = @(
    Join-Path -Path $repositoryRoot -ChildPath 'src/PSFortiCNAPP/Public/*.ps1'
    Join-Path -Path $repositoryRoot -ChildPath 'src/PSFortiCNAPP/Private/*.ps1'
)
$configuration.CodeCoverage.OutputFormat = 'JaCoCo'
$configuration.CodeCoverage.OutputPath = Join-Path -Path $artifactsPath -ChildPath 'coverage.xml'
$configuration.CodeCoverage.CoveragePercentTarget = 85

$result = Invoke-Pester -Configuration $configuration
if ($result.FailedCount -gt 0) {
    throw "Pester reported $($result.FailedCount) failed test(s)."
}
if ($null -ne $result.CodeCoverage -and $result.CodeCoverage.CoveragePercent -lt 85) {
    throw "Code coverage was $($result.CodeCoverage.CoveragePercent) percent; at least 85 percent is required."
}

return $result
