# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPKeyIdDisplay {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyId
    )

    $normalizedKeyId = $KeyId.Trim()
    if ($normalizedKeyId.Length -le 4) {
        return '****'
    }

    return '****{0}' -f $normalizedKeyId.Substring(
        $normalizedKeyId.Length - 4,
        4
    )
}
