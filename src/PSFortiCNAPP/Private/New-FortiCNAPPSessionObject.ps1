# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function New-FortiCNAPPSessionObject {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$SessionRecord
    )

    $session = [pscustomobject][ordered]@{
        SessionId           = $SessionRecord.SessionId
        EnvironmentName     = $SessionRecord.EnvironmentName
        AccountName         = $SessionRecord.AccountName
        BaseUri             = $SessionRecord.BaseUri
        AuthenticationMode  = $SessionRecord.AuthenticationMode
        KeyIdDisplay        = $SessionRecord.KeyIdDisplay
        ConnectedAtUtc      = $SessionRecord.ConnectedAtUtc
        ExpiresAtUtc        = $SessionRecord.ExpiresAtUtc
        TokenLifetimeSeconds = $SessionRecord.TokenLifetimeSeconds
        IsConnected         = $true
    }
    $session.PSObject.TypeNames.Insert(
        0,
        'PSFortiCNAPP.Session'
    )

    return $session
}
