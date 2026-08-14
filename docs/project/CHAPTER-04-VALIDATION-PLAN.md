<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Validation Plan

The Chapter 4 branch must pass:

- PowerShell 7.6 on Windows, Ubuntu, and macOS
- PSScriptAnalyzer
- Pester unit, contract, and content tests
- At least 85 percent code coverage
- Module manifest and export synchronization
- SPDX header checks
- Repository safety scanning
- Zero Unicode U+2014 occurrences
- Development package construction
- SHA-256 package verification

The validation does not establish tenant behavior. No tenant request is made.
