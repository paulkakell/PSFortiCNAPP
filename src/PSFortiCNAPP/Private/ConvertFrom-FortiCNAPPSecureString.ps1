# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function ConvertFrom-FortiCNAPPSecureString {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [securestring]$SecureString
    )

    $credential = [pscredential]::new(
        'PSFortiCNAPP',
        $SecureString
    )

    return $credential.GetNetworkCredential().Password
}
