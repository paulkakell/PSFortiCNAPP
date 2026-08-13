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
    $Path = Join-Path -Path $repositoryRoot -ChildPath 'tests/Fixtures/Synthetic/chapter-03-findings.json'
}

$manifestPath = Join-Path -Path $repositoryRoot -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
Import-Module -Name $manifestPath -Force -ErrorAction Stop

$fixture = Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json -Depth 20
if ($fixture.dataClassification -ne 'Synthetic') {
    throw 'This example accepts only a fixture explicitly classified as Synthetic.'
}

$collectedAtUtc = [DateTimeOffset]::Parse($fixture.collectedAtUtc).ToUniversalTime()
$records = @(
    $fixture.findings |
        ConvertTo-FortiCNAPPEvidenceRecord `
            -SourceSystem 'Chapter03Fixture' `
            -DataClassification SYNTHETIC `
            -CollectedAtUtc $collectedAtUtc
)

$openRecords = @(
    $records | Where-Object -FilterScript { $_.IsOpen }
)
$currentPriorityRecords = @(
    $records |
        Where-Object -FilterScript {
            $_.IsPriorityCandidate -and $_.IsCurrentEvidence
        } |
        Sort-Object -Property SeverityRank, ObservedAtUtc, EvidenceId
)
$stalePriorityRecords = @(
    $records |
        Where-Object -FilterScript {
            $_.IsPriorityCandidate -and -not $_.IsCurrentEvidence
        } |
        Sort-Object -Property SeverityRank, ObservedAtUtc, EvidenceId
)
$domainCounts = @(
    $records |
        Group-Object -Property Domain |
        Sort-Object -Property @{
            Expression = 'Count'
            Descending = $true
        }, @{
            Expression = 'Name'
            Descending = $false
        } |
        ForEach-Object -Process {
            [pscustomobject][ordered]@{
                Domain = $_.Name
                Count  = $_.Count
            }
        }
)

$currentPriorityRatePercent = if ($openRecords.Count -eq 0) {
    $null
}
else {
    [math]::Round(
        ($currentPriorityRecords.Count / $openRecords.Count) * 100,
        2
    )
}

$result = [pscustomobject][ordered]@{
    DataClassification         = 'SYNTHETIC'
    Organization               = $fixture.organization
    CollectedAtUtc             = $collectedAtUtc
    TotalFindingCount          = $records.Count
    OpenFindingCount           = $openRecords.Count
    CurrentPriorityCount       = $currentPriorityRecords.Count
    StalePriorityCount         = $stalePriorityRecords.Count
    CurrentPriorityRatePercent = $currentPriorityRatePercent
    PriorityRateDenominator    = 'Open findings'
    DomainCounts               = $domainCounts
    CurrentPriorityRecords     = $currentPriorityRecords
    StalePriorityRecords       = $stalePriorityRecords
    Records                    = $records
}
$result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.SyntheticFindingSummary')

return $result
