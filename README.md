<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# PSFortiCNAPP

PowerShell 7 security automation for the FortiCNAPP v2 API and LQL

PSFortiCNAPP is the companion PowerShell 7 module and source repository for:

**PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring**

Author: Paul Kell

PSFortiCNAPP is an independent community open-source project maintained in `paulkakell/PSFortiCNAPP`. It is not an official Fortinet product and is not affiliated with or endorsed by Fortinet.

## Current status

Public companion artifacts for Chapters 1 through 5 are accepted. Chapter 6 adds the reusable API v2 request client, bounded retries, continuation handling, redacted logging, and schema discovery.

Tenant-facing behavior remains `VERIFY IN TENANT` until its official source, access requirements, response contract, failure behavior, and controlled validation are recorded.

## Current commands

```powershell
Import-Module ./src/PSFortiCNAPP/PSFortiCNAPP.psd1 -Force
Get-Command -Module PSFortiCNAPP
```

The module exports eleven commands through Chapter 6. The public API client supports GET and POST. State-changing methods are not exposed.

## Development setup

PowerShell 7.6 or later is required.

```powershell
pwsh ./build/Install-Dependencies.ps1
pwsh ./build/Invoke-Quality.ps1
pwsh ./build/Package.ps1 -Clean
```

The quality command runs PSScriptAnalyzer, Pester with coverage, module-manifest validation, SPDX checks, the U+2014 prohibition, and repository credential-pattern checks.

## Synthetic labs

```powershell
pwsh ./examples/foundations/Review-SyntheticScopeRegister.ps1
pwsh ./examples/chapter-03/Review-SyntheticFindings.ps1
pwsh ./examples/chapter-04/Review-SyntheticHttpExchanges.ps1
pwsh ./examples/chapter-05/Review-SyntheticAuthenticationProfiles.ps1
pwsh ./examples/chapter-06/Review-SyntheticRequestPlan.ps1
```

All lab organizations, accounts, resources, findings, exchanges, authentication profiles, request plans, timestamps, and metrics are synthetic.

## Project goals

The project teaches a PowerShell beginner to build production-minded FortiCNAPP automation that preserves evidence lineage, handles failure explicitly, and produces defensible engineer and CISO outputs.

Official distribution will use GitHub Releases only. PowerShell Gallery publication is excluded.

## Project structure

- `src/PSFortiCNAPP/`: module source.
- `tests/`: unit, contract, content, integration, and fixture areas.
- `build/`: dependency, quality, build, test, and package scripts.
- `tools/`: repository policy scanners.
- `examples/`: executable synthetic and sanitized examples.
- `docs/`: public companion documentation, references, sources, and verification records.
- `manuscript/chapters/`: production notes and short publishing notices only.

Complete commercial chapters are maintained outside the public repository.

## Licensing

Executable material is Apache-2.0. Repository documentation and original diagrams are CC BY 4.0. The commercial manuscript remains separately copyrighted. See `LICENSE`, `LICENSE-SCOPE.md`, and `docs/project/MANUSCRIPT-REPOSITORY-BOUNDARY.md`.
