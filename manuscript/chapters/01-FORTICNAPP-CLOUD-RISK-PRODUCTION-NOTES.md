<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 1 Production Notes: FortiCNAPP and the Cloud Risk Problem

## Status

Full chapter draft implemented on `phase2/chapter-01`.

Remaining gates:

- Cross-platform continuous integration on the chapter branch.
- Editorial review.
- Technical review.
- Author approval.
- Merge after the Phase 2 foundation reaches `main`.

## Chapter purpose

Establish that cloud-security automation is trustworthy only when it identifies intended scope, collected evidence, missing evidence, calculation rules, and remaining uncertainty.

## Implemented reader outcomes

The draft teaches the reader to:

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
| Full chapter draft | `manuscript/chapters/01-FORTICNAPP-AND-THE-CLOUD-RISK-PROBLEM.md` |
| Primary source register | `docs/source-register/CHAPTER-01.md` |
| Evidence vocabulary | `docs/reference/EVIDENCE-LABELS.md` |
| Scope-register data | `tests/Fixtures/Synthetic/chapter-01-scope-register.json` |
| Lab calculation | `examples/foundations/Review-SyntheticScopeRegister.ps1` |
| Fixture contract | `tests/Contract/SyntheticScopeFixture.Tests.ps1` |
| Chapter contract | `tests/Content/Chapter01.Tests.ps1` |
| Repository controls | `tests/Content/Repository.Tests.ps1` |

## Preserved cautions

- The synthetic platform list is not proof of current feature support.
- An observed count requires its denominator.
- Stale and missing evidence remain separate.
- Exclusion from the denominator is not successful coverage.
- The executive view uses the same underlying facts as the engineer view.
- Authentication and endpoint implementation remain outside Chapter 1.

## Completion gate

The chapter can be marked complete after:

- Current branch checks pass on Windows, Ubuntu, and macOS.
- The chapter contract confirms the twenty-part anatomy and production word range.
- Editorial review accepts the voice and beginner progression.
- Technical review accepts the scope, evidence, and metric distinctions.
- Author approval is recorded.
