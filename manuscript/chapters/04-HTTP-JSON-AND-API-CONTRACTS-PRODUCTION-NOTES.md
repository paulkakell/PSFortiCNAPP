<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 4 Production Notes: HTTP, JSON, and API Contracts

## Status

Public companion increment prepared on `phase2/chapter-04-companion`.

The complete commercial manuscript is maintained outside `paulkakell/PSFortiCNAPP`.

## Prerequisites and versions

- PowerShell 7.6 or later
- `PSFortiCNAPP` development module version `0.1.0`
- Chapter 3 export-contract correction merged into `main`
- Pester 5.9.0 and PSScriptAnalyzer 1.25.0 for repository validation
- Supplied FortiCNAPP API source snapshot declared as OpenAPI 3.0.3 and API version 2.0

## Verified interfaces

Verified official standards and tools:

- HTTP semantics
- JSON syntax
- URI syntax
- Reserved `.invalid` domain use
- PowerShell web and JSON commands
- PowerShell hash tables and error handling
- The controlled FortiCNAPP API 2.0 source snapshot identity and hash

Verified FortiCNAPP endpoints: none.

Verified FortiCNAPP request parameters: none.

Verified FortiCNAPP response properties: none.

Verified LQL datasources and fields: none.

## Assumptions

- Chapter 4 teaches a local HTTP exchange contract before authentication and transport.
- The synthetic JSON-or-empty contract is a project design choice.
- The placeholder `/api/v2/example` path is not a provider endpoint.
- The reserved host `tenant.example.invalid` is intentionally non-routable.
- Query values and sensitive headers are unsafe for ordinary output.
- Raw provider response preservation requires a later evidence-store design.

## Repository changes

- `src/PSFortiCNAPP/Public/ConvertFrom-FortiCNAPPHttpExchange.ps1`
- `src/PSFortiCNAPP/PSFortiCNAPP.psd1`
- `src/PSFortiCNAPP/PSFortiCNAPP.psm1`
- `src/PSFortiCNAPP/Formats/PSFortiCNAPP.Format.ps1xml`
- `tests/Fixtures/Synthetic/chapter-04-http-exchanges.json`
- `examples/chapter-04/Review-SyntheticHttpExchanges.ps1`
- `tests/Unit/ConvertFrom-FortiCNAPPHttpExchange.Tests.ps1`
- `tests/Contract/Chapter04Fixture.Tests.ps1`
- `tests/Contract/Chapter04Example.Tests.ps1`
- `tests/Content/Chapter04.Tests.ps1`
- `docs/concepts/CHAPTER-04-HTTP-JSON-API-CONTRACTS.md`
- `docs/reference/HTTP-EXCHANGE-CONTRACT.md`
- `docs/source-register/CHAPTER-04.md`
- `docs/chapter-map/chapter-04.md`
- `README.md`
- `CHANGELOG.md`
- `examples/README.md`
- `src/PSFortiCNAPP/README.md`
- `docs/project/ROADMAP.md`
- `manuscript/chapters/04-HTTP-JSON-AND-API-CONTRACTS-PRODUCTION-NOTES.md`

## Test inventory

- Unit tests for valid JSON, empty body, unsupported media type, malformed JSON, query redaction, header redaction, hashing, status classification, duration, and structured errors
- Fixture tests for provenance, reserved host, unique identifiers, scenario coverage, and secret-pattern absence
- End-to-end example tests for totals and absence of query values and raw response text
- Manifest and module-export contract updates
- Public documentation contract
- Existing cross-platform repository tests

## Code inventory

New public command:

- `ConvertFrom-FortiCNAPPHttpExchange`

New public type:

- `PSFortiCNAPP.HttpExchange`

New example type:

- `PSFortiCNAPP.SyntheticHttpContractSummary`

## Budget

Planned commercial manuscript: 6,500 words.

Public guide target: 1,500 to 2,500 words.

Repository source and test growth: approximately 800 to 1,200 lines.

## Known limitations

- The command does not make an HTTP request.
- Authentication and token handling are not implemented.
- The allowlist covers only Chapter 4 diagnostic headers.
- HTTP date-form `Retry-After` is not converted to seconds.
- Compressed, binary, streaming, and multipart bodies are not modeled.
- Raw response bodies are not returned or archived.
- JSON schema validation is not implemented.
- No observed FortiCNAPP response has been used.
- The body contract is a project design, not a provider guarantee.
- Tenant-dependent behavior remains `VERIFY IN TENANT`.

## Reporting layers

1. CISO decision brief: transport success does not prove usable evidence.
2. Risk and trend explanation: status, media type, and contract validity have separate denominators.
3. Security engineer evidence: method, safe URI, UTC timing, status, safe headers, body state, size, hash, and issues.
4. Machine-readable evidence: typed exchange and synthetic summary objects.

## Completion gates

- Current branch checks pass on Windows, Ubuntu, and macOS.
- All Pester tests pass.
- Coverage remains at or above 85 percent.
- PSScriptAnalyzer passes.
- Manifest and loader export the same four public commands.
- SPDX and repository-safety checks pass.
- Development package and checksum verification pass.
- Zero U+2014 characters are present.
- The commercial manuscript remains outside the public repository.
