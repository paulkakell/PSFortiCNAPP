# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 1 manuscript contract' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:ChapterPath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'manuscript/chapters/01-FORTICNAPP-AND-THE-CLOUD-RISK-PROBLEM.md'
        $script:SourceRegisterPath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'docs/source-register/CHAPTER-01.md'
        $script:Chapter = Get-Content -LiteralPath $script:ChapterPath -Raw -Encoding utf8
        $script:SourceRegister = Get-Content -LiteralPath $script:SourceRegisterPath -Raw -Encoding utf8
    }

    It 'uses the manuscript license identifier' {
        $script:Chapter | Should -Match 'SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript'
    }

    It 'contains the approved twenty-part chapter anatomy' {
        $sectionNumbers = @(
            [regex]::Matches($script:Chapter, '(?m)^##\s+(?<Number>\d+)\.') |
                ForEach-Object -Process { [int]$_.Groups['Number'].Value }
        )

        $sectionNumbers | Should -Be @(1..20)
    }

    It 'stays within the Chapter 1 production word range' {
        $words = [regex]::Matches($script:Chapter, "[\p{L}\p{N}][\p{L}\p{N}'-]*")
        $words.Count | Should -BeGreaterOrEqual 4500
        $words.Count | Should -BeLessOrEqual 9000
    }

    It 'labels the runnable output as synthetic' {
        $script:Chapter | Should -Match 'Evidence label:\s+`SYNTHETIC`'
    }

    It 'does not claim that tenant verification is complete' {
        $script:Chapter | Should -Match 'VERIFY IN TENANT'
        $script:Chapter | Should -Match 'No tenant-dependent verification item is closed by Chapter 1'
    }

    It 'records all Chapter 1 primary source identifiers' {
        foreach ($sourceNumber in 1..11) {
            $sourceId = 'C1-S{0:d3}' -f $sourceNumber
            $script:SourceRegister | Should -Match ([regex]::Escape($sourceId))
        }
    }

    It 'uses the project terminology at first substantive reference' {
        $script:Chapter | Should -Match 'FortiCNAPP, formerly Lacework'
    }
}
