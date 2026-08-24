<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 7 Source Register

Chapter: **Asset Inventory, Pagination, and Data Quality**

Access date: 2026-08-24

## C7-S001: FortiCNAPP Inventory search

- Publisher: Fortinet
- Controlled source: `docs/source-register/FORTICNAPP-API-2.0-SNAPSHOT.md`
- Declared API version: 2.0
- Operation: `POST /api/v2/Inventory/search`
- Supports: inventory retrieval through an advanced-search request body
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: permissions, populated resource types, exact response fields, time-field applicability, and observed tenant behavior remain `VERIFY IN TENANT`.

## C7-S002: FortiCNAPP pagination conventions

- Publisher: Fortinet
- Controlled source: FortiCNAPP API 2.0 snapshot overview
- Supports: page size up to 5,000 rows, result-set limit up to 500,000 rows, and continuation metadata where an endpoint supplies `paging`
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: endpoint-specific pagination behavior and continuation response headers require controlled tenant validation.

## C7-S003: PowerShell date and time

- Publisher: Microsoft
- Version: PowerShell 7.6 and the associated .NET runtime
- Supports: `DateTimeOffset` UTC conversion and Unix epoch millisecond conversion
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: provider acceptance of a specific request-field format is a separate contract.

## C7-S004: Synthetic coverage fixture

- Publisher: PSFortiCNAPP project
- Path: `tests/Fixtures/Synthetic/chapter-07-asset-coverage.json`
- Supports: denominator, freshness, missing, stale, excluded, unexpected, and duplicate teaching cases
- Evidence class: `SYNTHETIC`
- Limitation: no value is production evidence.

## Source decision

The inventory endpoint and general pagination limits are documented. The public lab remains synthetic. Provider record fields are retained without normalization until controlled tenant fixtures support a stable contract.
