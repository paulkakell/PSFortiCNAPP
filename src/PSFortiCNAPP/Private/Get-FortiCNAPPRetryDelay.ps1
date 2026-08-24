# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPRetryDelay {
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 20)]
        [int]$Attempt,

        [Parameter(Mandatory)]
        [ValidateRange(0.01, 120)]
        [double]$InitialDelaySeconds,

        [Parameter()]
        [AllowNull()]
        [object]$Headers,

        [Parameter()]
        [ValidateRange(0, 5000)]
        [int]$JitterMaximumMilliseconds = 250
    )

    foreach ($headerName in @('Retry-After', 'RateLimit-Reset')) {
        if ($null -eq $Headers) {
            break
        }

        $headerValue = Get-FortiCNAPPHeaderValue `
            -Headers $Headers `
            -Name $headerName
        $seconds = 0.0
        if (
            -not [string]::IsNullOrWhiteSpace($headerValue) -and
            [double]::TryParse(
                $headerValue,
                [System.Globalization.NumberStyles]::Float,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [ref]$seconds
            ) -and
            $seconds -ge 0
        ) {
            return [math]::Round($seconds, 3)
        }
    }

    $baseDelay = $InitialDelaySeconds * [math]::Pow(2, $Attempt - 1)
    $jitterSeconds = if ($JitterMaximumMilliseconds -eq 0) {
        0.0
    }
    else {
        (Get-Random -Minimum 0 -Maximum ($JitterMaximumMilliseconds + 1)) / 1000.0
    }

    return [math]::Round($baseDelay + $jitterSeconds, 3)
}
