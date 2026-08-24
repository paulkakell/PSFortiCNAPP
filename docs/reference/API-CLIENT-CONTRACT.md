<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# API Client Contract

Module version: `0.1.0`

## `PSFortiCNAPP.ApiResponse`

| Property | Meaning |
|---|---|
| `SessionId` | Process-local session identifier |
| `EnvironmentName` | Operator-defined environment label |
| `AccountName` | Connected account configuration |
| `RequestUri` | HTTPS URI without query values |
| `QueryParameterNames` | Query names only |
| `StatusCode` | Last HTTP status |
| `PageCount` | Successfully collected pages |
| `RecordCount` | Aggregated data records |
| `CollectionComplete` | No continuation remained at completion |
| `Data` | Parsed provider data records |
| `Attempts` | Safe per-attempt telemetry |
| `CorrelationId` | Provider request identifier when returned |
| `RateLimit` | Documented rate metadata when returned |
| `LastBodyLengthBytes` | UTF-8 length of the last response body |
| `LastBodySha256` | SHA-256 of the last response body |
| `RawResponseReturned` | Always false in Chapter 6 |
| `SensitiveValuesExposed` | Always false in Chapter 6 |

## Retry behavior

Default retry statuses: 429, 500, and 503.

Precedence for delay selection:

1. Numeric `Retry-After`.
2. Numeric `RateLimit-Reset`.
3. Exponential delay based on `InitialRetryDelaySeconds`.
4. Random jitter up to `JitterMaximumMilliseconds`.

Retries are module behavior. Actual tenant response headers and reset semantics remain `VERIFY IN TENANT`.
