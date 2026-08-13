# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter file boundary' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:ChapterDirectory = Join-Path $root 'manuscript/chapters'
        $script:Boundary = Get-Content -LiteralPath (Join-Path $root 'docs/project/MANUSCRIPT-REPOSITORY-BOUNDARY.md') -Raw -Encoding utf8
    }

    It 'contains no complete chapter after Chapter 1' {
        $files = @(Get-ChildItem -LiteralPath $script:ChapterDirectory -File -Filter '*.md')
        $unexpected = @(
            $files |
                Where-Object {
                    $_.Name -match '^0[2-9]-' -and
                    $_.Name -notmatch '-PRODUCTION-NOTES\.md$'
                }
        )

        $unexpected.Count | Should -Be 0
    }

    It 'records the current boundary follow-up' {
        $script:Boundary | Should -Match 'GitHub issue #6'
    }
}
