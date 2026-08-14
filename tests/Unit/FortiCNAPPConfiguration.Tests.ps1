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

Describe 'New-FortiCNAPPConfiguration' {
    It 'creates a typed secret-free configuration' {
        $result = New-FortiCNAPPConfiguration `
            -AccountName 'training' `
            -KeyId 'SYNTHETIC_KEY_1001' `
            -EnvironmentName 'Synthetic Training' `
            -BaseUri 'https://tenant.example.invalid/' `
            -TokenLifetimeSeconds 900

        $result.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.Configuration'
        $result.BaseUri.AbsoluteUri |
            Should -Be 'https://tenant.example.invalid/'
        $result.TokenEndpoint.AbsoluteUri |
            Should -Be 'https://tenant.example.invalid/api/v2/access/tokens'
        $result.AuthenticationMode | Should -Be 'AccountApiKey'
        $result.TokenLifetimeSeconds | Should -Be 900
        $result.ContainsSecret | Should -BeFalse
        $result.KeyIdDisplay | Should -Be '****1001'
    }

    It 'derives the documented tenant-host pattern' {
        $result = New-FortiCNAPPConfiguration `
            -AccountName 'kestrel-training' `
            -KeyId 'SYNTHETIC_KEY_1002'

        $result.BaseUri.AbsoluteUri |
            Should -Be 'https://kestrel-training.lacework.net/'
    }

    It 'does not contain credential-shaped properties' {
        $result = New-FortiCNAPPConfiguration `
            -AccountName 'training' `
            -KeyId 'SYNTHETIC_KEY_1003' `
            -BaseUri 'https://tenant.example.invalid/'
        $propertyNames = @($result.PSObject.Properties.Name)

        $propertyNames -join ',' |
            Should -Not -Match '(?i)secret|password|access.?token|bearer'
    }

    It 'rejects an insecure base URI' {
        {
            New-FortiCNAPPConfiguration `
                -AccountName 'training' `
                -KeyId 'SYNTHETIC_KEY_1004' `
                -BaseUri 'http://tenant.example.invalid/'
        } | Should -Throw -ExpectedMessage '*absolute HTTPS URI*'
    }
}

Describe 'Test-FortiCNAPPConfiguration' {
    It 'returns a valid local result for a complete profile' {
        $profile = [pscustomobject]@{
            EnvironmentName      = 'Synthetic'
            AccountName          = 'training'
            BaseUri              = 'https://tenant.example.invalid/'
            TokenEndpoint        = 'https://tenant.example.invalid/api/v2/access/tokens'
            AuthenticationMode   = 'AccountApiKey'
            KeyId                = 'SYNTHETIC_KEY_2001'
            TokenLifetimeSeconds = 900
            ContainsSecret       = $false
        }

        $result = Test-FortiCNAPPConfiguration -Configuration $profile

        $result.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.ConfigurationValidation'
        $result.Valid | Should -BeTrue
        $result.FailCount | Should -Be 0
    }

    It 'rejects a missing key identifier' {
        $profile = [pscustomobject]@{
            EnvironmentName      = 'Synthetic'
            AccountName          = 'training'
            BaseUri              = 'https://tenant.example.invalid/'
            TokenEndpoint        = 'https://tenant.example.invalid/api/v2/access/tokens'
            KeyId                = ''
            TokenLifetimeSeconds = 900
        }

        $result = Test-FortiCNAPPConfiguration -Configuration $profile

        $result.Valid | Should -BeFalse
        $result.Checks |
            Where-Object Name -EQ 'KeyId' |
            Select-Object -ExpandProperty Status |
            Should -Be 'Fail'
    }

    It 'rejects an embedded secret-shaped property' {
        $profile = [pscustomobject]@{
            EnvironmentName      = 'Synthetic'
            AccountName          = 'training'
            BaseUri              = 'https://tenant.example.invalid/'
            TokenEndpoint        = 'https://tenant.example.invalid/api/v2/access/tokens'
            KeyId                = 'SYNTHETIC_KEY_2002'
            TokenLifetimeSeconds = 900
            ApiSecret            = 'synthetic-placeholder'
        }

        $result = Test-FortiCNAPPConfiguration -Configuration $profile

        $result.Valid | Should -BeFalse
    }

    It 'warns when the requested lifetime exceeds the project default' {
        $profile = [pscustomobject]@{
            EnvironmentName      = 'Synthetic'
            AccountName          = 'training'
            BaseUri              = 'https://tenant.example.invalid/'
            TokenEndpoint        = 'https://tenant.example.invalid/api/v2/access/tokens'
            KeyId                = 'SYNTHETIC_KEY_2003'
            TokenLifetimeSeconds = 7200
        }

        $result = Test-FortiCNAPPConfiguration -Configuration $profile

        $result.Valid | Should -BeTrue
        $result.WarningCount | Should -Be 1
    }
}
