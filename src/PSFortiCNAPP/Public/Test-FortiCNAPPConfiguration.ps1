# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Test-FortiCNAPPConfiguration {
    <#
    .SYNOPSIS
    Validates a FortiCNAPP connection configuration without making a request.

    .DESCRIPTION
    Checks the configuration shape, HTTPS authority, token endpoint, key
    identifier, token lifetime, and absence of embedded secret properties. The
    command performs local validation only and returns a structured result.

    .PARAMETER Configuration
    Configuration-shaped object to validate.

    .OUTPUTS
    PSFortiCNAPP.ConfigurationValidation
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [psobject]$Configuration
    )

    process {
        $checks = [System.Collections.Generic.List[object]]::new()

        function Add-ConfigurationCheck {
            param(
                [string]$Name,
                [ValidateSet('Pass', 'Warning', 'Fail')]
                [string]$Status,
                [string]$Message
            )

            $checks.Add(
                [pscustomobject][ordered]@{
                    Name    = $Name
                    Status  = $Status
                    Message = $Message
                }
            )
        }

        $environmentProperty = $Configuration.PSObject.Properties['EnvironmentName']
        $environmentName = if ($null -eq $environmentProperty) {
            $null
        }
        else {
            [string]$environmentProperty.Value
        }
        if ([string]::IsNullOrWhiteSpace($environmentName)) {
            Add-ConfigurationCheck `
                -Name 'EnvironmentName' `
                -Status Fail `
                -Message 'EnvironmentName is required.'
        }
        else {
            Add-ConfigurationCheck `
                -Name 'EnvironmentName' `
                -Status Pass `
                -Message 'EnvironmentName is present.'
        }

        $accountProperty = $Configuration.PSObject.Properties['AccountName']
        $accountName = if ($null -eq $accountProperty) {
            $null
        }
        else {
            [string]$accountProperty.Value
        }
        if (
            [string]::IsNullOrWhiteSpace($accountName) -or
            $accountName.Trim() -notmatch '^[A-Za-z0-9][A-Za-z0-9-]{0,62}$'
        ) {
            Add-ConfigurationCheck `
                -Name 'AccountName' `
                -Status Fail `
                -Message 'AccountName is missing or has an unsupported shape.'
        }
        else {
            Add-ConfigurationCheck `
                -Name 'AccountName' `
                -Status Pass `
                -Message 'AccountName has the expected local shape.'
        }

        $keyIdProperty = $Configuration.PSObject.Properties['KeyId']
        $keyId = if ($null -eq $keyIdProperty) {
            $null
        }
        else {
            [string]$keyIdProperty.Value
        }
        if ([string]::IsNullOrWhiteSpace($keyId)) {
            Add-ConfigurationCheck `
                -Name 'KeyId' `
                -Status Fail `
                -Message 'KeyId is required.'
        }
        else {
            Add-ConfigurationCheck `
                -Name 'KeyId' `
                -Status Pass `
                -Message 'KeyId is present. Its authorization remains tenant dependent.'
        }

        $baseUri = $null
        $baseUriProperty = $Configuration.PSObject.Properties['BaseUri']
        if (
            $null -ne $baseUriProperty -and
            $null -ne $baseUriProperty.Value
        ) {
            [void][uri]::TryCreate(
                [string]$baseUriProperty.Value,
                [UriKind]::Absolute,
                [ref]$baseUri
            )
        }

        if (
            $null -eq $baseUri -or
            $baseUri.Scheme -ne 'https' -or
            -not [string]::IsNullOrWhiteSpace($baseUri.UserInfo) -or
            -not [string]::IsNullOrWhiteSpace($baseUri.Query) -or
            -not [string]::IsNullOrWhiteSpace($baseUri.Fragment) -or
            $baseUri.AbsolutePath -notin @('', '/')
        ) {
            Add-ConfigurationCheck `
                -Name 'BaseUri' `
                -Status Fail `
                -Message 'BaseUri must be an absolute HTTPS tenant authority without credentials, query, fragment, or additional path.'
        }
        else {
            Add-ConfigurationCheck `
                -Name 'BaseUri' `
                -Status Pass `
                -Message 'BaseUri satisfies the local HTTPS authority contract.'

            if (
                $baseUri.Host -notlike '*.lacework.net' -and
                $baseUri.Host -notlike '*.example.invalid'
            ) {
                Add-ConfigurationCheck `
                    -Name 'BaseUriHost' `
                    -Status Warning `
                    -Message 'The host is outside the documented lacework.net pattern and the reserved synthetic example pattern. Verify it before use.'
            }
            else {
                Add-ConfigurationCheck `
                    -Name 'BaseUriHost' `
                    -Status Pass `
                    -Message 'The host matches a documented or reserved synthetic pattern.'
            }
        }

        $tokenEndpoint = $null
        $tokenEndpointProperty = $Configuration.PSObject.Properties['TokenEndpoint']
        if (
            $null -ne $tokenEndpointProperty -and
            $null -ne $tokenEndpointProperty.Value
        ) {
            [void][uri]::TryCreate(
                [string]$tokenEndpointProperty.Value,
                [UriKind]::Absolute,
                [ref]$tokenEndpoint
            )
        }

        if (
            $null -eq $tokenEndpoint -or
            $tokenEndpoint.Scheme -ne 'https' -or
            $tokenEndpoint.AbsolutePath -ne '/api/v2/access/tokens' -or
            -not [string]::IsNullOrWhiteSpace($tokenEndpoint.Query) -or
            -not [string]::IsNullOrWhiteSpace($tokenEndpoint.Fragment)
        ) {
            Add-ConfigurationCheck `
                -Name 'TokenEndpoint' `
                -Status Fail `
                -Message 'TokenEndpoint must use HTTPS and the documented /api/v2/access/tokens path.'
        }
        elseif (
            $null -ne $baseUri -and
            $tokenEndpoint.Authority -ne $baseUri.Authority
        ) {
            Add-ConfigurationCheck `
                -Name 'TokenEndpoint' `
                -Status Fail `
                -Message 'TokenEndpoint must use the same authority as BaseUri.'
        }
        else {
            Add-ConfigurationCheck `
                -Name 'TokenEndpoint' `
                -Status Pass `
                -Message 'TokenEndpoint satisfies the local endpoint contract.'
        }

        $lifetimeProperty = $Configuration.PSObject.Properties['TokenLifetimeSeconds']
        $tokenLifetimeSeconds = 0
        $lifetimeIsValid = (
            $null -ne $lifetimeProperty -and
            [int]::TryParse(
                [string]$lifetimeProperty.Value,
                [ref]$tokenLifetimeSeconds
            ) -and
            $tokenLifetimeSeconds -gt 0
        )
        if (-not $lifetimeIsValid) {
            Add-ConfigurationCheck `
                -Name 'TokenLifetimeSeconds' `
                -Status Fail `
                -Message 'TokenLifetimeSeconds must be a positive integer.'
        }
        else {
            Add-ConfigurationCheck `
                -Name 'TokenLifetimeSeconds' `
                -Status Pass `
                -Message 'TokenLifetimeSeconds is explicit and positive.'

            if ($tokenLifetimeSeconds -gt 3600) {
                Add-ConfigurationCheck `
                    -Name 'TokenLifetimePolicy' `
                    -Status Warning `
                    -Message 'The requested lifetime exceeds the project default of 3600 seconds. Confirm the operational need and current provider limit.'
            }
        }

        $secretPropertyNames = @(
            $Configuration.PSObject.Properties.Name |
                Where-Object -FilterScript {
                    $_ -match '(?i)secret|password|access.?token|bearer'
                }
        )
        if ($secretPropertyNames.Count -gt 0) {
            Add-ConfigurationCheck `
                -Name 'EmbeddedSecrets' `
                -Status Fail `
                -Message 'Configuration objects cannot contain secret or bearer-token properties.'
        }
        else {
            Add-ConfigurationCheck `
                -Name 'EmbeddedSecrets' `
                -Status Pass `
                -Message 'No credential-shaped property name is present.'
        }

        $failed = @($checks | Where-Object Status -EQ 'Fail')
        $warnings = @($checks | Where-Object Status -EQ 'Warning')
        $passed = @($checks | Where-Object Status -EQ 'Pass')

        $result = [pscustomobject][ordered]@{
            EnvironmentName = $environmentName
            AccountName     = $accountName
            BaseUri         = $baseUri
            Valid           = $failed.Count -eq 0
            CheckCount      = $checks.Count
            PassCount       = $passed.Count
            WarningCount    = $warnings.Count
            FailCount       = $failed.Count
            Checks          = $checks.ToArray()
        }
        $result.PSObject.TypeNames.Insert(
            0,
            'PSFortiCNAPP.ConfigurationValidation'
        )

        return $result
    }
}
