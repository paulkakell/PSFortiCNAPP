<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Project Roadmap

## Phase 1: Editorial, Technical, Licensing, and Repository Blueprint

Status: Approved on August 13, 2026, with controlled-tenant and independent-review items remaining open.

Delivered:

- Current-state and instruction analysis.
- Market promise and reader personas.
- Prerequisites, outcomes, and non-goals.
- Six-part, sixteen-chapter, six-appendix outline.
- Chapter labs and companion artifacts.
- Book bible and editorial standards.
- PowerShell module architecture.
- API, LQL, evidence, security, testing, and release strategy.
- Fictional case-study specification.
- Source hierarchy and verification ledger.
- Executive metric framework.
- Split-license implementation.
- Repository tree and workflow blueprint.
- A 1,000 to 1,500 word sample section.

Open nonblocking items remain recorded in `PHASE-1-REVIEW-CHECKLIST.md`.

## Phase 2: Chapter and Module Production

Status: Foundation in progress.

Method: one chapter at a time after approval of the prior chapter and its repository artifacts.

For each chapter:

1. Confirm outcomes, lab, source set, and verification items.
2. Implement or extend the matching module capability.
3. Create tests and synthetic fixtures.
4. Perform required tenant validation.
5. Draft the chapter using the twenty-part chapter anatomy.
6. Run technical, editorial, license, privacy, and prohibited-character checks.
7. Review the chapter and repository diff together.
8. Record an approved chapter baseline.

Current foundation increment:

- Governance and contribution controls.
- Loadable PowerShell 7.6 module scaffold.
- Non-network environment and module-information commands.
- Chapter 1 synthetic scope-register lab.
- Pester, PSScriptAnalyzer, packaging, and CI foundations.

Suggested production sequence:

- Wave 1: Chapters 1 through 4, foundations.
- Wave 2: Chapters 5 through 7, API client and inventory.
- Wave 3: Chapters 8 and 9, LQL.
- Wave 4: Chapters 10 through 12, compliance, vulnerability, identity, and exposure.
- Wave 5: Chapters 13 and 14, alert evidence and executive reporting.
- Wave 6: Chapters 15 and 16, operations, capstone, and release.
- Wave 7: Appendices, cross-references, and final examples.

## Phase 3: Integration, Validation, and Publication Preparation

Deliverables:

- Integrated manuscript.
- Terminology and cross-reference audit.
- Full source and version audit.
- End-to-end code and lab execution.
- Clean module release candidate.
- GitHub Release assets, checksums, and SBOM.
- Final executive-metric and data-quality review.
- Security, privacy, and secret-leak review.
- License and third-party-material review.
- Indexing and publisher handoff assets as required.

Exit criteria:

- Complete manuscript falls within the approved word range or has an explicit exception.
- All runnable code matches the tagged repository release.
- Essential verification-ledger items are resolved.
- Open limitations are disclosed in the relevant chapter and release notes.
- Release installation is validated from downloaded assets.
- The repository contains no prohibited tenant data or credentials.

## Initial release milestones

| Milestone | Module version target | Manuscript alignment |
|---|---:|---|
| Secure client foundation | 0.1.0 | Chapters 1 through 6 |
| Inventory and data quality | 0.2.0 | Chapter 7 |
| LQL workflow | 0.3.0 | Chapters 8 and 9 |
| Compliance and vulnerability | 0.4.0 | Chapters 10 and 11 |
| Identity and alert evidence | 0.5.0 | Chapters 12 and 13 |
| Executive reporting | 0.6.0 | Chapter 14 |
| Operations and capstone | 0.9.0 | Chapters 15 and 16 |
| Publication-aligned release | 1.0.0 | Final integrated manuscript |

These targets are planning anchors. Technical evidence may require a different minor-version boundary.
