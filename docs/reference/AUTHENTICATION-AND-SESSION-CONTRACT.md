<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Authentication and Session Contract

Module version: `0.1.0` development baseline

Validation context: official FortiCNAPP API v2 source records plus synthetic and mocked tests. Live tenant behavior remains `VERIFY IN TENANT`.

## Configuration

`PSFortiCNAPP.Configuration` contains:

- `EnvironmentName`
- `AccountName`
- `BaseUri`
- `TokenEndpoint`
- `AuthenticationMode`
- `KeyId`
- `KeyIdDisplay`
- `TokenLifetimeSeconds`
- `ContainsSecret`
- `CreatedAtUtc`

The object cannot contain an API secret or bearer token. `KeyIdDisplay` is intended for ordinary display.

## Local validation

`PSFortiCNAPP.ConfigurationValidation` reports `Valid`, pass, warning, and failure counts, plus individual checks. It establishes only the local configuration contract.

It does not prove:

- Tenant existence
- Key activation
- Role assignment
- Least privilege
- Account or subaccount scope
- Token issuance

## Temporary-token request

Documented route:

```text
POST /api/v2/access/tokens
```

The request sends:

```json
{
  "keyId": "<configured key identifier>",
  "expiryTime": 3600
}
```

The API secret is supplied through bearer authorization only for this token request. `expiryTime` is always explicit.

A response is accepted only when `token` is non-empty and `expiresAt` is an unambiguous future timestamp.

## Session

`PSFortiCNAPP.Session` exposes safe metadata:

- `SessionId`
- `EnvironmentName`
- `AccountName`
- `BaseUri`
- `AuthenticationMode`
- `KeyIdDisplay`
- `ConnectedAtUtc`
- `ExpiresAtUtc`
- `TokenLifetimeSeconds`
- `IsConnected`

The bearer token is retained in module-private process state keyed by `SessionId`.

## Context

`PSFortiCNAPP.Context` reports local connection and expiration state. `ReadyForRequest` means only that local state exists and is not expired.

## Disconnect

`Disconnect-FortiCNAPP` clears the module-held token reference and removes the local session record. `RemoteTokenRevoked` remains false because no remote revocation operation is implemented.

## Error identifiers

| Identifier | Meaning |
|---|---|
| `PSFortiCNAPP.Configuration.InvalidAccountName` | Account-name shape failed local validation |
| `PSFortiCNAPP.Configuration.InvalidBaseUri` | Tenant authority failed the HTTPS authority contract |
| `PSFortiCNAPP.Configuration.Invalid` | Constructed configuration was not locally valid |
| `PSFortiCNAPP.Authentication.InvalidConfiguration` | Connection attempted with an invalid configuration |
| `PSFortiCNAPP.Authentication.EmptySecret` | Supplied SecureString resolved to an empty value |
| `PSFortiCNAPP.Authentication.Unauthorized` | Token request returned HTTP 401 when observable |
| `PSFortiCNAPP.Authentication.Forbidden` | Token request returned HTTP 403 when observable |
| `PSFortiCNAPP.Authentication.TokenRequestFailed` | Token request failed without a separately classified status |
| `PSFortiCNAPP.Authentication.InvalidTokenResponse` | Required token response values were absent or malformed |
| `PSFortiCNAPP.Authentication.ExpiredTokenResponse` | Token response was already expired |
| `PSFortiCNAPP.Session.InvalidObject` | Supplied session object lacked a valid identifier |
| `PSFortiCNAPP.Session.NotConnected` | Session identifier was not present in module-private state |

Raw provider response bodies are not included in these errors.

## Limitations

- Account API-key authentication only
- No FortiCloud implementation
- No token refresh
- No remote token revocation
- Process-local state only
- No claim of forensic memory erasure
- Permissions and scope remain `VERIFY IN TENANT`
