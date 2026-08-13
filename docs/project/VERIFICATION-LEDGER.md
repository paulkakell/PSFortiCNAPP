<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Verification Ledger

This ledger controls technical claims that depend on current FortiCNAPP behavior. Each item begins as `OPEN` and becomes publishable only after current documentation and, where required, controlled validation support it.

Approved states are `OPEN`, `IN PROGRESS`, `VERIFIED OFFICIAL`, `VERIFIED IN TENANT`, `BLOCKED`, `REVERIFY`, and `NOT APPLICABLE`.

A completed record identifies the source version, environment class, method, expected result, observed result, sanitized evidence location, reviewer, date, limitations, and revalidation trigger. Real environment names and sensitive values are excluded.

| ID | Validation area | Status | Chapter |
|---|---|---|---:|
| V-001 | Connection lifecycle | OPEN | 5 |
| V-002 | Read-only access model | OPEN | 5 |
| V-003 | Environment context | OPEN | 5 |
| V-004 | Provider communication metadata | OPEN | 6 |
| V-005 | Failure classification | OPEN | 6 |
| V-006 | Timing and recovery behavior | OPEN | 6 |
| V-007 | Schema discovery | OPEN | 6 |
| V-008 | Paging behavior | OPEN | 7 |
| V-009 | Asset inventory fields | OPEN | 7 |
| V-010 | Inventory data quality | OPEN | 7 |
| V-011 | LQL datasource discovery | OPEN | 8 |
| V-012 | LQL language behavior | OPEN | 8 |
| V-013 | LQL result behavior | OPEN | 9 |
| V-014 | Policy evidence | OPEN | 9 |
| V-015 | Compliance field mapping | OPEN | 10 |
| V-016 | Compliance history | OPEN | 10 |
| V-017 | Vulnerability field mapping | OPEN | 11 |
| V-018 | Vulnerability record identity | OPEN | 11 |
| V-019 | Identity relationships | OPEN | 12 |
| V-020 | Exposure relationships | OPEN | 12 |
| V-021 | Alert field mapping | OPEN | 13 |
| V-022 | Alert evidence relationships | OPEN | 13 |
| V-023 | Native and derived reporting | OPEN | 14 |
| V-024 | Metric data quality | OPEN | 14 |
| V-025 | Scheduled operation | OPEN | 15 |
| V-026 | Reliability controls | OPEN | 15 |
| V-027 | Release installation | OPEN | 16 |
| V-028 | Release-content inspection | OPEN | 16 |

## Update template

```text
ID:
Status:
Claim:
Source and version:
Environment class:
Method:
Expected:
Observed:
Evidence location:
Limitations:
Reviewer:
Date:
Revalidation trigger:
```

An open item may appear in early drafting only when the related detail is marked `VERIFY IN TENANT`, represented synthetically, or omitted. An essential runnable claim must be resolved before its chapter is declared technically complete.
