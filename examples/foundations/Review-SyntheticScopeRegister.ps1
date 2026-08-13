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

if ([string]::IsNullOrWhiteSpace($Path)) {
    $repositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
    $Path = Join-Path -Path $repositoryRoot -ChildPath 'tests/Fixtures/Synthetic/chapter-01-scope-register.json'
}

$register = Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json -Depth 20
if ($register.dataClassification -ne 'Synthetic') {
    throw 'This example accepts only a scope register explicitly classified as Synthetic.'
}

$expectedScopes = @($register.scopes | Where-Object -Property expectedInFortiCNAPP -EQ $true)
$observedScopes = @($expectedScopes | Where-Object -Property evidenceState -EQ 'Observed')
$missingScopes = @($expectedScopes | Where-Object -Property evidenceState -EQ 'Missing')
$staleScopes = @($expectedScopes | Where-Object -Property evidenceState -EQ 'Stale')

$coveragePercent = if ($expectedScopes.Count -eq 0) {
    $null
}
else {
    [math]::Round(($observedScopes.Count / $expectedScopes.Count) * 100, 2)
}

[pscustomobject][ordered]@{
    DataClassification  = $register.dataClassification
    Organization        = $register.organization
    AsOfUtc             = [DateTimeOffset]::Parse($register.asOfUtc)
    Denominator         = $register.denominatorDefinition
    ExpectedScopeCount  = $expectedScopes.Count
    ObservedScopeCount  = $observedScopes.Count
    MissingScopeCount   = $missingScopes.Count
    StaleScopeCount     = $staleScopes.Count
    CoveragePercent     = $coveragePercent
    MissingScopeIds     = @($missingScopes.scopeId)
    StaleScopeIds       = @($staleScopes.scopeId)
}
