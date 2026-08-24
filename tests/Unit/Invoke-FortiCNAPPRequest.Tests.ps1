# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

BeforeAll {
    $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
    $script:ManifestPath = Join-Path -Path $script:RepositoryRoot -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
    Import-Module -Name $script:ManifestPath -Force -ErrorAction Stop

    function New-ConnectedSyntheticSession {
        InModuleScope PSFortiCNAPP {
            $sessionId = [guid]::NewGuid().ToString('N')
            $record = [pscustomobject]@{
                SessionId            = $sessionId
                EnvironmentName      = 'Synthetic Test'
                AccountName          = 'training'
                BaseUri              = [uri]'https://tenant.example.invalid/'
                AuthenticationMode   = 'AccountApiKey'
                KeyIdDisplay         = '****3001'
                ConnectedAtUtc       = [DateTimeOffset]::UtcNow
                ExpiresAtUtc         = [DateTimeOffset]::UtcNow.AddHours(1)
                TokenLifetimeSeconds = 3600
                AccessToken          = 'synthetic-private-bearer-token'
            }
            $script:FortiCNAPPSessionStore[$sessionId] = $record
            New-FortiCNAPPSessionObject -SessionRecord $record
        }
    }
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-FortiCNAPPRequest' {
    BeforeEach {
        $script:session = New-ConnectedSyntheticSession
        Mock -ModuleName PSFortiCNAPP -CommandName Start-Sleep
    }

    It 'returns a typed response without sensitive values' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            [pscustomobject]@{
                StatusCode = 200
                Headers = @{
                    'Content-Type' = 'application/json'
                    'X-Request-Id' = 'syn-request-001'
                    'RateLimit-Limit' = '480'
                    'RateLimit-Remaining' = '479'
                    'RateLimit-Reset' = '0'
                }
                Content = '{"data":[{"name":"synthetic"}]}'
            }
        }

        $result = Invoke-FortiCNAPPRequest -Session $script:session -Method GET -Path 'schemas/AuditLogs'

        $result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.ApiResponse'
        $result.StatusCode | Should -Be 200
        $result.RecordCount | Should -Be 1
        $result.CorrelationId | Should -Be 'syn-request-001'
        $result.RateLimit.Remaining | Should -Be '479'
        $result.RawResponseReturned | Should -BeFalse
        $result.SensitiveValuesExposed | Should -BeFalse
        $result.PSObject.Properties.Name -join ',' | Should -Not -Match '(?i)authorization|access.?token|bearer'
    }

    It 'sends query values but returns only query names' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            param($Uri, $Method, $Headers, $Body, $TimeoutSeconds)
            $script:observedUri = $Uri.AbsoluteUri
            [pscustomobject]@{ StatusCode = 200; Headers = @{}; Content = '{"data":[]}' }
        }

        $result = Invoke-FortiCNAPPRequest `
            -Session $script:session `
            -Method GET `
            -Path 'Alerts' `
            -Query @{ startTime = '2026-08-01T00:00:00Z'; status = 'Open' }

        $script:observedUri | Should -Match 'status=Open'
        $result.RequestUri.AbsoluteUri | Should -Be 'https://tenant.example.invalid/api/v2/Alerts'
        $result.QueryParameterNames | Should -Contain 'startTime'
        $result.QueryParameterNames | Should -Contain 'status'
        $result.RequestUri.AbsoluteUri | Should -Not -Match 'Open|2026-08-01'
    }

    It 'serializes a POST body' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            param($Uri, $Method, $Headers, $Body, $TimeoutSeconds)
            $script:observedBody = $Body
            [pscustomobject]@{ StatusCode = 200; Headers = @{}; Content = '{"data":[]}' }
        }

        Invoke-FortiCNAPPRequest `
            -Session $script:session `
            -Method POST `
            -Path 'Queries/validate' `
            -Body @{ queryText = 'synthetic query text' } | Out-Null

        ($script:observedBody | ConvertFrom-Json).queryText | Should -Be 'synthetic query text'
    }

    It 'retries a documented 429 response using Retry-After' {
        $script:attempt = 0
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            $script:attempt++
            if ($script:attempt -eq 1) {
                return [pscustomobject]@{
                    StatusCode = 429
                    Headers = @{ 'Retry-After' = '2'; 'Content-Type' = 'application/json' }
                    Content = '{"message":"synthetic rate limit"}'
                }
            }
            [pscustomobject]@{ StatusCode = 200; Headers = @{}; Content = '{"data":[1]}' }
        }

        $result = Invoke-FortiCNAPPRequest `
            -Session $script:session `
            -Method GET `
            -Path 'schemas' `
            -MaxRetryCount 2 `
            -JitterMaximumMilliseconds 0

        $result.Attempts | Should -HaveCount 2
        $result.Attempts[0].RetryDelaySeconds | Should -Be 2
        Should -Invoke -ModuleName PSFortiCNAPP -CommandName Start-Sleep -Times 1
    }

    It 'does not retry a 403 response' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            [pscustomobject]@{
                StatusCode = 403
                Headers = @{ 'Content-Type' = 'application/json' }
                Content = '{"message":"synthetic forbidden"}'
            }
        }

        {
            Invoke-FortiCNAPPRequest -Session $script:session -Method GET -Path 'schemas'
        } | Should -Throw -ExpectedMessage '*HTTP status 403*'

        Should -Invoke -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -Times 1
        Should -Invoke -ModuleName PSFortiCNAPP -CommandName Start-Sleep -Times 0
    }

    It 'retries a transport failure and then succeeds' {
        $script:attempt = 0
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            $script:attempt++
            if ($script:attempt -eq 1) { throw 'synthetic network failure' }
            [pscustomobject]@{ StatusCode = 200; Headers = @{}; Content = '{"data":[]}' }
        }

        $result = Invoke-FortiCNAPPRequest `
            -Session $script:session `
            -Method GET `
            -Path 'schemas' `
            -InitialRetryDelaySeconds 0.01 `
            -JitterMaximumMilliseconds 0

        $result.Attempts[0].Outcome | Should -Be 'TransportError'
        $result.Attempts[1].Outcome | Should -Be 'Success'
    }

    It 'aggregates validated continuation pages' {
        $script:attempt = 0
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            $script:attempt++
            if ($script:attempt -eq 1) {
                return [pscustomobject]@{
                    StatusCode = 200
                    Headers = @{}
                    Content = '{"paging":{"rows":1,"totalRows":2,"urls":{"nextPage":"https://tenant.example.invalid/api/v2/Inventory/syn-next"}},"data":[{"id":"one"}]}'
                }
            }
            [pscustomobject]@{ StatusCode = 200; Headers = @{}; Content = '{"data":[{"id":"two"}]}' }
        }

        $result = Invoke-FortiCNAPPRequest `
            -Session $script:session `
            -Method POST `
            -Path 'Inventory/search' `
            -Body @{ csp = 'AWS' } `
            -AllPages

        $result.PageCount | Should -Be 2
        $result.RecordCount | Should -Be 2
        $result.CollectionComplete | Should -BeTrue
        $result.Data[1].id | Should -Be 'two'
    }

    It 'rejects a continuation URI on another authority' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            [pscustomobject]@{
                StatusCode = 200
                Headers = @{}
                Content = '{"paging":{"urls":{"nextPage":"https://other.example.invalid/api/v2/Inventory/syn-next"}},"data":[{"id":"one"}]}'
            }
        }

        {
            Invoke-FortiCNAPPRequest `
                -Session $script:session `
                -Method POST `
                -Path 'Inventory/search' `
                -Body @{ csp = 'AWS' } `
                -AllPages
        } | Should -Throw -ExpectedMessage '*connected tenant authority*'
    }

    It 'rejects successful malformed JSON' {
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            [pscustomobject]@{ StatusCode = 200; Headers = @{}; Content = '{broken' }
        }

        {
            Invoke-FortiCNAPPRequest -Session $script:session -Method GET -Path 'schemas'
        } | Should -Throw -ExpectedMessage '*not valid JSON*'
    }

    It 'writes redacted JSON Lines telemetry' {
        $logPath = Join-Path $TestDrive 'request.jsonl'
        Mock -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -MockWith {
            [pscustomobject]@{ StatusCode = 200; Headers = @{}; Content = '{"data":[]}' }
        }

        Invoke-FortiCNAPPRequest `
            -Session $script:session `
            -Method GET `
            -Path 'Alerts' `
            -Query @{ status = 'SyntheticPrivateValue' } `
            -LogPath $logPath | Out-Null

        $text = Get-Content -LiteralPath $logPath -Raw
        $text | Should -Match 'QueryParameterNames'
        $text | Should -Not -Match 'SyntheticPrivateValue|synthetic-private-bearer-token'
    }

    It 'rejects an expired session before transport' {
        InModuleScope PSFortiCNAPP -Parameters @{ Session = $script:session } {
            param($Session)
            $record = Get-FortiCNAPPSessionRecord -Session $Session
            $record.ExpiresAtUtc = [DateTimeOffset]::UtcNow.AddSeconds(10)
        }

        {
            Invoke-FortiCNAPPRequest -Session $script:session -Method GET -Path 'schemas'
        } | Should -Throw -ExpectedMessage '*expired or too close*'

        Should -Invoke -ModuleName PSFortiCNAPP -CommandName Invoke-FortiCNAPPHttpTransport -Times 0
    }
}
