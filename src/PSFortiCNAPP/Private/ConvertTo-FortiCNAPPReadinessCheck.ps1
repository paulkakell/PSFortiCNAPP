# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function ConvertTo-FortiCNAPPReadinessCheck {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Pass', 'Warning', 'Fail', 'NotApplicable')]
        [string]$Status,

        [Parameter(Mandatory)]
        [bool]$Required,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Evidence = '',

        [Parameter()]
        [AllowEmptyString()]
        [string]$Remediation = ''
    )

    $result = [pscustomobject][ordered]@{
        Name        = $Name
        Status      = $Status
        Required    = $Required
        Message     = $Message
        Evidence    = $Evidence
        Remediation = $Remediation
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.EnvironmentCheck')

    return $result
}
