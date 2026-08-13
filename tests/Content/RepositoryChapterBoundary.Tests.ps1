# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter file boundary' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:ChapterDirectory = Join-Path $root 'manuscript/chapters'
        $script:Boundary = Get-Content -LiteralPath (Join-Path $root 'docs/project/MANUSCRIPT-REPOSITORY-BOUNDARY.md') -Raw -Encoding utf8
    }

    It 'allows only short notices and production notes' {
        $numberedFiles = @(
            Get-ChildItem -LiteralPath $script:ChapterDirectory -File -Filter '*.md' |
                Where-Object {
                    $_.Name -match '^\d{2}-' -and
                    $_.Name -notmatch '-PRODUCTION-NOTES\.md$'
                }
        )

        foreach ($file in $numberedFiles) {
            $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
            $content | Should -Match 'Publishing Asset Notice'
            [regex]::Matches($content, "[\p{L}\p{N}][\p{L}\p{N}'-]*").Count | Should -BeLessThan 250
        }
    }

    It 'documents the active-tree and history distinction' {
        $script:Boundary | Should -Match 'active public tree contains no complete commercial chapter'
        $script:Boundary | Should -Match 'Earlier Git history is a separate review question'
    }
}
