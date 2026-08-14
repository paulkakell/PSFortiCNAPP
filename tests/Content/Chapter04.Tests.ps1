# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 4 public companion contract' {
    BeforeAll {
        $root = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path

        $script:Guide = Get-Content `
            -LiteralPath (
                Join-Path $root 'docs/concepts/CHAPTER-04-HTTP-JSON-API-CONTRACTS.md'
            ) `
            -Raw `
            -Encoding utf8
        $script:Sources = Get-Content `
            -LiteralPath (
                Join-Path $root 'docs/source-register/CHAPTER-04.md'
            ) `
            -Raw `
            -Encoding utf8
        $script:Notes = Get-Content `
            -LiteralPath (
                Join-Path $root 'manuscript/chapters/04-HTTP-JSON-AND-API-CONTRACTS-PRODUCTION-NOTES.md'
            ) `
            -Raw `
            -Encoding utf8
    }

    It 'records all twelve source identifiers' {
        foreach ($number in 1..12) {
            $script:Sources |
                Should -Match ('C4-S{0:d3}' -f $number)
        }
    }

    It 'states that the placeholder is not an endpoint' {
        $script:Guide |
            Should -Match 'not a FortiCNAPP endpoint'
        $script:Sources |
            Should -Match 'not a FortiCNAPP endpoint'
    }

    It 'documents the public command and output types' {
        $script:Guide |
            Should -Match 'ConvertFrom-FortiCNAPPHttpExchange'
        $script:Guide |
            Should -Match 'PSFortiCNAPP\.HttpExchange'
        $script:Guide |
            Should -Match 'PSFortiCNAPP\.SyntheticHttpContractSummary'
    }

    It 'preserves the no-network and no-tenant boundary' {
        $script:Notes |
            Should -Match 'Verified FortiCNAPP endpoints: none'
        $script:Notes |
            Should -Match 'The command does not make an HTTP request'
        $script:Notes |
            Should -Match 'Tenant-dependent behavior remains `VERIFY IN TENANT`'
    }

    It 'keeps the complete commercial manuscript outside the repository' {
        $script:Guide |
            Should -Match 'not the commercial chapter manuscript'
        $script:Notes |
            Should -Match 'complete commercial manuscript is maintained outside'
    }
}
