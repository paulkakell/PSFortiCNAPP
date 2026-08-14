<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 CISO Traceability

Decision statement: HTTP transport success does not by itself establish usable security evidence.

Engineer evidence supporting the statement:

- Six synthetic exchanges in scope
- Four HTTP 2xx responses
- Three valid local JSON-or-empty contracts
- Two warning contracts with unsupported media types
- One invalid contract with malformed declared JSON
- Query values and sensitive header values absent from normalized output

Machine-readable source: `PSFortiCNAPP.SyntheticHttpContractSummary` and its `PSFortiCNAPP.HttpExchange` records.
