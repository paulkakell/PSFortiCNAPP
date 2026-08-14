<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 5 Source Register

Chapter: **Authentication, Service Users, and Session Safety**

Access date: 2026-08-14

The runnable public lab is synthetic and makes no network request. The module includes the documented account API-key token request path, but tenant authorization and operational behavior remain `VERIFY IN TENANT` until controlled validation is recorded.

## C5-S001: FortiCNAPP API keys and access tokens

- Publisher: Fortinet
- Title: API keys and access tokens
- Product: FortiCNAPP
- URL: https://docs.fortinet.com/document/forticnapp/latest/api-reference/932048/api-keys-and-access-tokens
- Supports: Account API keys are exchanged for temporary access tokens; the request identifies the key and requests an expiration period.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Tenant role assignment, service-user scope, token issuance, actual expiration, and failure behavior require controlled tenant evidence.

## C5-S002: Supplied FortiCNAPP API 2.0 source snapshot

- Publisher: Fortinet
- Repository record: `docs/source-register/FORTICNAPP-API-2.0-SNAPSHOT.md`
- Declared API version: 2.0
- OpenAPI version: 3.0.3
- SHA-256: `7015f76895f20f6934d0d391ab0e76ebccb83bd692cd41c32fac5fbf445b39d7`
- Supports: `POST /api/v2/access/tokens`, request properties `keyId` and `expiryTime`, and response properties `token` and `expiresAt`.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The vendor snapshot is not redistributed. The implementation always sends `expiryTime` explicitly because source descriptions differ on whether omission is permitted.

## C5-S003: Invoke-RestMethod

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6
- Supports: HTTPS requests, headers, JSON request bodies, timeout control, and terminating-error handling.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: PowerShell command behavior does not establish FortiCNAPP authorization or response correctness.

## C5-S004: SecureString

- Publisher: Microsoft
- Version: .NET and PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/dotnet/api/system.security.securestring
- Supports: Accepting a secret without declaring a plain-text string parameter.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: SecureString is not a universal secret vault and does not prove forensic erasure. The implementation must briefly materialize text to construct the provider request.

## C5-S005: PSCredential

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscredential
- Supports: Converting a SecureString for immediate use by a request helper.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The resulting plain-text value must not be logged, returned, serialized, or retained after request construction.

## C5-S006: Read-Host

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/read-host?view=powershell-7.6
- Supports: Interactive secret entry with `-AsSecureString`.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Interactive entry is not suitable for every scheduler or CI system. Automated secret providers are introduced later.

## C5-S007: ShouldProcess

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/how-to-support-transactions?view=powershell-7.6
- Supports: `SupportsShouldProcess`, `-WhatIf`, and `-Confirm` behavior for commands that create or remove session state.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: `-WhatIf` proves only that the module skipped its action path.

## C5-S008: SecretManagement

- Publisher: Microsoft
- Product: Microsoft.PowerShell.SecretManagement
- URL: https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules
- Supports: A common PowerShell interface for retrieving secrets from registered vault extensions.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The core module does not require SecretManagement or a specific vault. Provider-specific examples remain optional repository material.

## C5-S009: PowerShell error handling

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.6
- Supports: Terminating-error handling and cleanup in `finally`.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Raw provider error bodies may contain sensitive data and are not propagated by the token helper.

## C5-S010: URI construction

- Publisher: Microsoft
- Product: .NET
- URL: https://learn.microsoft.com/en-us/dotnet/api/system.uribuilder
- Supports: Normalizing an HTTPS authority and constructing the token endpoint without string-concatenating query values.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: A valid URI does not prove the correct tenant or authorization.

## Verification decision

`POST /api/v2/access/tokens` and its documented request and response names may be described as `VERIFIED OFFICIAL`.

The following remain `VERIFY IN TENANT`:

- Which service-user role is least privilege for a specific workflow
- Which account or subaccount scope the key reaches
- Whether the key is accepted in the target tenant
- Actual token lifetime and expiration behavior
- Current 401 and 403 response bodies
- Tenant-specific identity, organization, and context behavior
- FortiCloud authentication behavior

No tenant-verification item is closed by the synthetic Chapter 5 lab.
