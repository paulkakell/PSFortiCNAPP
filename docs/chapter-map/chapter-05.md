<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 5 Repository Map

Chapter: **Authentication, Service Users, and Session Safety**

Commercial manuscript location: outside the public repository.

## Reader workflow

1. Create a secret-free configuration.
2. Validate the tenant authority, key identifier, token route, and lifetime.
3. Review the five synthetic profiles.
4. Enter a secret interactively only in a controlled session.
5. Use `Connect-FortiCNAPP -WhatIf` before a live token request.
6. Inspect safe session context.
7. Remove local session state.
8. Run the related Pester tests.

## Artifact map

| Chapter element | Public artifact |
|---|---|
| Configuration constructor | `src/PSFortiCNAPP/Public/New-FortiCNAPPConfiguration.ps1` |
| Local validation | `src/PSFortiCNAPP/Public/Test-FortiCNAPPConfiguration.ps1` |
| Temporary-token connection | `src/PSFortiCNAPP/Public/Connect-FortiCNAPP.ps1` |
| Safe context | `src/PSFortiCNAPP/Public/Get-FortiCNAPPContext.ps1` |
| Local disconnect | `src/PSFortiCNAPP/Public/Disconnect-FortiCNAPP.ps1` |
| Private token request | `src/PSFortiCNAPP/Private/Invoke-FortiCNAPPTokenRequest.ps1` |
| Synthetic profiles | `tests/Fixtures/Synthetic/chapter-05-authentication-profiles.json` |
| Complete lab | `examples/chapter-05/Review-SyntheticAuthenticationProfiles.ps1` |
| Public guide | `docs/concepts/CHAPTER-05-AUTHENTICATION-SESSION-SAFETY.md` |
| Object contract | `docs/reference/AUTHENTICATION-AND-SESSION-CONTRACT.md` |
| Source traceability | `docs/source-register/CHAPTER-05.md` |
| Production traceability | `manuscript/chapters/05-AUTHENTICATION-SERVICE-USERS-AND-SESSION-SAFETY-PRODUCTION-NOTES.md` |

## Expected synthetic result

- Five profiles
- Two locally valid profiles
- Three locally invalid profiles
- Five expected outcomes reproduced
- Zero live requests
- Zero secret values

## Boundary

The lab is synthetic. The module implements the documented token-request shape, but service-user permissions, tenant scope, live issuance, response variation, and FortiCloud authentication remain `VERIFY IN TENANT`.
