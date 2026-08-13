<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Phase 1 Validation Report

Validation date: 2026-08-13

## Automated checks

| Check | Result |
|---|---|
| Files before this report | 27 |
| Markdown files before this report | 21 |
| UTF-8 text files scanned | 27 |
| Unicode U+2014 occurrences | 0 |
| Sample prose word count | 1224 |
| Required sample range | 1,000 to 1,500 words |
| Sample range result | PASS |
| Six parts in master outline | PASS |
| Sixteen chapters in master outline | PASS |
| Six appendices in master outline | PASS |
| Verification-ledger items | 28 |
| Production API endpoint implementation included | No |
| Real tenant credentials or identifiers included | No |

## Manual consistency checks

- The exact book title is consistent across the README, book bible, and outline.
- The module name is consistently `PSFortiCNAPP`.
- GitHub Releases is the only planned public distribution channel.
- PowerShell Gallery is explicitly excluded.
- The split-license mapping is consistent across the root notice, license-scope document, and file headers.
- Open endpoint, schema, pagination, LQL, permission, and product-behavior claims are controlled by the verification ledger.
- The sample section uses synthetic data and does not present an unverified FortiCNAPP endpoint or LQL query.

## Runtime limitation

The generation environment did not contain a PowerShell executable, so `tools/Test-ProhibitedCharacters.ps1` could not be executed under PowerShell during packaging. Its intended check was independently reproduced by a UTF-8 repository scan, which found zero U+2014 occurrences. The PowerShell script should be parsed and executed in the first repository CI run.
