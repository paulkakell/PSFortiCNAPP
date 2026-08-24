# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Write-FortiCNAPPRequestLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$Entry
    )

    $parentPath = Split-Path -Parent $LiteralPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        [void](New-Item -ItemType Directory -Path $parentPath -Force)
    }

    $line = $Entry | ConvertTo-Json -Depth 20 -Compress
    Add-Content -LiteralPath $LiteralPath -Value $line -Encoding utf8
}
