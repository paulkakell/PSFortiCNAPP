# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

BeforeAll {
    $script:RepositoryRoot = (
        Resolve-Path -LiteralPath (
            Join-Path -Path $PSScriptRoot -ChildPath '../..'
        )
    ).Path
    $script:ManifestPath = Join-Path `
        -Path $script:RepositoryRoot `
        -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'

    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
    Import-Module -Name $script:ManifestPath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'PSFortiCNAPP module foundation' {
    It 'imports under the approved module name' {
        $module = Get-Module -Name PSFortiCNAPP
        $module | Should -Not -BeNullOrEmpty
        $module.Name | Should -Be 'PSFortiCNAPP'
    }

    It 'exports only the approved Chapter 5 commands' {
        $commands = @(
            Get-Command -Module PSFortiCNAPP |
                Select-Object -ExpandProperty Name |
                Sort-Object
        )
        $expected = @(
            'Connect-FortiCNAPP'
            'ConvertFrom-FortiCNAPPHttpExchange'
            'ConvertTo-FortiCNAPPEvidenceRecord'
            'Disconnect-FortiCNAPP'
            'Get-FortiCNAPPContext'
            'Get-FortiCNAPPModuleInfo'
            'New-FortiCNAPPConfiguration'
            'Test-FortiCNAPPConfiguration'
            'Test-FortiCNAPPEnvironment'
        ) | Sort-Object

        $commands | Should -HaveCount 9
        $commands | Should -Be $expected
    }

    It 'returns typed module information without a network call' {
        $result = Get-FortiCNAPPModuleInfo

        $result.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.ModuleInfo'
        $result.Name | Should -Be 'PSFortiCNAPP'
        $result.Version | Should -Be ([version]'0.1.0')
        $result.MinimumPowerShellVersion |
            Should -Be ([version]'7.6.0')
        $result.Distribution | Should -Be 'GitHub Releases'
        $result.ProjectUri.AbsoluteUri |
            Should -Be 'https://github.com/paulkakell/PSFortiCNAPP'
        $result.IsDevelopmentVersion | Should -BeTrue
    }

    It 'does not expose credential-shaped properties in module information' {
        $propertyNames = @(
            Get-FortiCNAPPModuleInfo |
                Get-Member -MemberType NoteProperty |
                Select-Object -ExpandProperty Name
        )
        $joinedNames = $propertyNames -join ','

        $joinedNames |
            Should -Not -Match '(?i)secret|password|token|credential|api.?key'
    }
}
