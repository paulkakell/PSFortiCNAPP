<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Phase 1 Review Checklist

## Repository analysis

- [x] Repository identified and default branch confirmed.
- [x] Existing files reviewed.
- [x] Current blanket GPL-3.0 license identified as incompatible with the approved split-license model.
- [x] Missing source, test, documentation, workflow, and release structure recorded.
- [x] Repository metadata recommendations prepared.

## Editorial blueprint

- [x] Exact title recorded.
- [x] Market promise defined.
- [x] Primary and secondary personas defined.
- [x] Prerequisites and non-goals defined.
- [x] Beginner learning progression defined.
- [x] Twenty-part chapter anatomy defined.
- [x] Fictional case study defined.
- [x] Voice, style, security, and output conventions defined.
- [x] Six-part, sixteen-chapter, six-appendix outline prepared.
- [x] Word allocation prepared.
- [x] Sample section prepared.
- [x] Sample voice and scope approved by author.

## Technical blueprint

- [x] PowerShell baseline selected.
- [x] Module layers defined.
- [x] Provisional command families defined.
- [x] Authentication and configuration model defined.
- [x] Transport, error, retry, pagination, and diagnostic models defined.
- [x] LQL discovery and validation lifecycle defined.
- [x] Evidence and data-quality models defined.
- [x] Unit, contract, integration, static-analysis, and coverage strategy defined.
- [x] GitHub Release artifact model defined.
- [x] Public command families approved as the Phase 2 design baseline.
- [ ] Initial controlled tenant and permission model designated.

## Verification

- [x] Source hierarchy established.
- [x] Evidence labels established.
- [x] Initial verification ledger created.
- [x] High-risk validation areas listed.
- [ ] Initial FortiCNAPP tenant version recorded.
- [ ] Initial Lacework FortiCNAPP CLI version recorded.
- [x] Verification storage model approved: sanitized fixtures in the repository and restricted validation records outside it.

## Executive reporting

- [x] Metric object model defined.
- [x] Coverage, compliance, vulnerability, identity, alert, and automation metric families defined.
- [x] Denominator, scope, freshness, and confidence rules defined.
- [x] Anti-patterns defined.
- [ ] Initial executive metric set approved for Chapter 14.

## Licensing and repository governance

- [x] Apache-2.0 scope defined for executable material.
- [x] CC BY 4.0 scope defined for project documentation and diagrams.
- [x] Manuscript all-rights-reserved scope defined.
- [x] SPDX file-header rule defined.
- [x] Root license replacement prepared.
- [x] GitHub Releases-only distribution recorded.
- [x] PowerShell Gallery excluded.
- [x] Split-license model approved for application to the GitHub repository.
- [ ] Repository metadata update approved as a separate GitHub settings action.
- [ ] Branch protection remains pending; pull-request workflow implementation is approved for Phase 2.

## Quality controls

- [x] Unicode U+2014 prohibition recorded.
- [x] Repository scan tool prepared.
- [x] Synthetic and sanitized data labels defined.
- [x] No real tenant data included in Phase 1 artifacts.
- [x] Phase 1 package contains no production API endpoint implementation.
- [ ] Independent editorial review completed.
- [ ] Independent technical review completed.
- [x] Final Phase 1 approval recorded.

## Binding decisions

1. Keep the exact title and module name.
2. Use PowerShell 7.6 LTS as the initial baseline.
3. Use the split-license model in `LICENSE-SCOPE.md`.
4. Use Kestrel Vale Health Services as the fictional case study.
5. Use `VERIFY IN TENANT` as the mandatory unresolved-claim marker.
6. Use the proposed public command families as the Phase 2 design baseline.
7. Use GitHub Releases as the only public module distribution channel.

## Phase 1 approval record

```text
Decision: Approved to proceed to the Phase 2 foundation
Approved by: Paul Kell
Date: 2026-08-13
Exceptions: Controlled-tenant designation, product and CLI version capture,
            Chapter 14 metric selection, repository metadata, branch protection,
            and independent reviews remain open. They cannot support provider
            claims until completed.
Required revisions: None blocking the Phase 2 foundation.
Next authorized action: Add governance, module scaffolding, synthetic fixtures,
                        tests, build scripts, and pull-request CI on a stacked
                        Phase 2 branch, then open a draft pull request.
```
