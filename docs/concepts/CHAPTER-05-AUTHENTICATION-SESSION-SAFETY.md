<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 5 Companion Guide: Authentication, Service Users, and Session Safety

This guide supports Chapter 5 of *PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring*. It is independent open-source documentation, not the commercial chapter manuscript.

## Purpose

Authentication is a boundary, not a convenience setting. A useful connection workflow must keep identity, configuration, secret input, temporary tokens, tenant scope, and local session state separate.

Chapter 5 adds a narrow account API-key workflow. The module creates a secret-free configuration, accepts the API secret as a `SecureString`, requests a temporary token from the documented FortiCNAPP v2 route, stores the bearer token in module-private state, and returns a safe session object.

The synthetic lab does not connect to a tenant. It validates five invented profiles and confirms that insecure or incomplete profiles fail before any request can occur.

## Public commands

Chapter 5 adds:

```powershell
New-FortiCNAPPConfiguration
Test-FortiCNAPPConfiguration
Connect-FortiCNAPP
Get-FortiCNAPPContext
Disconnect-FortiCNAPP
```

The complete module surface also retains the four commands accepted in Chapters 1 through 4.

## Build a secret-free configuration

```powershell
$configuration = New-FortiCNAPPConfiguration `
    -AccountName 'contoso-security' `
    -KeyId 'ACCOUNT_KEY_IDENTIFIER' `
    -EnvironmentName 'Production' `
    -TokenLifetimeSeconds 3600
```

`AccountName` and `KeyId` are configuration values. The API secret is not part of the object. When `BaseUri` is omitted, the command derives the documented tenant-host pattern:

```text
https://<account-name>.lacework.net/
```

An explicit authority can be supplied when it has been verified:

```powershell
$configuration = New-FortiCNAPPConfiguration `
    -AccountName 'contoso-security' `
    -KeyId 'ACCOUNT_KEY_IDENTIFIER' `
    -BaseUri 'https://contoso-security.lacework.net/'
```

The constructor accepts only an absolute HTTPS authority without user information, query values, fragments, or an additional path. It constructs the documented token route:

```text
/api/v2/access/tokens
```

The configuration includes the raw key identifier because the token request needs it. Default reporting should use `KeyIdDisplay`, which reveals only the last four characters. The key identifier is not the API secret, but it should still be handled as operational metadata rather than printed without need.

## Validate before connecting

```powershell
$validation = Test-FortiCNAPPConfiguration `
    -Configuration $configuration

$validation.Valid
$validation.Checks
```

Validation checks:

- Environment and account names are present.
- The tenant authority is absolute HTTPS.
- The authority contains no embedded credentials, query, fragment, or extra path.
- The token endpoint uses the same authority and the documented route.
- The key identifier is present.
- The requested lifetime is a positive integer.
- The object has no property whose name suggests an embedded secret or bearer token.

A warning is not silently converted into success. A custom host or lifetime above the project default can remain locally valid while requiring explicit review.

Local validation cannot prove that the tenant exists, the key is active, the assigned role is least privilege, or the account scope is correct. Those facts remain `VERIFY IN TENANT`.

## Enter the API secret

For an interactive session:

```powershell
$secret = Read-Host 'Enter the FortiCNAPP API secret' -AsSecureString
```

Do not place the secret in the script, command line, settings template, transcript, fixture, or source-control history.

`SecureString` narrows accidental exposure, but it is not a universal vault. The request helper must briefly materialize text to construct the provider authorization header. It clears its local references in `finally`, does not return the value, and replaces provider error detail with a structured sanitized error. This is ordinary credential hygiene, not a claim of forensic memory erasure.

Automated jobs should retrieve secrets from an approved store. The core module does not require a specific vault dependency. Microsoft.PowerShell.SecretManagement can provide a common retrieval interface, while operating-system, cloud, and enterprise vault examples remain optional companion material.

## Connect explicitly

```powershell
$session = Connect-FortiCNAPP `
    -Configuration $configuration `
    -Secret $secret
```

The command sends an explicit request body containing the key identifier and `expiryTime`. Sending the requested lifetime avoids depending on omission behavior that differs across source descriptions.

A successful response must contain a non-empty temporary token and an unambiguous future `expiresAt` timestamp. A 2xx response without that contract is rejected.

The returned `PSFortiCNAPP.Session` contains safe metadata only:

- Session identifier
- Environment and account names
- Base URI
- Authentication mode
- Masked key identifier
- UTC connection and expiration timestamps
- Requested lifetime
- Connection state

The bearer token is held in a module-private dictionary keyed by the session identifier. It is not a note property on the returned object and should not appear in default formatting, ordinary serialization, or error output.

Use `-WhatIf` to verify the target without requesting a token:

```powershell
Connect-FortiCNAPP `
    -Configuration $configuration `
    -Secret $secret `
    -WhatIf
```

## Inspect context safely

```powershell
$context = Get-FortiCNAPPContext -Session $session

$context |
    Select-Object EnvironmentName, AccountName, BaseUri, IsConnected, IsExpired, RemainingSeconds, ReadyForRequest
```

`ReadyForRequest` is a local calculation. It means the session record exists and its expiration has not passed. It does not prove that the provider will accept the token or authorize a later endpoint.

The context object deliberately omits the bearer token and API secret.

## Disconnect locally

```powershell
$result = Disconnect-FortiCNAPP -Session $session
```

The command clears the token reference held by the module and removes the local session record. It returns `RemoteTokenRevoked = $false` because Chapter 5 does not implement or claim a provider-side revocation operation.

Use `-WhatIf` to inspect the local action without removing state:

```powershell
Disconnect-FortiCNAPP -Session $session -WhatIf
```

After disconnection:

```powershell
Get-FortiCNAPPContext -Session $session
```

returns `IsConnected = $false` and `ReadyForRequest = $false`.

## Run the synthetic profile lab

```powershell
$summary = pwsh -NoProfile -File `
    ./examples/chapter-05/Review-SyntheticAuthenticationProfiles.ps1
```

Expected synthetic totals:

| Property | Value |
|---|---:|
| `ProfileCount` | 5 |
| `ValidProfileCount` | 2 |
| `InvalidProfileCount` | 3 |
| `ExpectedMatchCount` | 5 |
| `LiveRequestCount` | 0 |
| `SecretValueCount` | 0 |

The profiles cover a documented host pattern, a reserved synthetic host, insecure HTTP, a missing key identifier, and an incorrect token path.

## Failure behavior

The configuration commands stop on malformed account names and insecure or path-bearing authorities. `Connect-FortiCNAPP` stops when local validation fails, the token request fails, required response properties are absent, expiration is ambiguous, or the token is already expired.

The token helper classifies 401 and 403 separately when a status is available, but it does not copy provider response bodies into the public error. Tenant-specific response envelopes remain `VERIFY IN TENANT`.

## Service users and least privilege

Use a non-human service identity for unattended automation when the tenant supports the required model. Grant only the permissions needed by the intended read-only workflow, establish an owner, record the purpose, rotate the key, monitor use, and remove access when the automation is retired.

Chapter 5 does not name a universal FortiCNAPP role because role availability and scope can vary. Determine the least-privilege assignment in the target tenant and record the validation evidence before treating the configuration as production-ready.

## Reporting layers

CISO decision brief: authentication material is not embedded in code or output, temporary credentials have an explicit lifetime, and session state can be inspected and removed.

Risk explanation: a locally valid profile is necessary but does not establish tenant authorization or least privilege.

Engineer evidence: configuration checks, masked key identifier, safe tenant authority, token endpoint, UTC connection and expiration times, session identifier, and sanitized failure category.

Machine-readable evidence: `PSFortiCNAPP.ConfigurationValidation`, `PSFortiCNAPP.Session`, `PSFortiCNAPP.Context`, `PSFortiCNAPP.DisconnectResult`, and the synthetic profile summary.

## Boundaries

- Documented token endpoint: `POST /api/v2/access/tokens`
- Live tenant validation: none
- Live token retained in fixtures or tests: none
- FortiCloud authentication: not implemented
- Provider-side revocation: not implemented
- Endpoint authorization: `VERIFY IN TENANT`
- Service-user permissions: `VERIFY IN TENANT`
- State-changing security remediation: none

The reusable request client, token use for ordinary API calls, retries, response capture, and schema discovery begin in Chapter 6.
