<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Source Hierarchy

Review date: 2026-08-13

## Governing rule

The evidence supporting a statement must match the precision of that statement. A product overview can support a broad explanation. Exact operation names, fields, pagination behavior, limits, permissions, or tenant-specific behavior require current technical documentation and controlled validation.

## Priority order

1. Current FortiCNAPP documentation and reference material available to the controlled validation environment.
2. Current Fortinet Developer Network FortiCNAPP reference material.
3. Current Fortinet product guides, LQL references, CLI guidance, and release notes.
4. Reproducible observation in a controlled environment using the narrowest practical access.
5. Official PowerShell, Pester, GitHub, SPDX, Apache, Creative Commons, and REUSE documentation for their respective technologies.
6. Secondary sources only as discovery aids, never as the sole authority for production claims.

## Source register requirements

Each significant technical claim records:

- Claim or behavior.
- Source owner and title.
- Version or release context.
- Access date.
- Relevant section or operation.
- Environment class and region when behavior can vary.
- Verification-ledger identifier.
- Sanitized evidence location.
- Revalidation trigger.

## FortiCNAPP source classes

| Source class | Approved use | Required control |
|---|---|---|
| Product document library | Current concepts, interfaces, and release changes | Record guide version and access date |
| Developer API reference | Supported operation and schema claims | Match the reference to the validation context |
| LQL reference | Language structure and documented constraints | Confirm datasource and field availability |
| CLI help and documentation | Discovery and diagnostic workflows | Pin the tested CLI version |
| Controlled environment observation | Confirm behavior that can vary by tenant or release | Retain sanitized, reproducible evidence |

## Engineering source classes

Use official Microsoft PowerShell guidance for runtime, module, and secret-management behavior; official Pester guidance for tests; official GitHub guidance for releases; and authoritative SPDX, Apache, Creative Commons, and REUSE material for licensing practices.

## Revalidation triggers

Reopen an affected claim when:

- FortiCNAPP release notes mention the relevant feature or interface.
- The controlled environment or CLI version changes.
- A schema, response fixture, or query result changes.
- A contract or integration test fails.
- A reader supplies reproducible conflicting behavior.
- The project changes its PowerShell baseline, license model, or distribution process.

## Citation and reproduction policy

Summarize source material in original language. Use brief quotations only when exact wording is necessary. Do not reproduce complete vendor examples, schemas, screenshots, or tables without compatible rights and attribution.
