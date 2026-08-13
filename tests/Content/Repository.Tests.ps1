# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Repository content controls' {
    BeforeAll {
        $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
    }

    It 'contains no prohibited U+2014 characters' {
        $scanner = Join-Path -Path $script:RepositoryRoot -ChildPath 'tools/Test-ProhibitedCharacters.ps1'
        { & $scanner -Path $script:RepositoryRoot | Out-Null } | Should -Not -Throw
    }

    It 'uses the expected SPDX license headers' {
        $scanner = Join-Path -Path $script:RepositoryRoot -ChildPath 'tools/Test-LicenseHeaders.ps1'
        { & $scanner -Path $script:RepositoryRoot | Out-Null } | Should -Not -Throw
    }

    It 'contains no recognized credential material' {
        $scanner = Join-Path -Path $script:RepositoryRoot -ChildPath 'tools/Test-RepositorySafety.ps1'
        { & $scanner -Path $script:RepositoryRoot | Out-Null } | Should -Not -Throw
    }
}
