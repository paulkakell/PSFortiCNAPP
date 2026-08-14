# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

$script:NewFortiCNAPPConfigurationCore = (
    Get-Command -Name New-FortiCNAPPConfiguration -CommandType Function
).ScriptBlock

function New-FortiCNAPPConfiguration {
    <#
    .SYNOPSIS
    Creates a secret-free FortiCNAPP connection configuration.

    .DESCRIPTION
    Calls the Chapter 5 constructor and removes its internal ContainsSecret
    validation marker before returning the public object. The configuration
    retains no secret-shaped property name or credential value.

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

    $parameters = @{
        AccountName          = $AccountName
        KeyId                = $KeyId
        EnvironmentName      = $EnvironmentName
        TokenLifetimeSeconds = $TokenLifetimeSeconds
    }
    if ($PSBoundParameters.ContainsKey('BaseUri')) {
        $parameters.BaseUri = $BaseUri
    }

    $configuration = & $script:NewFortiCNAPPConfigurationCore @parameters
    $configuration.PSObject.Properties.Remove('ContainsSecret')

    return $configuration
}
