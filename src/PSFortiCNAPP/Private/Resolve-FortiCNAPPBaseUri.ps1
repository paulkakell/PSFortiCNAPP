# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Resolve-FortiCNAPPBaseUri {
    [CmdletBinding()]
    [OutputType([uri])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AccountName,

        [Parameter()]
        [AllowNull()]
        [uri]$BaseUri
    )

    $normalizedAccountName = $AccountName.Trim()
    if ($normalizedAccountName -notmatch '^[A-Za-z0-9][A-Za-z0-9-]{0,62}$') {
        Write-Error `
            -Message 'AccountName must contain letters, numbers, or hyphens and cannot begin with a hyphen.' `
            -ErrorId 'PSFortiCNAPP.Configuration.InvalidAccountName' `
            -Category InvalidArgument `
            -TargetObject $AccountName `
            -ErrorAction Stop
    }

    $candidate = if ($null -eq $BaseUri) {
        [uri](
            'https://{0}.lacework.net/' -f
            $normalizedAccountName.ToLowerInvariant()
        )
    }
    else {
        $BaseUri
    }

    if (-not $candidate.IsAbsoluteUri -or $candidate.Scheme -ne 'https') {
        Write-Error `
            -Message 'BaseUri must be an absolute HTTPS URI.' `
            -ErrorId 'PSFortiCNAPP.Configuration.InvalidBaseUri' `
            -Category InvalidArgument `
            -TargetObject $candidate `
            -ErrorAction Stop
    }

    if (
        -not [string]::IsNullOrWhiteSpace($candidate.UserInfo) -or
        -not [string]::IsNullOrWhiteSpace($candidate.Query) -or
        -not [string]::IsNullOrWhiteSpace($candidate.Fragment)
    ) {
        Write-Error `
            -Message 'BaseUri cannot contain user information, a query, or a fragment.' `
            -ErrorId 'PSFortiCNAPP.Configuration.InvalidBaseUri' `
            -Category InvalidArgument `
            -TargetObject $candidate `
            -ErrorAction Stop
    }

    if ($candidate.AbsolutePath -notin @('', '/')) {
        Write-Error `
            -Message 'BaseUri must identify the tenant authority without an additional path.' `
            -ErrorId 'PSFortiCNAPP.Configuration.InvalidBaseUri' `
            -Category InvalidArgument `
            -TargetObject $candidate `
            -ErrorAction Stop
    }

    $builder = [UriBuilder]::new($candidate)
    $builder.Path = '/'
    $builder.Query = ''
    $builder.Fragment = ''

    return $builder.Uri
}
