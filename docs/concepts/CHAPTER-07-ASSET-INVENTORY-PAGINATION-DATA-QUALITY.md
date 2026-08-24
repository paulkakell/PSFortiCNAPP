<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 7 Companion Guide: Asset Inventory, Pagination, and Data Quality

This guide supports Chapter 7 of *PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring*. It is independent repository documentation, not the commercial manuscript.

## Purpose

An inventory response is not proof of complete coverage. A collection can succeed while expected assets are missing, observations are stale, duplicates exist, or records appear outside the intended scope.

Chapter 7 separates two jobs:

1. `Get-FortiCNAPPAsset` collects provider records through the documented inventory search route.
2. `Measure-FortiCNAPPAssetCoverage` compares observed assets with an explicit scope register.

The collection result preserves provider records as `Unnormalized`. Exact provider fields remain `VERIFY IN TENANT` until a controlled response fixture and schema contract are approved.

## Documented interface

The controlled FortiCNAPP API 2.0 source documents:

```text
POST /api/v2/Inventory/search
```

The project uses the shared Chapter 6 request client for authentication, retries, pagination, logging, and response metadata.

The source documents inventory time filtering and supplies `createdOrUpdatedTime` in an example. Whether that field is accepted for the target tenant and release remains `VERIFY IN TENANT`.

## Smallest collection example

```powershell
$assets = Get-FortiCNAPPAsset `
    -Session $session `
    -StartTimeUtc ([DateTimeOffset]'2026-08-23T00:00:00Z') `
    -EndTimeUtc ([DateTimeOffset]'2026-08-24T00:00:00Z') `
    -PageSize 5000
```

The command converts the UTC boundaries to Unix epoch milliseconds, builds the request body, and delegates continuation handling to `Invoke-FortiCNAPPRequest`.

The returned type is `PSFortiCNAPP.AssetInventoryResult`. Important properties include the UTC window, page count, record count, completion state, correlation identifier, rate metadata, unnormalized provider records, and tenant-validation state.

The command does not rename unknown provider fields or invent asset identifiers.

## Run the synthetic coverage lab

```powershell
$result = pwsh -NoProfile -File `
    ./examples/chapter-07/Review-SyntheticAssetCoverage.ps1
```

Expected synthetic result:

| Measure | Value |
|---|---:|
| Included scope assets | 8 |
| Current observations | 6 |
| Stale observations | 1 |
| Missing observations | 1 |
| Excluded assets | 1 |
| Unexpected assets | 1 |
| Assets with duplicate observations | 1 |
| Current coverage | 75 percent |

The formula is current included assets divided by included scope assets, multiplied by 100. Excluded assets do not enter the denominator. Stale and missing observations do not count as current coverage.

## Data-quality interpretation

The result retains separate collections for current, stale, missing, excluded, unexpected, and duplicate assets.

A duplicate does not automatically mean two assets exist. It means the input contained more than one observation for the same asset identifier. The function uses the latest timestamp for current-versus-stale classification and retains the duplicate record for review.

An unexpected asset may indicate scope drift, a discovery gap, a newly onboarded resource, or an identifier mismatch. It is not automatically an error.

## Engineer evidence

A reproducible assessment records collection and assessment timestamps in UTC, included and excluded scope records, freshness threshold, source record identifiers, duplicate groups, missing and stale asset lists, unexpected observations, formula, denominator, and tenant-validation state.

## Executive interpretation

A defensible synthetic statement is:

> Six of eight included synthetic assets have current observations, for 75 percent current coverage. One included asset is stale and one is missing. One unexpected asset and one duplicate observation require engineering review before leadership treats the inventory as complete.

This statement does not claim that risk improved. It describes visibility and its limitations.

## Boundaries

- Data classification: `SYNTHETIC`
- Documented endpoint: `POST /api/v2/Inventory/search`
- Controlled tenant execution: not performed
- Provider record normalization: not approved
- Coverage calculation: PowerShell-derived
- State-changing behavior: none
- External enrichment: none
- Exact permissions and field availability: `VERIFY IN TENANT`

The complete commercial chapter remains outside `paulkakell/PSFortiCNAPP`.
