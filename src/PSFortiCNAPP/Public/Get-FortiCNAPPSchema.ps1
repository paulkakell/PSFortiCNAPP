# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPSchema {
    <#
    .SYNOPSIS
    Retrieves documented FortiCNAPP API v2 schema metadata.

    .DESCRIPTION
    Calls the documented schemas route through Invoke-FortiCNAPPRequest. Type and
    Subtype remain tenant and release dependent. The command returns the provider
    response without inventing or narrowing additional properties.

    .PARAMETER Session
    Connected PSFortiCNAPP session.

    .PARAMETER Type
    Optional schema type. When omitted, the documented schema-list route is used.

    .PARAMETER Subtype
    Optional subtype. Type is required when Subtype is supplied.

    .OUTPUTS
    PSFortiCNAPP.SchemaResult
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$Session,

        [Parameter()]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Type,

        [Parameter()]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Subtype
    )

    if (-not [string]::IsNullOrWhiteSpace($Subtype) -and [string]::IsNullOrWhiteSpace($Type)) {
        Write-Error `
            -Message 'Type is required when Subtype is supplied.' `
            -ErrorId 'PSFortiCNAPP.Schema.TypeRequired' `
            -Category InvalidArgument `
            -TargetObject $Subtype `
            -ErrorAction Stop
    }

    $path = if ([string]::IsNullOrWhiteSpace($Type)) {
        'schemas'
    }
    elseif ([string]::IsNullOrWhiteSpace($Subtype)) {
        'schemas/{0}' -f [uri]::EscapeDataString($Type)
    }
    else {
        'schemas/{0}/{1}' -f
            [uri]::EscapeDataString($Type),
            [uri]::EscapeDataString($Subtype)
    }

    $response = Invoke-FortiCNAPPRequest `
        -Session $Session `
        -Method GET `
        -Path $path

    $result = [pscustomobject][ordered]@{
        Type                        = $Type
        Subtype                     = $Subtype
        RetrievedAtUtc              = [DateTimeOffset]::UtcNow
        StatusCode                  = $response.StatusCode
        Schema                      = $response.Data
        CorrelationId               = $response.CorrelationId
        SourcePath                  = $response.RequestUri.AbsolutePath
        TenantValidationState       = 'VERIFY IN TENANT'
        AdditionalPropertiesAllowed = $true
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.SchemaResult')

    return $result
}
