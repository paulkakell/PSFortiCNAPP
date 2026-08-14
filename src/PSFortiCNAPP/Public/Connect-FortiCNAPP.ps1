# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Connect-FortiCNAPP {
    <#
    .SYNOPSIS
    Requests a temporary access token and creates an explicit session.

    .DESCRIPTION
    Validates a secret-free configuration, uses the supplied SecureString only
    for the temporary-token request, validates the response, stores the bearer
    token in module-private session state, and returns a safe session object.

    The returned object does not contain the API secret or bearer token.

    .PARAMETER Configuration
    A configuration created by New-FortiCNAPPConfiguration or an equivalent
    object that passes Test-FortiCNAPPConfiguration.

    .PARAMETER Secret
    API secret supplied as SecureString.

    .PARAMETER TimeoutSeconds
    Request timeout in seconds.

    .EXAMPLE
    $secret = Read-Host 'API secret' -AsSecureString
    $session = Connect-FortiCNAPP `
        -Configuration $configuration `
        -Secret $secret

    .OUTPUTS
    PSFortiCNAPP.Session
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
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

    $validation = Test-FortiCNAPPConfiguration `
        -Configuration $Configuration
    if (-not $validation.Valid) {
        Write-Error `
            -Message 'The FortiCNAPP configuration failed local validation.' `
            -ErrorId 'PSFortiCNAPP.Authentication.InvalidConfiguration' `
            -Category InvalidData `
            -TargetObject $validation `
            -ErrorAction Stop
    }

    if (
        -not $PSCmdlet.ShouldProcess(
            $Configuration.BaseUri.AbsoluteUri,
            'Request a temporary FortiCNAPP access token'
        )
    ) {
        return
    }

    $response = Invoke-FortiCNAPPTokenRequest `
        -Configuration $Configuration `
        -Secret $Secret `
        -TimeoutSeconds $TimeoutSeconds

    $tokenProperty = $response.PSObject.Properties['token']
    $expiresProperty = $response.PSObject.Properties['expiresAt']
    if (
        $null -eq $tokenProperty -or
        [string]::IsNullOrWhiteSpace([string]$tokenProperty.Value) -or
        $null -eq $expiresProperty -or
        [string]::IsNullOrWhiteSpace([string]$expiresProperty.Value)
    ) {
        Write-Error `
            -Message 'The temporary-token response did not contain the required token and expiresAt values.' `
            -ErrorId 'PSFortiCNAPP.Authentication.InvalidTokenResponse' `
            -Category InvalidData `
            -TargetObject $Configuration.TokenEndpoint `
            -ErrorAction Stop
    }

    $expiresText = ([string]$expiresProperty.Value).Trim()
    if ($expiresText -notmatch '(?i)(Z|[+-]\d{2}:\d{2})$') {
        Write-Error `
            -Message 'The temporary-token expiration must include Z or an explicit UTC offset.' `
            -ErrorId 'PSFortiCNAPP.Authentication.InvalidTokenResponse' `
            -Category InvalidData `
            -TargetObject $Configuration.TokenEndpoint `
            -ErrorAction Stop
    }

    $dateTimeStyles = (
        [System.Globalization.DateTimeStyles]::AssumeUniversal -bor
        [System.Globalization.DateTimeStyles]::AdjustToUniversal
    )
    $expiresAtUtc = [DateTimeOffset]::MinValue
    if (
        -not [DateTimeOffset]::TryParse(
            $expiresText,
            [System.Globalization.CultureInfo]::InvariantCulture,
            $dateTimeStyles,
            [ref]$expiresAtUtc
        )
    ) {
        Write-Error `
            -Message 'The temporary-token expiration could not be parsed.' `
            -ErrorId 'PSFortiCNAPP.Authentication.InvalidTokenResponse' `
            -Category InvalidData `
            -TargetObject $Configuration.TokenEndpoint `
            -ErrorAction Stop
    }

    $connectedAtUtc = [DateTimeOffset]::UtcNow
    $expiresAtUtc = $expiresAtUtc.ToUniversalTime()
    if ($expiresAtUtc -le $connectedAtUtc) {
        Write-Error `
            -Message 'The temporary-token response was already expired.' `
            -ErrorId 'PSFortiCNAPP.Authentication.ExpiredTokenResponse' `
            -Category InvalidData `
            -TargetObject $Configuration.TokenEndpoint `
            -ErrorAction Stop
    }

    $sessionId = [guid]::NewGuid().ToString('N')
    $sessionRecord = [pscustomobject][ordered]@{
        SessionId            = $sessionId
        EnvironmentName      = $Configuration.EnvironmentName
        AccountName          = $Configuration.AccountName
        BaseUri              = $Configuration.BaseUri
        AuthenticationMode   = $Configuration.AuthenticationMode
        KeyIdDisplay         = Get-FortiCNAPPKeyIdDisplay `
            -KeyId $Configuration.KeyId
        ConnectedAtUtc       = $connectedAtUtc
        ExpiresAtUtc         = $expiresAtUtc
        TokenLifetimeSeconds = $Configuration.TokenLifetimeSeconds
        AccessToken          = [string]$tokenProperty.Value
    }

    $script:FortiCNAPPSessionStore.Add(
        $sessionId,
        $sessionRecord
    )

    $response = $null
    $tokenProperty = $null

    return New-FortiCNAPPSessionObject `
        -SessionRecord $sessionRecord
}
