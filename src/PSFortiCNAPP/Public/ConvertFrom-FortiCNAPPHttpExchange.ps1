# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function ConvertFrom-FortiCNAPPHttpExchange {
    <#
    .SYNOPSIS
    Converts a synthetic or sanitized HTTP exchange into a safe contract object.

    .DESCRIPTION
    Validates a captured HTTP exchange, removes query values and sensitive
    headers, normalizes timestamps to UTC, classifies the status code, inspects
    the response media type, parses JSON when appropriate, and returns a stable
    object for testing and later transport-layer development.

    The command performs local transformation only. It makes no network request,
    does not authenticate, and accepts only SYNTHETIC or SANITIZED input.

    .PARAMETER InputObject
    HTTP exchange object to validate and normalize.

    .PARAMETER DataClassification
    Provenance label for the input. Only SYNTHETIC and SANITIZED are accepted.

    .EXAMPLE
    $exchange |
        ConvertFrom-FortiCNAPPHttpExchange `
            -DataClassification SYNTHETIC

    .OUTPUTS
    PSFortiCNAPP.HttpExchange
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [psobject]$InputObject,

        [Parameter()]
        [ValidateSet('SYNTHETIC', 'SANITIZED')]
        [string]$DataClassification = 'SYNTHETIC'
    )

    process {
        $requiredPropertyNames = @(
            'exchangeId'
            'method'
            'requestUri'
            'startedAtUtc'
            'completedAtUtc'
            'statusCode'
            'responseBody'
        )

        $values = @{}
        foreach ($propertyName in $requiredPropertyNames) {
            $property = $InputObject.PSObject.Properties[$propertyName]
            if ($null -eq $property -or $null -eq $property.Value) {
                Write-Error `
                    -Message "Input object property '$propertyName' is required." `
                    -ErrorId 'PSFortiCNAPP.HttpExchange.RequiredPropertyMissing' `
                    -Category InvalidData `
                    -TargetObject $InputObject `
                    -ErrorAction Stop
            }

            $values[$propertyName] = $property.Value
        }

        $exchangeId = ([string]$values['exchangeId']).Trim()
        if ([string]::IsNullOrWhiteSpace($exchangeId)) {
            Write-Error `
                -Message 'exchangeId cannot be empty or whitespace.' `
                -ErrorId 'PSFortiCNAPP.HttpExchange.InvalidExchangeId' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $method = ([string]$values['method']).Trim().ToUpperInvariant()
        $allowedMethods = @(
            'GET'
            'HEAD'
            'OPTIONS'
            'POST'
            'PUT'
            'PATCH'
            'DELETE'
        )
        if ($method -notin $allowedMethods) {
            Write-Error `
                -Message "HTTP method '$method' is not supported." `
                -ErrorId 'PSFortiCNAPP.HttpExchange.InvalidMethod' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $requestUri = $null
        if (
            -not [Uri]::TryCreate(
                ([string]$values['requestUri']).Trim(),
                [UriKind]::Absolute,
                [ref]$requestUri
            ) -or
            $requestUri.Scheme -ne 'https'
        ) {
            Write-Error `
                -Message 'requestUri must be an absolute HTTPS URI.' `
                -ErrorId 'PSFortiCNAPP.HttpExchange.InvalidRequestUri' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $timestampPattern = '(?i)(Z|[+-]\d{2}:\d{2})$'
        $dateTimeStyles = (
            [System.Globalization.DateTimeStyles]::AssumeUniversal -bor
            [System.Globalization.DateTimeStyles]::AdjustToUniversal
        )

        $startedText = ([string]$values['startedAtUtc']).Trim()
        $completedText = ([string]$values['completedAtUtc']).Trim()
        if (
            $startedText -notmatch $timestampPattern -or
            $completedText -notmatch $timestampPattern
        ) {
            Write-Error `
                -Message 'HTTP exchange timestamps must include Z or an explicit UTC offset.' `
                -ErrorId 'PSFortiCNAPP.HttpExchange.InvalidTimestamp' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $startedAtUtc = [DateTimeOffset]::MinValue
        $completedAtUtc = [DateTimeOffset]::MinValue
        $startedIsValid = [DateTimeOffset]::TryParse(
            $startedText,
            [System.Globalization.CultureInfo]::InvariantCulture,
            $dateTimeStyles,
            [ref]$startedAtUtc
        )
        $completedIsValid = [DateTimeOffset]::TryParse(
            $completedText,
            [System.Globalization.CultureInfo]::InvariantCulture,
            $dateTimeStyles,
            [ref]$completedAtUtc
        )
        if (-not $startedIsValid -or -not $completedIsValid) {
            Write-Error `
                -Message 'One or more HTTP exchange timestamps are invalid.' `
                -ErrorId 'PSFortiCNAPP.HttpExchange.InvalidTimestamp' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $startedAtUtc = $startedAtUtc.ToUniversalTime()
        $completedAtUtc = $completedAtUtc.ToUniversalTime()
        if ($completedAtUtc -lt $startedAtUtc) {
            Write-Error `
                -Message 'completedAtUtc cannot precede startedAtUtc.' `
                -ErrorId 'PSFortiCNAPP.HttpExchange.InvalidDuration' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $statusCode = 0
        if (
            -not [int]::TryParse(
                [string]$values['statusCode'],
                [ref]$statusCode
            ) -or
            $statusCode -lt 100 -or
            $statusCode -gt 599
        ) {
            Write-Error `
                -Message 'statusCode must be an integer from 100 through 599.' `
                -ErrorId 'PSFortiCNAPP.HttpExchange.InvalidStatusCode' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $reasonPhraseProperty = $InputObject.PSObject.Properties['reasonPhrase']
        $reasonPhrase = if (
            $null -eq $reasonPhraseProperty -or
            $null -eq $reasonPhraseProperty.Value -or
            [string]::IsNullOrWhiteSpace([string]$reasonPhraseProperty.Value)
        ) {
            $null
        }
        else {
            ([string]$reasonPhraseProperty.Value).Trim()
        }

        $headerProperty = $InputObject.PSObject.Properties['headers']
        $headers = if ($null -eq $headerProperty -or $null -eq $headerProperty.Value) {
            [pscustomobject]@{}
        }
        else {
            $headerProperty.Value
        }

        $sensitiveHeaderNames = @(
            'authorization'
            'proxy-authorization'
            'cookie'
            'set-cookie'
            'x-api-key'
            'x-auth-token'
        )
        $safeHeaderNames = @(
            'content-type'
            'date'
            'etag'
            'last-modified'
            'ratelimit-limit'
            'ratelimit-remaining'
            'ratelimit-reset'
            'retry-after'
            'x-request-id'
        )

        $safeHeaders = [System.Collections.Generic.List[object]]::new()
        $redactedHeaderNames = [System.Collections.Generic.List[string]]::new()
        $ignoredHeaderNames = [System.Collections.Generic.List[string]]::new()

        foreach ($header in $headers.PSObject.Properties) {
            $headerName = ([string]$header.Name).Trim()
            $headerKey = $headerName.ToLowerInvariant()
            if ($headerKey -in $sensitiveHeaderNames) {
                $redactedHeaderNames.Add($headerName)
                continue
            }

            if ($headerKey -notin $safeHeaderNames) {
                $ignoredHeaderNames.Add($headerName)
                continue
            }

            $safeHeaders.Add(
                [pscustomobject][ordered]@{
                    Name  = $headerName
                    Value = [string]$header.Value
                }
            )
        }

        $contentTypeProperty = $InputObject.PSObject.Properties['responseContentType']
        $contentTypeText = if (
            $null -ne $contentTypeProperty -and
            $null -ne $contentTypeProperty.Value -and
            -not [string]::IsNullOrWhiteSpace([string]$contentTypeProperty.Value)
        ) {
            ([string]$contentTypeProperty.Value).Trim()
        }
        else {
            $contentTypeHeader = $safeHeaders |
                Where-Object -FilterScript {
                    $_.Name -ieq 'Content-Type'
                } |
                Select-Object -First 1

            if ($null -eq $contentTypeHeader) {
                $null
            }
            else {
                $contentTypeHeader.Value
            }
        }

        $mediaType = if ([string]::IsNullOrWhiteSpace($contentTypeText)) {
            $null
        }
        else {
            ($contentTypeText -split ';', 2)[0].Trim().ToLowerInvariant()
        }

        $responseBody = [string]$values['responseBody']
        $bodyBytes = [System.Text.UTF8Encoding]::new($false).GetBytes(
            $responseBody
        )
        $bodyLengthBytes = $bodyBytes.Length
        $bodySha256 = if ($bodyLengthBytes -eq 0) {
            $null
        }
        else {
            [Convert]::ToHexString(
                [System.Security.Cryptography.SHA256]::HashData($bodyBytes)
            ).ToLowerInvariant()
        }

        $isJsonMediaType = (
            $mediaType -eq 'application/json' -or
            $mediaType -eq 'application/problem+json' -or
            $mediaType -like 'application/*+json'
        )

        $parsedBody = $null
        $bodyState = 'Empty'
        $validationIssues = [System.Collections.Generic.List[string]]::new()

        if ($bodyLengthBytes -eq 0) {
            $bodyState = 'Empty'
        }
        elseif ($isJsonMediaType) {
            try {
                $parsedBody = $responseBody |
                    ConvertFrom-Json -Depth 100 -ErrorAction Stop
                $bodyState = 'ValidJson'
            }
            catch {
                $bodyState = 'MalformedJson'
                $validationIssues.Add(
                    'The response declared a JSON media type but the body was not valid JSON.'
                )
            }
        }
        else {
            $bodyState = 'UnsupportedMediaType'
            $validationIssues.Add(
                'The response body used a media type outside the JSON-or-empty chapter contract.'
            )
        }

        if ($statusCode -eq 204 -and $bodyLengthBytes -gt 0) {
            $validationIssues.Add(
                'HTTP status 204 was accompanied by a non-empty response body.'
            )
        }

        $statusFamily = switch ([math]::Floor($statusCode / 100)) {
            1 { 'Informational' }
            2 { 'Success' }
            3 { 'Redirection' }
            4 { 'ClientError' }
            5 { 'ServerError' }
            default { 'Unknown' }
        }

        $contractState = if (
            $bodyState -eq 'MalformedJson' -or
            ($statusCode -eq 204 -and $bodyLengthBytes -gt 0)
        ) {
            'Invalid'
        }
        elseif ($validationIssues.Count -gt 0) {
            'Warning'
        }
        else {
            'Valid'
        }

        $queryParameterNames = [System.Collections.Generic.List[string]]::new()
        if (-not [string]::IsNullOrWhiteSpace($requestUri.Query)) {
            foreach ($queryPart in $requestUri.Query.TrimStart('?') -split '&') {
                if ([string]::IsNullOrWhiteSpace($queryPart)) {
                    continue
                }

                $name = [Uri]::UnescapeDataString(
                    ($queryPart -split '=', 2)[0]
                )
                if (-not [string]::IsNullOrWhiteSpace($name)) {
                    $queryParameterNames.Add($name)
                }
            }
        }

        $safeRequestUri = [Uri]::new(
            $requestUri.GetLeftPart([UriPartial]::Path)
        )

        $requestIdHeader = $safeHeaders |
            Where-Object -FilterScript {
                $_.Name -ieq 'X-Request-Id'
            } |
            Select-Object -First 1
        $retryAfterHeader = $safeHeaders |
            Where-Object -FilterScript {
                $_.Name -ieq 'Retry-After'
            } |
            Select-Object -First 1

        $retryAfterSeconds = $null
        if ($null -ne $retryAfterHeader) {
            $parsedRetryAfter = 0
            if (
                [int]::TryParse(
                    $retryAfterHeader.Value,
                    [ref]$parsedRetryAfter
                )
            ) {
                $retryAfterSeconds = $parsedRetryAfter
            }
        }

        $result = [pscustomobject][ordered]@{
            ExchangeId              = $exchangeId
            DataClassification      = $DataClassification.ToUpperInvariant()
            Method                  = $method
            RequestUri              = $safeRequestUri
            QueryParameterNames     = $queryParameterNames.ToArray()
            StartedAtUtc            = $startedAtUtc
            CompletedAtUtc          = $completedAtUtc
            DurationMilliseconds    = [math]::Round(
                ($completedAtUtc - $startedAtUtc).TotalMilliseconds,
                3
            )
            StatusCode              = $statusCode
            ReasonPhrase            = $reasonPhrase
            StatusFamily            = $statusFamily
            IsSuccessStatusCode     = $statusCode -ge 200 -and $statusCode -le 299
            ResponseContentType     = $contentTypeText
            ResponseMediaType       = $mediaType
            BodyState               = $bodyState
            BodyLengthBytes         = $bodyLengthBytes
            BodySha256              = $bodySha256
            ParsedBody              = $parsedBody
            SafeHeaders             = $safeHeaders.ToArray()
            RedactedHeaderNames     = $redactedHeaderNames.ToArray()
            IgnoredHeaderNames      = $ignoredHeaderNames.ToArray()
            CorrelationId           = if ($null -eq $requestIdHeader) {
                $null
            }
            else {
                $requestIdHeader.Value
            }
            RetryAfterSeconds       = $retryAfterSeconds
            ContractState           = $contractState
            ValidationIssues        = $validationIssues.ToArray()
            RawBodyReturned         = $false
        }
        $result.PSObject.TypeNames.Insert(
            0,
            'PSFortiCNAPP.HttpExchange'
        )

        $result
    }
}
