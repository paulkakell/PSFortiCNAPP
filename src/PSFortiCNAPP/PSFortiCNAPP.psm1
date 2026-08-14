#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Set-StrictMode -Version Latest

$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

$privateFiles = @(
    Get-ChildItem -LiteralPath $privatePath -Filter '*.ps1' -File -ErrorAction Stop |
        Sort-Object -Property FullName
)
$publicFiles = @(
    Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' -File -ErrorAction Stop |
        Sort-Object -Property FullName
)

foreach ($file in $privateFiles) {
    . $file.FullName
}

if ($null -eq (Get-Variable -Name FortiCNAPPSessionStore -Scope Script -ErrorAction SilentlyContinue)) {
    $script:FortiCNAPPSessionStore = [System.Collections.Generic.Dictionary[string, object]]::new(
        [System.StringComparer]::Ordinal
    )
}

foreach ($file in $publicFiles) {
    . $file.FullName
}

$publicFunctions = @(
    'Connect-FortiCNAPP'
    'ConvertFrom-FortiCNAPPHttpExchange'
    'ConvertTo-FortiCNAPPEvidenceRecord'
    'Disconnect-FortiCNAPP'
    'Get-FortiCNAPPContext'
    'Get-FortiCNAPPModuleInfo'
    'New-FortiCNAPPConfiguration'
    'Test-FortiCNAPPConfiguration'
    'Test-FortiCNAPPEnvironment'
)

Export-ModuleMember -Function $publicFunctions
