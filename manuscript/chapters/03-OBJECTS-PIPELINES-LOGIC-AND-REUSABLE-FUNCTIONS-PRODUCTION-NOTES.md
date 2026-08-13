<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 3 Production Notes: Objects, Pipelines, Logic, and Reusable Functions

## Status

Public companion implementation prepared on `phase2/chapter-03-companion`.

The complete commercial chapter is maintained outside `paulkakell/PSFortiCNAPP`.

## Chapter purpose

Teach the PowerShell object, pipeline, filtering, grouping, conditional, iteration, and reusable-function model required before HTTP and FortiCNAPP provider interfaces are introduced.

## Prerequisites

- Chapter 1 scope and evidence concepts
- Chapter 2 PowerShell 7.6 workspace and readiness procedure
- PowerShell 7.6 or later
- Repository source at the accepted Chapter 3 revision
- No FortiCNAPP tenant access

## Versions

- PowerShell baseline: 7.6 LTS
- Pester: 5.9.0 in repository CI
- PSScriptAnalyzer: 1.25.0 in repository CI
- Module development version: 0.1.0
- Official distribution: GitHub Releases only
- PowerShell Gallery: not used

## Verified interfaces

- Microsoft PowerShell language and command behavior listed in `docs/source-register/CHAPTER-03.md`
- Local JSON fixture loading
- Local pipeline transformation
- Local Pester and PSScriptAnalyzer execution

Verified FortiCNAPP endpoints: none.

Verified LQL datasources and fields: none.

## Assumptions

- All organizations, findings, accounts, resources, owners, timestamps, and metrics are synthetic.
- `Observed` and `Stale` are chapter fixture states, not a claim about a FortiCNAPP enum.
- The High-or-Critical priority candidate rule is a PowerShell-derived synthetic teaching rule.
- Provider response normalization, pagination, authentication, retries, and raw evidence preservation remain later work.

## Repository changes

- `src/PSFortiCNAPP/Public/ConvertTo-FortiCNAPPEvidenceRecord.ps1`
- `src/PSFortiCNAPP/PSFortiCNAPP.psd1`
- `src/PSFortiCNAPP/PSFortiCNAPP.psm1`
- `src/PSFortiCNAPP/Formats/PSFortiCNAPP.Format.ps1xml`
- `examples/chapter-03/Review-SyntheticFindings.ps1`
- `examples/README.md`
- `tests/Fixtures/Synthetic/chapter-03-findings.json`
- `tests/Unit/ConvertTo-FortiCNAPPEvidenceRecord.Tests.ps1`
- `tests/Unit/Module.Tests.ps1`
- `tests/Contract/Chapter03Fixture.Tests.ps1`
- `tests/Contract/Chapter03Example.Tests.ps1`
- `tests/Contract/Manifest.Tests.ps1`
- `tests/Content/Chapter03.Tests.ps1`
- `docs/concepts/CHAPTER-03-OBJECTS-PIPELINES-FUNCTIONS.md`
- `docs/chapter-map/chapter-03.md`
- `docs/source-register/CHAPTER-03.md`

## Tests

The increment requires:

- Public export and manifest contracts
- Stable evidence-record type and property tests
- Pipeline collection and ordering test
- UTC normalization test
- Optional context handling
- Severity, status, evidence-state, and timestamp rejection tests
- No raw-input retention
- Synthetic fixture classification, domain, value-set, time, and identifier checks
- End-to-end example summary checks
- Public guide and source-register contract
- Existing repository safety, license, U+2014, coverage, and package checks

## Budget

Planned commercial manuscript: 6,500 words.

Prepared commercial manuscript word count: 5,851 words.

The final editorial pass may expand the chapter toward the planning target when diagrams, review questions, and layout requirements are finalized. Padding is not permitted.

## Verification ledger

No FortiCNAPP tenant-dependent item is closed by Chapter 3.

PowerShell language and command claims are `VERIFIED OFFICIAL` through the fourteen Microsoft records in `docs/source-register/CHAPTER-03.md`.

All runnable security data and calculations are `SYNTHETIC`.

## Code inventory

- One exported normalization command
- One runnable example
- One ten-record synthetic fixture
- One evidence-record formatting view
- Module manifest and loader updates

## Test inventory

- Command unit tests
- Fixture contract tests
- Example contract tests
- Module export tests
- Manifest tests
- Public companion content tests
- Existing repository-wide quality tests

## Known limitations

- The evidence record is not yet a FortiCNAPP API response model.
- The command accepts only synthetic or sanitized classifications.
- Missing and unavailable collection states are modeled outside finding records.
- Duplicate source IDs are not reconciled by the normalization function.
- The example priority rule is not a remediation SLA, exploitability model, business-impact score, or FortiCNAPP-native metric.
- Raw input preservation and field-level provenance are deferred to later evidence architecture.
- No tenant, region, permission, retention, rate-limit, pagination, or schema behavior is validated.

## Completion results

Populate after current-head CI:

```text
Commit:
Windows:
Ubuntu:
macOS:
Pester:
Coverage:
PSScriptAnalyzer:
U+2014:
Repository safety:
Package:
Known CI limitations:
```

## Quality result

The chapter is not complete until the current public branch passes the cross-platform matrix and the commercial manuscript receives editorial, technical, and author review.
