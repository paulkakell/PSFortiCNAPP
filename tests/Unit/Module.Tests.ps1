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

Describe 'PSFortiCNAPP module foundation' {
    It 'imports under the approved module name' {
        $module = Get-Module -Name PSFortiCNAPP
        $module | Should -Not -BeNullOrEmpty
        $module.Name | Should -Be 'PSFortiCNAPP'
    }

    It 'exports only the approved Chapter 7 commands' {
        $commands = @(Get-Command -Module PSFortiCNAPP | Select-Object -ExpandProperty Name | Sort-Object)
        $commands | Should -HaveCount 13
        $commands | Should -Contain 'Get-FortiCNAPPAsset'
        $commands | Should -Contain 'Measure-FortiCNAPPAssetCoverage'
        $commands | Should -Contain 'Invoke-FortiCNAPPRequest'
        $commands | Should -Contain 'Get-FortiCNAPPSchema'
    }

    It 'has one canonical definition for every exported command' {
        $publicPath = Join-Path $script:RepositoryRoot 'src/PSFortiCNAPP/Public'
        $definitions = Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' -File |
            ForEach-Object {
                $text = Get-Content -LiteralPath $_.FullName -Raw
                foreach ($match in [regex]::Matches($text, '(?im)^function\s+([A-Za-z0-9-]+)\s*\{')) {
                    [pscustomobject]@{ Name = $match.Groups[1].Value; Path = $_.FullName }
                }
            }

        foreach ($command in Get-Command -Module PSFortiCNAPP) {
            @($definitions | Where-Object Name -EQ $command.Name) | Should -HaveCount 1
        }
    }

    It 'returns typed module information without a network call' {
        $result = Get-FortiCNAPPModuleInfo
        $result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.ModuleInfo'
        $result.Name | Should -Be 'PSFortiCNAPP'
        $result.Version | Should -Be ([version]'0.1.0')
        $result.Distribution | Should -Be 'GitHub Releases'
    }

    It 'does not expose credential-shaped properties in module information' {
        $propertyNames = @(Get-FortiCNAPPModuleInfo | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
        $propertyNames -join ',' | Should -Not -Match '(?i)secret|password|token|credential|api.?key'
    }
}
