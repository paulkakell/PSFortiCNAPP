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

# These exceptions are exact rule-and-file pairs. They do not disable a rule for
# other files. Each pair records a reviewed false positive or a pure constructor
# whose approved PowerShell verb does not represent an external state change.
$approvedAnalyzerExceptions = @(
    [pscustomobject]@{
        RuleName  = 'PSAvoidAssignmentToAutomaticVariable'
        ScriptName = 'Test-ProhibitedCharacters.ps1'
        Rationale = 'The repository scanner intentionally collects match records and its runtime policy check remains mandatory.'
    }
    [pscustomobject]@{
        RuleName  = 'PSAvoidAssignmentToAutomaticVariable'
        ScriptName = 'Test-RepositorySafety.ps1'
        Rationale = 'The repository scanner intentionally collects match records and its runtime policy check remains mandatory.'
    }
    [pscustomobject]@{
        RuleName  = 'PSUseDeclaredVarsMoreThanAssignments'
        ScriptName = 'Invoke-FortiCNAPPRequest.ps1'
        Rationale = 'Request state is consumed through ordered retry and telemetry branches that the analyzer does not fully trace.'
    }
    [pscustomobject]@{
        RuleName  = 'PSUseShouldProcessForStateChangingFunctions'
        ScriptName = 'New-FortiCNAPPConfiguration.ps1'
        Rationale = 'The command constructs and validates an in-memory object and changes no external or persistent state.'
    }
    [pscustomobject]@{
        RuleName  = 'PSUseShouldProcessForStateChangingFunctions'
        ScriptName = 'New-FortiCNAPPRequestUri.ps1'
        Rationale = 'The private helper constructs an in-memory URI and changes no external or persistent state.'
    }
    [pscustomobject]@{
        RuleName  = 'PSUseShouldProcessForStateChangingFunctions'
        ScriptName = 'New-FortiCNAPPSessionObject.ps1'
        Rationale = 'The private helper constructs a safe in-memory session view and changes no external or persistent state.'
    }
    [pscustomobject]@{
        RuleName  = 'PSAvoidAssignmentToAutomaticVariable'
        ScriptName = 'Review-SyntheticAuthenticationProfiles.ps1'
        Rationale = 'The synthetic lab uses a local collection named Matches; no regular-expression capture state is consumed.'
    }
)

foreach ($target in $analysisTargets) {
    $targetPath = Join-Path -Path $repositoryRoot -ChildPath $target
    $findings = @(Invoke-ScriptAnalyzer -Path $targetPath -Recurse -Settings $settingsPath)
    foreach ($finding in $findings) {
        $isApprovedException = $false
        foreach ($exception in $approvedAnalyzerExceptions) {
            if (
                $finding.RuleName -eq $exception.RuleName -and
                $finding.ScriptName -eq $exception.ScriptName
            ) {
                $isApprovedException = $true
                break
            }
        }

        if ($isApprovedException) {
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
