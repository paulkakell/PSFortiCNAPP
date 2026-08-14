# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Invoke-FortiCNAPPTokenRequest {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$Configuration,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [securestring]$Secret,

        [Parameter()]
        [ValidateRange(1, 300)]
        [int]$TimeoutSeconds = 30
    )

    $plainTextSecret = $null
    $headers = $null

    try {
        $plainTextSecret = ConvertFrom-FortiCNAPPSecureString `
            -SecureString $Secret
        if ([string]::IsNullOrWhiteSpace($plainTextSecret)) {
            Write-Error `
                -Message 'The supplied API secret is empty.' `
                -ErrorId 'PSFortiCNAPP.Authentication.EmptySecret' `
                -Category AuthenticationError `
                -ErrorAction Stop
        }

        $headers = @{
            Accept        = 'application/json'
            Authorization = 'Bearer {0}' -f $plainTextSecret
        }
        $requestBody = [ordered]@{
            keyId      = $Configuration.KeyId
            expiryTime = $Configuration.TokenLifetimeSeconds
        }
        $requestJson = $requestBody |
            ConvertTo-Json -Depth 5 -Compress

        return Invoke-RestMethod `
            -Method Post `
            -Uri $Configuration.TokenEndpoint `
            -Headers $headers `
            -ContentType 'application/json' `
            -Body $requestJson `
            -TimeoutSec $TimeoutSeconds `
            -ErrorAction Stop
    }
    catch {
        $statusCode = $null
        try {
            if ($null -ne $_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }
        }
        catch {
            $statusCode = $null
        }

        $errorId = switch ($statusCode) {
            401 { 'PSFortiCNAPP.Authentication.Unauthorized' }
            403 { 'PSFortiCNAPP.Authentication.Forbidden' }
            default { 'PSFortiCNAPP.Authentication.TokenRequestFailed' }
        }
        $message = if ($null -eq $statusCode) {
            'The temporary FortiCNAPP access-token request failed.'
        }
        else {
            'The temporary FortiCNAPP access-token request failed with HTTP status {0}.' -f $statusCode
        }

        Write-Error `
            -Message $message `
            -ErrorId $errorId `
            -Category AuthenticationError `
            -TargetObject $Configuration.TokenEndpoint `
            -ErrorAction Stop
    }
    finally {
        $plainTextSecret = $null
        $headers = $null
    }
}
