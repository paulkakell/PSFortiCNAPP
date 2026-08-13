<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Technical Blueprint

## Runtime and scope

PSFortiCNAPP targets PowerShell 7.6 LTS on Windows, Linux, and macOS. Phase 1 defines architecture only. Production behavior will be added after current FortiCNAPP documentation and controlled validation support it.

## Architecture

The module is divided into clear layers:

1. Session context and configuration.
2. Provider communication.
3. Paging and reliability controls.
4. LQL discovery and execution.
5. Evidence normalization.
6. Data-quality assessment.
7. Technical and executive reporting.
8. Diagnostics and test support.

Public functions return structured objects. Formatting remains separate from collection and calculation. Unknown or missing evidence stays unknown and is never converted into a favorable result.

## Planned source tree

```text
src/PSFortiCNAPP/
  PSFortiCNAPP.psd1
  PSFortiCNAPP.psm1
  Public/
  Private/
  Formats/
  Types/
```

The module manifest explicitly lists exported functions. Private implementation remains replaceable without changing stable public object contracts.

## Planned command areas

The initial public surface will cover:

- Connection context and validation.
- Schema and datasource discovery.
- LQL validation and execution.
- Asset, compliance, vulnerability, identity, policy, and alert evidence.
- Technical reports and executive summaries.

Command names remain provisional until the Phase 2 interface review. Each provider-facing command stays `VERIFY IN TENANT` until its access requirements, source behavior, output mapping, paging, and failure cases are validated.

## Evidence contract

Common evidence properties identify the evidence type, source, source version, environment context, cloud scope, collection time, observation time, quality state, verification state, and protected raw-evidence reference.

Quality assessment covers coverage, freshness, completeness, consistency, validity, and lineage. Reports disclose those limits.

## Reliability and LQL

A shared provider layer will handle request construction, timing, response validation, bounded recovery, and safe diagnostics. Paging remains operation-specific.

LQL work follows a discovery-first process: inspect available data, validate a small query, test edge cases, record the validation context, and recheck after relevant provider changes.

## Testing and release

Pester will provide unit, contract, and controlled integration tests. PSScriptAnalyzer will review executable files. Continuous integration will test the supported PowerShell baseline on Windows, Ubuntu, and macOS.

GitHub Releases is the only public distribution channel. Release assets will include a versioned module archive, checksums, an SPDX SBOM, and notes describing supported versions, validation scope, limitations, and upgrade considerations.
