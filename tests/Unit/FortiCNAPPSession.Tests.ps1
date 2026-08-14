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

    function New-TestConfiguration {
        New-FortiCNAPPConfiguration `
            -AccountName 'training' `
            -KeyId 'SYNTHETIC_KEY_3001' `
            -EnvironmentName 'Synthetic Test' `
            -BaseUri 'https://tenant.example.invalid/' `
            -TokenLifetimeSeconds 900
    }

    function New-TestSecret {
        ConvertTo-SecureString `
            -String 'synthetic-secret-value' `
            -AsPlainText `
            -Force
    }
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'Connect-FortiCNAPP' {
    BeforeEach {
        Mock `
            -ModuleName PSFortiCNAPP `
            -CommandName Invoke-FortiCNAPPTokenRequest `
            -MockWith {
                [pscustomobject]@{
                    token     = 'synthetic-temporary-token'
                    expiresAt = [DateTimeOffset]::UtcNow.AddMinutes(15).ToString('o')
                }
            }
    }

    It 'returns a typed session without sensitive properties' {
        $session = Connect-FortiCNAPP `
            -Configuration (New-TestConfiguration) `
            -Secret (New-TestSecret) `
            -Confirm:$false

        $session.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.Session'
        $session.IsConnected | Should -BeTrue
        $session.BaseUri.AbsoluteUri |
            Should -Be 'https://tenant.example.invalid/'
        $session.KeyIdDisplay | Should -Be '****3001'
        $session.PSObject.Properties.Name -join ',' |
            Should -Not -Match '(?i)access.?token|bearer|secret|password'
    }

    It 'returns safe context with remaining lifetime' {
        $session = Connect-FortiCNAPP `
            -Configuration (New-TestConfiguration) `
            -Secret (New-TestSecret) `
            -Confirm:$false

        $context = Get-FortiCNAPPContext -Session $session

        $context.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.Context'
        $context.IsConnected | Should -BeTrue
        $context.IsExpired | Should -BeFalse
        $context.ReadyForRequest | Should -BeTrue
        $context.RemainingSeconds | Should -BeGreaterThan 0
        $context.SensitiveValuesExposed | Should -BeFalse
    }

    It 'does not request a token under WhatIf' {
        $result = Connect-FortiCNAPP `
            -Configuration (New-TestConfiguration) `
            -Secret (New-TestSecret) `
            -WhatIf

        $result | Should -BeNullOrEmpty
        Should `
            -Invoke `
            -ModuleName PSFortiCNAPP `
            -CommandName Invoke-FortiCNAPPTokenRequest `
            -Times 0
    }

    It 'rejects a malformed token response' {
        Mock `
            -ModuleName PSFortiCNAPP `
            -CommandName Invoke-FortiCNAPPTokenRequest `
            -MockWith {
                [pscustomobject]@{
                    unexpected = 'synthetic'
                }
            }

        {
            Connect-FortiCNAPP `
                -Configuration (New-TestConfiguration) `
                -Secret (New-TestSecret) `
                -Confirm:$false
        } | Should -Throw -ExpectedMessage '*required token and expiresAt*'
    }

    It 'rejects an already expired response' {
        Mock `
            -ModuleName PSFortiCNAPP `
            -CommandName Invoke-FortiCNAPPTokenRequest `
            -MockWith {
                [pscustomobject]@{
                    token     = 'synthetic-expired-token'
                    expiresAt = [DateTimeOffset]::UtcNow.AddMinutes(-1).ToString('o')
                }
            }

        {
            Connect-FortiCNAPP `
                -Configuration (New-TestConfiguration) `
                -Secret (New-TestSecret) `
                -Confirm:$false
        } | Should -Throw -ExpectedMessage '*already expired*'
    }
}

Describe 'Disconnect-FortiCNAPP' {
    BeforeEach {
        Mock `
            -ModuleName PSFortiCNAPP `
            -CommandName Invoke-FortiCNAPPTokenRequest `
            -MockWith {
                [pscustomobject]@{
                    token     = 'synthetic-temporary-token'
                    expiresAt = [DateTimeOffset]::UtcNow.AddMinutes(15).ToString('o')
                }
            }
    }

    It 'removes local session state without claiming remote revocation' {
        $session = Connect-FortiCNAPP `
            -Configuration (New-TestConfiguration) `
            -Secret (New-TestSecret) `
            -Confirm:$false

        $result = Disconnect-FortiCNAPP `
            -Session $session `
            -Confirm:$false
        $context = Get-FortiCNAPPContext -Session $session

        $result.Disconnected | Should -BeTrue
        $result.RemoteTokenRevoked | Should -BeFalse
        $result.SensitiveValuesExposed | Should -BeFalse
        $context.IsConnected | Should -BeFalse
        $context.ReadyForRequest | Should -BeFalse
    }

    It 'preserves local state under WhatIf' {
        $session = Connect-FortiCNAPP `
            -Configuration (New-TestConfiguration) `
            -Secret (New-TestSecret) `
            -Confirm:$false

        $result = Disconnect-FortiCNAPP `
            -Session $session `
            -WhatIf
        $context = Get-FortiCNAPPContext -Session $session

        $result.Disconnected | Should -BeFalse
        $context.IsConnected | Should -BeTrue
    }
}
