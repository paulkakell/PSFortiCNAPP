<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Public Increment Status

Chapter: **HTTP, JSON, and API Contracts**

Branch: `phase2/chapter-04-companion`

## Included

- Local synthetic HTTP exchange parser
- Typed HTTP exchange object
- Six-exchange synthetic fixture
- Runnable JSON and response-contract lab
- Unit, fixture, example, manifest, export, and content tests
- Public guide, object contract, source register, chapter map, and production notes

## Excluded

- Complete commercial chapter manuscript
- Tenant credentials
- Live HTTP requests
- FortiCNAPP endpoint implementation
- Provider request or response field claims
- LQL datasources or fields
- State-changing operations

## Validation gate

The increment must pass the PowerShell 7.6 matrix on Windows, Ubuntu, and macOS, including Pester, coverage, PSScriptAnalyzer, manifest validation, SPDX checks, repository safety checks, U+2014 scanning, package construction, and checksum verification.

Tenant-dependent behavior remains `VERIFY IN TENANT`.
