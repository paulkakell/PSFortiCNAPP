<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Changelog

All notable repository and module changes are recorded here. The project follows Semantic Versioning after the first tagged release.

## [Unreleased]

### Added

- PowerShell 7.6 module, tests, packaging, and cross-platform CI foundations.
- Synthetic labs for scope, findings, HTTP contracts, authentication profiles, and API request planning.
- Secret-free configuration and explicit temporary-token sessions.
- `Invoke-FortiCNAPPRequest` with bounded retries, safe pagination, redacted JSON Lines telemetry, and predictable objects.
- `Get-FortiCNAPPSchema` for documented schema discovery routes.

### Changed

- Public module surface expanded to eleven commands.
- Chapter 5 configuration validation consolidated into one canonical function definition.
- Project status advanced through the Chapter 6 public companion increment.

### Security

- Bearer tokens remain in module-private process state.
- Request output and logs exclude authorization material, query values, and raw response bodies.
- Continuation URLs must use the connected tenant authority and an API v2 path.
