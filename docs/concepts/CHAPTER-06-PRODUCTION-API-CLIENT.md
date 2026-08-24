<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 6 Companion Guide: A Production-Minded API Client

This guide supports Chapter 6 of *PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring*. It is independent open-source documentation, not the commercial manuscript.

## Purpose

Repeated one-line REST calls hide the controls that matter during security collection. `Invoke-FortiCNAPPRequest` centralizes tenant authority validation, bearer-token use, JSON serialization, response parsing, bounded retries, pagination, correlation metadata, rate-limit metadata, and redacted logging.

## Public commands

```powershell
Invoke-FortiCNAPPRequest
Get-FortiCNAPPSchema
```

The request command supports GET and POST because the documented API uses both for read-oriented collection, search, validation, and schema operations. It does not expose PUT, PATCH, or DELETE in this chapter.

## Smallest request

```powershell
$response = Invoke-FortiCNAPPRequest `
    -Session $session `
    -Method GET `
    -Path 'schemas/AuditLogs'
```

The response is a `PSFortiCNAPP.ApiResponse` object. It includes safe URI metadata, status, page and record counts, parsed data, attempt telemetry, request correlation, documented rate headers when present, body length, and SHA-256. It excludes authorization material, query values, and raw response text.

## Retry policy

The Chapter 6 client retries HTTP 429, 500, and 503 because the controlled API source documents those responses and identifies 429 as rate limiting. The retry count is bounded. `Retry-After` takes precedence, followed by `RateLimit-Reset`, then exponential backoff plus jitter.

A 401 or 403 is not retried. Repeating an unauthorized or forbidden request does not repair the credential or permission problem.

## Pagination

Use `-AllPages` only when the endpoint returns `paging.urls.nextPage`.

```powershell
$response = Invoke-FortiCNAPPRequest `
    -Session $session `
    -Method POST `
    -Path 'Inventory/search' `
    -Body $requestBody `
    -AllPages
```

Continuation URIs must use HTTPS, the connected tenant authority, and an `/api/v2/` path. Automatic collection stops at `MaxPageCount`, whose maximum value is 100. That bound corresponds to the documented 500,000-row result limit divided by the documented 5,000-row page limit, but endpoint applicability remains `VERIFY IN TENANT`.

## Redacted logging

`-LogPath` writes JSON Lines attempt records. Each entry includes safe path, query names, timing, status, retry decision, correlation ID, and remaining-rate value. It does not include the bearer token, request body, query values, or response body.

## Schema discovery

```powershell
$schema = Get-FortiCNAPPSchema `
    -Session $session `
    -Type AuditLogs
```

The API source documents `/api/v2/schemas`, `/api/v2/schemas/{type}`, and `/api/v2/schemas/{type}/{subtype}`. Available types, subtypes, and properties can vary by release and tenant. The command therefore returns the provider structure and labels tenant validation explicitly.

## Engineer interpretation

The client gives an engineer a reproducible record of what was requested, how many attempts occurred, whether paging completed, which response status was observed, and whether correlation or rate metadata was present.

## CISO interpretation

The existence of a successful API call is not a security outcome. The useful management statement is whether collection completed within the expected scope, whether rate or permission limits affected evidence, and whether the result is current enough to support a decision.

## Boundaries

- The endpoint and response conventions come from the controlled FortiCNAPP API 2.0 source snapshot.
- No controlled tenant request was performed for this chapter.
- Role permissions, response headers, rate-reset behavior, schema availability, and proxy behavior remain `VERIFY IN TENANT`.
- The public lab performs zero network requests.
- State-changing methods remain outside the general client.
