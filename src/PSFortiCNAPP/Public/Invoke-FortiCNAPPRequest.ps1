# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Invoke-FortiCNAPPRequest {
    <#
    .SYNOPSIS
    Sends an authenticated request through the PSFortiCNAPP API v2 client.

    .DESCRIPTION
    Validates a connected session, builds an HTTPS API v2 URI, sends GET or POST,
    applies bounded retries, parses JSON, follows validated continuation links,
    records safe request telemetry, and returns predictable PowerShell objects.

    The command does not return the bearer token, Authorization header, request
    body text, query values, or raw response body text.

    .PARAMETER Session
    Connected PSFortiCNAPP session.

    .PARAMETER Method
    GET or POST. State-changing HTTP methods are not exposed by this client.

    .PARAMETER Path
    Relative path under `/api/v2/`, such as `schemas/AuditLogs`.

    .PARAMETER Query
    Optional query key-value pairs. Values are sent but omitted from output and logs.

    .PARAMETER Body
    Optional POST request body. It is serialized with explicit JSON depth.

    .PARAMETER AllPages
    Follows documented `paging.urls.nextPage` continuation links.

    .PARAMETER MaxPageCount
    Maximum pages collected. The maximum of 100 aligns with the documented
    500,000-row result limit divided by the documented 5,000-row page limit.

    .PARAMETER MaxRetryCount
    Number of retries after the first attempt.

    .PARAMETER RetryStatusCode
    HTTP statuses eligible for retry. Defaults to documented 429, 500, and 503.

    .PARAMETER InitialRetryDelaySeconds
    Exponential retry delay before jitter when no provider delay is available.

    .PARAMETER MaximumRetryDelaySeconds
    Upper delay bound.

    .PARAMETER JitterMaximumMilliseconds
    Maximum random jitter added to module-derived retry delay.

    .PARAMETER TimeoutSeconds
    Per-attempt HTTP timeout.

    .PARAMETER JsonDepth
    JSON serialization and parsing depth.

    .PARAMETER LogPath
    Optional JSON Lines destination for safe attempt telemetry.

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
        [ValidateRange(0, 10)]
        [int]$MaxRetryCount = 3,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int[]]$RetryStatusCode = @(429, 500, 503),

        [Parameter()]
        [ValidateRange(0.01, 300)]
        [double]$InitialRetryDelaySeconds = 1,

        [Parameter()]
        [ValidateRange(0.01, 600)]
        [double]$MaximumRetryDelaySeconds = 60,

        [Parameter()]
        [ValidateRange(0, 60000)]
        [int]$JitterMaximumMilliseconds = 500,

        [Parameter()]
        [ValidateRange(1, 300)]
        [int]$TimeoutSeconds = 30,

        [Parameter()]
        [ValidateRange(2, 100)]
        [int]$JsonDepth = 50,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LogPath
    )

    $sessionRecord = Get-FortiCNAPPSessionRecord -Session $Session
    $now = [DateTimeOffset]::UtcNow
    if ($sessionRecord.ExpiresAtUtc -le $now.AddSeconds(30)) {
        Write-Error `
            -Message 'The FortiCNAPP session is expired or too close to expiration for a request.' `
            -ErrorId 'PSFortiCNAPP.Request.SessionExpired' `
            -Category AuthenticationError `
            -TargetObject $Session `
            -ErrorAction Stop
    }

    $currentUri = New-FortiCNAPPRequestUri `
        -BaseUri $sessionRecord.BaseUri `
        -Path $Path `
        -Query $Query
    $initialUri = $currentUri
    $queryNames = @($Query.Keys | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    $bodyText = $null
    if ($null -ne $Body) {
        $bodyText = $Body | ConvertTo-Json -Depth $JsonDepth -Compress
        $bodyByteCount = [System.Text.UTF8Encoding]::new($false).GetByteCount($bodyText)
        if ($bodyByteCount -gt 1MB) {
            Write-Error `
                -Message 'The JSON request body exceeds the documented 1 MB limit.' `
                -ErrorId 'PSFortiCNAPP.Request.BodyTooLarge' `
                -Category LimitsExceeded `
                -TargetObject $bodyByteCount `
                -ErrorAction Stop
        }
    }

    $allData = [System.Collections.Generic.List[object]]::new()
    $allAttempts = [System.Collections.Generic.List[object]]::new()
    $pageCount = 0
    $collectionComplete = $false
    $lastStatusCode = 0
    $lastHeaders = $null
    $lastContentBytes = [byte[]]@()
    $lastParsedResponse = $null

    while ($true) {
        if ($pageCount -ge $MaxPageCount) {
            Write-Error `
                -Message "The collection reached MaxPageCount $MaxPageCount before the provider indicated completion." `
                -ErrorId 'PSFortiCNAPP.Request.PageLimitExceeded' `
                -Category LimitsExceeded `
                -TargetObject $currentUri `
                -ErrorAction Stop
        }

        $pageCount++
        $attemptNumber = 0
        $pageSucceeded = $false

        while (-not $pageSucceeded) {
            $attemptNumber++
            $startedAtUtc = [DateTimeOffset]::UtcNow
            $safePath = $currentUri.AbsolutePath
            $headers = @{
                Authorization = 'Bearer {0}' -f $sessionRecord.AccessToken
                Accept = 'application/json'
            }
            if ($null -ne $bodyText) {
                $headers['Content-Type'] = 'application/json'
            }

            try {
                $transportResponse = Invoke-FortiCNAPPHttpTransport `
                    -Uri $currentUri `
                    -Method $Method `
                    -Headers $headers `
                    -Body $bodyText `
                    -TimeoutSeconds $TimeoutSeconds

                $completedAtUtc = [DateTimeOffset]::UtcNow
                $statusCode = [int]$transportResponse.StatusCode
                $lastStatusCode = $statusCode
                $lastHeaders = $transportResponse.Headers
                $contentText = if ($null -eq $transportResponse.Content) {
                    ''
                }
                else {
                    [string]$transportResponse.Content
                }
                $lastContentBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($contentText)
                $correlationId = Get-FortiCNAPPHeaderValue -Headers $lastHeaders -Name 'X-Request-Id'
                $rateLimitRemaining = Get-FortiCNAPPHeaderValue -Headers $lastHeaders -Name 'RateLimit-Remaining'

                $isSuccess = $statusCode -ge 200 -and $statusCode -le 299
                if ($isSuccess) {
                    if ([string]::IsNullOrWhiteSpace($contentText)) {
                        $lastParsedResponse = $null
                    }
                    else {
                        try {
                            $lastParsedResponse = $contentText | ConvertFrom-Json -Depth $JsonDepth -ErrorAction Stop
                        }
                        catch {
                            Write-Error `
                                -Message 'A successful FortiCNAPP response was not valid JSON.' `
                                -ErrorId 'PSFortiCNAPP.Request.InvalidJson' `
                                -Category InvalidData `
                                -TargetObject $currentUri `
                                -ErrorAction Stop
                        }
                    }

                    $attempt = [pscustomobject][ordered]@{
                        Page = $pageCount
                        Attempt = $attemptNumber
                        StartedAtUtc = $startedAtUtc
                        CompletedAtUtc = $completedAtUtc
                        DurationMilliseconds = [math]::Round(($completedAtUtc - $startedAtUtc).TotalMilliseconds, 3)
                        StatusCode = $statusCode
                        Outcome = 'Success'
                        RetryScheduled = $false
                        RetryDelaySeconds = 0
                        CorrelationId = $correlationId
                        RateLimitRemaining = $rateLimitRemaining
                    }
                    $allAttempts.Add($attempt)
                    Write-FortiCNAPPRequestLog `
                        -LogPath $LogPath `
                        -Entry ([ordered]@{
                            TimestampUtc = $completedAtUtc
                            SessionId = $sessionRecord.SessionId
                            EnvironmentName = $sessionRecord.EnvironmentName
                            Method = $Method
                            SafePath = $safePath
                            QueryParameterNames = $queryNames
                            Page = $pageCount
                            Attempt = $attemptNumber
                            StatusCode = $statusCode
                            Outcome = 'Success'
                            CorrelationId = $correlationId
                            RateLimitRemaining = $rateLimitRemaining
                        })
                    $pageSucceeded = $true
                    break
                }

                $shouldRetryStatus = $statusCode -in $RetryStatusCode
                $canRetry = $shouldRetryStatus -and $attemptNumber -le $MaxRetryCount
                $retryDelaySeconds = if ($canRetry) {
                    Get-FortiCNAPPRetryDelay `
                        -Headers $lastHeaders `
                        -AttemptNumber $attemptNumber `
                        -InitialDelaySeconds $InitialRetryDelaySeconds `
                        -MaximumDelaySeconds $MaximumRetryDelaySeconds `
                        -JitterMaximumMilliseconds $JitterMaximumMilliseconds
                }
                else {
                    0
                }

                $attempt = [pscustomobject][ordered]@{
                    Page = $pageCount
                    Attempt = $attemptNumber
                    StartedAtUtc = $startedAtUtc
                    CompletedAtUtc = $completedAtUtc
                    DurationMilliseconds = [math]::Round(($completedAtUtc - $startedAtUtc).TotalMilliseconds, 3)
                    StatusCode = $statusCode
                    Outcome = 'HttpError'
                    RetryScheduled = $canRetry
                    RetryDelaySeconds = $retryDelaySeconds
                    CorrelationId = $correlationId
                    RateLimitRemaining = $rateLimitRemaining
                }
                $allAttempts.Add($attempt)
                Write-FortiCNAPPRequestLog `
                    -LogPath $LogPath `
                    -Entry ([ordered]@{
                        TimestampUtc = $completedAtUtc
                        SessionId = $sessionRecord.SessionId
                        EnvironmentName = $sessionRecord.EnvironmentName
                        Method = $Method
                        SafePath = $safePath
                        QueryParameterNames = $queryNames
                        Page = $pageCount
                        Attempt = $attemptNumber
                        StatusCode = $statusCode
                        Outcome = 'HttpError'
                        RetryScheduled = $canRetry
                        RetryDelaySeconds = $retryDelaySeconds
                        CorrelationId = $correlationId
                        RateLimitRemaining = $rateLimitRemaining
                    })

                if ($canRetry) {
                    Start-Sleep -Milliseconds ([int][math]::Round($retryDelaySeconds * 1000))
                    continue
                }

                Write-Error `
                    -Message "The FortiCNAPP request returned HTTP status $statusCode after $attemptNumber attempt(s)." `
                    -ErrorId 'PSFortiCNAPP.Request.HttpError' `
                    -Category InvalidResult `
                    -TargetObject $currentUri `
                    -ErrorAction Stop
            }
            catch {
                if ($_.FullyQualifiedErrorId -match '^PSFortiCNAPP\.Request\.(HttpError|InvalidJson)') {
                    throw
                }

                $completedAtUtc = [DateTimeOffset]::UtcNow
                $safeMessage = "Transport failure: $($_.Exception.GetType().Name)."
                $canRetryTransport = $attemptNumber -le $MaxRetryCount
                $retryDelaySeconds = if ($canRetryTransport) {
                    Get-FortiCNAPPRetryDelay `
                        -AttemptNumber $attemptNumber `
                        -InitialDelaySeconds $InitialRetryDelaySeconds `
                        -MaximumDelaySeconds $MaximumRetryDelaySeconds `
                        -JitterMaximumMilliseconds $JitterMaximumMilliseconds
                }
                else {
                    0
                }

                $allAttempts.Add([pscustomobject][ordered]@{
                    Page = $pageCount
                    Attempt = $attemptNumber
                    StartedAtUtc = $startedAtUtc
                    CompletedAtUtc = $completedAtUtc
                    DurationMilliseconds = [math]::Round(($completedAtUtc - $startedAtUtc).TotalMilliseconds, 3)
                    StatusCode = $null
                    Outcome = 'TransportError'
                    RetryScheduled = $canRetryTransport
                    RetryDelaySeconds = $retryDelaySeconds
                    CorrelationId = $null
                    RateLimitRemaining = $null
                })
                Write-FortiCNAPPRequestLog `
                    -LogPath $LogPath `
                    -Entry ([ordered]@{
                        TimestampUtc = $completedAtUtc
                        SessionId = $sessionRecord.SessionId
                        EnvironmentName = $sessionRecord.EnvironmentName
                        Method = $Method
                        SafePath = $safePath
                        QueryParameterNames = $queryNames
                        Page = $pageCount
                        Attempt = $attemptNumber
                        Outcome = 'TransportError'
                        RetryScheduled = $canRetryTransport
                        RetryDelaySeconds = $retryDelaySeconds
                        Message = $safeMessage
                    })

                if ($canRetryTransport) {
                    Start-Sleep -Milliseconds ([int][math]::Round($retryDelaySeconds * 1000))
                    continue
                }

                Write-Error `
                    -Message "The FortiCNAPP request failed after $attemptNumber attempt(s). $safeMessage" `
                    -ErrorId 'PSFortiCNAPP.Request.TransportFailure' `
                    -Category ConnectionError `
                    -TargetObject $currentUri `
                    -ErrorAction Stop
            }
        }

        if ($null -ne $lastParsedResponse) {
            $dataProperty = $lastParsedResponse.PSObject.Properties['data']
            if ($null -ne $dataProperty -and $null -ne $dataProperty.Value) {
                foreach ($record in @($dataProperty.Value)) {
                    $allData.Add($record)
                }
            }
            elseif ($pageCount -eq 1) {
                $allData.Add($lastParsedResponse)
            }
        }

        if (-not $AllPages -or $null -eq $lastParsedResponse) {
            $collectionComplete = $true
            break
        }

        $nextPageText = $null
        $pagingProperty = $lastParsedResponse.PSObject.Properties['paging']
        if ($null -ne $pagingProperty -and $null -ne $pagingProperty.Value) {
            $urlsProperty = $pagingProperty.Value.PSObject.Properties['urls']
            if ($null -ne $urlsProperty -and $null -ne $urlsProperty.Value) {
                $nextProperty = $urlsProperty.Value.PSObject.Properties['nextPage']
                if ($null -ne $nextProperty -and $null -ne $nextProperty.Value) {
                    $nextPageText = [string]$nextProperty.Value
                }
            }
        }

        if ([string]::IsNullOrWhiteSpace($nextPageText)) {
            $collectionComplete = $true
            break
        }

        $currentUri = New-FortiCNAPPRequestUri `
            -BaseUri $sessionRecord.BaseUri `
            -AbsoluteUri ([uri]$nextPageText)
    }

    $lastBodySha256 = if ($lastContentBytes.Length -eq 0) {
        $null
    }
    else {
        [Convert]::ToHexString(
            [System.Security.Cryptography.SHA256]::HashData($lastContentBytes)
        ).ToLowerInvariant()
    }

    $result = [pscustomobject][ordered]@{
        SessionId = $sessionRecord.SessionId
        EnvironmentName = $sessionRecord.EnvironmentName
        AccountName = $sessionRecord.AccountName
        Method = $Method
        RequestUri = [uri]::new($initialUri.GetLeftPart([UriPartial]::Path))
        QueryParameterNames = $queryNames
        StatusCode = $lastStatusCode
        PageCount = $pageCount
        RecordCount = $allData.Count
        CollectionComplete = $collectionComplete
        Data = $allData.ToArray()
        Attempts = $allAttempts.ToArray()
        CorrelationId = Get-FortiCNAPPHeaderValue -Headers $lastHeaders -Name 'X-Request-Id'
        RateLimit = [pscustomobject][ordered]@{
            Limit = Get-FortiCNAPPHeaderValue -Headers $lastHeaders -Name 'RateLimit-Limit'
            Remaining = Get-FortiCNAPPHeaderValue -Headers $lastHeaders -Name 'RateLimit-Remaining'
            Reset = Get-FortiCNAPPHeaderValue -Headers $lastHeaders -Name 'RateLimit-Reset'
        }
        LastBodyLengthBytes = $lastContentBytes.Length
        LastBodySha256 = $lastBodySha256
        RawResponseReturned = $false
        SensitiveValuesExposed = $false
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.ApiResponse')

    return $result
}
