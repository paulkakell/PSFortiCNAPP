<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 3 Companion Guide: Objects, Pipelines, Logic, and Reusable Functions

This guide supports Chapter 3 of *PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring*. It is independent open-source documentation, not the commercial chapter manuscript.

## Purpose

Chapter 3 introduces the object and pipeline model used throughout `PSFortiCNAPP`. The public companion lab uses a synthetic ten-record finding fixture. It makes no network request and does not claim any FortiCNAPP endpoint, schema, datasource, permission, or tenant behavior.

The lab demonstrates four design rules:

1. Data collection and normalization return objects.
2. A filter operates on properties, not formatted display text.
3. A calculated rate names its denominator.
4. Stale evidence remains visible rather than being counted as current evidence.

## Prerequisites

- PowerShell 7.6 or later
- The repository checked out at the Chapter 3 branch, commit, or later accepted revision
- No FortiCNAPP credential or tenant access
- A profile-independent PowerShell session for reproducible execution

Run the repository readiness check first:

```powershell
pwsh -NoProfile -File ./examples/foundations/Test-Environment.ps1
```

## Public command

Chapter 3 adds:

```powershell
ConvertTo-FortiCNAPPEvidenceRecord
```

The command accepts finding-shaped objects through the pipeline and returns `PSFortiCNAPP.EvidenceRecord` objects. It performs local transformation only.

Required input properties:

- `sourceRecordId`
- `domain`
- `findingType`
- `title`
- `severity`
- `status`
- `resourceId`
- `resourceType`
- `cloudProvider`
- `observedAtUtc`
- `evidenceState`

Optional context properties:

- `accountId`
- `region`
- `owner`
- `businessService`

Supported values in this chapter are deliberately narrow. Severity is `Critical`, `High`, `Medium`, `Low`, or `Info`. Status is `Open`, `Resolved`, `AcceptedRisk`, or `Suppressed`. Evidence state is `Observed` or `Stale`.

A missing or unavailable source is not a finding record. Later collection layers will represent collection completeness separately.

## Smallest working example

```powershell
Import-Module ./src/PSFortiCNAPP/PSFortiCNAPP.psd1 -Force

$finding = [pscustomobject]@{
    sourceRecordId = 'syn-001'
    domain         = 'Compliance'
    findingType    = 'Configuration'
    title          = 'Synthetic public storage configuration'
    severity       = 'High'
    status         = 'Open'
    resourceId     = 'synthetic-resource-01'
    resourceType   = 'ObjectStorage'
    cloudProvider  = 'AWS'
    observedAtUtc  = '2026-08-13T18:00:00Z'
    evidenceState  = 'Observed'
}

$finding | ConvertTo-FortiCNAPPEvidenceRecord
```

The returned object has the type name `PSFortiCNAPP.EvidenceRecord`. Its UTC timestamps, canonical severity and status values, stable source identifier, and calculated boolean properties can be inspected or passed to another command.

## Run the complete synthetic lab

From the repository root:

```powershell
$summary = pwsh -NoProfile -File ./examples/chapter-03/Review-SyntheticFindings.ps1
```

When already running inside `pwsh`, use:

```powershell
$summary = ./examples/chapter-03/Review-SyntheticFindings.ps1
```

The result has the type name `PSFortiCNAPP.SyntheticFindingSummary`.

Expected synthetic values:

| Property | Expected value |
|---|---:|
| `TotalFindingCount` | 10 |
| `OpenFindingCount` | 7 |
| `CurrentPriorityCount` | 3 |
| `StalePriorityCount` | 1 |
| `CurrentPriorityRatePercent` | 42.86 |
| `PriorityRateDenominator` | `Open findings` |

The 42.86 percent value is calculated as three current open High or Critical records divided by seven open records. It is a PowerShell-derived synthetic teaching rule, not a FortiCNAPP risk score or provider metric.

Inspect the records behind the result:

```powershell
$summary.CurrentPriorityRecords |
    Select-Object EvidenceId, Severity, Domain, ResourceId, Owner

$summary.StalePriorityRecords |
    Select-Object EvidenceId, Severity, ObservedAtUtc, ResourceId

$summary.DomainCounts
```

## Why stale evidence is separate

The stale High-severity record remains an `IsPriorityCandidate` because its status and severity still meet the synthetic rule. It is excluded from `CurrentPriorityRecords` because `IsCurrentEvidence` is false.

This distinction prevents a stale record from being presented as current while retaining it for investigation. Stale does not mean resolved. It means the current state has not been established by the available evidence.

## Object contract

`PSFortiCNAPP.EvidenceRecord` includes:

- Source identity and classification
- Collection and observation timestamps normalized to UTC
- Evidence state
- Security domain and finding type
- Severity, severity rank, and status
- Current, open, and priority booleans
- Cloud, account, region, resource, service, and owner context

The normalization command does not retain the original input object. Raw provider preservation will be implemented in later transport and evidence layers. Chapter 3 is limited to local synthetic or sanitized transformation.

## Failure behavior

The command stops with a structured error when:

- A required property is missing or empty
- Severity is unsupported
- Status is unsupported
- Evidence state is unsupported
- The observation timestamp cannot be parsed

Example:

```powershell
$invalid = [pscustomobject]@{
    sourceRecordId = 'syn-invalid'
}

try {
    $invalid | ConvertTo-FortiCNAPPEvidenceRecord -ErrorAction Stop
}
catch {
    $_.FullyQualifiedErrorId
    $_.Exception.Message
}
```

Do not replace missing required evidence with an empty string or a fabricated default. The calling workflow must decide whether to reject, quarantine, or separately represent an incomplete record.

## Engineer interpretation

The lab produces a reproducible transformation contract. An engineer can trace every normalized record to a synthetic source record ID, inspect the exact filter, identify stale evidence, and reproduce the denominator.

The object model is intentionally generic. It teaches the pipeline mechanics needed before provider-specific response fields are introduced.

## CISO interpretation

The summary is not an executive risk claim. It demonstrates how an eventual executive measure must expose its scope and denominator.

A defensible statement for this synthetic exercise is:

> Three of seven open synthetic findings meet the current High-or-Critical teaching rule. One additional High-severity record is stale and requires renewed evidence before current exposure can be stated.

The statement distinguishes current evidence, stale evidence, and the denominator. It does not present 42.86 percent as improvement, coverage, or provider-native risk.

## Repository paths

| Purpose | Path |
|---|---|
| Public normalization command | `src/PSFortiCNAPP/Public/ConvertTo-FortiCNAPPEvidenceRecord.ps1` |
| Runnable lab | `examples/chapter-03/Review-SyntheticFindings.ps1` |
| Synthetic fixture | `tests/Fixtures/Synthetic/chapter-03-findings.json` |
| Command unit tests | `tests/Unit/ConvertTo-FortiCNAPPEvidenceRecord.Tests.ps1` |
| Fixture contract | `tests/Contract/Chapter03Fixture.Tests.ps1` |
| Example contract | `tests/Contract/Chapter03Example.Tests.ps1` |
| Public guide contract | `tests/Content/Chapter03.Tests.ps1` |
| Source register | `docs/source-register/CHAPTER-03.md` |
| Production notes | `manuscript/chapters/03-OBJECTS-PIPELINES-LOGIC-AND-REUSABLE-FUNCTIONS-PRODUCTION-NOTES.md` |

## Boundaries

- Data classification: `SYNTHETIC`
- Verified FortiCNAPP endpoints: none
- Verified LQL datasources and fields: none
- Tenant validation performed: none
- State-changing behavior: none
- External enrichment: none
- Provider-native metric claims: none

The commercial chapter is maintained outside `paulkakell/PSFortiCNAPP`.
