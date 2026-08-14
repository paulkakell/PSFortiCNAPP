# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'PSFortiCNAPP module manifest contract' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:ManifestPath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
        $script:Manifest = Test-ModuleManifest `
            -Path $script:ManifestPath `
            -ErrorAction Stop
    }

    It 'uses the initial semantic version' {
        $script:Manifest.Version | Should -Be ([version]'0.1.0')
    }

    It 'requires PowerShell 7.6 and the Core edition' {
        $script:Manifest.PowerShellVersion |
            Should -Be ([version]'7.6')
        $script:Manifest.CompatiblePSEditions |
            Should -Contain 'Core'
    }

    It 'exports exactly the approved Chapter 4 functions' {
        $functions = @(
            $script:Manifest.ExportedFunctions.Keys |
                Sort-Object
        )

        $functions | Should -HaveCount 4
        $functions |
            Should -Contain 'ConvertFrom-FortiCNAPPHttpExchange'
        $functions |
            Should -Contain 'ConvertTo-FortiCNAPPEvidenceRecord'
        $functions |
            Should -Contain 'Get-FortiCNAPPModuleInfo'
        $functions |
            Should -Contain 'Test-FortiCNAPPEnvironment'
    }

    It 'contains project and license metadata' {
        $script:Manifest.PrivateData.PSData.ProjectUri |
            Should -Be 'https://github.com/paulkakell/PSFortiCNAPP'
        $script:Manifest.PrivateData.PSData.LicenseUri |
            Should -Match '/LICENSE$'
    }
}
