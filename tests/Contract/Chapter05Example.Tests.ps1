# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 5 synthetic authentication example' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:ExamplePath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'examples/chapter-05/Review-SyntheticAuthenticationProfiles.ps1'
    }

    It 'returns the designed synthetic totals' {
        $result = & $script:ExamplePath

        $result.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.SyntheticAuthenticationProfileSummary'
        $result.DataClassification | Should -Be 'SYNTHETIC'
        $result.ProfileCount | Should -Be 5
        $result.ValidProfileCount | Should -Be 2
        $result.InvalidProfileCount | Should -Be 3
        $result.ExpectedMatchCount | Should -Be 5
        $result.AllExpectationsMet | Should -BeTrue
    }

    It 'makes no live request and includes no secret count' {
        $result = & $script:ExamplePath

        $result.LiveRequestCount | Should -Be 0
        $result.SecretValueCount | Should -Be 0
    }
}
