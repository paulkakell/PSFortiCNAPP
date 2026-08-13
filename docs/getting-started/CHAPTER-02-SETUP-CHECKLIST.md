<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 2 Setup Checklist

Use this checklist before running the Chapter 2 lab or any later PSFortiCNAPP example.

## Runtime

- [ ] Start PowerShell with `pwsh`, not `powershell.exe`.
- [ ] Run `$PSVersionTable.PSVersion` and confirm version 7.6.0 or later.
- [ ] Run `$PSVersionTable.PSEdition` and confirm `Core`.
- [ ] Record the actual patch version used for the lab.
- [ ] Use the official Microsoft installation page for the current operating system when an upgrade is required.

## Repository

- [ ] Clone or download the repository from its canonical GitHub location.
- [ ] Confirm the active branch or release tag before running examples.
- [ ] Do not run a script copied from an unverified mirror or message attachment.
- [ ] Review the script path and contents before execution.
- [ ] Keep generated evidence, logs, and temporary files outside tracked source paths unless the exercise explicitly states otherwise.

## Workspace

- [ ] Select an existing filesystem directory owned by the current user.
- [ ] Avoid system directories and shared locations unless their access model is understood.
- [ ] Build paths with `Join-Path` rather than a hard-coded slash or backslash.
- [ ] Create separate `evidence`, `logs`, and `tmp` directories when later exercises require them.
- [ ] Confirm that the destination has enough space for the intended work.
- [ ] Confirm that local retention and backup rules are appropriate for security evidence.

## Configuration

- [ ] Review `examples/config/psforticnapp.settings.example.json`.
- [ ] Confirm `dataClassification` is `SyntheticTemplate`.
- [ ] Confirm `sensitiveValuesIncluded` is `false`.
- [ ] Do not add authentication material to the repository copy.
- [ ] Keep machine-specific settings in an ignored local file or approved configuration system.
- [ ] Treat ignore rules as convenience controls, not as proof that a file can never be committed.

## PowerShell behavior

- [ ] Use `Get-Command` to confirm which command will run.
- [ ] Use `Get-Help <command> -Examples` before relying on unfamiliar syntax.
- [ ] Use `Get-Member` to inspect returned objects rather than parsing formatted text.
- [ ] Use `-ErrorAction Stop` where the lab requires a failed command to enter `catch`.
- [ ] Inspect `$Error[0]` or `Get-Error` when a command fails.
- [ ] Do not enable broad transcription while handling sensitive values.
- [ ] Do not make a production script depend on personal profile aliases or variables.

## Repository readiness command

From the repository root:

```powershell
pwsh -NoProfile -File ./examples/foundations/Test-Environment.ps1 `
    -WorkspacePath $HOME
```

On Linux or macOS, the line continuation character remains the PowerShell backtick when the command is entered in `pwsh`. A single-line form avoids copy errors:

```powershell
pwsh -NoProfile -File ./examples/foundations/Test-Environment.ps1 -WorkspacePath $HOME
```

## Expected result

A ready environment returns a `PSFortiCNAPP.EnvironmentReadiness` object with:

- `Ready` equal to `True`.
- `Complete` equal to `True` when the write test was performed.
- Zero failed checks.
- A workspace path resolved through the filesystem provider.
- No authentication or tenant properties.

A failed result is useful evidence. Correct the named failed check instead of editing the output to appear successful.

## Completion record

```text
Date:
Operating system:
PowerShell version:
Repository branch or tag:
Workspace path:
Ready:
Complete:
Exceptions:
```
