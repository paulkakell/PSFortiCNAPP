# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 4 synthetic HTTP contract example' {
    BeforeAll {
        $script:Root = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:ExamplePath = Join-Path `
            -Path $script:Root `
            -ChildPath 'examples/chapter-04/Review-SyntheticHttpExchanges.ps1'
    }

    It 'returns the expected typed summary' {
        $result = & $script:ExamplePath

        $result.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.SyntheticHttpContractSummary'
        $result.DataClassification | Should -Be 'SYNTHETIC'
        $result.ExchangeCount | Should -Be 6
        $result.SuccessCount | Should -Be 4
        $result.ValidContractCount | Should -Be 3
        $result.WarningContractCount | Should -Be 2
        $result.InvalidContractCount | Should -Be 1
    }

    It 'keeps malformed and unsupported bodies visible' {
        $result = & $script:ExamplePath

        $result.ContractIssueExchanges.ExchangeId |
            Should -Contain 'syn-http-200-malformed-json'
        $result.ContractIssueExchanges.ExchangeId |
            Should -Contain 'syn-http-503-html'
        $result.ContractIssueExchanges.ExchangeId |
            Should -Contain 'syn-http-200-text'
    }

    It 'does not return a query value or raw response body' {
        $result = & $script:ExamplePath
        $serialized = $result | ConvertTo-Json -Depth 20

        $serialized | Should -Not -Match 'synthetic-cursor'
        $serialized | Should -Not -Match 'Synthetic upstream service page'
    }
}
