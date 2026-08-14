# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPSessionRecord {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$Session,

        [Parameter()]
        [switch]$AllowMissing
    )

    $sessionIdProperty = $Session.PSObject.Properties['SessionId']
    if (
        $null -eq $sessionIdProperty -or
        [string]::IsNullOrWhiteSpace([string]$sessionIdProperty.Value)
    ) {
        Write-Error `
            -Message 'The supplied object does not contain a valid SessionId.' `
            -ErrorId 'PSFortiCNAPP.Session.InvalidObject' `
            -Category InvalidArgument `
            -TargetObject $Session `
            -ErrorAction Stop
    }

    $sessionId = [string]$sessionIdProperty.Value
    if ($script:FortiCNAPPSessionStore.ContainsKey($sessionId)) {
        return $script:FortiCNAPPSessionStore[$sessionId]
    }

    if ($AllowMissing) {
        return $null
    }

    Write-Error `
        -Message 'The FortiCNAPP session is not connected in this module instance.' `
        -ErrorId 'PSFortiCNAPP.Session.NotConnected' `
        -Category ObjectNotFound `
        -TargetObject $Session `
        -ErrorAction Stop
}
