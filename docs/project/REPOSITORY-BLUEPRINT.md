<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Repository Blueprint

## Target structure

```text
PSFortiCNAPP/
  .github/
    ISSUE_TEMPLATE/
    workflows/
  build/
  docs/
    diagrams/
    project/
    reference/
  examples/
  manuscript/
    chapters/
    outline/
    sample/
  src/
    PSFortiCNAPP/
      Public/
      Private/
      Formats/
      Types/
      PSFortiCNAPP.psd1
      PSFortiCNAPP.psm1
  tests/
    Unit/
    Contract/
    Integration/
    Fixtures/
  tools/
  LICENSES/
  LICENSE
  LICENSE-SCOPE.md
  NOTICE
  README.md
```

Phase 1 establishes the documentation, outline, sample, licensing, and quality controls. Production module code begins only after Phase 1 approval.

## Branch and review model

- `main` remains the release branch.
- Work occurs on short-lived, purpose-specific branches.
- Direct changes to `main` should be restricted after continuous integration is established.
- Pull requests identify affected documentation, module interfaces, tests, verification items, and licenses.
- Printed examples and repository files must remain synchronized.

## Commit boundaries

Changes should be separated into reviewable groups:

1. Licensing and governance.
2. Editorial architecture and manuscript planning.
3. Technical and verification architecture.
4. Module implementation.
5. Tests and fixtures.
6. Release packaging.

## Issue categories

The repository should distinguish software defects, documentation defects, tenant-verification work, schema changes, security reports, and release preparation. Each issue should include enough version and reproduction context for another contributor to assess it safely.

## Continuous integration

The initial workflow design includes:

- PowerShell parsing and static analysis.
- Unit and contract tests.
- Coverage reporting.
- File-license checks.
- Prohibited-character checks.
- Repository-content safety checks.
- Markdown and reference validation.
- Nonrelease module packaging and archive inspection.

Controlled integration tests run separately and are disabled by default. They use approved test environments and retain only sanitized evidence.

## Release workflow

An approved semantic-version tag starts the release workflow. The workflow rebuilds from a clean checkout, repeats quality checks, packages the module, generates checksums and an SBOM, validates installation, and creates one GitHub Release.

Planned assets:

- `PSFortiCNAPP-vX.Y.Z.zip`
- `SHA256SUMS.txt`
- `PSFortiCNAPP-vX.Y.Z-SBOM.spdx.json`
- Release notes describing supported versions, validation scope, limitations, and upgrade considerations.

## Version progression

| Version | Planned scope |
|---|---|
| 0.1.0 | Connection, transport, diagnostics, and fixtures |
| 0.2.0 | Inventory and pagination |
| 0.3.0 | LQL discovery and execution |
| 0.4.0 | Compliance and vulnerability workflows |
| 0.5.0 | Identity and alert evidence |
| 0.6.0 | Executive metrics and reports |
| 0.9.0 | Capstone and release candidate |
| 1.0.0 | Publication-aligned stable release |

## Book-to-code traceability

Every chapter records its repository tag or commit, example paths, test paths, fixture paths, verification-ledger identifiers, and validated product and PowerShell versions.

## Fixture governance

Fixtures are synthetic or sanitized and carry provenance metadata. They exclude real customer details, live account identifiers, personal data, and sensitive connection material.

## Suggested repository metadata

Description:

`PowerShell 7 module and companion source for evidence-driven FortiCNAPP API v2 and LQL security automation.`

Topics:

`powershell`, `powershell-module`, `forticnapp`, `lacework`, `cloud-security`, `security-automation`, `lql`, `api-v2`, `compliance`, and `vulnerability-management`.

Metadata changes require a separate authorized GitHub action.

## Phase gates

Phase 1 exits after blueprint, license, outline, sample, and verification approval. Phase 2 exits after all chapters, matching module capabilities, tests, and required validations are complete. Phase 3 exits after integrated manuscript review, end-to-end code validation, and final GitHub Release preparation.
