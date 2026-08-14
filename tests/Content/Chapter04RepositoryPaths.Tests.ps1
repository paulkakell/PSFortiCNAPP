# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 4 repository path inventory' {
    BeforeAll {
        $script:Root = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
    }

    It 'contains every required public companion path' {
        $paths = @(
            'src/PSFortiCNAPP/Public/ConvertFrom-FortiCNAPPHttpExchange.ps1'
            'tests/Fixtures/Synthetic/chapter-04-http-exchanges.json'
            'examples/chapter-04/Review-SyntheticHttpExchanges.ps1'
            'docs/concepts/CHAPTER-04-HTTP-JSON-API-CONTRACTS.md'
            'docs/reference/HTTP-EXCHANGE-CONTRACT.md'
            'docs/source-register/CHAPTER-04.md'
            'docs/chapter-map/chapter-04.md'
            'manuscript/chapters/04-HTTP-JSON-AND-API-CONTRACTS-PRODUCTION-NOTES.md'
        )

        foreach ($path in $paths) {
            Test-Path -LiteralPath (Join-Path $script:Root $path) |
                Should -BeTrue
        }
    }
}
