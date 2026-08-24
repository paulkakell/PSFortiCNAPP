# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function New-FortiCNAPPRequestUri {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Creates an in-memory URI description and changes no external or persistent state.'
    )]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [uri]$BaseUri,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [AllowNull()]
        [System.Collections.IDictionary]$Query
    )

    $trimmedPath = $Path.Trim()
    $absoluteUri = $null
    $isAbsolute = [uri]::TryCreate(
        $trimmedPath,
        [UriKind]::Absolute,
        [ref]$absoluteUri
    )

    if ($isAbsolute) {
        if (
            $absoluteUri.Scheme -ne 'https' -or
            $absoluteUri.Authority -ne $BaseUri.Authority -or
            -not $absoluteUri.AbsolutePath.StartsWith('/api/v2/', [System.StringComparison]::OrdinalIgnoreCase)
        ) {
            Write-Error `
                -Message 'An absolute request URI must use HTTPS, the connected tenant authority, and an /api/v2/ path.' `
                -ErrorId 'PSFortiCNAPP.Request.InvalidAbsoluteUri' `
                -Category InvalidArgument `
                -TargetObject $Path `
                -ErrorAction Stop
        }

        if ($null -ne $Query -and $Query.Count -gt 0) {
            Write-Error `
                -Message 'Query cannot be combined with an absolute continuation URI.' `
                -ErrorId 'PSFortiCNAPP.Request.AmbiguousQuery' `
                -Category InvalidArgument `
                -TargetObject $Path `
                -ErrorAction Stop
        }

        $uri = $absoluteUri
    }
    else {
        if (
            $trimmedPath.Contains('?') -or
            $trimmedPath.Contains('#') -or
            $trimmedPath -match '(^|/)\.\.(/|$)'
        ) {
            Write-Error `
                -Message 'Relative request paths cannot contain query text, fragments, or parent traversal.' `
                -ErrorId 'PSFortiCNAPP.Request.InvalidRelativePath' `
                -Category InvalidArgument `
                -TargetObject $Path `
                -ErrorAction Stop
        }

        $relativePath = $trimmedPath.TrimStart('/')
        if (-not $relativePath.StartsWith('api/v2/', [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = 'api/v2/{0}' -f $relativePath
        }

        $builder = [UriBuilder]::new([uri]::new($BaseUri, $relativePath))
        $queryParts = [System.Collections.Generic.List[string]]::new()

        if ($null -ne $Query) {
            foreach ($key in @($Query.Keys | Sort-Object)) {
                $name = ([string]$key).Trim()
                if ([string]::IsNullOrWhiteSpace($name)) {
                    Write-Error `
                        -Message 'Query parameter names cannot be empty.' `
                        -ErrorId 'PSFortiCNAPP.Request.InvalidQueryName' `
                        -Category InvalidArgument `
                        -TargetObject $Query `
                        -ErrorAction Stop
                }

                if ($name -match '(?i)authorization|access.?token|api.?secret|password') {
                    Write-Error `
                        -Message "Query parameter '$name' is not allowed because it appears credential shaped." `
                        -ErrorId 'PSFortiCNAPP.Request.SensitiveQueryName' `
                        -Category SecurityError `
                        -TargetObject $name `
                        -ErrorAction Stop
                }

                $values = if (
                    $Query[$key] -is [System.Collections.IEnumerable] -and
                    $Query[$key] -isnot [string]
                ) {
                    @($Query[$key])
                }
                else {
                    @($Query[$key])
                }

                foreach ($value in $values) {
                    if ($null -eq $value) {
                        continue
                    }

                    $queryParts.Add(
                        '{0}={1}' -f
                            [uri]::EscapeDataString($name),
                            [uri]::EscapeDataString([string]$value)
                    )
                }
            }
        }

        $builder.Query = $queryParts -join '&'
        $uri = $builder.Uri
    }

    $queryNames = [System.Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace($uri.Query)) {
        foreach ($part in $uri.Query.TrimStart('?') -split '&') {
            if (-not [string]::IsNullOrWhiteSpace($part)) {
                $queryNames.Add(
                    [uri]::UnescapeDataString(($part -split '=', 2)[0])
                )
            }
        }
    }

    [pscustomobject][ordered]@{
        Uri                 = $uri
        SafeUri             = [uri]::new($uri.GetLeftPart([UriPartial]::Path))
        QueryParameterNames = $queryNames.ToArray()
    }
}
