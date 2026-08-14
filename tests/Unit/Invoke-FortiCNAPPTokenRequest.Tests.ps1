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

Describe 'Invoke-FortiCNAPPTokenRequest private contract' {
    It 'sends an explicit key identifier and expiry time' {
        InModuleScope PSFortiCNAPP {
            $configuration = [pscustomobject]@{
                KeyId                = 'SYNTHETIC_KEY_4001'
                TokenLifetimeSeconds = 900
                TokenEndpoint        = [uri]'https://tenant.example.invalid/api/v2/access/tokens'
            }
            $secret = ConvertTo-SecureString `
                -String 'synthetic-secret-value' `
                -AsPlainText `
                -Force
            $script:capturedRequest = $null

            Mock Invoke-RestMethod {
                param(
                    $Method,
                    $Uri,
                    $Headers,
                    $ContentType,
                    $Body,
                    $TimeoutSec,
                    $ErrorAction
                )
                $script:capturedRequest = [pscustomobject]@{
                    Method      = $Method
                    Uri         = $Uri
                    Headers     = $Headers
                    ContentType = $ContentType
                    Body        = $Body
                    TimeoutSec  = $TimeoutSec
                }
                [pscustomobject]@{
                    token     = 'synthetic-token'
                    expiresAt = [DateTimeOffset]::UtcNow.AddMinutes(15).ToString('o')
                }
            }

            $result = Invoke-FortiCNAPPTokenRequest `
                -Configuration $configuration `
                -Secret $secret `
                -TimeoutSeconds 12
            $body = $script:capturedRequest.Body |
                ConvertFrom-Json

            $result.token | Should -Be 'synthetic-token'
            $script:capturedRequest.Method | Should -Be 'Post'
            $script:capturedRequest.Uri.AbsoluteUri |
                Should -Be 'https://tenant.example.invalid/api/v2/access/tokens'
            $script:capturedRequest.ContentType |
                Should -Be 'application/json'
            $script:capturedRequest.TimeoutSec | Should -Be 12
            $body.keyId | Should -Be 'SYNTHETIC_KEY_4001'
            $body.expiryTime | Should -Be 900
            $script:capturedRequest.Headers.Authorization |
                Should -Be 'Bearer synthetic-secret-value'
        }
    }

    It 'returns a sanitized error for a failed request' {
        InModuleScope PSFortiCNAPP {
            $configuration = [pscustomobject]@{
                KeyId                = 'SYNTHETIC_KEY_4002'
                TokenLifetimeSeconds = 900
                TokenEndpoint        = [uri]'https://tenant.example.invalid/api/v2/access/tokens'
            }
            $secretText = 'synthetic-secret-value'
            $secret = ConvertTo-SecureString `
                -String $secretText `
                -AsPlainText `
                -Force

            Mock Invoke-RestMethod {
                throw [System.Net.Http.HttpRequestException]::new(
                    'Synthetic transport failure'
                )
            }

            $caught = $null
            try {
                Invoke-FortiCNAPPTokenRequest `
                    -Configuration $configuration `
                    -Secret $secret
            }
            catch {
                $caught = $_
            }

            $caught | Should -Not -BeNullOrEmpty
            $caught.Exception.Message |
                Should -Not -Match ([regex]::Escape($secretText))
            $caught.FullyQualifiedErrorId |
                Should -Match '^PSFortiCNAPP\.Authentication\.TokenRequestFailed'
        }
    }
}
