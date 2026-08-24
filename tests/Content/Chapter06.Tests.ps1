# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 6 public companion content' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:guidePath = Join-Path $root 'docs/concepts/CHAPTER-06-PRODUCTION-API-CLIENT.md'
        $script:sourcePath = Join-Path $root 'docs/source-register/CHAPTER-06.md'
        $script:notesPath = Join-Path $root 'manuscript/chapters/06-PRODUCTION-QUALITY-API-CLIENT-PRODUCTION-NOTES.md'
        $script:guide = Get-Content -LiteralPath $script:guidePath -Raw
        $script:source = Get-Content -LiteralPath $script:sourcePath -Raw
        $script:notes = Get-Content -LiteralPath $script:notesPath -Raw
    }

    It 'documents both Chapter 6 public commands' {
        $script:guide | Should -Match 'Invoke-FortiCNAPPRequest'
        $script:guide | Should -Match 'Get-FortiCNAPPSchema'
    }

    It 'records tenant-dependent limitations' {
        $script:guide | Should -Match 'VERIFY IN TENANT'
        $script:source | Should -Match 'controlled tenant validation remains open'
    }

    It 'keeps the commercial manuscript outside the public repository' {
        $script:guide | Should -Match 'not the commercial manuscript'
        $script:notes.Length | Should -BeLessThan 7000
    }
}
