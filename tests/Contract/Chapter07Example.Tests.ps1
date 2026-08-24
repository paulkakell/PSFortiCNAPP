# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 7 example contract' {
    BeforeAll {
        $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:ExamplePath = Join-Path -Path $script:RepositoryRoot -ChildPath 'examples/chapter-07/Review-SyntheticAssetCoverage.ps1'
        $script:Result = & $script:ExamplePath
    }

    It 'returns the asset coverage type' {
        $script:Result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.AssetCoverage'
    }

    It 'reproduces the expected synthetic result' {
        $script:Result.IntendedAssetCount | Should -Be 8
        $script:Result.CurrentAssetCount | Should -Be 6
        $script:Result.StaleAssetCount | Should -Be 1
        $script:Result.MissingAssetCount | Should -Be 1
        $script:Result.ExcludedAssetCount | Should -Be 1
        $script:Result.UnexpectedAssetCount | Should -Be 1
        $script:Result.DuplicateAssetCount | Should -Be 1
        $script:Result.CoveragePercent | Should -Be 75
    }

    It 'labels the result as synthetic and PowerShell-derived' {
        $script:Result.DataClassification | Should -Be 'SYNTHETIC'
        $script:Result.CalculationAuthority | Should -Be 'PowerShellDerived'
        $script:Result.TenantValidationState | Should -Be 'NOT APPLICABLE'
    }
}
