<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Engineering Traceability

Each normalized exchange retains:

- Synthetic or sanitized provenance
- Method and query-free HTTPS URI
- Query parameter names without values
- UTC start and completion timestamps
- PowerShell-derived duration
- Status code and family
- Media type and body state
- UTF-8 body length and SHA-256
- Parsed JSON when valid
- Approved diagnostic headers
- Redacted and ignored header names
- Request correlation identifier when available
- Retry-After seconds when numeric
- Local contract state and validation issues

Raw response text is not returned.
