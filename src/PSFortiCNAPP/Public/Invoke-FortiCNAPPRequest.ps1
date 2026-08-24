# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Invoke-FortiCNAPPRequest {
    <#
    .SYNOPSIS
    Sends a validated FortiCNAPP API v2 request through an explicit session.

    .DESCRIPTION
    Builds a tenant-scoped HTTPS request, applies the module-private bearer token,
    serializes an optional JSON body, parses JSON responses, records safe request
    metadata, follows documented continuation URLs when requested, and performs
    bounded retries for documented transient status codes.

    The command never returns the bearer token, raw authorization header, request
    query values, or unparsed response body text.

    .PARAMETER Session
    Connected PSFortiCNAPP session.

    .PARAMETER Method
    GET or POST. Chapter 6 keeps the general client read-only by default and adds
    POST for documented search and validation operations.

    .PARAMETER Path
    Relative API v2 path or an absolute continuation URI supplied by FortiCNAPP.

    .PARAMETER Query
    Query parameters. Values are sent but not returned in ordinary output or logs.

    .PARAMETER Body
    Optional request body serialized to JSON with depth 100.

    .PARAMETER AllPages
    Follow the documented paging.urls.nextPage value until no continuation remains.

    .PARAMETER MaxPageCount
    Safety bound for automatic pagination.

    .PARAMETER MaxRetryCount
    Maximum number of retries after the first request attempt.

    .PARAMETER LogPath
    Optional JSON Lines file receiving redacted request telemetry.

    .EXAMPLE
    Invoke-FortiCNAPPRequest `
        -Session $session `
        -Method GET `
        -Path 'schemas/AuditLogs'

    .OUTPUTS
    PSFortiCNAPP.ApiResponse
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$Session,

        [Parameter(Mandatory)]
        [ValidateSet('GET', 'POST')]
        [string]$Method,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [AllowNull()]
        [System.Collections.IDictionary]$Query,

        [Parameter()]
        [AllowNull()]
        [psobject]$Body,

        [Parameter()]
        [switch]$AllPages,

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$MaxPageCount = 100,

        [Parameter()]
        [ValidateRange(0, 8)]
        [int]$MaxRetryCount = 3,

        [Parameter()]
        [ValidateRange(0.01, 120)]
        [double]$InitialRetryDelaySeconds = 1,

        [Parameter()]
        [ValidateRange(0, 5000)]
        [int]$JitterMaximumMilliseconds = 250,

        [Parameter()]
        [ValidateRange(1, 300)]
        [int]$TimeoutSeconds = 30,

        [Parameter()]
        [AllowNull()]
        [string]$LogPath
    )

    $sessionRecord = Get-FortiCNAPPSessionRecord -Session $Session
    $nowUtc = [DateTimeOffset]::UtcNow
    if ($sessionRecord.ExpiresAtUtc -le $nowUtc.AddSeconds(30)) {
        Write-Error `
            -Message 'The FortiCNAPP session is expired or too close to expiration for a new request.' `
            -ErrorId 'PSFortiCNAPP.Request.SessionExpired' `
            -Category AuthenticationError `
            -TargetObject $Session `
            -ErrorAction Stop
    }

    $serializedBody = if ($null -eq $Body) {
        $null
    }
    else {
        $Body | ConvertTo-Json -Depth 100 -Compress
    }

    $currentPath = $Path
    $currentQuery = $Query
    $currentMethod = $Method
    $currentBody = $serializedBody
    $pageCount = 0
    $allData = [System.Collections.Generic.List[object]]::new()
    $attemptRecords = [System.Collections.Generic.List[object]]::new()
    $lastParsedBody = $null
    $lastPaging = $null
    $lastSafeUri = $null
    $lastQueryNames = @()
    $lastStatusCode = $null
    $lastCorrelationId = $null
    $lastRateLimit = $null
    $lastBodyLength = 0
    $lastBodySha256 = $null
    $collectionComplete = $false

    while ($true) {
        $pageCount++
        if ($pageCount -gt $MaxPageCount) {
            Write-Error `
                -Message "Pagination exceeded the configured MaxPageCount value of $MaxPageCount." `
                -ErrorId 'PSFortiCNAPP.Request.PageLimitExceeded' `
                -Category LimitsExceeded `
                -TargetObject $lastSafeUri `
                -ErrorAction Stop
        }

        $requestUri = New-FortiCNAPPRequestUri `
            -BaseUri $sessionRecord.BaseUri `
            -Path $currentPath `
            -Query $currentQuery
        $lastSafeUri = $requestUri.SafeUri
        $lastQueryNames = $requestUri.QueryParameterNames

        $headers = @{
            Authorization  = 'Bearer {0}' -f $sessionRecord.AccessToken
            Accept         = 'application/json'
            'Content-Type' = 'application/json'
        }

        $pageSucceeded = $false
        for ($attempt = 1; $attempt -le ($MaxRetryCount + 1); $attempt++) {
            $attemptStartedAtUtc = [DateTimeOffset]::UtcNow
            $transportResponse = $null
            $transportError = $null

            try {
                $transportResponse = Invoke-FortiCNAPPHttpTransport `
                    -Uri $requestUri.Uri `
                    -Method $currentMethod `
                    -Headers $headers `
                    -Body $currentBody `
                    -TimeoutSeconds $TimeoutSeconds
            }
            catch {
                $transportError = $_
            }

            $attemptCompletedAtUtc = [DateTimeOffset]::UtcNow
            $durationMilliseconds = [math]::Round(
                ($attemptCompletedAtUtc - $attemptStartedAtUtc).TotalMilliseconds,
                3
            )

            if ($null -ne $transportError) {
                $retryable = $attempt -le $MaxRetryCount
                $attemptRecord = [pscustomobject][ordered]@{
                    Page                 = $pageCount
                    Attempt              = $attempt
                    StartedAtUtc         = $attemptStartedAtUtc
                    CompletedAtUtc       = $attemptCompletedAtUtc
                    DurationMilliseconds = $durationMilliseconds
                    Method               = $currentMethod
                    RequestUri           = $requestUri.SafeUri.AbsoluteUri
                    QueryParameterNames  = $requestUri.QueryParameterNames
                    StatusCode           = $null
                    Outcome              = 'TransportError'
                    Retryable            = $retryable
                    RetryDelaySeconds    = $null
                    CorrelationId        = $null
                    RateLimitRemaining   = $null
                    ErrorType            = $transportError.Exception.GetType().FullName
                }

                if ($retryable) {
                    $attemptRecord.RetryDelaySeconds = Get-FortiCNAPPRetryDelay `
                        -Attempt $attempt `
                        -InitialDelaySeconds $InitialRetryDelaySeconds `
                        -JitterMaximumMilliseconds $JitterMaximumMilliseconds
                }

                $attemptRecords.Add($attemptRecord)
                if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
                    Write-FortiCNAPPRequestLog -LiteralPath $LogPath -Entry $attemptRecord
                }

                if ($retryable) {
                    Start-Sleep -Milliseconds ([int][math]::Ceiling($attemptRecord.RetryDelaySeconds * 1000))
                    continue
                }

                Write-Error `
                    -Message 'The FortiCNAPP request failed before an HTTP response was received.' `
                    -ErrorId 'PSFortiCNAPP.Request.TransportFailure' `
                    -Category ConnectionError `
                    -TargetObject $requestUri.SafeUri `
                    -ErrorAction Stop
            }

            $statusCode = [int]$transportResponse.StatusCode
            $responseHeaders = if ($null -eq $transportResponse.Headers) {
                @{}
            }
            else {
                $transportResponse.Headers
            }
            $content = if ($null -eq $transportResponse.Content) {
                ''
            }
            else {
                [string]$transportResponse.Content
            }

            $contentBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($content)
            $contentSha256 = if ($contentBytes.Length -eq 0) {
                $null
            }
            else {
                [Convert]::ToHexString(
                    [System.Security.Cryptography.SHA256]::HashData($contentBytes)
                ).ToLowerInvariant()
            }

            $contentType = Get-FortiCNAPPHeaderValue -Headers $responseHeaders -Name 'Content-Type'
            $parsedBody = $null
            $parseFailed = $false
            if ($contentBytes.Length -gt 0) {
                try {
                    $parsedBody = $content | ConvertFrom-Json -Depth 100 -ErrorAction Stop
                }
                catch {
                    $parseFailed = $true
                }
            }

            $correlationId = Get-FortiCNAPPHeaderValue -Headers $responseHeaders -Name 'X-Request-Id'
            $rateLimit = [pscustomobject][ordered]@{
                Limit     = Get-FortiCNAPPHeaderValue -Headers $responseHeaders -Name 'RateLimit-Limit'
                Remaining = Get-FortiCNAPPHeaderValue -Headers $responseHeaders -Name 'RateLimit-Remaining'
                Reset     = Get-FortiCNAPPHeaderValue -Headers $responseHeaders -Name 'RateLimit-Reset'
            }

            $isSuccess = $statusCode -in @(200, 201, 204)
            $retryableStatus = $statusCode -in @(429, 500, 503)
            $retryable = $retryableStatus -and $attempt -le $MaxRetryCount
            $outcome = if ($isSuccess) {
                'Success'
            }
            elseif ($retryable) {
                'Retry'
            }
            else {
                'HttpError'
            }

            $attemptRecord = [pscustomobject][ordered]@{
                Page                 = $pageCount
                Attempt              = $attempt
                StartedAtUtc         = $attemptStartedAtUtc
                CompletedAtUtc       = $attemptCompletedAtUtc
                DurationMilliseconds = $durationMilliseconds
                Method               = $currentMethod
                RequestUri           = $requestUri.SafeUri.AbsoluteUri
                QueryParameterNames  = $requestUri.QueryParameterNames
                StatusCode           = $statusCode
                Outcome              = $outcome
                Retryable            = $retryable
                RetryDelaySeconds    = $null
                CorrelationId        = $correlationId
                RateLimitRemaining   = $rateLimit.Remaining
                ErrorType            = $null
            }

            if ($retryable) {
                $attemptRecord.RetryDelaySeconds = Get-FortiCNAPPRetryDelay `
                    -Attempt $attempt `
                    -InitialDelaySeconds $InitialRetryDelaySeconds `
                    -Headers $responseHeaders `
                    -JitterMaximumMilliseconds $JitterMaximumMilliseconds
            }

            $attemptRecords.Add($attemptRecord)
            if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
                Write-FortiCNAPPRequestLog -LiteralPath $LogPath -Entry $attemptRecord
            }

            if ($retryable) {
                Start-Sleep -Milliseconds ([int][math]::Ceiling($attemptRecord.RetryDelaySeconds * 1000))
                continue
            }

            if (-not $isSuccess) {
                $providerMessage = if (
                    $null -ne $parsedBody -and
                    $null -ne $parsedBody.PSObject.Properties['message']
                ) {
                    ([string]$parsedBody.message).Trim()
                }
                else {
                    $null
                }
                $message = if ([string]::IsNullOrWhiteSpace($providerMessage)) {
                    "FortiCNAPP returned HTTP status $statusCode."
                }
                else {
                    "FortiCNAPP returned HTTP status $statusCode: $providerMessage"
                }

                Write-Error `
                    -Message $message `
                    -ErrorId "PSFortiCNAPP.Request.Http$statusCode" `
                    -Category InvalidOperation `
                    -TargetObject $requestUri.SafeUri `
                    -ErrorAction Stop
            }

            if ($parseFailed) {
                Write-Error `
                    -Message 'The successful FortiCNAPP response body was not valid JSON.' `
                    -ErrorId 'PSFortiCNAPP.Request.InvalidJsonResponse' `
                    -Category InvalidData `
                    -TargetObject $requestUri.SafeUri `
                    -ErrorAction Stop
            }

            $pageData = if (
                $null -ne $parsedBody -and
                $null -ne $parsedBody.PSObject.Properties['data']
            ) {
                @($parsedBody.data)
            }
            elseif ($null -ne $parsedBody) {
                @($parsedBody)
            }
            else {
                @()
            }

            foreach ($item in $pageData) {
                $allData.Add($item)
            }

            $paging = if (
                $null -ne $parsedBody -and
                $null -ne $parsedBody.PSObject.Properties['paging']
            ) {
                $parsedBody.paging
            }
            else {
                $null
            }

            $lastParsedBody = $parsedBody
            $lastPaging = $paging
            $lastStatusCode = $statusCode
            $lastCorrelationId = $correlationId
            $lastRateLimit = $rateLimit
            $lastBodyLength = $contentBytes.Length
            $lastBodySha256 = $contentSha256
            $pageSucceeded = $true
            break
        }

        if (-not $pageSucceeded) {
            Write-Error `
                -Message 'The FortiCNAPP page request did not complete.' `
                -ErrorId 'PSFortiCNAPP.Request.PageFailure' `
                -Category InvalidResult `
                -TargetObject $lastSafeUri `
                -ErrorAction Stop
        }

        $nextPage = $null
        if (
            $null -ne $lastPaging -and
            $null -ne $lastPaging.PSObject.Properties['urls'] -and
            $null -ne $lastPaging.urls -and
            $null -ne $lastPaging.urls.PSObject.Properties['nextPage']
        ) {
            $nextPage = [string]$lastPaging.urls.nextPage
        }

        if (-not $AllPages -or [string]::IsNullOrWhiteSpace($nextPage)) {
            $collectionComplete = [string]::IsNullOrWhiteSpace($nextPage)
            break
        }

        $currentPath = $nextPage
        $currentQuery = $null
        $currentMethod = 'GET'
        $currentBody = $null
    }

    $result = [pscustomobject][ordered]@{
        SessionId              = $sessionRecord.SessionId
        EnvironmentName        = $sessionRecord.EnvironmentName
        AccountName            = $sessionRecord.AccountName
        RequestUri             = $lastSafeUri
        QueryParameterNames    = $lastQueryNames
        StatusCode             = $lastStatusCode
        PageCount              = $pageCount
        RecordCount            = $allData.Count
        CollectionComplete     = $collectionComplete
        Data                   = $allData.ToArray()
        LastParsedBody         = $lastParsedBody
        LastPaging             = $lastPaging
        Attempts               = $attemptRecords.ToArray()
        CorrelationId          = $lastCorrelationId
        RateLimit              = $lastRateLimit
        LastBodyLengthBytes    = $lastBodyLength
        LastBodySha256         = $lastBodySha256
        RawResponseReturned    = $false
        SensitiveValuesExposed = $false
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.ApiResponse')

    return $result
}
