# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

$script:TestFortiCNAPPConfigurationCore = (
    Get-Command -Name Test-FortiCNAPPConfiguration -CommandType Function
).ScriptBlock

function Test-FortiCNAPPConfiguration {
    <#
    .SYNOPSIS
    Validates a FortiCNAPP connection configuration without making a request.

    .DESCRIPTION
    Preserves the public Chapter 5 validation contract while treating the
    boolean ContainsSecret marker as metadata rather than secret material. A
    true marker still fails validation. Other credential-shaped properties are
    passed to the core validator unchanged and fail its embedded-secret check.

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
        $containsSecretProperty = $Configuration.PSObject.Properties['ContainsSecret']
        if (
            $null -eq $containsSecretProperty -or
            [bool]$containsSecretProperty.Value
        ) {
            return & $script:TestFortiCNAPPConfigurationCore `
                -Configuration $Configuration
        }

        $safeProperties = [ordered]@{}
        foreach ($property in $Configuration.PSObject.Properties) {
            if ($property.Name -ne 'ContainsSecret') {
                $safeProperties[$property.Name] = $property.Value
            }
        }

        return & $script:TestFortiCNAPPConfigurationCore `
            -Configuration ([pscustomobject]$safeProperties)
    }
}
