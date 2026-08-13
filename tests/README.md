<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Tests

The test suite is organized by purpose:

- `Unit/`: behavior isolated to module functions.
- `Contract/`: public command, manifest, fixture, and later provider-contract expectations.
- `Content/`: licensing, prohibited-character, and repository-safety controls.
- `Integration/`: controlled tenant tests added later and disabled by default.
- `Fixtures/Synthetic/`: fabricated data used for public tests and labs.

Run the suite through `build/Invoke-Quality.ps1` so static analysis and repository checks run with Pester.
