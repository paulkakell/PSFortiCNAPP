<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# PSFortiCNAPP

PowerShell 7 security automation for the FortiCNAPP v2 API and LQL

PSFortiCNAPP is the companion PowerShell 7 module and source repository for:

**PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring**

Author: Paul Kell

PSFortiCNAPP is an independent community open-source project maintained in `paulkakell/PSFortiCNAPP`. It is not an official Fortinet product and is not affiliated with or endorsed by Fortinet.

## Current status

The project is in Phase 2 chapter and repository production. The foundation and Chapter 1 companion artifacts are on `main`. The Chapter 2 public companion increment is under review.

The current module is loadable and tested, but it intentionally contains no live FortiCNAPP authentication, endpoint, or LQL implementation. Provider-facing behavior remains `VERIFY IN TENANT` until its official source, access requirements, response contract, failure behavior, and controlled validation are recorded.

## Foundation commands

```powershell
Import-Module ./src/PSFortiCNAPP/PSFortiCNAPP.psd1 -Force

Get-FortiCNAPPModuleInfo
Test-FortiCNAPPEnvironment -WorkspacePath $PWD
```

- `Get-FortiCNAPPModuleInfo` returns module, runtime, platform, distribution, project, and licensing metadata without a network call.
- `Test-FortiCNAPPEnvironment` returns a non-sensitive readiness object for PowerShell, operating system, workspace, and write access.

## Development setup

PowerShell 7.6 or later is required.

```powershell
pwsh ./build/Install-Dependencies.ps1
pwsh ./build/Invoke-Quality.ps1
pwsh ./build/Package.ps1 -Clean
```

The quality command runs PSScriptAnalyzer, Pester with coverage, module-manifest validation, SPDX checks, the U+2014 prohibition, and repository credential-pattern checks.

The package command creates a development ZIP and SHA-256 file under `artifacts/package`. Public distribution will use GitHub Releases only after release gates are complete.

## Synthetic Chapter 1 lab

```powershell
pwsh ./examples/foundations/Review-SyntheticScopeRegister.ps1
```

The lab calculates current observed coverage from an invented Kestrel Vale Health Services scope register. It distinguishes observed, missing, stale, and excluded evidence and states the denominator. It is not proof of FortiCNAPP product behavior.

## Project goals

The project will teach a PowerShell beginner how to build production-minded FortiCNAPP automation that:

- Uses PowerShell 7 and the FortiCNAPP API v2.
- Uses LQL only after the datasource, fields, syntax, and behavior have been verified.
- Preserves evidence lineage from source through transformation and reporting.
- Produces useful objects for engineers and defensible metrics for security leaders.
- Covers AWS, Azure, Google Cloud, Kubernetes, containers, hosts, identities, compliance, vulnerabilities, and threat evidence.
- Ships through GitHub Releases. PowerShell Gallery publication is intentionally excluded.

## Project structure

- `src/PSFortiCNAPP/`: module source.
- `tests/`: unit, contract, content, integration, and fixture areas.
- `build/`: dependency, quality, build, test, and package scripts.
- `tools/`: repository policy scanners.
- `examples/`: executable synthetic and sanitized examples.
- `docs/project/`: binding project architecture and status.
- `docs/reference/`: reusable evidence and command references.
- `docs/source-register/`: first-party source records and non-redistributed source snapshot metadata.
- `manuscript/outline/`: separately copyrighted planning outline.
- `manuscript/sample/`: the approved Phase 1 sample.
- `manuscript/chapters/`: production notes and one documented legacy Chapter 1 file.

Complete commercial chapters are maintained outside the public companion repository. GitHub issue #6 tracks the legacy Chapter 1 correction. See `docs/project/MANUSCRIPT-REPOSITORY-BOUNDARY.md`.

## Governance

Read `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, and `CODE_OF_CONDUCT.md` before opening a pull request or issue. Public contributions must exclude credentials, protected tenant data, and complete commercial chapter prose.

## Licensing

This is a multi-license repository. Executable material is Apache-2.0, project documentation and diagrams are CC BY 4.0, and limited publication-planning material is separately copyrighted. See `LICENSE`, `LICENSE-SCOPE.md`, and `docs/project/MANUSCRIPT-REPOSITORY-BOUNDARY.md` before reusing content.
