<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 7 Production Notes: Asset Inventory, Pagination, and Data Quality

## Status

Public companion contract correction prepared. The complete commercial manuscript is maintained outside `paulkakell/PSFortiCNAPP`.

## Prerequisites and versions

- PowerShell 7.6 or later
- `PSFortiCNAPP` development module version `0.1.0`
- Accepted Chapters 1 through 6
- Controlled FortiCNAPP API 2.0 source snapshot
- Pester 5.9.0 and PSScriptAnalyzer 1.25.0 for repository validation

## Verified interface

- Method: `POST`
- Path: `/api/v2/Inventory/search`
- General page limit: 5,000 rows
- General result-set limit: 500,000 rows
- Controlled tenant validation: not performed
- Provider field normalization: not approved

## Assumptions

- Collection uses explicit UTC boundaries.
- The shared client handles bounded continuation processing.
- `createdOrUpdatedTime` is retained as a documented example and remains `VERIFY IN TENANT`.
- An explicit scope register supplies the reporting denominator.
- Stale and missing observations do not count as current coverage.
- Duplicate and unexpected records remain visible.

## Code inventory

- `Get-FortiCNAPPAsset`
- `Measure-FortiCNAPPAssetCoverage`
- `PSFortiCNAPP.AssetInventoryResult`
- `PSFortiCNAPP.AssetCoverage`

## Test inventory

- Inventory request-shape and validation unit tests
- Coverage calculation and data-quality unit tests
- Synthetic fixture contract
- End-to-end example contract
- Manifest and module-export synchronization
- Public content and manuscript-boundary checks

## Reporting layers

1. CISO decision brief: state current coverage and material gaps.
2. Risk and trend explanation: disclose denominator, threshold, exclusions, and data-quality conditions.
3. Engineer evidence: retain scope IDs, asset IDs, timestamps, duplicate groups, missing and stale records.
4. Machine-readable evidence: return `PSFortiCNAPP.AssetCoverage`.

## Budget

Commercial manuscript target: 6,000 words.

## Known limitations

- No controlled tenant collection was performed.
- Provider records remain unnormalized.
- Exact permissions and response properties remain `VERIFY IN TENANT`.
- The synthetic coverage calculation does not prove FortiCNAPP product coverage.
- The freshness threshold is an explicit project input, not a provider guarantee.

## Completion gates

- Thirteen public commands are synchronized across the manifest and module loader.
- Chapter 7 unit, contract, and content tests pass.
- Repository coverage remains at or above 85 percent.
- PSScriptAnalyzer passes.
- SPDX and repository safety checks pass.
- Package and checksum verification pass.
- The repository contains zero U+2014 characters.
