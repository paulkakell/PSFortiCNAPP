#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requirements = @(
    [pscustomobject]@{ Name = 'Pester'; Version = [version]'5.9.0' }
    [pscustomobject]@{ Name = 'PSScriptAnalyzer'; Version = [version]'1.25.0' }
)

foreach ($requirement in $requirements) {
    $installed = @(
        Get-Module -ListAvailable -Name $requirement.Name |
            Where-Object -FilterScript { $_.Version -eq $requirement.Version }
    )

    if ($installed.Count -eq 0) {
        if ($null -ne (Get-Command -Name Install-PSResource -ErrorAction SilentlyContinue)) {
            Install-PSResource `
                -Name $requirement.Name `
                -Version $requirement.Version.ToString() `
                -Repository PSGallery `
                -Scope CurrentUser `
                -TrustRepository `
                -AcceptLicense
        }
        else {
            $repository = Get-PSRepository -Name PSGallery -ErrorAction Stop
            if ($repository.InstallationPolicy -ne 'Trusted') {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
            Install-Module `
                -Name $requirement.Name `
                -RequiredVersion $requirement.Version `
                -Repository PSGallery `
                -Scope CurrentUser `
                -Force `
                -AllowClobber
        }
    }
}

foreach ($requirement in $requirements) {
    $module = Get-Module -ListAvailable -Name $requirement.Name |
        Where-Object -FilterScript { $_.Version -eq $requirement.Version } |
        Select-Object -First 1

    [pscustomobject]@{
        Name      = $requirement.Name
        Version   = $requirement.Version
        Installed = $null -ne $module
    }
}
