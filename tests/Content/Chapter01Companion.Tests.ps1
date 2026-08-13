# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 1 companion artifacts' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:Notes = Get-Content -LiteralPath (Join-Path $root 'manuscript/chapters/01-FORTICNAPP-CLOUD-RISK-PRODUCTION-NOTES.md') -Raw -Encoding utf8
        $script:Sources = Get-Content -LiteralPath (Join-Path $root 'docs/source-register/CHAPTER-01.md') -Raw -Encoding utf8
        $script:Fixture = Get-Content -LiteralPath (Join-Path $root 'tests/Fixtures/Synthetic/chapter-01-scope-register.json') -Raw -Encoding utf8 | ConvertFrom-Json -Depth 20
    }

    It 'keeps the fixture synthetic' {
        $script:Fixture.dataClassification | Should -Be 'Synthetic'
    }

    It 'records the eleven source identifiers' {
        foreach ($number in 1..11) {
            $script:Sources | Should -Match ('C1-S{0:d3}' -f $number)
        }
    }

    It 'preserves denominator and evidence-state distinctions' {
        $script:Notes | Should -Match 'Five scopes in the denominator'
        $script:Notes | Should -Match 'missing scope'
        $script:Notes | Should -Match 'stale scope'
    }

    It 'keeps tenant behavior unresolved' {
        $script:Notes | Should -Match 'VERIFY IN TENANT'
    }
}
