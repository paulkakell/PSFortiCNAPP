# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

@{
    RootModule = 'PSFortiCNAPP.psm1'
    ModuleVersion = '0.1.0'
    GUID = '0f26b9a3-52be-4ed0-bcd6-a8f06d9ec96b'
    Author = 'Paul Kell'
    CompanyName = 'PSFortiCNAPP Contributors'
    Copyright = '(c) 2026 Paul Kell. Executable material is licensed under Apache-2.0.'
    Description = 'PowerShell 7 module for evidence-driven FortiCNAPP security automation.'
    PowerShellVersion = '7.6'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
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
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    FormatsToProcess = @('Formats/PSFortiCNAPP.Format.ps1xml')
    PrivateData = @{
        PSData = @{
            Tags = @(
                'PowerShell'
                'FortiCNAPP'
                'Lacework'
                'CloudSecurity'
                'SecurityAutomation'
            )
            LicenseUri = 'https://github.com/paulkakell/PSFortiCNAPP/blob/main/LICENSE'
            ProjectUri = 'https://github.com/paulkakell/PSFortiCNAPP'
            ReleaseNotes = 'Foundation, local HTTP contracts, and explicit temporary-token session management.'
        }
    }
}
