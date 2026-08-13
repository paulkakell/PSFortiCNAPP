# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 1 public companion contract' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:Notice = Get-Content -LiteralPath (Join-Path $root 'manuscript/chapters/01-FORTICNAPP-AND-THE-CLOUD-RISK-PROBLEM.md') -Raw -Encoding utf8
        $script:Notes = Get-Content -LiteralPath (Join-Path $root 'manuscript/chapters/01-FORTICNAPP-CLOUD-RISK-PRODUCTION-NOTES.md') -Raw -Encoding utf8
        $script:Sources = Get-Content -LiteralPath (Join-Path $root 'docs/source-register/CHAPTER-01.md') -Raw -Encoding utf8
        $script:Fixture = Get-Content -LiteralPath (Join-Path $root 'tests/Fixtures/Synthetic/chapter-01-scope-register.json') -Raw -Encoding utf8 | ConvertFrom-Json -Depth 20
    }

    It 'publishes a notice instead of the complete chapter' {
        $script:Notice | Should -Match 'Publishing Asset Notice'
        $script:Notice | Should -Match 'maintained outside the active public tree'
        [regex]::Matches($script:Notice, "[\p{L}\p{N}][\p{L}\p{N}'-]*").Count | Should -BeLessThan 250
    }

    It 'retains the Chapter 1 companion artifacts' {
        $script:Notes | Should -Match 'Five scopes in the denominator'
        $script:Fixture.dataClassification | Should -Be 'Synthetic'
    }

    It 'records all Chapter 1 primary source identifiers' {
        foreach ($number in 1..11) {
            $script:Sources | Should -Match ('C1-S{0:d3}' -f $number)
        }
    }

    It 'keeps tenant-dependent behavior unresolved' {
        $script:Notes | Should -Match 'VERIFY IN TENANT'
    }
}
