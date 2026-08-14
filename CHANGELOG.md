<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Changelog

All notable repository and module changes are recorded here. The project follows Semantic Versioning after the first tagged release.

## [Unreleased]

### Added

- Phase 2 governance and contribution files.
- PowerShell 7.6 module, test, packaging, and CI foundations.
- Synthetic scope, finding, HTTP-contract, and authentication-profile labs.
- `Get-FortiCNAPPModuleInfo`.
- `Test-FortiCNAPPEnvironment`.
- `ConvertTo-FortiCNAPPEvidenceRecord`.
- `ConvertFrom-FortiCNAPPHttpExchange`.
- `New-FortiCNAPPConfiguration` and `Test-FortiCNAPPConfiguration`.
- `Connect-FortiCNAPP`, `Get-FortiCNAPPContext`, and `Disconnect-FortiCNAPP`.
- Explicit account API-key temporary-token request with process-local private session state.

### Changed

- Public module surface expanded to nine commands.
- Project status advanced through the Chapter 5 public companion increment.

### Security

- Credentials remain outside configuration objects, fixtures, ordinary output, and error text.
- Public sessions expose safe metadata while bearer tokens remain in module-private process state.
- Local disconnect clears the module-held token reference without claiming remote revocation.
- Repository rules prohibit credentials, private keys, real tenant evidence, and unreviewed provider claims in public fixtures and examples.
