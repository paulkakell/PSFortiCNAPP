# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Public repository manuscript boundary' {
    BeforeAll {
        $repositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:ChapterDirectory = Join-Path -Path $repositoryRoot -ChildPath 'manuscript/chapters'
        $script:BoundaryPath = Join-Path -Path $repositoryRoot -ChildPath 'docs/project/MANUSCRIPT-REPOSITORY-BOUNDARY.md'
    }

    It 'contains only production notes and the directory readme' {
        $unexpectedFiles = @(
            Get-ChildItem -LiteralPath $script:ChapterDirectory -File -Filter '*.md' |
                Where-Object {
                    $_.Name -ne 'README.md' -and
                    $_.Name -notmatch '-PRODUCTION-NOTES\.md$'
                }
        )

        $unexpectedFiles.FullName | Should -BeNullOrEmpty
    }

    It 'documents the public content boundary' {
        $boundary = Get-Content -LiteralPath $script:BoundaryPath -Raw -Encoding utf8
        $boundary | Should -Match 'complete commercial manuscript'
        $boundary | Should -Match 'earlier objects or commits from Git history'
    }
}
