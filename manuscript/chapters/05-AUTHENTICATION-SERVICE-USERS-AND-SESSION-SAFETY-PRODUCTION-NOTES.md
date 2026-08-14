<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 5 Production Notes: Authentication, Service Users, and Session Safety

## Status

Public companion increment prepared on `phase2/chapter-05-final`.

The complete commercial manuscript is maintained outside `paulkakell/PSFortiCNAPP`.

## Prerequisites and versions

- PowerShell 7.6 or later
- `PSFortiCNAPP` development module version `0.1.0`
- Accepted Chapters 1 through 4 on `main`
- Pester 5.9.0 and PSScriptAnalyzer 1.25.0 for repository validation
- Supplied FortiCNAPP API source snapshot declared as OpenAPI 3.0.3 and API version 2.0

## Verified interfaces

Verified official FortiCNAPP contract:

- `POST /api/v2/access/tokens`
- Request property `keyId`
- Request property `expiryTime`
- Response property `token`
- Response property `expiresAt`
- Account API secret supplied as bearer authorization for the token request

The implementation sends `expiryTime` explicitly because current source descriptions differ on whether omission is permitted.

Verified PowerShell and .NET interfaces:

- `Invoke-RestMethod`
- `SecureString`
- `PSCredential`
- `Read-Host -AsSecureString`
- `SupportsShouldProcess`
- `UriBuilder`
- Structured error handling

Verified LQL datasources and fields: none.

## Tenant-dependent behavior

The following remain `VERIFY IN TENANT`:

- Service-user availability and role names
- Least-privilege permissions for each workflow
- Account, subaccount, and organization scope
- Key activation and acceptance
- Actual token expiration behavior
- Observed 401 and 403 responses
- Context returned by later provider APIs
- FortiCloud authentication

## Assumptions

- Account API-key authentication is the first implemented authentication path.
- Configuration objects contain no API secret or bearer token.
- A default requested lifetime of 3600 seconds is a project choice, not an assertion that every tenant must accept it.
- A custom tenant authority must be verified before use.
- The returned session object is safe metadata; module-private state retains the temporary token.
- Local disconnect clears module-held state but does not claim provider-side revocation.
- `ReadyForRequest` is a PowerShell-derived local state, not proof of provider authorization.

## Repository changes

Public commands:

- `src/PSFortiCNAPP/Public/New-FortiCNAPPConfiguration.ps1`
- `src/PSFortiCNAPP/Public/Test-FortiCNAPPConfiguration.ps1`
- `src/PSFortiCNAPP/Public/Connect-FortiCNAPP.ps1`
- `src/PSFortiCNAPP/Public/Get-FortiCNAPPContext.ps1`
- `src/PSFortiCNAPP/Public/Disconnect-FortiCNAPP.ps1`

Private helpers:

- `src/PSFortiCNAPP/Private/ConvertFrom-FortiCNAPPSecureString.ps1`
- `src/PSFortiCNAPP/Private/Resolve-FortiCNAPPBaseUri.ps1`
- `src/PSFortiCNAPP/Private/Get-FortiCNAPPKeyIdDisplay.ps1`
- `src/PSFortiCNAPP/Private/Invoke-FortiCNAPPTokenRequest.ps1`
- `src/PSFortiCNAPP/Private/Get-FortiCNAPPSessionRecord.ps1`
- `src/PSFortiCNAPP/Private/New-FortiCNAPPSessionObject.ps1`

Module contract:

- `src/PSFortiCNAPP/PSFortiCNAPP.psd1`
- `src/PSFortiCNAPP/PSFortiCNAPP.psm1`
- `src/PSFortiCNAPP/Formats/PSFortiCNAPP.Format.ps1xml`

Lab and tests:

- `tests/Fixtures/Synthetic/chapter-05-authentication-profiles.json`
- `examples/chapter-05/Review-SyntheticAuthenticationProfiles.ps1`
- `tests/Unit/FortiCNAPPConfiguration.Tests.ps1`
- `tests/Unit/Invoke-FortiCNAPPTokenRequest.Tests.ps1`
- `tests/Unit/FortiCNAPPSession.Tests.ps1`
- `tests/Contract/Chapter05Fixture.Tests.ps1`
- `tests/Contract/Chapter05Example.Tests.ps1`
- `tests/Content/Chapter05.Tests.ps1`
- Existing module and manifest contracts

Documentation:

- `docs/concepts/CHAPTER-05-AUTHENTICATION-SESSION-SAFETY.md`
- `docs/reference/AUTHENTICATION-AND-SESSION-CONTRACT.md`
- `docs/source-register/CHAPTER-05.md`
- `docs/chapter-map/chapter-05.md`
- Project status and index files

## Code inventory

New exported commands: five.

Total exported commands after Chapter 5: nine.

New private helpers: six.

New public object types:

- `PSFortiCNAPP.Configuration`
- `PSFortiCNAPP.ConfigurationValidation`
- `PSFortiCNAPP.Session`
- `PSFortiCNAPP.Context`
- `PSFortiCNAPP.DisconnectResult`

New example type:

- `PSFortiCNAPP.SyntheticAuthenticationProfileSummary`

## Test inventory

- Configuration construction and HTTPS authority validation
- Explicit token endpoint construction
- Absence of embedded credential-shaped properties
- Five-profile synthetic fixture contract
- Synthetic lab totals and zero-request boundary
- Explicit `keyId` and `expiryTime` request body
- Authorization-header construction inside the private request helper
- Sanitized request failures
- Safe session output
- Context and expiration calculations
- Malformed and expired token responses
- `Connect-FortiCNAPP -WhatIf`
- Local disconnect and `Disconnect-FortiCNAPP -WhatIf`
- Manifest and module-export synchronization
- Existing cross-platform repository checks

## Security design

- The API secret is accepted only as `SecureString` by the public connection command.
- Plain text exists briefly inside the private request helper because an HTTP header requires text.
- Plain-text and header references are cleared in `finally`.
- The helper does not propagate raw provider response bodies.
- The bearer token is stored only in module-private session state.
- Public session, context, and disconnect objects contain no token or secret property.
- Configuration contains the key identifier but not the secret.
- Default display uses a masked key identifier.
- No TLS bypass or certificate-validation override is present.
- No secret-management dependency is required by the core module.

## Budget

Planned commercial manuscript: 6,000 to 6,500 words.

Public guide target: 1,500 to 2,500 words.

Repository source and test growth: approximately 1,200 to 1,800 lines.

## Known limitations

- The implementation has not been validated against a controlled FortiCNAPP tenant.
- Service-user roles and permissions remain tenant dependent.
- FortiCloud authentication is not implemented.
- Session state is process-local and does not survive module removal or process exit.
- Local disconnect does not revoke a provider token.
- Token refresh is not implemented.
- The request client for ordinary provider endpoints is deferred to Chapter 6.
- A process memory dump may still recover transient or retained credential material.
- The implementation does not claim secure forensic erasure.
- Custom authority support requires operator verification.
- Provider limits remain authoritative when they differ from local requested values.

## Reporting layers

1. CISO decision brief: credentials are not embedded in code or returned objects, and temporary access has explicit expiration.
2. Risk explanation: local configuration validity does not prove tenant authorization or least privilege.
3. Security engineer evidence: safe authority, token endpoint, masked key identifier, request lifetime, UTC connection and expiration, failure class, and session state.
4. Machine-readable evidence: typed configuration, validation, session, context, disconnect, and synthetic summary objects.

## Completion gates

- Current branch checks pass on Windows, Ubuntu, and macOS.
- All Pester tests pass.
- Coverage remains at or above 85 percent.
- PSScriptAnalyzer passes.
- Manifest and loader export the same nine commands.
- Secret, SPDX, repository-safety, and prohibited-character checks pass.
- Development package and checksum verification pass.
- The commercial manuscript remains outside the public repository.
- The manuscript word count is recorded.
- Zero U+2014 characters are present.
