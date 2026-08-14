<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Companion Guide: HTTP, JSON, and API Contracts

This guide supports Chapter 4 of *PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring*. It is independent open-source documentation, not the commercial chapter manuscript.

## Purpose

A status code does not prove that a response is usable security evidence. A reliable collector must also understand the safe request target, UTC timing, response media type, headers, body state, and validation result.

The Chapter 4 lab uses six synthetic exchanges. It makes no network request. The reserved host `tenant.example.invalid` is not a tenant, and `/api/v2/example` is not a FortiCNAPP endpoint.

## Public command

```powershell
ConvertFrom-FortiCNAPPHttpExchange
```

The command accepts a synthetic or sanitized exchange through the pipeline and returns `PSFortiCNAPP.HttpExchange`. It performs local transformation only.

Required input properties:

- `exchangeId`
- `method`
- `requestUri`
- `startedAtUtc`
- `completedAtUtc`
- `statusCode`
- `responseBody`

Optional properties include `reasonPhrase`, `responseContentType`, and `headers`.

Only `SYNTHETIC` and `SANITIZED` classifications are accepted. Live collection belongs to later chapters.

## Smallest working example

```powershell
Import-Module ./src/PSFortiCNAPP/PSFortiCNAPP.psd1 -Force

$exchange = [pscustomobject]@{
    exchangeId          = 'syn-http-smallest'
    method              = 'GET'
    requestUri          = 'https://tenant.example.invalid/api/v2/example?limit=10'
    startedAtUtc        = '2026-08-13T20:00:00Z'
    completedAtUtc      = '2026-08-13T20:00:00.125Z'
    statusCode          = 200
    reasonPhrase        = 'OK'
    responseContentType = 'application/json'
    headers             = [pscustomobject]@{
        'Content-Type' = 'application/json'
        'X-Request-Id' = 'syn-request-smallest'
    }
    responseBody        = '{"data":[{"id":"syn-001"}]}'
}

$result = $exchange |
    ConvertFrom-FortiCNAPPHttpExchange `
        -DataClassification SYNTHETIC
```

Inspect the typed result:

```powershell
$result | Get-Member
$result |
    Select-Object ExchangeId, StatusCode, BodyState, ContractState
$result.ParsedBody.data
```

## Contract states

| State | Meaning |
|---|---|
| `Valid` | The exchange satisfies the local JSON-or-empty contract |
| `Warning` | The exchange is diagnostic evidence but uses an unsupported media type |
| `Invalid` | Declared JSON is malformed, or another explicit contract rule failed |

The contract state is PowerShell-derived. It is not a provider-native severity or incident status.

## Body states

| State | Meaning |
|---|---|
| `Empty` | The response body contains zero UTF-8 bytes |
| `ValidJson` | A JSON-compatible media type parsed successfully |
| `MalformedJson` | The response declared JSON but parsing failed |
| `UnsupportedMediaType` | A non-empty body used a media type outside the chapter contract |

A 200 response with malformed JSON remains invalid for the local contract. An HTML error page is not parsed as JSON merely because the caller expected JSON.

## Safe request and header handling

The returned `RequestUri` contains only scheme, host, and path. `QueryParameterNames` retains query names without values.

Known sensitive headers are removed:

- `Authorization`
- `Proxy-Authorization`
- `Cookie`
- `Set-Cookie`
- `X-Api-Key`
- `X-Auth-Token`

A small allowlist retains selected diagnostic metadata, including content type, request identifier, retry timing, and rate metadata. Unknown header values are not returned.

The command refuses non-HTTPS URIs. HTTPS alone does not prove the correct tenant, authorization, certificate chain, or endpoint.

## Response hashing

For a non-empty body, the object includes `BodyLengthBytes` and `BodySha256`. The raw body is not returned. Valid JSON is available through `ParsedBody`; unsupported or malformed text is represented through state, size, hash, and validation issues.

A hash supports integrity comparison. It does not prove source authority or completeness.

## Run the synthetic lab

```powershell
$summary = pwsh -NoProfile -File `
    ./examples/chapter-04/Review-SyntheticHttpExchanges.ps1
```

Expected synthetic totals:

| Property | Value |
|---|---:|
| `ExchangeCount` | 6 |
| `SuccessCount` | 4 |
| `ValidContractCount` | 3 |
| `WarningContractCount` | 2 |
| `InvalidContractCount` | 1 |

Inspect the problem cases:

```powershell
$summary.ContractIssueExchanges |
    Select-Object ExchangeId, StatusCode, BodyState, ContractState
```

The summary type is `PSFortiCNAPP.SyntheticHttpContractSummary`.

## Engineer interpretation

The lab establishes a local response contract before transport code exists:

- HTTP success and body validity are separate.
- Query values and sensitive headers do not enter ordinary output.
- JSON parsing follows the declared media type.
- Empty, unsupported, and malformed bodies remain distinct.
- Duration, body size, hash, and request identifiers remain available for diagnosis.
- Raw body text is not casually propagated to logs or reports.

## CISO interpretation

A defensible synthetic statement is:

> Four of six synthetic exchanges returned HTTP success status codes. Only three satisfied the local JSON-or-empty contract. One successful response contained malformed JSON, so transport success did not establish usable evidence.

The statement names the denominator and separates transport outcome from evidence quality.

## Failure behavior

The command stops with a structured error when a required property is absent, the URI is not absolute HTTPS, a timestamp is ambiguous or invalid, completion precedes start, the method is unsupported, or the status code is outside 100 through 599.

Body-contract problems are returned as object state. This lets a later collector preserve diagnostic metadata for malformed or unexpected content.

## Tests

```powershell
pwsh ./build/Invoke-Quality.ps1
```

Chapter 4 tests cover typed output, UTC normalization, duration, query-value removal, header redaction, JSON parsing, empty responses, retry metadata, HTML, malformed JSON, fixture provenance, synthetic totals, manifest synchronization, and structured failures.

## Repository paths

| Purpose | Path |
|---|---|
| Public parser | `src/PSFortiCNAPP/Public/ConvertFrom-FortiCNAPPHttpExchange.ps1` |
| Runnable lab | `examples/chapter-04/Review-SyntheticHttpExchanges.ps1` |
| Synthetic fixture | `tests/Fixtures/Synthetic/chapter-04-http-exchanges.json` |
| Unit tests | `tests/Unit/ConvertFrom-FortiCNAPPHttpExchange.Tests.ps1` |
| Fixture contract | `tests/Contract/Chapter04Fixture.Tests.ps1` |
| Example contract | `tests/Contract/Chapter04Example.Tests.ps1` |
| Source register | `docs/source-register/CHAPTER-04.md` |
| Chapter map | `docs/chapter-map/chapter-04.md` |
| Production notes | `manuscript/chapters/04-HTTP-JSON-AND-API-CONTRACTS-PRODUCTION-NOTES.md` |

## Boundaries

- Data classification: `SYNTHETIC`
- Live HTTP requests: none
- Tenant authentication: none
- Verified FortiCNAPP endpoints: none
- Verified request or response fields: none
- Verified LQL datasources or fields: none
- State-changing behavior: none
- External enrichment: none

Authentication begins in Chapter 5. The reusable provider request client, retries, observed headers, response handling, and schema discovery begin in Chapter 6.
