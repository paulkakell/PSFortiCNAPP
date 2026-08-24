<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Asset Inventory and Coverage Contract

Module version: `0.1.0`

## `PSFortiCNAPP.AssetInventoryResult`

`Get-FortiCNAPPAsset` returns a collection envelope, not a normalized asset schema.

| Property | Meaning |
|---|---|
| `EnvironmentName` | Safe session environment label |
| `AccountName` | Safe account label |
| `CollectedAtUtc` | PowerShell collection completion time |
| `StartTimeUtc` | Requested UTC window start |
| `EndTimeUtc` | Requested UTC window end |
| `TimeField` | Requested provider time-filter field |
| `RequestedPageSize` | Requested page size |
| `PageCount` | Pages accepted by the shared client |
| `RecordCount` | Provider records returned |
| `CollectionComplete` | Whether requested continuation processing completed |
| `CorrelationId` | Provider or client correlation identifier |
| `RateLimit` | Safe rate metadata when available |
| `ProviderRecords` | Provider objects without local field invention |
| `ProviderRecordShape` | `Unnormalized` |
| `TenantValidationState` | `VERIFY IN TENANT` |
| `SensitiveValuesExposed` | Must remain false |

## `PSFortiCNAPP.AssetCoverage`

`Measure-FortiCNAPPAssetCoverage` returns a local calculation.

| Property | Meaning |
|---|---|
| `IntendedAssetCount` | Included scope denominator |
| `CurrentAssetCount` | Included assets with observations inside the freshness window |
| `StaleAssetCount` | Included assets with observations older than the threshold |
| `MissingAssetCount` | Included assets without an observation |
| `ExcludedAssetCount` | Scope records intentionally outside the denominator |
| `UnexpectedAssetCount` | Observed assets not found in included scope |
| `DuplicateAssetCount` | Asset identifiers with more than one observation |
| `CoveragePercent` | Current assets divided by included scope assets |
| `CoverageDenominator` | `Included scope assets` |
| `CalculationAuthority` | `PowerShellDerived` |

A zero included denominator produces a null percentage rather than a fabricated zero-percent result.
