# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

BeforeAll {
    $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
    $script:ManifestPath = Join-Path -Path $script:RepositoryRoot -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
    Import-Module -Name $script:ManifestPath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'Test-FortiCNAPPEnvironment' {
    It 'returns a ready typed result for a writable filesystem workspace' {
        $workspace = New-Item -ItemType Directory -Path (Join-Path -Path $TestDrive -ChildPath 'ready')
        $beforeNames = @(Get-ChildItem -LiteralPath $workspace.FullName -Force | Select-Object -ExpandProperty Name)

        $result = Test-FortiCNAPPEnvironment -WorkspacePath $workspace.FullName

        $afterNames = @(Get-ChildItem -LiteralPath $workspace.FullName -Force | Select-Object -ExpandProperty Name)
        $result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.EnvironmentReadiness'
        $result.Ready | Should -BeTrue
        $result.Complete | Should -BeTrue
        $result.FailCount | Should -Be 0
        $result.NotApplicableCount | Should -Be 0
        $result.CheckCount | Should -Be 5
        $result.Checks | Should -HaveCount 5
        ($beforeNames -join '|') | Should -Be ($afterNames -join '|')
        ($result.Checks | Where-Object -Property Name -EQ 'WorkspaceWrite').Status | Should -Be 'Pass'
    }

    It 'records a skipped write probe as NotApplicable' {
        $workspace = New-Item -ItemType Directory -Path (Join-Path -Path $TestDrive -ChildPath 'skip')

        $result = Test-FortiCNAPPEnvironment -WorkspacePath $workspace.FullName -SkipWriteTest
        $writeCheck = $result.Checks | Where-Object -Property Name -EQ 'WorkspaceWrite'

        $result.Ready | Should -BeTrue
        $result.Complete | Should -BeFalse
        $result.NotApplicableCount | Should -Be 1
        $writeCheck.Status | Should -Be 'NotApplicable'
        $result.Recommendations | Should -Contain 'Run again without SkipWriteTest before using workflows that create evidence or reports.'
    }

    It 'returns a failed readiness result for a missing workspace' {
        $missingPath = Join-Path -Path $TestDrive -ChildPath 'does-not-exist'

        $result = Test-FortiCNAPPEnvironment -WorkspacePath $missingPath
        $workspaceCheck = $result.Checks | Where-Object -Property Name -EQ 'WorkspacePath'
        $writeCheck = $result.Checks | Where-Object -Property Name -EQ 'WorkspaceWrite'

        $result.Ready | Should -BeFalse
        $result.Complete | Should -BeFalse
        $result.FailCount | Should -BeGreaterThan 0
        $workspaceCheck.Status | Should -Be 'Fail'
        $writeCheck.Status | Should -Be 'NotApplicable'
    }

    It 'returns a failed readiness result when the workspace path is a file' {
        $filePath = Join-Path -Path $TestDrive -ChildPath 'workspace.txt'
        Set-Content -LiteralPath $filePath -Value 'not a directory' -Encoding utf8NoBOM

        $result = Test-FortiCNAPPEnvironment -WorkspacePath $filePath
        $workspaceCheck = $result.Checks | Where-Object -Property Name -EQ 'WorkspacePath'

        $result.Ready | Should -BeFalse
        $workspaceCheck.Status | Should -Be 'Fail'
        $workspaceCheck.Message | Should -Match 'not a directory'
    }

    It 'makes the minimum-version check explicit' {
        $workspace = New-Item -ItemType Directory -Path (Join-Path -Path $TestDrive -ChildPath 'version')
        $futureVersion = [version]::new($PSVersionTable.PSVersion.Major + 1, 0)

        $result = Test-FortiCNAPPEnvironment -WorkspacePath $workspace.FullName -MinimumPowerShellVersion $futureVersion -SkipWriteTest
        $versionCheck = $result.Checks | Where-Object -Property Name -EQ 'PowerShellVersion'

        $result.Ready | Should -BeFalse
        $versionCheck.Status | Should -Be 'Fail'
        $versionCheck.Evidence | Should -Be $PSVersionTable.PSVersion.ToString()
    }
}
