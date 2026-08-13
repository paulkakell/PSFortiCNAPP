<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 2 Production Notes: Starting Securely with PowerShell 7

## Status

The commercial Chapter 2 draft is complete as a publishing asset. The active public repository contains only its companion artifacts, source register, tests, and these production notes.

Completed public gates:

- Cross-platform continuous integration.
- Pester and PSScriptAnalyzer checks.
- Setup checklist and settings-template contracts.
- U+2014 validation.
- Repository boundary correction.

Editorial, publisher, and final technical review remain manuscript activities outside the public repository.

## Chapter purpose

Give a PowerShell beginner a safe, cross-platform, profile-independent environment for the repository and later automation work.

## Implemented reader outcomes

The chapter teaches the reader to:

1. Distinguish PowerShell 7 from Windows PowerShell 5.1.
2. Confirm version and edition through `$PSVersionTable`.
3. Discover commands and help.
4. Inspect objects rather than formatted text.
5. Construct cross-platform paths.
6. Understand output streams and basic error records.
7. Avoid hidden profile dependencies.
8. Create and test an intentional workspace.
9. Review a non-sensitive settings template.
10. Interpret readiness and completeness separately.

## Operational scenario

A new Kestrel Vale engineer receives an environment-dependent command that works only on a teammate's workstation. The chapter replaces hidden assumptions with a supported runtime, canonical source revision, profile-independent entry point, explicit workspace, and typed readiness result.

## Lab contract

The lab uses:

- `docs/getting-started/CHAPTER-02-SETUP-CHECKLIST.md`
- `examples/foundations/Test-Environment.ps1`
- `examples/config/psforticnapp.settings.example.json`
- `Test-FortiCNAPPEnvironment`

Expected outcomes:

- Writable workspace: `Ready=True`, `Complete=True`, zero failures.
- Write test skipped: `Ready=True`, `Complete=False`.
- Missing workspace: `Ready=False`, with failed path evidence and an unattempted write check.

## Source status

`docs/source-register/CHAPTER-02.md` contains fourteen first-party records reviewed on August 13, 2026. It covers lifecycle, installation, runtime coexistence, command discovery, help, variables, automatic variables, paths, output streams, errors, profiles, repository cloning, and ignore behavior.

The runnable lab requires no tenant-dependent claim.

## Repository traceability

| Chapter element | Repository artifact |
|---|---|
| Production record | `manuscript/chapters/02-STARTING-SECURELY-WITH-POWERSHELL-7-PRODUCTION-NOTES.md` |
| Primary source register | `docs/source-register/CHAPTER-02.md` |
| Setup checklist | `docs/getting-started/CHAPTER-02-SETUP-CHECKLIST.md` |
| Settings template | `examples/config/psforticnapp.settings.example.json` |
| Environment example | `examples/foundations/Test-Environment.ps1` |
| Public readiness command | `src/PSFortiCNAPP/Public/Test-FortiCNAPPEnvironment.ps1` |
| Public artifact contract | `tests/Content/Chapter02.Tests.ps1` |
| Configuration contract | `tests/Contract/Chapter02Configuration.Tests.ps1` |
| Manuscript boundary contract | `tests/Content/ManuscriptBoundary.Tests.ps1` |

## Preserved cautions

- `powershell.exe` is not presented as PowerShell 7.
- A supported runtime does not prove tenant access.
- A variable is not presented as a protected value store.
- Ignore rules do not protect content already committed.
- Profiles are not hidden production dependencies.
- A host message cannot replace a returned readiness object.
- Native exit codes follow the native program's contract.
- Workspace readiness is point-in-time local evidence.

## Completion record

Public companion artifacts are complete for the current baseline. The commercial chapter remains subject to editorial, publisher, and final technical review outside the public repository.
