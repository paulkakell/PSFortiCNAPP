<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 3 Repository Map

Chapter: **Objects, Pipelines, Logic, and Reusable Functions**

Commercial manuscript location: outside the public repository.

## Reader workflow

1. Run the Chapter 2 environment check.
2. Inspect the synthetic fixture.
3. Convert one record with `ConvertTo-FortiCNAPPEvidenceRecord`.
4. Run the complete Chapter 3 example.
5. Inspect current and stale priority collections.
6. Run the related Pester tests.

## Artifact map

| Chapter element | Public artifact |
|---|---|
| Objects and custom types | `src/PSFortiCNAPP/Public/ConvertTo-FortiCNAPPEvidenceRecord.ps1` |
| Pipeline input | `tests/Unit/ConvertTo-FortiCNAPPEvidenceRecord.Tests.ps1` |
| Filtering and sorting | `examples/chapter-03/Review-SyntheticFindings.ps1` |
| Grouping | `DomainCounts` in the Chapter 3 example |
| Conditional calculation | `CurrentPriorityRatePercent` in the Chapter 3 example |
| Synthetic input | `tests/Fixtures/Synthetic/chapter-03-findings.json` |
| Public tutorial | `docs/concepts/CHAPTER-03-OBJECTS-PIPELINES-FUNCTIONS.md` |
| Source traceability | `docs/source-register/CHAPTER-03.md` |
| Production traceability | `manuscript/chapters/03-OBJECTS-PIPELINES-LOGIC-AND-REUSABLE-FUNCTIONS-PRODUCTION-NOTES.md` |

## Expected synthetic result

- Ten total findings
- Seven open findings
- Three current open High-or-Critical records
- One stale open High record
- A 42.86 percent current synthetic priority rate using open findings as the denominator

## Validation status

The accepted Chapter 3 branch must pass:

- Windows, Ubuntu, and macOS PowerShell 7.6 jobs
- 65 Pester tests with zero failures
- The 85 percent repository coverage threshold
- PSScriptAnalyzer
- Module-manifest and export contracts
- SPDX, repository safety, and U+2014 checks
- Development package and SHA-256 verification

No provider endpoint, LQL datasource, tenant behavior, or product metric is asserted.
