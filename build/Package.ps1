#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath,

    [Parameter()]
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path -Path $repositoryRoot -ChildPath 'artifacts/package'
}
if ($Clean -and (Test-Path -LiteralPath $OutputPath)) {
    Remove-Item -LiteralPath $OutputPath -Recurse -Force
}
[void](New-Item -ItemType Directory -Path $OutputPath -Force)

$moduleBuildPath = Join-Path -Path $repositoryRoot -ChildPath 'artifacts/module'
$build = & (Join-Path -Path $PSScriptRoot -ChildPath 'Build.ps1') -OutputPath $moduleBuildPath -Clean

$archiveName = 'PSFortiCNAPP-v{0}.zip' -f $build.Version
$archivePath = Join-Path -Path $OutputPath -ChildPath $archiveName
$hashPath = "$archivePath.sha256"

if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}
Compress-Archive -Path $build.ModulePath -DestinationPath $archivePath -CompressionLevel Optimal

$archiveHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
[System.IO.File]::WriteAllText(
    $hashPath,
    "$archiveHash  $archiveName`n",
    [System.Text.UTF8Encoding]::new($false)
)

$archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    $manifestEntry = $archive.Entries |
        Where-Object -FilterScript { $_.FullName -eq 'PSFortiCNAPP/PSFortiCNAPP.psd1' } |
        Select-Object -First 1
    if ($null -eq $manifestEntry) {
        throw 'The package does not contain PSFortiCNAPP/PSFortiCNAPP.psd1.'
    }
}
finally {
    $archive.Dispose()
}

[pscustomobject][ordered]@{
    Name        = $archiveName
    Version     = $build.Version
    ArchivePath = $archivePath
    HashPath    = $hashPath
    Sha256      = $archiveHash
    SizeBytes   = (Get-Item -LiteralPath $archivePath).Length
    Verified    = $true
}
