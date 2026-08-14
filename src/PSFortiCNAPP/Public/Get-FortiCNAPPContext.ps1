# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPContext {
    <#
    .SYNOPSIS
    Returns non-sensitive state for a FortiCNAPP session.

    .DESCRIPTION
    Resolves the session against module-private state and reports connection,
    expiration, tenant, environment, and remaining-lifetime information. It does
    not return the API secret or bearer token.

    .PARAMETER Session
    Session object returned by Connect-FortiCNAPP.

    .OUTPUTS
    PSFortiCNAPP.Context
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [psobject]$Session
    )

    process {
        $record = Get-FortiCNAPPSessionRecord `
            -Session $Session `
            -AllowMissing
        $checkedAtUtc = [DateTimeOffset]::UtcNow

        if ($null -eq $record) {
            $context = [pscustomobject][ordered]@{
                SessionId             = $Session.SessionId
                EnvironmentName       = $Session.EnvironmentName
                AccountName           = $Session.AccountName
                BaseUri               = $Session.BaseUri
                AuthenticationMode    = $Session.AuthenticationMode
                KeyIdDisplay          = $Session.KeyIdDisplay
                CheckedAtUtc          = $checkedAtUtc
                ConnectedAtUtc        = $Session.ConnectedAtUtc
                ExpiresAtUtc          = $Session.ExpiresAtUtc
                RemainingSeconds      = 0
                IsConnected           = $false
                IsExpired             = $null
                ReadyForRequest       = $false
                SensitiveValuesExposed = $false
            }
        }
        else {
            $remainingSeconds = [math]::Floor(
                ($record.ExpiresAtUtc - $checkedAtUtc).TotalSeconds
            )
            if ($remainingSeconds -lt 0) {
                $remainingSeconds = 0
            }
            $isExpired = $record.ExpiresAtUtc -le $checkedAtUtc

            $context = [pscustomobject][ordered]@{
                SessionId             = $record.SessionId
                EnvironmentName       = $record.EnvironmentName
                AccountName           = $record.AccountName
                BaseUri               = $record.BaseUri
                AuthenticationMode    = $record.AuthenticationMode
                KeyIdDisplay          = $record.KeyIdDisplay
                CheckedAtUtc          = $checkedAtUtc
                ConnectedAtUtc        = $record.ConnectedAtUtc
                ExpiresAtUtc          = $record.ExpiresAtUtc
                RemainingSeconds      = [int64]$remainingSeconds
                IsConnected           = $true
                IsExpired             = $isExpired
                ReadyForRequest       = -not $isExpired
                SensitiveValuesExposed = $false
            }
        }

        $context.PSObject.TypeNames.Insert(
            0,
            'PSFortiCNAPP.Context'
        )
        return $context
    }
}
