# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Disconnect-FortiCNAPP {
    <#
    .SYNOPSIS
    Removes a FortiCNAPP session from module-private state.

    .DESCRIPTION
    Clears the module-held bearer-token reference and removes the local session
    record. This command does not claim to revoke the provider token remotely.

    .PARAMETER Session
    Session object returned by Connect-FortiCNAPP.

    .OUTPUTS
    PSFortiCNAPP.DisconnectResult
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
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
        $wasConnected = $null -ne $record
        $removed = $false

        if (
            $wasConnected -and
            $PSCmdlet.ShouldProcess(
                [string]$Session.SessionId,
                'Remove the local FortiCNAPP session and clear its token reference'
            )
        ) {
            $record.AccessToken = $null
            $removed = $script:FortiCNAPPSessionStore.Remove(
                [string]$Session.SessionId
            )
        }

        $result = [pscustomobject][ordered]@{
            SessionId             = [string]$Session.SessionId
            EnvironmentName       = $Session.EnvironmentName
            AccountName           = $Session.AccountName
            WasConnected          = $wasConnected
            Disconnected          = $removed
            RemoteTokenRevoked    = $false
            CompletedAtUtc        = [DateTimeOffset]::UtcNow
            SensitiveValuesExposed = $false
        }
        $result.PSObject.TypeNames.Insert(
            0,
            'PSFortiCNAPP.DisconnectResult'
        )

        return $result
    }
}
