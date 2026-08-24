<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 7 Repository Map

Chapter: **Asset Inventory, Pagination, and Data Quality**

Commercial manuscript location: outside the public repository.

| Chapter element | Public artifact |
|---|---|
| Inventory collection | `src/PSFortiCNAPP/Public/Get-FortiCNAPPAsset.ps1` |
| Coverage calculation | `src/PSFortiCNAPP/Public/Measure-FortiCNAPPAssetCoverage.ps1` |
| Synthetic scope and observations | `tests/Fixtures/Synthetic/chapter-07-asset-coverage.json` |
| Runnable lab | `examples/chapter-07/Review-SyntheticAssetCoverage.ps1` |
| Collection tests | `tests/Unit/Get-FortiCNAPPAsset.Tests.ps1` |
| Coverage tests | `tests/Unit/Measure-FortiCNAPPAssetCoverage.Tests.ps1` |
| Fixture contract | `tests/Contract/Chapter07Fixture.Tests.ps1` |
| Example contract | `tests/Contract/Chapter07Example.Tests.ps1` |
| Public guide | `docs/concepts/CHAPTER-07-ASSET-INVENTORY-PAGINATION-DATA-QUALITY.md` |
| Object contract | `docs/reference/ASSET-INVENTORY-AND-COVERAGE-CONTRACT.md` |
| Source register | `docs/source-register/CHAPTER-07.md` |
| Verification record | `docs/verification/chapter-07-verification.json` |
| Production notes | `manuscript/chapters/07-ASSET-INVENTORY-PAGINATION-AND-DATA-QUALITY-PRODUCTION-NOTES.md` |

Expected synthetic coverage is six current assets from an eight-asset included denominator, or 75 percent. One asset is stale, one is missing, one is excluded, one is unexpected, and one asset identifier has duplicate observations.
