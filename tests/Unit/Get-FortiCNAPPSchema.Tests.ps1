# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

BeforeAll {
    $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
    $script:ManifestPath = Join-Path -Path $script:RepositoryRoot -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
    Import-Module -Name $script:ManifestPath -Force -ErrorAction Stop
    $script:session = [pscustomobject]@{ SessionId = 'synthetic-session' }
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'Get-FortiCNAPPSchema' {
    It 'returns a typed tenant-dependent schema result' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPRequest -MockWith {
            [pscustomobject]@{
                StatusCode = 200
                Data = @([pscustomobject]@{ name = 'createdTime'; type = 'integer' })
                CorrelationId = 'syn-schema-001'
                RequestUri = [uri]'https://tenant.example.invalid/api/v2/schemas/AuditLogs'
            }
        }

        $result = Get-FortiCNAPPSchema -Session $script:session -Type AuditLogs

        $result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.SchemaResult'
        $result.Type | Should -Be 'AuditLogs'
        $result.Schema[0].name | Should -Be 'createdTime'
        $result.TenantValidationState | Should -Be 'VERIFY IN TENANT'
        $result.AdditionalPropertiesAllowed | Should -BeTrue
    }

    It 'uses the subtype path' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPRequest -MockWith {
            param($Session, $Method, $Path)
            $script:observedPath = $Path
            [pscustomobject]@{
                StatusCode = 200
                Data = @()
                CorrelationId = $null
                RequestUri = [uri]('https://tenant.example.invalid/api/v2/' + $Path)
            }
        }

        Get-FortiCNAPPSchema -Session $script:session -Type AlertChannels -Subtype SlackChannel | Out-Null

        $script:observedPath | Should -Be 'schemas/AlertChannels/SlackChannel'
    }

    It 'requires Type when Subtype is supplied' {
        {
            Get-FortiCNAPPSchema -Session $script:session -Subtype SlackChannel
        } | Should -Throw -ExpectedMessage '*Type is required*'
    }
}
