# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPHeaderValue {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Headers,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    if ($Headers -is [System.Collections.IDictionary]) {
        foreach ($key in $Headers.Keys) {
            if ([string]$key -ieq $Name) {
                $value = $Headers[$key]
                if ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
                    return (@($value) -join ',')
                }

                return [string]$value
            }
        }

        return $null
    }

    foreach ($property in $Headers.PSObject.Properties) {
        if ($property.Name -ieq $Name) {
            $value = $property.Value
            if ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
                return (@($value) -join ',')
            }

            return [string]$value
        }
    }

    return $null
}
