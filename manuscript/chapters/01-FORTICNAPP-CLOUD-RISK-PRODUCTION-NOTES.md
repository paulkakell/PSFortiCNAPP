<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 1 Production Notes: FortiCNAPP and the Cloud Risk Problem

## Status

The commercial Chapter 1 draft is complete as a publishing asset. The active public repository contains only its companion artifacts, source register, tests, and these production notes.

Completed public gates:

- Cross-platform continuous integration.
- Synthetic fixture and calculation tests.
- Source-register review.
- U+2014 validation.
- Repository boundary correction.

Editorial, publisher, and final technical review remain manuscript activities outside the public repository.

## Chapter purpose

Establish that cloud-security automation is trustworthy only when it identifies intended scope, collected evidence, missing evidence, calculation rules, and remaining uncertainty.

## Implemented reader outcomes

The chapter teaches the reader to:

1. Distinguish visibility, evidence, finding, risk, and decision.
2. Explain why a console count is not automatically a complete metric.
3. Identify the role of a scope register before provider collection begins.
4. Separate observed, missing, stale, excluded, and unavailable evidence.
5. State a coverage denominator before calculating a percentage.
6. Read the synthetic Chapter 1 PowerShell lab.
7. Translate one evidence object into technical and executive interpretations.

## Operational scenario

Kestrel Vale Health Services receives conflicting cloud-risk summaries because separate teams use different scope and freshness rules. The chapter resolves the disagreement by defining intended scope before interpreting collected evidence.

## Lab contract

The lab uses:

- `tests/Fixtures/Synthetic/chapter-01-scope-register.json`
- `examples/foundations/Review-SyntheticScopeRegister.ps1`

Expected synthetic result:

- Five scopes in the denominator.
- Three currently observed scopes.
- One missing scope.
- One stale scope.
- Sixty percent current observed coverage.

## Source status

The source plan is implemented in `docs/source-register/CHAPTER-01.md` with eleven first-party records reviewed on August 13, 2026.

The register covers:

- Current FortiCNAPP API naming and API v2 direction.
- FortiCNAPP CLI naming and interface role.
- LQL and datasource discovery.
- Feature and integration variability across cloud contexts.
- PowerShell 7.6 LTS lifecycle support.

Tenant-specific integrations, permissions, schemas, datasources, freshness, and observed results remain `VERIFY IN TENANT`.

## Repository traceability

| Chapter element | Repository artifact |
|---|---|
| Production record | `manuscript/chapters/01-FORTICNAPP-CLOUD-RISK-PRODUCTION-NOTES.md` |
| Primary source register | `docs/source-register/CHAPTER-01.md` |
| Evidence vocabulary | `docs/reference/EVIDENCE-LABELS.md` |
| Scope-register data | `tests/Fixtures/Synthetic/chapter-01-scope-register.json` |
| Lab calculation | `examples/foundations/Review-SyntheticScopeRegister.ps1` |
| Fixture contract | `tests/Contract/SyntheticScopeFixture.Tests.ps1` |
| Public artifact contract | `tests/Content/Chapter01.Tests.ps1` |
| Manuscript boundary contract | `tests/Content/ManuscriptBoundary.Tests.ps1` |
| Repository controls | `tests/Content/Repository.Tests.ps1` |

## Preserved cautions

- The synthetic platform list is not proof of current feature support.
- An observed count requires its denominator.
- Stale and missing evidence remain separate.
- Exclusion from the denominator is not successful coverage.
- The executive view uses the same underlying facts as the engineer view.
- Authentication and endpoint implementation remain outside Chapter 1.

## Completion record

Public companion artifacts are complete for the current baseline. The commercial chapter remains subject to editorial, publisher, and final technical review outside the public repository.
