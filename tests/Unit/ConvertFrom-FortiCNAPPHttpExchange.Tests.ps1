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

    function New-ValidSyntheticExchange {
        [pscustomobject]@{
            exchangeId          = 'syn-unit-http-001'
            method              = 'GET'
            requestUri          = 'https://tenant.example.invalid/api/v2/example?cursor=secret-shaped-value&limit=10'
            startedAtUtc        = '2026-08-13T20:00:00Z'
            completedAtUtc      = '2026-08-13T20:00:00.125Z'
            statusCode          = 200
            reasonPhrase        = 'OK'
            responseContentType = 'application/json; charset=utf-8'
            headers             = [pscustomobject]@{
                'Content-Type'  = 'application/json; charset=utf-8'
                'X-Request-Id'  = 'syn-unit-request-001'
                'Authorization' = 'not-retained'
            }
            responseBody        = '{"data":[{"id":"syn-001"}]}'
        }
    }
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-FortiCNAPPHttpExchange' {
    It 'returns a stable typed exchange' {
        $result = New-ValidSyntheticExchange |
            ConvertFrom-FortiCNAPPHttpExchange `
                -DataClassification SYNTHETIC

        $result.PSObject.TypeNames[0] |
            Should -Be 'PSFortiCNAPP.HttpExchange'
        $result.ExchangeId | Should -Be 'syn-unit-http-001'
        $result.Method | Should -Be 'GET'
        $result.StatusCode | Should -Be 200
        $result.StatusFamily | Should -Be 'Success'
        $result.IsSuccessStatusCode | Should -BeTrue
        $result.BodyState | Should -Be 'ValidJson'
        $result.ContractState | Should -Be 'Valid'
        $result.RawBodyReturned | Should -BeFalse
    }

    It 'normalizes timestamps and calculates duration' {
        $result = New-ValidSyntheticExchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.StartedAtUtc.Offset | Should -Be ([TimeSpan]::Zero)
        $result.CompletedAtUtc.Offset | Should -Be ([TimeSpan]::Zero)
        $result.DurationMilliseconds | Should -Be 125
    }

    It 'removes query values while retaining parameter names' {
        $result = New-ValidSyntheticExchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.RequestUri.AbsoluteUri |
            Should -Be 'https://tenant.example.invalid/api/v2/example'
        $result.QueryParameterNames | Should -Contain 'cursor'
        $result.QueryParameterNames | Should -Contain 'limit'
        $result.RequestUri.AbsoluteUri |
            Should -Not -Match 'secret-shaped-value'
    }

    It 'redacts sensitive headers and preserves an approved request identifier' {
        $result = New-ValidSyntheticExchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.RedactedHeaderNames | Should -Contain 'Authorization'
        $result.CorrelationId | Should -Be 'syn-unit-request-001'
        ($result.SafeHeaders.Name -join ',') |
            Should -Not -Match '(?i)authorization'
    }

    It 'parses JSON without returning raw body text' {
        $result = New-ValidSyntheticExchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.ParsedBody.data[0].id | Should -Be 'syn-001'
        $result.BodyLengthBytes | Should -BeGreaterThan 0
        $result.BodySha256 | Should -Match '^[0-9a-f]{64}$'
        $result.PSObject.Properties.Name |
            Should -Not -Contain 'ResponseBody'
    }

    It 'records an empty 204 response as valid' {
        $exchange = New-ValidSyntheticExchange
        $exchange.statusCode = 204
        $exchange.reasonPhrase = 'No Content'
        $exchange.responseContentType = $null
        $exchange.headers = [pscustomobject]@{}
        $exchange.responseBody = ''

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.BodyState | Should -Be 'Empty'
        $result.ContractState | Should -Be 'Valid'
        $result.BodySha256 | Should -BeNullOrEmpty
    }

    It 'classifies a JSON rate-limit response and parses Retry-After' {
        $exchange = New-ValidSyntheticExchange
        $exchange.statusCode = 429
        $exchange.reasonPhrase = 'Too Many Requests'
        $exchange.responseContentType = 'application/problem+json'
        $exchange.headers = [pscustomobject]@{
            'Content-Type' = 'application/problem+json'
            'Retry-After'  = '30'
        }
        $exchange.responseBody = '{"message":"Synthetic rate limit"}'

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.StatusFamily | Should -Be 'ClientError'
        $result.IsSuccessStatusCode | Should -BeFalse
        $result.RetryAfterSeconds | Should -Be 30
        $result.BodyState | Should -Be 'ValidJson'
    }

    It 'does not parse an HTML response as JSON' {
        $exchange = New-ValidSyntheticExchange
        $exchange.statusCode = 503
        $exchange.responseContentType = 'text/html'
        $exchange.headers = [pscustomobject]@{
            'Content-Type' = 'text/html'
        }
        $exchange.responseBody = '<html>Synthetic</html>'

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.StatusFamily | Should -Be 'ServerError'
        $result.BodyState | Should -Be 'UnsupportedMediaType'
        $result.ContractState | Should -Be 'Warning'
        $result.ParsedBody | Should -BeNullOrEmpty
    }

    It 'marks malformed declared JSON as invalid' {
        $exchange = New-ValidSyntheticExchange
        $exchange.responseBody = '{"data":['

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.BodyState | Should -Be 'MalformedJson'
        $result.ContractState | Should -Be 'Invalid'
        $result.ValidationIssues.Count | Should -Be 1
    }

    It 'rejects a missing required property with a stable error identifier' {
        $exchange = New-ValidSyntheticExchange
        $exchange.PSObject.Properties.Remove('statusCode')
        $caughtError = $null

        try {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange `
                    -ErrorAction Stop
        }
        catch {
            $caughtError = $_
        }

        $caughtError | Should -Not -BeNullOrEmpty
        $caughtError.FullyQualifiedErrorId |
            Should -Match '^PSFortiCNAPP\.HttpExchange\.RequiredPropertyMissing'
    }

    It 'rejects a non-HTTPS request URI' {
        $exchange = New-ValidSyntheticExchange
        $exchange.requestUri = 'http://tenant.example.invalid/api/v2/example'

        {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange
        } | Should -Throw -ExpectedMessage '*absolute HTTPS URI*'
    }

    It 'rejects timestamps without an explicit offset' {
        $exchange = New-ValidSyntheticExchange
        $exchange.startedAtUtc = '2026-08-13T20:00:00'

        {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange
        } | Should -Throw -ExpectedMessage '*must include Z*'
    }

    It 'rejects a completion time before the start time' {
        $exchange = New-ValidSyntheticExchange
        $exchange.completedAtUtc = '2026-08-13T19:59:59Z'

        {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange
        } | Should -Throw -ExpectedMessage '*cannot precede*'
    }

    It 'rejects an invalid status code' {
        $exchange = New-ValidSyntheticExchange
        $exchange.statusCode = 700

        {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange
        } | Should -Throw -ExpectedMessage '*100 through 599*'
    }

    It 'rejects an unsupported method' {
        $exchange = New-ValidSyntheticExchange
        $exchange.method = 'CONNECT'

        {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange
        } | Should -Throw -ExpectedMessage '*not supported*'
    }

    It 'accepts SANITIZED classification and canonicalizes a lowercase method' {
        $exchange = New-ValidSyntheticExchange
        $exchange.method = 'post'

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange `
                -DataClassification SANITIZED

        $result.DataClassification | Should -Be 'SANITIZED'
        $result.Method | Should -Be 'POST'
    }

    It 'uses the Content-Type header when the explicit property is absent' {
        $exchange = New-ValidSyntheticExchange
        $exchange.PSObject.Properties.Remove('responseContentType')

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.ResponseMediaType | Should -Be 'application/json'
        $result.BodyState | Should -Be 'ValidJson'
    }

    It 'accepts a structured suffix JSON media type' {
        $exchange = New-ValidSyntheticExchange
        $exchange.responseContentType = 'application/vnd.synthetic+json'
        $exchange.headers = [pscustomobject]@{
            'Content-Type' = 'application/vnd.synthetic+json'
        }

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.BodyState | Should -Be 'ValidJson'
        $result.ContractState | Should -Be 'Valid'
    }

    It 'returns an ignored header name without returning its value' {
        $exchange = New-ValidSyntheticExchange
        $exchange.headers |
            Add-Member `
                -NotePropertyName 'X-Unmodeled-Header' `
                -NotePropertyValue 'must-not-be-returned'

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange
        $serialized = $result | ConvertTo-Json -Depth 20

        $result.IgnoredHeaderNames |
            Should -Contain 'X-Unmodeled-Header'
        $serialized | Should -Not -Match 'must-not-be-returned'
    }

    It 'handles an exchange without optional headers or reason phrase' {
        $exchange = New-ValidSyntheticExchange
        $exchange.PSObject.Properties.Remove('headers')
        $exchange.PSObject.Properties.Remove('reasonPhrase')

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.ReasonPhrase | Should -BeNullOrEmpty
        $result.SafeHeaders | Should -BeNullOrEmpty
        $result.CorrelationId | Should -BeNullOrEmpty
    }

    It 'classifies informational and redirection status families' -ForEach @(
        @{ Code = 101; Family = 'Informational' }
        @{ Code = 302; Family = 'Redirection' }
    ) {
        $exchange = New-ValidSyntheticExchange
        $exchange.statusCode = $Code
        $exchange.responseContentType = $null
        $exchange.headers = [pscustomobject]@{}
        $exchange.responseBody = ''

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.StatusFamily | Should -Be $Family
        $result.IsSuccessStatusCode | Should -BeFalse
    }

    It 'marks a non-empty 204 response as invalid' {
        $exchange = New-ValidSyntheticExchange
        $exchange.statusCode = 204

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.ContractState | Should -Be 'Invalid'
        $result.ValidationIssues |
            Should -Contain 'HTTP status 204 was accompanied by a non-empty response body.'
    }

    It 'leaves a non-integer Retry-After value uncalculated' {
        $exchange = New-ValidSyntheticExchange
        $exchange.statusCode = 429
        $exchange.headers = [pscustomobject]@{
            'Content-Type' = 'application/json'
            'Retry-After'  = 'Wed, 21 Oct 2026 07:28:00 GMT'
        }

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.RetryAfterSeconds | Should -BeNullOrEmpty
    }

    It 'rejects an empty exchange identifier' {
        $exchange = New-ValidSyntheticExchange
        $exchange.exchangeId = '   '

        {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange
        } | Should -Throw -ExpectedMessage '*cannot be empty*'
    }

    It 'rejects a timestamp that has an offset marker but is not a date' {
        $exchange = New-ValidSyntheticExchange
        $exchange.startedAtUtc = 'not-a-dateZ'

        {
            $exchange |
                ConvertFrom-FortiCNAPPHttpExchange
        } | Should -Throw -ExpectedMessage '*timestamps are invalid*'
    }

    It 'returns no query names when the URI has no query' {
        $exchange = New-ValidSyntheticExchange
        $exchange.requestUri = 'https://tenant.example.invalid/api/v2/example'

        $result = $exchange |
            ConvertFrom-FortiCNAPPHttpExchange

        $result.QueryParameterNames | Should -BeNullOrEmpty
    }
}
