<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# HTTP Exchange Contract

`PSFortiCNAPP.HttpExchange` is the local Chapter 4 representation of a synthetic or sanitized HTTP exchange.

## Output properties

| Property | Meaning |
|---|---|
| `ExchangeId` | Stable caller-supplied exchange identifier |
| `DataClassification` | `SYNTHETIC` or `SANITIZED` |
| `Method` | Canonical uppercase HTTP method |
| `RequestUri` | Absolute HTTPS URI without query or fragment |
| `QueryParameterNames` | Query names retained without values |
| `StartedAtUtc` | UTC request start |
| `CompletedAtUtc` | UTC request completion |
| `DurationMilliseconds` | PowerShell-derived elapsed time |
| `StatusCode` | HTTP status code |
| `StatusFamily` | Informational, Success, Redirection, ClientError, or ServerError |
| `IsSuccessStatusCode` | True for 200 through 299 |
| `ResponseMediaType` | Lowercase media type without parameters |
| `BodyState` | Empty, ValidJson, MalformedJson, or UnsupportedMediaType |
| `BodyLengthBytes` | UTF-8 body length |
| `BodySha256` | SHA-256 of a non-empty body |
| `ParsedBody` | Parsed JSON object when available |
| `SafeHeaders` | Approved diagnostic response headers |
| `RedactedHeaderNames` | Known sensitive header names removed from output |
| `IgnoredHeaderNames` | Unmodeled header names omitted from output |
| `CorrelationId` | Approved request identifier when present |
| `RetryAfterSeconds` | Integer Retry-After value when present |
| `ContractState` | Valid, Warning, or Invalid |
| `ValidationIssues` | Local contract issues |
| `RawBodyReturned` | Always false in Chapter 4 |

## Authority

Method, status code, timestamps, media type, body bytes, and header values originate from the supplied synthetic or sanitized object.

Status family, success classification, duration, query-name extraction, hashing, body state, and contract state are deterministic PowerShell calculations.

No output property is a FortiCNAPP provider-native risk score or tenant validation result.
