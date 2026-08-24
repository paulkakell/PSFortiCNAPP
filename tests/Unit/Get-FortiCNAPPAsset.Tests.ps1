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

Describe 'Get-FortiCNAPPAsset' {
    BeforeEach {
        $script:observed = $null
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPRequest -MockWith {
            param(
                $Session,
                $Method,
                $Path,
                $Body,
                $AllPages,
                $MaxPageCount,
                $LogPath
            )

            $script:observed = [pscustomobject]@{
                Method       = $Method
                Path         = $Path
                Body         = $Body
                AllPages     = $AllPages
                MaxPageCount = $MaxPageCount
                LogPath      = $LogPath
            }

            [pscustomobject]@{
                EnvironmentName       = 'Synthetic'
                AccountName           = 'tenant-example'
                PageCount             = 2
                RecordCount           = 2
                CollectionComplete    = $true
                CorrelationId         = 'syn-correlation-07'
                RateLimitLimit        = 480
                RateLimitRemaining    = 479
                RateLimitResetSeconds = 60
                Data = @(
                    [pscustomobject]@{ syntheticId = 'asset-001' }
                    [pscustomobject]@{ syntheticId = 'asset-002' }
                )
            }
        }
    }

    It 'builds the documented inventory request shape and returns a typed result' {
        $result = Get-FortiCNAPPAsset `
            -Session $script:session `
            -StartTimeUtc ([DateTimeOffset]'2026-08-23T00:00:00Z') `
            -EndTimeUtc ([DateTimeOffset]'2026-08-23T01:00:00Z') `
            -PageSize 250 `
            -Return @('resourceId', 'resourceType') `
            -Filter @([pscustomobject]@{ field = 'csp'; expression = 'eq'; value = 'AWS' }) `
            -Sort @([pscustomobject]@{ field = 'resourceId'; direction = 'asc' }) `
            -MaxPageCount 12 `
            -LogPath 'synthetic-log.jsonl'

        $result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.AssetInventoryResult'
        $result.RecordCount | Should -Be 2
        $result.PageCount | Should -Be 2
        $result.CollectionComplete | Should -BeTrue
        $result.ProviderRecordShape | Should -Be 'Unnormalized'
        $result.TenantValidationState | Should -Be 'VERIFY IN TENANT'
        $result.SensitiveValuesExposed | Should -BeFalse
        $result.RateLimit.Limit | Should -Be 480
        $result.RateLimit.Remaining | Should -Be 479
        $result.RateLimit.ResetSeconds | Should -Be 60

        $script:observed.Method | Should -Be 'POST'
        $script:observed.Path | Should -Be 'Inventory/search'
        $script:observed.AllPages | Should -BeTrue
        $script:observed.MaxPageCount | Should -Be 12
        $script:observed.Body.timeFilter.startTime | Should -Be 1787443200000
        $script:observed.Body.timeFilter.endTime | Should -Be 1787446800000
        $script:observed.Body.pageFilter.rows | Should -Be 250
        $script:observed.Body.returns | Should -Be @('resourceId', 'resourceType')
        $script:observed.Body.filters[0].field | Should -Be 'csp'
    }

    It 'rejects a reversed collection window before transport' {
        {
            Get-FortiCNAPPAsset `
                -Session $script:session `
                -StartTimeUtc ([DateTimeOffset]'2026-08-23T02:00:00Z') `
                -EndTimeUtc ([DateTimeOffset]'2026-08-23T01:00:00Z')
        } | Should -Throw -ExpectedMessage '*later than StartTimeUtc*'

        Should -Invoke -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPRequest -Times 0
    }

    It 'rejects a malformed local time field before transport' {
        {
            Get-FortiCNAPPAsset `
                -Session $script:session `
                -StartTimeUtc ([DateTimeOffset]'2026-08-23T00:00:00Z') `
                -EndTimeUtc ([DateTimeOffset]'2026-08-23T01:00:00Z') `
                -TimeField 'created time; remove'
        } | Should -Throw -ExpectedMessage '*unsupported local shape*'

        Should -Invoke -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPRequest -Times 0
    }
}
