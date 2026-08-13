#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$WorkspacePath = (Get-Location).Path,

    [Parameter()]
    [switch]$SkipWriteTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (
    Resolve-Path -LiteralPath (
        Join-Path -Path $PSScriptRoot -ChildPath '../..'
    )
).Path
$manifestPath = Join-Path `
    -Path $repositoryRoot `
    -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'

Import-Module -Name $manifestPath -Force -ErrorAction Stop

Get-FortiCNAPPModuleInfo
Test-FortiCNAPPEnvironment `
    -WorkspacePath $WorkspacePath `
    -SkipWriteTest:$SkipWriteTest
