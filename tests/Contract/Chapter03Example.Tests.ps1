# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 3 synthetic review example' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:ExamplePath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'examples/chapter-03/Review-SyntheticFindings.ps1'
        $script:FixturePath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'tests/Fixtures/Synthetic/chapter-03-findings.json'

        $script:Result = & $script:ExamplePath -Path $script:FixturePath
    }

    It 'returns the expected typed synthetic summary' {
        $script:Result.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.SyntheticFindingSummary'
        $script:Result.DataClassification | Should -Be 'SYNTHETIC'
        $script:Result.Organization |
            Should -Be 'Kestrel Vale Health Services'
    }

    It 'reports the designed counts and denominator' {
        $script:Result.TotalFindingCount | Should -Be 10
        $script:Result.OpenFindingCount | Should -Be 7
        $script:Result.CurrentPriorityCount | Should -Be 3
        $script:Result.StalePriorityCount | Should -Be 1
        $script:Result.CurrentPriorityRatePercent | Should -Be 42.86
        $script:Result.PriorityRateDenominator |
            Should -Be 'Open findings'
    }

    It 'retains current and stale records separately' {
        @($script:Result.CurrentPriorityRecords) | Should -HaveCount 3
        @($script:Result.StalePriorityRecords) | Should -HaveCount 1
        @(
            $script:Result.CurrentPriorityRecords |
                Where-Object -FilterScript {
                    -not $_.IsCurrentEvidence
                }
        ) | Should -HaveCount 0
        $script:Result.StalePriorityRecords[0].IsCurrentEvidence |
            Should -BeFalse
    }

    It 'returns normalized evidence records' {
        @($script:Result.Records) | Should -HaveCount 10
        foreach ($record in $script:Result.Records) {
            $record.PSObject.TypeNames[0] |
                Should -Be 'PSFortiCNAPP.EvidenceRecord'
            $record.DataClassification | Should -Be 'SYNTHETIC'
            $record.ObservedAtUtc.Offset | Should -Be ([TimeSpan]::Zero)
        }
    }
}
