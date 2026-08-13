# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 2 manuscript contract' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:ChapterPath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'manuscript/chapters/02-STARTING-SECURELY-WITH-POWERSHELL-7.md'
        $script:SourceRegisterPath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'docs/source-register/CHAPTER-02.md'
        $script:ChecklistPath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'docs/getting-started/CHAPTER-02-SETUP-CHECKLIST.md'
        $script:Chapter = Get-Content -LiteralPath $script:ChapterPath -Raw -Encoding utf8
        $script:SourceRegister = Get-Content -LiteralPath $script:SourceRegisterPath -Raw -Encoding utf8
        $script:Checklist = Get-Content -LiteralPath $script:ChecklistPath -Raw -Encoding utf8
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

    It 'stays within the Chapter 2 production word range' {
        $words = [regex]::Matches($script:Chapter, "[\p{L}\p{N}][\p{L}\p{N}'-]*")
        $words.Count | Should -BeGreaterOrEqual 5000
        $words.Count | Should -BeLessOrEqual 9000
    }

    It 'distinguishes PowerShell 7 from Windows PowerShell' {
        $script:Chapter | Should -Match 'pwsh'
        $script:Chapter | Should -Match 'powershell\.exe'
        $script:Chapter | Should -Match 'PSEdition'
    }

    It 'uses profile-independent execution for the lab' {
        $script:Chapter | Should -Match 'pwsh -NoProfile -File'
        $script:Chapter | Should -Match 'personal profile state'
    }

    It 'labels displayed readiness output as synthetic' {
        $script:Chapter | Should -Match 'Evidence label:\s+`SYNTHETIC`'
    }

    It 'keeps tenant work outside the chapter boundary' {
        $script:Chapter | Should -Match 'No FortiCNAPP tenant connection is made in this chapter'
        $script:Chapter | Should -Match 'VERIFY IN TENANT'
    }

    It 'records all Chapter 2 primary source identifiers' {
        foreach ($sourceNumber in 1..14) {
            $sourceId = 'C2-S{0:d3}' -f $sourceNumber
            $script:SourceRegister | Should -Match ([regex]::Escape($sourceId))
        }
    }

    It 'provides the canonical readiness command in the setup checklist' {
        $script:Checklist | Should -Match 'pwsh -NoProfile -File ./examples/foundations/Test-Environment\.ps1'
        $script:Checklist | Should -Match 'PSFortiCNAPP\.EnvironmentReadiness'
    }
}
