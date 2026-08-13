# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Get-FortiCNAPPModuleInfo {
    <#
    .SYNOPSIS
    Returns non-sensitive information about the loaded PSFortiCNAPP module.

    .DESCRIPTION
    Produces a structured object describing the loaded module version, runtime
    baseline, supported operating systems, distribution policy, project URI,
    module path, and license allocation. The command performs no network call.

    .EXAMPLE
    Get-FortiCNAPPModuleInfo

    .OUTPUTS
    PSFortiCNAPP.ModuleInfo
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $module = $MyInvocation.MyCommand.Module
    if ($null -eq $module) {
        throw 'Get-FortiCNAPPModuleInfo must run from the imported PSFortiCNAPP module.'
    }

    $result = [pscustomobject][ordered]@{
        Name                     = $module.Name
        Version                  = $module.Version
        MinimumPowerShellVersion = [version]'7.6.0'
        PSEdition                = 'Core'
        SupportedPlatforms       = @('Windows', 'Linux', 'macOS')
        Distribution             = 'GitHub Releases'
        ProjectUri               = [uri]'https://github.com/paulkakell/PSFortiCNAPP'
        ModuleBase               = $module.ModuleBase
        IsDevelopmentVersion     = $module.Version.Major -eq 0
        LicenseSummary           = 'Apache-2.0 code; CC-BY-4.0 project documentation; manuscript separately licensed.'
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.ModuleInfo')

    return $result
}
