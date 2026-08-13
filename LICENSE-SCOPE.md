<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# License Scope

## Purpose

The repository combines software, project documentation, and a commercial manuscript. A single license would either over-restrict the software or unintentionally grant rights to the manuscript. The repository therefore uses file-level licensing.

## License map

| Content | Default location | License | SPDX identifier |
|---|---|---|---|
| PowerShell module source | `src/` | Apache License 2.0 | `Apache-2.0` |
| Tests and fixtures created for the project | `tests/` | Apache License 2.0 | `Apache-2.0` |
| Build and release tools | `tools/`, `build/`, `.github/workflows/` | Apache License 2.0 | `Apache-2.0` |
| Executable examples | `examples/` | Apache License 2.0 | `Apache-2.0` |
| Project documentation | `docs/` | CC BY 4.0 | `CC-BY-4.0` |
| Project diagrams | `docs/diagrams/` | CC BY 4.0 unless marked otherwise | `CC-BY-4.0` |
| Book manuscript and publication assets | `manuscript/` | Copyright 2026 Paul Kell. All rights reserved. | `LicenseRef-Paul-Kell-Manuscript` |

## File headers

Text files should contain an SPDX copyright line and an SPDX license identifier. Examples:

```text
SPDX-FileCopyrightText: 2026 Paul Kell
SPDX-License-Identifier: Apache-2.0
```

Markdown may place those lines inside an HTML comment. PowerShell files should use comment lines. Binary assets should use a matching `.license` sidecar file or a repository license annotation.

## Migration from the initial repository license

The initial repository contains a GPL-3.0 root license. Phase 1 replaces that blanket license with this split-license model before module code or manuscript text is added. The existing GPL file should not remain as an active root license because it would create ambiguity about manuscript and documentation rights.

## Attribution for CC BY 4.0 material

A reuse should identify Paul Kell as the creator, identify the material, state that it is licensed under CC BY 4.0, provide the license reference, and indicate whether changes were made.

## Trademarks and vendor material

Fortinet, FortiCNAPP, Lacework, PowerShell, GitHub, AWS, Microsoft Azure, Google Cloud, Kubernetes, and other product names may be trademarks of their owners. A repository license does not grant trademark rights. Vendor screenshots, copied documentation, schemas, or samples must not be added without a compatible right to reproduce them.

This file describes the project's intended license allocation and is not legal advice.
