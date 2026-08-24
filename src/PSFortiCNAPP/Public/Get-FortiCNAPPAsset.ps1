# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPAsset {
    <#
    .SYNOPSIS
    Collects FortiCNAPP inventory records through the documented API v2 search route.

    .DESCRIPTION
    Builds the documented Inventory search body, converts UTC boundaries to Unix
    epoch milliseconds, delegates transport and pagination to
    Invoke-FortiCNAPPRequest, and returns provider records with explicit scope
    and collection metadata.

    The command does not guess provider record fields. ProviderRecords remain
    unnormalized until a controlled tenant fixture and schema contract are
    approved.

    .PARAMETER Session
    Connected PSFortiCNAPP session.

    .PARAMETER StartTimeUtc
    Inclusive collection-window start.

    .PARAMETER EndTimeUtc
    Exclusive collection-window end.

    .PARAMETER TimeField
    Provider time-filter field. The controlled API source uses
    createdOrUpdatedTime as an example. Applicability remains tenant dependent.

    .PARAMETER PageSize
    Requested rows per page. The controlled API source documents a maximum of
    5000.

    .PARAMETER Return
    Optional provider field names requested through the documented returns array.

    .PARAMETER Filter
    Optional provider filters passed without local field interpretation.

    .PARAMETER Sort
    Optional provider sort definitions passed without local field interpretation.

    .PARAMETER MaxPageCount
    Maximum continuation pages.

    .PARAMETER LogPath
    Optional redacted JSON Lines request log.

    .OUTPUTS
    PSFortiCNAPP.AssetInventoryResult
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$Session,

        [Parameter(Mandatory)]
        [DateTimeOffset]$StartTimeUtc,

        [Parameter(Mandatory)]
        [DateTimeOffset]$EndTimeUtc,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$TimeField = 'createdOrUpdatedTime',

        [Parameter()]
        [ValidateRange(1, 5000)]
        [int]$PageSize = 5000,

        [Parameter()]
        [string[]]$Return,

        [Parameter()]
        [object[]]$Filter,

        [Parameter()]
        [object[]]$Sort,

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$MaxPageCount = 100,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LogPath
    )

    $startUtc = $StartTimeUtc.ToUniversalTime()
    $endUtc = $EndTimeUtc.ToUniversalTime()
    if ($endUtc -le $startUtc) {
        Write-Error `
            -Message 'EndTimeUtc must be later than StartTimeUtc.' `
            -ErrorId 'PSFortiCNAPP.Asset.InvalidTimeWindow' `
            -Category InvalidArgument `
            -TargetObject $EndTimeUtc `
            -ErrorAction Stop
    }

    if ($TimeField.Trim() -notmatch '^[A-Za-z][A-Za-z0-9_.-]{0,127}$') {
        Write-Error `
            -Message 'TimeField has an unsupported local shape.' `
            -ErrorId 'PSFortiCNAPP.Asset.InvalidTimeField' `
            -Category InvalidArgument `
            -TargetObject $TimeField `
            -ErrorAction Stop
    }

    $requestBody = [ordered]@{
        timeFilter = [ordered]@{
            field     = $TimeField.Trim()
            startTime = $startUtc.ToUnixTimeMilliseconds()
            endTime   = $endUtc.ToUnixTimeMilliseconds()
        }
        pageFilter = [ordered]@{
            page = 1
            rows = $PageSize
        }
    }

    if ($null -ne $Return -and $Return.Count -gt 0) {
        $requestBody['returns'] = @($Return)
    }
    if ($null -ne $Filter -and $Filter.Count -gt 0) {
        $requestBody['filters'] = @($Filter)
    }
    if ($null -ne $Sort -and $Sort.Count -gt 0) {
        $requestBody['sort'] = @($Sort)
    }

    $response = Invoke-FortiCNAPPRequest `
        -Session $Session `
        -Method POST `
        -Path 'Inventory/search' `
        -Body $requestBody `
        -AllPages `
        -MaxPageCount $MaxPageCount `
        -LogPath $LogPath

    $result = [pscustomobject][ordered]@{
        EnvironmentName        = $response.EnvironmentName
        AccountName            = $response.AccountName
        CollectedAtUtc         = [DateTimeOffset]::UtcNow
        StartTimeUtc           = $startUtc
        EndTimeUtc             = $endUtc
        TimeField              = $TimeField.Trim()
        RequestedPageSize      = $PageSize
        PageCount              = $response.PageCount
        RecordCount            = $response.RecordCount
        CollectionComplete     = $response.CollectionComplete
        CorrelationId          = $response.CorrelationId
        RateLimit              = $response.RateLimit
        ProviderRecords        = @($response.Data)
        ProviderRecordShape    = 'Unnormalized'
        TenantValidationState  = 'VERIFY IN TENANT'
        SensitiveValuesExposed = $false
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.AssetInventoryResult')

    return $result
}
