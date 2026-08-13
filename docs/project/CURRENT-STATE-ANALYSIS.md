<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Current-State Analysis

Analysis date: 2026-08-13
Repository: `paulkakell/PSFortiCNAPP`
Default branch: `main`

## Executive finding

The repository is a clean starting point but is not yet ready to receive module code or manuscript content. It contains only a one-line README and a GPL-3.0 root license. There is no source tree, test tree, documentation structure, workflow, release, issue taxonomy, repository description, or topic metadata.

The highest-priority correction is the license model. The approved project plan separates executable code, project documentation, and manuscript material. The current GPL-3.0 blanket license does not implement that model and would create avoidable ambiguity if new files were added under it.

## Repository observations

| Area | Observed state | Phase 1 action |
|---|---|---|
| README | Project name only | Replace with project identity, scope, status, distribution policy, and license summary |
| Root license | GPL-3.0 | Replace with a multi-license scope notice and complete license texts under `LICENSES/` |
| Source | None | Define `src/PSFortiCNAPP/` architecture without implementing production cmdlets |
| Tests | None | Define unit, contract, integration, and release test layers |
| Documentation | None | Add project blueprints, source hierarchy, verification ledger, and metric definitions |
| Manuscript | None | Add approved outline and one Phase 1 sample section only |
| Workflows | None | Define CI and release workflows for later implementation |
| Releases | None | Define GitHub Releases as the sole distribution channel |
| Issues | None | Define issue types for defects, documentation, verification, security, and release work |
| Repository metadata | No description or topics | Add during a later authorized GitHub maintenance step |
| Discussions | Disabled | Optional; not required for Phase 1 |
| Wiki | Enabled | Keep unused or disable later so durable guidance remains versioned in the repository |

## Instruction analysis

The controlling project instructions are internally consistent when treated as a phased publication and software project:

1. Phase 1 is a blueprint phase. It establishes binding rules and a review baseline.
2. Phase 2 writes one approved chapter at a time and builds the matching module capability.
3. Phase 3 integrates the full manuscript, validates all examples, and prepares the final release.
4. The reader is assumed to be new to PowerShell, but the technical standard is production-minded.
5. Executive reporting must be traceable to security-engineering evidence.
6. FortiCNAPP API and LQL details must never be guessed.
7. GitHub Releases is the distribution mechanism. PowerShell Gallery publication is excluded.
8. Unicode U+2014 is prohibited across the project.

## Risk register

| Risk | Consequence | Control |
|---|---|---|
| Blanket license retained | Rights ambiguity across code, docs, and manuscript | Complete the split-license migration before Phase 2 |
| Endpoint details copied from an old tenant or old documentation | Broken scripts or incorrect instructions | Verify against current official reference and controlled tenant behavior |
| LQL datasource names assumed | Queries fail or produce incomplete data | Discover sources and fields in the target tenant, then record evidence |
| Synthetic output presented as product output | Reader cannot distinguish teaching data from observed behavior | Label synthetic, sanitized, and tenant-verified evidence explicitly |
| Executive metric lacks denominator or scope | Misleading trend or risk statement | Require formula, denominator, period, filters, source, and quality flags |
| Beginner examples bypass engineering controls | Reader learns unsafe patterns | Introduce secure defaults and reliability controls as the code evolves |
| Repository and manuscript drift apart | Book code does not match release artifacts | Pin each chapter to a repository tag or commit and test all published examples |
| Product changes during writing | Stale API, LQL, or feature guidance | Maintain version notes, release-note checks, and revalidation gates |

## Phase 1 conclusion

The project can proceed without preserving any existing implementation because there is no implementation to migrate. Phase 1 should replace the repository shell with a legally clear, evidence-driven blueprint. Production code and full chapter drafting should begin only after the Phase 1 checklist is approved.
