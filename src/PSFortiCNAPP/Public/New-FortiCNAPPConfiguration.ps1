# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function New-FortiCNAPPConfiguration {
    <#
    .SYNOPSIS
    Creates a secret-free FortiCNAPP connection configuration.

    .DESCRIPTION
    Builds and validates the tenant authority, temporary-token endpoint, key
    identifier, environment label, and requested token lifetime. No secret or
    bearer token is accepted or stored.

    .PARAMETER AccountName
    FortiCNAPP account name used to derive the standard tenant authority when
    BaseUri is not supplied.

    .PARAMETER KeyId
    API key identifier. This value is not the API secret.

    .PARAMETER EnvironmentName
    Operator-defined environment label.

    .PARAMETER BaseUri
    Optional explicit HTTPS tenant authority. Use only after verification.

    .PARAMETER TokenLifetimeSeconds
    Explicit temporary-token lifetime sent to the provider. The project default
    is 3600 seconds. Current provider acceptance remains authoritative.

    .OUTPUTS
    PSFortiCNAPP.Configuration
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AccountName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentName = 'Default',

        [Parameter()]
        [AllowNull()]
        [uri]$BaseUri,

        [Parameter()]
        [ValidateRange(1, 2147483647)]
        [int]$TokenLifetimeSeconds = 3600
    )

    $resolvedBaseUri = Resolve-FortiCNAPPBaseUri `
        -AccountName $AccountName `
        -BaseUri $BaseUri
    $tokenEndpoint = [uri]::new(
        $resolvedBaseUri,
        'api/v2/access/tokens'
    )

    $configuration = [pscustomobject][ordered]@{
        EnvironmentName      = $EnvironmentName.Trim()
        AccountName          = $AccountName.Trim().ToLowerInvariant()
        BaseUri              = $resolvedBaseUri
        TokenEndpoint        = $tokenEndpoint
        AuthenticationMode   = 'AccountApiKey'
        KeyId                = $KeyId.Trim()
        KeyIdDisplay         = Get-FortiCNAPPKeyIdDisplay -KeyId $KeyId
        TokenLifetimeSeconds = $TokenLifetimeSeconds
        ContainsSecret       = $false
        CreatedAtUtc         = [DateTimeOffset]::UtcNow
    }
    $configuration.PSObject.TypeNames.Insert(
        0,
        'PSFortiCNAPP.Configuration'
    )

    $validation = Test-FortiCNAPPConfiguration `
        -Configuration $configuration
    if (-not $validation.Valid) {
        Write-Error `
            -Message 'The FortiCNAPP configuration failed local validation.' `
            -ErrorId 'PSFortiCNAPP.Configuration.Invalid' `
            -Category InvalidData `
            -TargetObject $validation `
            -ErrorAction Stop
    }

    return $configuration
}
