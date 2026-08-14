<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module Source

This directory contains the loadable `PSFortiCNAPP` module.

- `PSFortiCNAPP.psd1` defines the public contract and PowerShell 7.6 baseline.
- `PSFortiCNAPP.psm1` loads private functions before public functions, initializes process-local session state, and exports only the manifest-approved command list.
- `Public/` contains supported commands.
- `Private/` contains replaceable implementation details.
- `Formats/` contains presentation rules that do not alter returned objects.

Chapter 5 adds secret-free configuration, a documented temporary-token request, explicit safe session objects, context inspection, and local disconnect behavior.

The module does not yet provide a general provider request client, token refresh, remote token revocation, LQL execution, inventory collection, or remediation. Tenant permissions, scope, and observed authentication behavior remain `VERIFY IN TENANT`.
