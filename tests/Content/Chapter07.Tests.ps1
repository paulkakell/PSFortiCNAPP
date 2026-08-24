# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 7 public companion content' {
    BeforeAll {
        $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:RequiredPaths = @(
            'docs/concepts/CHAPTER-07-ASSET-INVENTORY-PAGINATION-DATA-QUALITY.md'
            'docs/reference/ASSET-INVENTORY-AND-COVERAGE-CONTRACT.md'
            'docs/source-register/CHAPTER-07.md'
            'docs/chapter-map/chapter-07.md'
            'docs/project/CHAPTER-07-STATUS.md'
            'docs/verification/chapter-07-verification.json'
            'examples/chapter-07/Review-SyntheticAssetCoverage.ps1'
            'manuscript/chapters/07-ASSET-INVENTORY-PAGINATION-AND-DATA-QUALITY-PRODUCTION-NOTES.md'
        )
    }

    It 'contains every required public companion path' {
        foreach ($relativePath in $script:RequiredPaths) {
            Test-Path -LiteralPath (Join-Path $script:RepositoryRoot $relativePath) |
                Should -BeTrue -Because $relativePath
        }
    }

    It 'keeps the commercial manuscript outside the repository' {
        $chapterFiles = Get-ChildItem `
            -LiteralPath (Join-Path $script:RepositoryRoot 'manuscript/chapters') `
            -Filter '07-*' `
            -File

        $chapterFiles | Should -HaveCount 1
        $chapterFiles[0].Name | Should -Match 'PRODUCTION-NOTES'
    }

    It 'labels tenant-dependent inventory fields for verification' {
        $guide = Get-Content `
            -LiteralPath (Join-Path $script:RepositoryRoot 'docs/concepts/CHAPTER-07-ASSET-INVENTORY-PAGINATION-DATA-QUALITY.md') `
            -Raw

        $guide | Should -Match 'VERIFY IN TENANT'
        $guide | Should -Match 'Unnormalized'
        $guide | Should -Match '75 percent'
    }
}
