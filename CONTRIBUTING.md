<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Contributing to PSFortiCNAPP

PSFortiCNAPP combines a PowerShell module, public project documentation, synthetic examples, and a separately copyrighted manuscript. Contributions must preserve those boundaries.

## Before opening a pull request

1. Create a purpose-specific branch.
2. Keep the change focused on one reviewable outcome.
3. Use synthetic or properly sanitized fixtures only.
4. Do not include credentials, real tenant names, account identifiers, personal data, or customer evidence.
5. Mark unresolved provider behavior `VERIFY IN TENANT`.
6. Add or update tests for executable behavior.
7. Add the correct SPDX header for the file location.
8. Run the complete local quality command.

```powershell
pwsh ./build/Install-Dependencies.ps1
pwsh ./build/Invoke-Quality.ps1
pwsh ./build/Package.ps1 -Clean
```

## Technical claims

A provider endpoint, request shape, response field, permission, pagination behavior, rate condition, datasource, or LQL behavior is not accepted as production fact merely because it worked once or appeared in generated output.

A provider-facing change should identify:

- The official source and version.
- The controlled environment class.
- The test method.
- The expected and observed result.
- The sanitized evidence location.
- Limitations and revalidation triggers.

## PowerShell expectations

- Target PowerShell 7.6 or later.
- Use approved verbs and singular nouns.
- Return structured objects rather than formatted strings.
- Keep formatting separate from collection and calculation.
- Use terminating errors for conditions that prevent a trustworthy result.
- Preserve unknown and unavailable states.
- Do not write secrets to output, diagnostics, files, or command-line arguments.
- Add `SupportsShouldProcess` to state-changing public commands.

## Pull-request description

Describe the user or operational problem, affected commands and chapters, tests performed, fixture classification, verification-ledger items, licensing impact, and remaining uncertainty.

## Licensing

By contributing, you agree that executable material may be distributed under Apache-2.0 and project documentation may be distributed under CC BY 4.0 according to `LICENSE-SCOPE.md`. Manuscript contributions require explicit acceptance into the separately copyrighted manuscript scope.
