<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 6 Production Notes: Building a Production-Quality FortiCNAPP API Client

## Prerequisites and versions

- PowerShell 7.6 or later
- `PSFortiCNAPP` development module version `0.1.0`
- Chapters 1 through 5 accepted
- Controlled FortiCNAPP API source snapshot declared as OpenAPI 3.0.3 and API version 2.0

## Verified interfaces

- General API response conventions
- `Authorization: Bearer` request header
- `Content-Type: application/json`
- `paging.rows`, `paging.totalRows`, and `paging.urls.nextPage`
- 5,000 rows per page and 500,000 rows per result set
- 480 requests per hour per user and documented RateLimit headers
- HTTP 429, 500, and 503 responses
- `/api/v2/schemas`, `/api/v2/schemas/{type}`, and `/api/v2/schemas/{type}/{subtype}`

Permissions and observed tenant behavior remain `VERIFY IN TENANT`.

## Repository changes

New public commands:

- `Invoke-FortiCNAPPRequest`
- `Get-FortiCNAPPSchema`

The Chapter 5 configuration compatibility wrappers are removed and their behavior is consolidated into the canonical validator.

## Tests

- Request success and safe output
- Query-value redaction
- POST serialization
- 429 retry with provider delay
- Non-retryable 403
- Transport retry
- Pagination aggregation
- Cross-authority continuation rejection
- Malformed successful JSON
- Redacted JSON Lines logging
- Expired-session rejection
- Schema type and subtype behavior

## Budget

Planned commercial manuscript: 7,000 words.

## Known limitations

- No controlled tenant request was executed.
- Proxy authentication is not modeled.
- HTTP date-form Retry-After is not parsed.
- The client supports GET and POST only.
- Raw response bodies are not returned or archived.
- Token renewal is deferred to operational orchestration.
- Endpoint-specific permissions remain `VERIFY IN TENANT`.

## Completion gates

- Windows, Ubuntu, and macOS PowerShell 7.6 jobs pass.
- Pester passes with repository coverage at or above 85 percent.
- PSScriptAnalyzer passes.
- Manifest and loader export the same eleven commands.
- SPDX, repository safety, packaging, and checksum checks pass.
- Zero U+2014 characters are present.
