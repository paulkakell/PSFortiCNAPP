# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Invoke-FortiCNAPPHttpTransport {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [uri]$Uri,

        [Parameter(Mandatory)]
        [ValidateSet('GET', 'POST')]
        [string]$Method,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [hashtable]$Headers,

        [Parameter()]
        [AllowNull()]
        [string]$Body,

        [Parameter(Mandatory)]
        [ValidateRange(1, 300)]
        [int]$TimeoutSeconds
    )

    $parameters = @{
        Uri                = $Uri
        Method             = $Method
        Headers            = $Headers
        TimeoutSec         = $TimeoutSeconds
        SkipHttpErrorCheck = $true
        ErrorAction        = 'Stop'
    }

    if ($null -ne $Body) {
        $parameters.Body = $Body
        $parameters.ContentType = 'application/json'
    }

    $response = Invoke-WebRequest @parameters

    [pscustomobject][ordered]@{
        StatusCode = [int]$response.StatusCode
        Headers    = $response.Headers
        Content    = [string]$response.Content
    }
}
