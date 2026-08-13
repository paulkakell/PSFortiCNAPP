<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Phase 2 Foundation

The first Phase 2 increment establishes a runnable project without introducing a live FortiCNAPP endpoint.

## Requirements

- PowerShell 7.6 or later.
- Git when working from a clone.
- Network access to PowerShell Gallery only when installing the pinned development dependencies.

## Install development dependencies

```powershell
pwsh ./build/Install-Dependencies.ps1
```

The foundation pins Pester 5.9.0 and PSScriptAnalyzer 1.25.0. Dependency updates require an ordinary pull request and a successful matrix run.

## Import the source module

```powershell
Import-Module ./src/PSFortiCNAPP/PSFortiCNAPP.psd1 -Force
Get-FortiCNAPPModuleInfo
```

The import performs no network call, creates no profile, and changes no persistent environment setting.

## Test the environment

```powershell
Test-FortiCNAPPEnvironment -WorkspacePath $PWD
```

The command returns one readiness object with five individual checks. Its temporary write probe is removed before the command returns. Use `-SkipWriteTest` only when a read-only assessment is intentional; the result remains ready when no check fails but records `Complete` as false and the write check as `NotApplicable`.

## Run quality controls

```powershell
pwsh ./build/Invoke-Quality.ps1
```

This runs:

1. The U+2014 character scan.
2. SPDX license-header validation.
3. Repository credential-pattern checks.
4. Module-manifest validation.
5. PSScriptAnalyzer.
6. Pester unit, contract, and content tests with coverage.

## Build and inspect a package

```powershell
pwsh ./build/Package.ps1 -Clean
```

The script creates a versioned ZIP and a SHA-256 file under `artifacts/package`. This is a development artifact, not a public release.

## Run the Chapter 1 synthetic lab

```powershell
pwsh ./examples/foundations/Review-SyntheticScopeRegister.ps1
```

The output states its denominator and separates observed, missing, stale, and excluded scopes. It is synthetic evidence and must not be cited as FortiCNAPP product behavior.
