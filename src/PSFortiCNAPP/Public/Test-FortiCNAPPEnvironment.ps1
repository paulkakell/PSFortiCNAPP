# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Test-FortiCNAPPEnvironment {
    <#
    .SYNOPSIS
    Tests whether the current PowerShell environment is ready for PSFortiCNAPP.

    .DESCRIPTION
    Performs non-network checks for the PowerShell version, PowerShell edition,
    operating system, workspace path, filesystem provider, and workspace write
    access. The write check creates and removes one temporary probe file.

    A failed check is returned as evidence in the result object. Missing or
    unavailable evidence is not converted into a passing result.

    .PARAMETER MinimumPowerShellVersion
    Minimum acceptable PowerShell version. The module baseline is 7.6.0.

    .PARAMETER WorkspacePath
    Existing workspace folder to assess.

    .PARAMETER SkipWriteTest
    Skips the temporary workspace write probe. The write check is recorded as
    NotApplicable rather than Pass.

    .EXAMPLE
    Test-FortiCNAPPEnvironment -WorkspacePath $HOME

    .EXAMPLE
    Test-FortiCNAPPEnvironment -WorkspacePath $PWD -SkipWriteTest

    .OUTPUTS
    PSFortiCNAPP.EnvironmentReadiness
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [ValidateNotNull()]
        [version]$MinimumPowerShellVersion = [version]'7.6.0',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspacePath = (Get-Location).Path,

        [Parameter()]
        [switch]$SkipWriteTest
    )

    $checks = [System.Collections.Generic.List[object]]::new()
    $currentPowerShellVersion = $PSVersionTable.PSVersion

    $powerShellVersionStatus = if ($currentPowerShellVersion -ge $MinimumPowerShellVersion) {
        'Pass'
    }
    else {
        'Fail'
    }
    $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
        -Name 'PowerShellVersion' `
        -Status $powerShellVersionStatus `
        -Required $true `
        -Message "PowerShell $currentPowerShellVersion is running; $MinimumPowerShellVersion or later is required." `
        -Evidence $currentPowerShellVersion.ToString() `
        -Remediation 'Install and run PowerShell 7.6 or later with pwsh.'))

    $edition = [string]$PSVersionTable.PSEdition
    $editionStatus = if ($edition -eq 'Core') { 'Pass' } else { 'Fail' }
    $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
        -Name 'PowerShellEdition' `
        -Status $editionStatus `
        -Required $true `
        -Message "PowerShell edition is $edition; Core is required." `
        -Evidence $edition `
        -Remediation 'Run the module in PowerShell 7 using pwsh rather than Windows PowerShell.'))

    $platform = if ($IsWindows) {
        'Windows'
    }
    elseif ($IsLinux) {
        'Linux'
    }
    elseif ($IsMacOS) {
        'macOS'
    }
    else {
        'Unknown'
    }
    $platformStatus = if ($platform -eq 'Unknown') { 'Fail' } else { 'Pass' }
    $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
        -Name 'OperatingSystem' `
        -Status $platformStatus `
        -Required $true `
        -Message "Detected operating system family: $platform." `
        -Evidence ([System.Runtime.InteropServices.RuntimeInformation]::OSDescription) `
        -Remediation 'Use a supported Windows, Linux, or macOS environment.'))

    $resolvedWorkspace = $null
    $workspaceItem = $null
    try {
        $workspaceItem = Get-Item -LiteralPath $WorkspacePath -Force -ErrorAction Stop
        if (-not $workspaceItem.PSIsContainer) {
            $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
                -Name 'WorkspacePath' `
                -Status 'Fail' `
                -Required $true `
                -Message 'The workspace path exists but is not a directory.' `
                -Evidence $workspaceItem.FullName `
                -Remediation 'Select an existing directory for the project workspace.'))
        }
        elseif ($workspaceItem.PSProvider.Name -ne 'FileSystem') {
            $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
                -Name 'WorkspacePath' `
                -Status 'Fail' `
                -Required $true `
                -Message 'The workspace path is not provided by the FileSystem provider.' `
                -Evidence $workspaceItem.PSProvider.Name `
                -Remediation 'Select a directory on a local or mounted filesystem.'))
        }
        else {
            $resolvedWorkspace = $workspaceItem.FullName
            $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
                -Name 'WorkspacePath' `
                -Status 'Pass' `
                -Required $true `
                -Message 'The workspace is an existing filesystem directory.' `
                -Evidence $resolvedWorkspace))
        }
    }
    catch {
        $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
            -Name 'WorkspacePath' `
            -Status 'Fail' `
            -Required $true `
            -Message 'The workspace path could not be resolved.' `
            -Evidence $WorkspacePath `
            -Remediation 'Create the directory or supply a valid existing workspace path.'))
    }

    if ($null -eq $resolvedWorkspace) {
        $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
            -Name 'WorkspaceWrite' `
            -Status 'NotApplicable' `
            -Required $true `
            -Message 'The write probe was not attempted because the workspace path was not valid.' `
            -Remediation 'Resolve the workspace-path failure before testing write access.'))
    }
    elseif ($SkipWriteTest) {
        $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
            -Name 'WorkspaceWrite' `
            -Status 'NotApplicable' `
            -Required $true `
            -Message 'The workspace write probe was skipped by request.' `
            -Evidence $resolvedWorkspace `
            -Remediation 'Run again without SkipWriteTest before using workflows that create evidence or reports.'))
    }
    else {
        $probePath = Join-Path -Path $resolvedWorkspace -ChildPath ('.psforticnapp-write-{0}.tmp' -f [guid]::NewGuid().ToString('N'))
        try {
            [System.IO.File]::WriteAllText(
                $probePath,
                'PSFortiCNAPP readiness probe',
                [System.Text.UTF8Encoding]::new($false)
            )
            $probe = Get-Item -LiteralPath $probePath -Force -ErrorAction Stop
            if ($probe.Length -gt 0) {
                $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
                    -Name 'WorkspaceWrite' `
                    -Status 'Pass' `
                    -Required $true `
                    -Message 'The workspace accepted and returned a temporary write probe.' `
                    -Evidence $resolvedWorkspace))
            }
            else {
                $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
                    -Name 'WorkspaceWrite' `
                    -Status 'Fail' `
                    -Required $true `
                    -Message 'The workspace created an empty probe unexpectedly.' `
                    -Evidence $resolvedWorkspace `
                    -Remediation 'Review filesystem health, quotas, and write permissions.'))
            }
        }
        catch {
            $checks.Add((ConvertTo-FortiCNAPPReadinessCheck `
                -Name 'WorkspaceWrite' `
                -Status 'Fail' `
                -Required $true `
                -Message 'The workspace write probe failed.' `
                -Evidence $resolvedWorkspace `
                -Remediation 'Grant the current user write access or choose a writable workspace.'))
        }
        finally {
            if (Test-Path -LiteralPath $probePath -PathType Leaf) {
                Remove-Item -LiteralPath $probePath -Force -ErrorAction SilentlyContinue
            }
        }
    }

    $failedChecks = @($checks | Where-Object -FilterScript { $_.Status -eq 'Fail' })
    $warningChecks = @($checks | Where-Object -FilterScript { $_.Status -eq 'Warning' })
    $passedChecks = @($checks | Where-Object -FilterScript { $_.Status -eq 'Pass' })
    $notApplicableChecks = @($checks | Where-Object -FilterScript { $_.Status -eq 'NotApplicable' })
    $incompleteRequiredChecks = @(
        $checks | Where-Object -FilterScript {
            $_.Required -and $_.Status -eq 'NotApplicable'
        }
    )
    $recommendations = @(
        $checks |
            Where-Object -FilterScript {
                $_.Status -in @('Fail', 'Warning', 'NotApplicable') -and
                -not [string]::IsNullOrWhiteSpace($_.Remediation)
            } |
            Select-Object -ExpandProperty Remediation -Unique
    )

    $result = [pscustomobject][ordered]@{
        CheckedAtUtc          = [DateTimeOffset]::UtcNow
        ComputerName          = [Environment]::MachineName
        OperatingSystem       = $platform
        OperatingSystemDetail = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
        Architecture          = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        PowerShellVersion     = $currentPowerShellVersion
        PSEdition             = $edition
        WorkspacePath         = if ($null -ne $resolvedWorkspace) { $resolvedWorkspace } else { $WorkspacePath }
        Ready                 = $failedChecks.Count -eq 0
        Complete              = $incompleteRequiredChecks.Count -eq 0
        CheckCount            = $checks.Count
        PassCount             = $passedChecks.Count
        WarningCount          = $warningChecks.Count
        FailCount             = $failedChecks.Count
        NotApplicableCount    = $notApplicableChecks.Count
        Checks                = $checks.ToArray()
        Recommendations       = $recommendations
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.EnvironmentReadiness')

    return $result
}
