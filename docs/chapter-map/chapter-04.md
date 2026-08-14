<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Repository Map

Chapter: **HTTP, JSON, and API Contracts**

Commercial manuscript location: outside the public repository.

## Reader workflow

1. Run the Chapter 2 environment check.
2. Review the synthetic HTTP fixture.
3. Convert one exchange into `PSFortiCNAPP.HttpExchange`.
4. Inspect the query-free URI and safe headers.
5. Compare status, body, and contract states.
6. Run the complete Chapter 4 example.
7. Run the related Pester tests.

## Artifact map

| Chapter element | Public artifact |
|---|---|
| HTTP exchange object | `src/PSFortiCNAPP/Public/ConvertFrom-FortiCNAPPHttpExchange.ps1` |
| JSON parsing | `BodyState` and `ParsedBody` in the public command |
| Query-value removal | `RequestUri` and `QueryParameterNames` |
| Header redaction | `SafeHeaders` and `RedactedHeaderNames` |
| Integrity metadata | `BodyLengthBytes` and `BodySha256` |
| Synthetic cases | `tests/Fixtures/Synthetic/chapter-04-http-exchanges.json` |
| Complete example | `examples/chapter-04/Review-SyntheticHttpExchanges.ps1` |
| Public tutorial | `docs/concepts/CHAPTER-04-HTTP-JSON-API-CONTRACTS.md` |
| Source traceability | `docs/source-register/CHAPTER-04.md` |
| Production traceability | `manuscript/chapters/04-HTTP-JSON-AND-API-CONTRACTS-PRODUCTION-NOTES.md` |

## Expected synthetic result

- Six total HTTP exchanges
- Four HTTP success responses
- Three valid local contracts
- Two warning contracts
- One invalid contract
- No query values or raw response bodies in the returned summary

## Boundary

The host `tenant.example.invalid` is reserved for synthetic use. The path `/api/v2/example` is not a FortiCNAPP endpoint.

No authentication, tenant request, API schema, LQL datasource, permission, or provider behavior is validated in Chapter 4.
