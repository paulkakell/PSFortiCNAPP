# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

BeforeAll {
    $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
    $script:ManifestPath = Join-Path -Path $script:RepositoryRoot -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
    $script:FixturePath = Join-Path -Path $script:RepositoryRoot -ChildPath 'tests/Fixtures/Synthetic/chapter-07-asset-coverage.json'
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
    Import-Module -Name $script:ManifestPath -Force -ErrorAction Stop
    $script:fixture = Get-Content -LiteralPath $script:FixturePath -Raw -Encoding utf8 | ConvertFrom-Json -Depth 30
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'Measure-FortiCNAPPAssetCoverage' {
    It 'returns the expected denominator-aware synthetic result' {
        $result = Measure-FortiCNAPPAssetCoverage `
            -ScopeRegister $script:fixture.scopeRegister `
            -ObservedAsset $script:fixture.observedAssets `
            -AsOfUtc ([DateTimeOffset]$script:fixture.asOfUtc) `
            -FreshnessThresholdHours $script:fixture.freshnessThresholdHours

        $result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.AssetCoverage'
        $result.IntendedAssetCount | Should -Be 8
        $result.CurrentAssetCount | Should -Be 6
        $result.StaleAssetCount | Should -Be 1
        $result.MissingAssetCount | Should -Be 1
        $result.ExcludedAssetCount | Should -Be 1
        $result.UnexpectedAssetCount | Should -Be 1
        $result.DuplicateAssetCount | Should -Be 1
        $result.CoveragePercent | Should -Be 75
        $result.CoverageDenominator | Should -Be 'Included scope assets'
        $result.CalculationAuthority | Should -Be 'PowerShellDerived'
    }

    It 'uses the latest observation when duplicate observations exist' {
        $result = Measure-FortiCNAPPAssetCoverage `
            -ScopeRegister $script:fixture.scopeRegister `
            -ObservedAsset $script:fixture.observedAssets `
            -AsOfUtc ([DateTimeOffset]$script:fixture.asOfUtc) `
            -FreshnessThresholdHours 24

        $awsRecord = $result.CurrentAssets |
            Where-Object AssetId -EQ 'syn-aws-ec2-01' |
            Select-Object -First 1

        $awsRecord.SourceRecordId | Should -Be 'obs-001'
        $result.DuplicateAssets[0].ObservationCount | Should -Be 2
    }

    It 'returns null coverage for an empty included denominator' {
        $scope = @(
            [pscustomobject]@{
                scopeId = 'excluded-01'
                assetId = 'asset-01'
                platform = 'AWS'
                included = $false
            }
        )

        $result = Measure-FortiCNAPPAssetCoverage `
            -ScopeRegister $scope `
            -ObservedAsset @() `
            -AsOfUtc ([DateTimeOffset]'2026-08-23T18:00:00Z')

        $result.IntendedAssetCount | Should -Be 0
        $result.CoveragePercent | Should -BeNullOrEmpty
    }

    It 'rejects an ambiguous observation timestamp' {
        $observation = @(
            [pscustomobject]@{
                sourceRecordId = 'obs-invalid'
                assetId = 'asset-01'
                platform = 'AWS'
                observedAtUtc = '2026-08-23 17:00:00'
            }
        )

        {
            Measure-FortiCNAPPAssetCoverage `
                -ScopeRegister $script:fixture.scopeRegister `
                -ObservedAsset $observation `
                -AsOfUtc ([DateTimeOffset]$script:fixture.asOfUtc)
        } | Should -Throw -ExpectedMessage '*explicit UTC offset*'
    }
}
