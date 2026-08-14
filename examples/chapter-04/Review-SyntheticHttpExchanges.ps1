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
        -ChildPath 'tests/Fixtures/Synthetic/chapter-04-http-exchanges.json'
}

$manifestPath = Join-Path `
    -Path $repositoryRoot `
    -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
Import-Module -Name $manifestPath -Force -ErrorAction Stop

$fixture = Get-Content `
    -LiteralPath $Path `
    -Raw `
    -Encoding utf8 |
    ConvertFrom-Json -Depth 100

if ($fixture.dataClassification -ne 'Synthetic') {
    throw 'This example accepts only a fixture classified as Synthetic.'
}

$exchanges = @(
    $fixture.exchanges |
        ConvertFrom-FortiCNAPPHttpExchange `
            -DataClassification SYNTHETIC
)

$statusCounts = @(
    $exchanges |
        Group-Object -Property StatusFamily |
        Sort-Object -Property Name |
        ForEach-Object -Process {
            [pscustomobject][ordered]@{
                StatusFamily = $_.Name
                Count        = $_.Count
            }
        }
)

$bodyStateCounts = @(
    $exchanges |
        Group-Object -Property BodyState |
        Sort-Object -Property Name |
        ForEach-Object -Process {
            [pscustomobject][ordered]@{
                BodyState = $_.Name
                Count     = $_.Count
            }
        }
)

$contractIssueExchanges = @(
    $exchanges |
        Where-Object -FilterScript {
            $_.ContractState -ne 'Valid'
        } |
        Sort-Object -Property ContractState, ExchangeId
)

$result = [pscustomobject][ordered]@{
    DataClassification       = 'SYNTHETIC'
    Organization             = $fixture.organization
    ExchangeCount            = $exchanges.Count
    SuccessCount             = @(
        $exchanges |
            Where-Object -FilterScript {
                $_.IsSuccessStatusCode
            }
    ).Count
    ValidContractCount       = @(
        $exchanges |
            Where-Object -FilterScript {
                $_.ContractState -eq 'Valid'
            }
    ).Count
    WarningContractCount     = @(
        $exchanges |
            Where-Object -FilterScript {
                $_.ContractState -eq 'Warning'
            }
    ).Count
    InvalidContractCount     = @(
        $exchanges |
            Where-Object -FilterScript {
                $_.ContractState -eq 'Invalid'
            }
    ).Count
    StatusCounts             = $statusCounts
    BodyStateCounts          = $bodyStateCounts
    ContractIssueExchanges   = $contractIssueExchanges
    Exchanges                = $exchanges
}
$result.PSObject.TypeNames.Insert(
    0,
    'PSFortiCNAPP.SyntheticHttpContractSummary'
)

return $result
