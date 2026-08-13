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
$settingsPath = Join-Path -Path $repositoryRoot -ChildPath 'PSScriptAnalyzerSettings.psd1'
$manifestPath = Join-Path -Path $repositoryRoot -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'

& (Join-Path -Path $repositoryRoot -ChildPath 'tools/Test-ProhibitedCharacters.ps1') -Path $repositoryRoot | Out-Host
& (Join-Path -Path $repositoryRoot -ChildPath 'tools/Test-LicenseHeaders.ps1') -Path $repositoryRoot | Out-Host
& (Join-Path -Path $repositoryRoot -ChildPath 'tools/Test-RepositorySafety.ps1') -Path $repositoryRoot | Out-Host

[void](Test-ModuleManifest -Path $manifestPath -ErrorAction Stop)
Import-Module -Name PSScriptAnalyzer -RequiredVersion 1.25.0 -Force -ErrorAction Stop

$analysisTargets = @('src', 'build', 'tools', 'examples')
$analysisFindings = [System.Collections.Generic.List[object]]::new()
# The two Phase 1 scanners assign a collection to PowerShell's automatic Matches variable.
# Their runtime policy checks remain mandatory. This exact-file exception is temporary and
# must be removed when those scanners are refactored without changing their enforcement.
foreach ($target in $analysisTargets) {
    $targetPath = Join-Path -Path $repositoryRoot -ChildPath $target
    $findings = @(Invoke-ScriptAnalyzer -Path $targetPath -Recurse -Settings $settingsPath)
    foreach ($finding in $findings) {
        $isApprovedFoundationException = (
            $finding.RuleName -eq 'PSAvoidAssignmentToAutomaticVariable' -and
            $finding.ScriptName -in @(
                'Test-ProhibitedCharacters.ps1',
                'Test-RepositorySafety.ps1'
            )
        )

        if ($isApprovedFoundationException) {
            continue
        }

        $analysisFindings.Add($finding)
    }
}

if ($analysisFindings.Count -gt 0) {
    $analysisFindings |
        Sort-Object -Property ScriptName, Line, RuleName |
        Format-Table -Property Severity, RuleName, ScriptName, Line, Message -AutoSize |
        Out-Host
    throw "PSScriptAnalyzer reported $($analysisFindings.Count) finding(s)."
}

& (Join-Path -Path $PSScriptRoot -ChildPath 'Test.ps1') -CI:$CI
