<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# PSFortiCNAPP

PSFortiCNAPP is the companion PowerShell 7 module and source repository for:

**PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring**

Author: Paul Kell

## Current status

The project is in Phase 1: Editorial, Technical, Licensing, and Repository Blueprint.

Phase 1 defines the book promise, reader personas, instructional structure, module architecture, verification rules, executive metrics, repository layout, and release model. It does not yet contain the production module or the complete manuscript.

## Project goals

The project will teach a PowerShell beginner how to build production-minded FortiCNAPP automation that:

- Uses PowerShell 7 and the FortiCNAPP API v2.
- Uses LQL only after the datasource, fields, syntax, and behavior have been verified.
- Preserves evidence lineage from source through transformation and reporting.
- Produces useful objects for engineers and defensible metrics for security leaders.
- Covers AWS, Azure, GCP, Kubernetes, containers, hosts, identities, compliance, vulnerabilities, and threat evidence.
- Ships through GitHub Releases. PowerShell Gallery publication is intentionally excluded.

## Phase 1 contents

- `docs/project/CURRENT-STATE-ANALYSIS.md`: repository and instruction analysis.
- `docs/project/BOOK-BIBLE.md`: binding editorial and technical rules.
- `docs/project/EDITORIAL-BLUEPRINT.md`: market promise, personas, pedagogy, and manuscript standards.
- `docs/project/TECHNICAL-BLUEPRINT.md`: module, API, LQL, security, testing, and reliability architecture.
- `docs/project/REPOSITORY-BLUEPRINT.md`: target tree, workflow, versioning, and release assets.
- `docs/project/SOURCE-HIERARCHY.md`: approved evidence sources and version controls.
- `docs/project/VERIFICATION-LEDGER.md`: initial tenant-validation register.
- `docs/project/EXECUTIVE-METRICS.md`: transparent CISO reporting framework.
- `docs/project/ROADMAP.md`: phase sequence and acceptance gates.
- `docs/project/PHASE-1-REVIEW-CHECKLIST.md`: approval checklist and open decisions.
- `manuscript/outline/MASTER-OUTLINE.md`: six-part, sixteen-chapter, six-appendix outline.
- `manuscript/sample/PHASE-1-SAMPLE.md`: required sample section.
- `tools/Test-ProhibitedCharacters.ps1`: repository check for Unicode U+2014.

## Licensing

This is a multi-license repository. Executable material is Apache-2.0, project documentation and diagrams are CC BY 4.0, and manuscript material is separately copyrighted. See `LICENSE` and `LICENSE-SCOPE.md` before reusing content.

## Technical claim policy

An endpoint path, request body, response field, pagination mechanism, rate limit, datasource, LQL field, or product behavior must not be represented as production fact until it is supported by an approved official source and, where tenant behavior can vary, validated in a controlled FortiCNAPP tenant.

Unresolved claims are marked `VERIFY IN TENANT` and tracked in the verification ledger.
