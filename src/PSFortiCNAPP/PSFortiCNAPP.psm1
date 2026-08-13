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

foreach ($file in $publicFiles) {
    . $file.FullName
}

$publicFunctions = @(
    'ConvertTo-FortiCNAPPEvidenceRecord'
    'Get-FortiCNAPPModuleInfo'
    'Test-FortiCNAPPEnvironment'
)

Export-ModuleMember -Function $publicFunctions
