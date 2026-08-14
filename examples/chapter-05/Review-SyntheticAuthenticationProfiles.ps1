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
        -ChildPath 'tests/Fixtures/Synthetic/chapter-05-authentication-profiles.json'
}

$manifestPath = Join-Path `
    -Path $repositoryRoot `
    -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
Import-Module -Name $manifestPath -Force -ErrorAction Stop

$fixture = Get-Content `
    -LiteralPath $Path `
    -Raw `
    -Encoding utf8 |
    ConvertFrom-Json -Depth 20
if ($fixture.dataClassification -ne 'Synthetic') {
    throw 'This example accepts only a fixture explicitly classified as Synthetic.'
}

$results = @(
    foreach ($profile in $fixture.profiles) {
        $configuration = [pscustomobject][ordered]@{
            EnvironmentName      = $profile.environmentName
            AccountName          = $profile.accountName
            BaseUri              = $profile.baseUri
            TokenEndpoint        = $profile.tokenEndpoint
            AuthenticationMode   = 'AccountApiKey'
            KeyId                = $profile.keyId
            TokenLifetimeSeconds = $profile.tokenLifetimeSeconds
            ContainsSecret       = $false
        }
        $validation = Test-FortiCNAPPConfiguration `
            -Configuration $configuration

        [pscustomobject][ordered]@{
            ProfileId      = $profile.profileId
            ExpectedValid  = [bool]$profile.expectedValid
            ActualValid    = $validation.Valid
            MatchesExpected = [bool]$profile.expectedValid -eq $validation.Valid
            PassCount      = $validation.PassCount
            WarningCount   = $validation.WarningCount
            FailCount      = $validation.FailCount
            Checks         = $validation.Checks
        }
    }
)

$summary = [pscustomobject][ordered]@{
    DataClassification = 'SYNTHETIC'
    Organization       = $fixture.organization
    ProfileCount       = $results.Count
    ValidProfileCount  = @($results | Where-Object ActualValid).Count
    InvalidProfileCount = @($results | Where-Object { -not $_.ActualValid }).Count
    ExpectedMatchCount = @($results | Where-Object MatchesExpected).Count
    AllExpectationsMet = @($results | Where-Object { -not $_.MatchesExpected }).Count -eq 0
    LiveRequestCount   = 0
    SecretValueCount   = 0
    Results            = $results
}
$summary.PSObject.TypeNames.Insert(
    0,
    'PSFortiCNAPP.SyntheticAuthenticationProfileSummary'
)

return $summary
