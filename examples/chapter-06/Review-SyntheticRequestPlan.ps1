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

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path -Path $repositoryRoot -ChildPath 'tests/Fixtures/Synthetic/chapter-06-api-client.json'
}

$fixture = Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json -Depth 20
if ($fixture.dataClassification -ne 'Synthetic') {
    throw 'This example accepts only a fixture explicitly classified as Synthetic.'
}

$scenarioResults = @(
    foreach ($scenario in $fixture.requestPlan) {
        $retryCount = @($scenario.statusSequence | Where-Object { $_ -in @(429, 500, 503) }).Count
        [pscustomobject][ordered]@{
            Scenario         = $scenario.scenario
            Method           = $scenario.method
            SafePath         = '/api/v2/{0}' -f $scenario.path.TrimStart('/')
            StatusSequence   = @($scenario.statusSequence)
            ExpectedAttempts = [int]$scenario.expectedAttempts
            RetryCount       = $retryCount
            ExpectedOutcome  = $scenario.expectedOutcome
            MakesNetworkCall = $false
        }
    }
)

$result = [pscustomobject][ordered]@{
    DataClassification   = 'SYNTHETIC'
    Organization         = $fixture.organization
    ScenarioCount        = $scenarioResults.Count
    SuccessScenarioCount = @($scenarioResults | Where-Object ExpectedOutcome -EQ 'Success').Count
    ErrorScenarioCount   = @($scenarioResults | Where-Object ExpectedOutcome -EQ 'HttpError').Count
    RetryScenarioCount   = @($scenarioResults | Where-Object RetryCount -GT 0).Count
    NetworkRequestCount  = 0
    Scenarios            = $scenarioResults
}
$result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.SyntheticRequestPlanSummary')

return $result
