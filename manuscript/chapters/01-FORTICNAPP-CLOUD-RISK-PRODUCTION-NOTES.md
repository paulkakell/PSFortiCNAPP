<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 1 Production Notes: FortiCNAPP and the Cloud Risk Problem

## Status

Foundation artifacts implemented. Full chapter drafting remains pending source verification and editorial review.

## Chapter purpose

Establish that cloud-security automation is trustworthy only when it identifies its intended scope, collected evidence, missing evidence, calculation rules, and remaining uncertainty.

## Reader outcomes

The reader will be able to:

1. Distinguish visibility, evidence, finding, risk, and decision.
2. Explain why a console count is not automatically a complete metric.
3. Identify the role of a scope register before provider collection begins.
4. Separate observed, missing, stale, excluded, and unavailable evidence.
5. State a coverage denominator before calculating a percentage.
6. Label synthetic data so it cannot be mistaken for tenant evidence.

## Operational scenario

Kestrel Vale Health Services receives separate summaries from cloud, container, vulnerability, and compliance teams. The totals disagree because each team uses a different scope and freshness rule. The CISO asks which number can support a decision.

The chapter does not resolve the disagreement by selecting the largest or newest number. It first establishes the intended environment and then asks which scopes were observed recently enough to count.

## Lab contract

The lab uses `tests/Fixtures/Synthetic/chapter-01-scope-register.json` and `examples/foundations/Review-SyntheticScopeRegister.ps1`.

The reader will:

1. Inspect the fixture classification and denominator definition.
2. Count scopes expected in FortiCNAPP.
3. Exclude the training scope from the denominator.
4. Separate current, missing, and stale evidence.
5. Calculate current observed coverage.
6. Explain why the result is a synthetic exercise rather than a provider claim.

Expected synthetic result:

- Five scopes in the denominator.
- Three currently observed scopes.
- One missing scope.
- One stale scope.
- Sixty percent current observed coverage.

## Evidence language

The chapter uses the labels in `docs/reference/EVIDENCE-LABELS.md`.

Statements about the current product name, console, CLI, API v2, LQL, or supported cloud coverage require current official sources. Tenant-dependent statements remain `VERIFY IN TENANT` until the verification ledger permits publication.

## Source plan

Primary sources to capture before the full draft:

- Current FortiCNAPP product overview and naming.
- Current FortiCNAPP API documentation entry point.
- Current Lacework FortiCNAPP CLI documentation and version support.
- Current LQL overview and datasource discovery guidance.
- PowerShell 7.6 lifecycle and support documentation.

Every source record will include title, publisher, version or publication date, access date, supported claim, and revalidation trigger.

## Repository traceability

| Chapter element | Repository artifact |
|---|---|
| Evidence vocabulary | `docs/reference/EVIDENCE-LABELS.md` |
| Scope-register data | `tests/Fixtures/Synthetic/chapter-01-scope-register.json` |
| Lab calculation | `examples/foundations/Review-SyntheticScopeRegister.ps1` |
| Fixture contract | `tests/Contract/SyntheticScopeFixture.Tests.ps1` |
| Repository controls | `tests/Content/Repository.Tests.ps1` |

## Drafting cautions

- Do not describe the synthetic platform list as proof of current FortiCNAPP support.
- Do not use an observed count without its denominator.
- Do not merge stale and missing evidence.
- Do not treat exclusion from the denominator as successful coverage.
- Do not claim the CISO needs fewer details; the executive view needs different details.
- Do not introduce authentication or endpoint code before Chapters 5 and 6.

## Completion gate

The chapter can move from production notes to complete draft after:

- Current official product and interface sources are recorded.
- The lab runs on Windows, Linux, and macOS under PowerShell 7.6.
- The fixture and example tests pass.
- The chapter uses the approved twenty-part anatomy.
- Editorial and technical reviews accept the distinction between scope, evidence, and risk.
