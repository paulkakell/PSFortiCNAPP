<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Phase 2 Foundation Status

## Scope

This increment creates the governance, module, synthetic-lab, test, build, package, and CI foundation needed before provider-facing commands are implemented.

## Implemented

- Cross-platform PowerShell 7.6 module manifest and loader.
- Explicit public command export list.
- Non-network module information and environment-readiness commands.
- Synthetic Chapter 1 scope register and transparent coverage example.
- Unit, contract, and repository-content tests.
- PSScriptAnalyzer and Pester dependency pins.
- SPDX, U+2014, and credential-pattern quality controls.
- Cross-platform pull-request workflow.
- Development ZIP and SHA-256 generation.
- Contribution, conduct, security, support, issue, and pull-request governance.

## Dependency and action baselines

| Component | Baseline | Source status |
|---|---:|---|
| PowerShell | 7.6.4 current LTS patch at implementation time | Official GitHub release |
| Pester | 5.9.0 | Official PowerShell Gallery package |
| PSScriptAnalyzer | 1.25.0 | Official PowerShell Gallery package |
| actions/checkout | v6.0.2 at `de0fac2e4500dabe0009e67214ff5f5447ce83dd` | Official signed tag target |
| actions/upload-artifact | v7.0.1 at `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | Official signed tag target |

Pester 6 is not adopted in this increment because the newly released major version requires a separate compatibility review. The project can evaluate that migration after the foundation test contract is stable.

## Deliberate exclusions

- No FortiCNAPP authentication.
- No API endpoint or request implementation.
- No LQL query.
- No live tenant fixture.
- No state-changing provider command.
- No public GitHub Release.
- No repository settings or branch-protection mutation.

## Exit criteria

- The source module imports on Windows, Ubuntu, and macOS under PowerShell 7.6 or later.
- Unit, contract, content, static-analysis, license, safety, and U+2014 checks pass.
- Coverage is at least 85 percent for the initial public and private functions.
- The development package contains the module manifest and has a generated SHA-256 value.
- The Chapter 1 synthetic fixture remains clearly classified and contains no credential or account patterns.
- Provider-facing work remains blocked behind the verification ledger.
