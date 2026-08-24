<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 6 Source Register

Chapter: **Building a Production-Quality FortiCNAPP API Client**

Access date: 2026-08-23

## C6-S001: Controlled FortiCNAPP API 2.0 snapshot

- Publisher: Fortinet
- Repository record: `docs/source-register/FORTICNAPP-API-2.0-SNAPSHOT.md`
- Declared API version: 2.0
- OpenAPI version: 3.0.3
- Supports: API response conventions, documented status codes, pagination, 5,000 rows per page, 500,000 rows per result set, continuation URLs, 480 requests per hour per user, RateLimit headers, 1 MB POST body limit, and schema routes.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Tenant permissions, endpoint applicability, observed headers, reset timing, proxies, and live schema availability remain `VERIFY IN TENANT`.

## C6-S002: PowerShell Invoke-WebRequest

- Publisher: Microsoft
- Version: PowerShell 7.6
- Supports: HTTPS request execution, response status, headers, content, timeout, and non-success response handling.
- Evidence class: `VERIFIED OFFICIAL`

## C6-S003: PowerShell JSON commands

- Publisher: Microsoft
- Version: PowerShell 7.6
- Supports: Explicit JSON serialization and parsing depth.
- Evidence class: `VERIFIED OFFICIAL`

## Source decision

The public lab is `SYNTHETIC` and performs zero requests. The client implementation follows documented contracts, but controlled tenant validation remains open.
