<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 6 Repository Map

Chapter: **Building a Production-Quality FortiCNAPP API Client**

Commercial manuscript location: outside the public repository.

| Chapter element | Public artifact |
|---|---|
| Central request command | `src/PSFortiCNAPP/Public/Invoke-FortiCNAPPRequest.ps1` |
| Schema discovery | `src/PSFortiCNAPP/Public/Get-FortiCNAPPSchema.ps1` |
| URI validation | `src/PSFortiCNAPP/Private/New-FortiCNAPPRequestUri.ps1` |
| Retry calculation | `src/PSFortiCNAPP/Private/Get-FortiCNAPPRetryDelay.ps1` |
| Redacted logging | `src/PSFortiCNAPP/Private/Write-FortiCNAPPRequestLog.ps1` |
| Synthetic plan | `tests/Fixtures/Synthetic/chapter-06-api-client.json` |
| Runnable lab | `examples/chapter-06/Review-SyntheticRequestPlan.ps1` |
| Unit tests | `tests/Unit/Invoke-FortiCNAPPRequest.Tests.ps1` |
| Public guide | `docs/concepts/CHAPTER-06-PRODUCTION-API-CLIENT.md` |
| Contract reference | `docs/reference/API-CLIENT-CONTRACT.md` |
| Source traceability | `docs/source-register/CHAPTER-06.md` |

No controlled tenant result is included.
