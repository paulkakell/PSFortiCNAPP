# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 2 companion artifacts' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:Notes = Get-Content -LiteralPath (Join-Path $root 'manuscript/chapters/02-STARTING-SECURELY-WITH-POWERSHELL-7-PRODUCTION-NOTES.md') -Raw -Encoding utf8
        $script:Sources = Get-Content -LiteralPath (Join-Path $root 'docs/source-register/CHAPTER-02.md') -Raw -Encoding utf8
        $script:Checklist = Get-Content -LiteralPath (Join-Path $root 'docs/getting-started/CHAPTER-02-SETUP-CHECKLIST.md') -Raw -Encoding utf8
    }

    It 'records the fourteen source identifiers' {
        foreach ($number in 1..14) {
            $script:Sources | Should -Match ('C2-S{0:d3}' -f $number)
        }
    }

    It 'provides the canonical readiness command' {
        $script:Checklist | Should -Match 'pwsh -NoProfile -File ./examples/foundations/Test-Environment\.ps1'
        $script:Checklist | Should -Match 'PSFortiCNAPP\.EnvironmentReadiness'
    }

    It 'preserves runtime and profile cautions' {
        $script:Notes | Should -Match 'powershell\.exe'
        $script:Notes | Should -Match 'Profiles are not hidden production dependencies'
    }

    It 'keeps tenant work outside this chapter' {
        $script:Notes | Should -Match 'does not prove tenant access'
    }
}
