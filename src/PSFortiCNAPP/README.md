<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module Source

This directory contains the loadable PSFortiCNAPP module.

- `PSFortiCNAPP.psd1` defines the public contract and PowerShell 7.6 baseline.
- `PSFortiCNAPP.psm1` loads private functions before public functions and exports only the manifest-approved command list.
- `Public/` contains supported commands.
- `Private/` contains replaceable implementation details.
- `Formats/` contains presentation rules that do not alter the returned objects.

The Phase 2 foundation intentionally performs no FortiCNAPP network request. Provider-facing commands remain blocked until their verification-ledger entries have acceptable evidence.
