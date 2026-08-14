<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Source Register

Chapter: **HTTP, JSON, and API Contracts**

Access date: 2026-08-13

The runnable chapter lab is local and synthetic. It makes no network request and closes no tenant-verification item.

## C4-S001: HTTP semantics

- Publisher: RFC Editor
- Title: RFC 9110, HTTP Semantics
- URL: https://www.rfc-editor.org/rfc/rfc9110
- Supports: HTTP methods, target URIs, status codes, header fields, and content.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The standard does not establish FortiCNAPP endpoint behavior.

## C4-S002: JSON

- Publisher: RFC Editor
- Title: RFC 8259, The JavaScript Object Notation Data Interchange Format
- URL: https://www.rfc-editor.org/rfc/rfc8259
- Supports: JSON objects, arrays, numbers, strings, booleans, and null.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Valid JSON does not prove schema validity.

## C4-S003: URI syntax

- Publisher: RFC Editor
- Title: RFC 3986, Uniform Resource Identifier: Generic Syntax
- URL: https://www.rfc-editor.org/rfc/rfc3986
- Supports: URI scheme, authority, path, query, and fragment components.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: URI syntax does not authorize access.

## C4-S004: Reserved example domains

- Publisher: RFC Editor
- Title: RFC 2606, Reserved Top Level DNS Names
- URL: https://www.rfc-editor.org/rfc/rfc2606
- Supports: `.invalid` is reserved for deliberately invalid names.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The synthetic host is not a FortiCNAPP tenant.

## C4-S005: Invoke-RestMethod

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6
- Supports: Sending HTTP requests and deserializing supported structured content.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Chapter 4 does not invoke it against a tenant.

## C4-S006: Invoke-WebRequest

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.6
- Supports: Web-response status, headers, and content.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Production transport behavior requires later tests.

## C4-S007: ConvertFrom-Json

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.6
- Supports: Converting JSON text to PowerShell objects with depth controls.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Parsing does not establish provider schema validity.

## C4-S008: ConvertTo-Json

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-json?view=powershell-7.6
- Supports: Serializing PowerShell objects to JSON with explicit depth.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Insufficient depth can omit nested properties.

## C4-S009: Hash tables

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.6
- Supports: Key-value collections used for structured lookup and headers.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: A hash table is not a protected secret store.

## C4-S010: Error handling

- Publisher: Microsoft
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.6
- Supports: Handling terminating errors with `try`, `catch`, and `finally`.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The production request client is implemented later.

## C4-S011: SHA-256 hashing

- Publisher: Microsoft
- Title: Get-FileHash
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-7.6
- Supports: SHA-256 integrity comparison.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: A hash does not establish source authority or completeness.

## C4-S012: FortiCNAPP API 2.0 source snapshot

- Publisher: Fortinet
- Repository record: `docs/source-register/FORTICNAPP-API-2.0-SNAPSHOT.md`
- Declared API version: 2.0
- OpenAPI version: 3.0.3
- SHA-256: `7015f76895f20f6934d0d391ab0e76ebccb83bd692cd41c32fac5fbf445b39d7`
- Supports: Controlled API contract discovery.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The vendor snapshot is not redistributed. Tenant permissions, populated resources, response variation, and observed behavior remain `VERIFY IN TENANT`.

## Source decision

Every host, path, exchange, header value, body, identifier, timestamp, metric, and displayed result in the runnable lab is `SYNTHETIC`.

The placeholder path `/api/v2/example` is not a FortiCNAPP endpoint. The host `tenant.example.invalid` is deliberately non-routable. No live provider contract is claimed.
