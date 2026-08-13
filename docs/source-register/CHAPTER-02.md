<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 2 Source Register

Chapter: **Starting Securely with PowerShell 7**

Access date: 2026-08-13

This register records the first-party sources used for Chapter 2. The chapter is about the local PowerShell environment, command discovery, workspace layout, paths, output streams, error inspection, profiles, and source-control hygiene. It does not introduce FortiCNAPP authentication or tenant access.

## C2-S001: PowerShell support lifecycle

- Publisher: Microsoft
- Title: PowerShell - Microsoft Lifecycle
- URL: https://learn.microsoft.com/lifecycle/products/powershell
- Supports: PowerShell 7.6 is a long-term support release with published support from March 18, 2026 through November 14, 2028.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Patch versions differ by installation channel and runner image.
- Revalidate when: Support dates change or the project adopts another LTS baseline.

## C2-S002: Cross-platform PowerShell installation

- Publisher: Microsoft
- Title: Install PowerShell on Windows, Linux, and macOS
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell?view=powershell-7.6
- Supports: Microsoft publishes platform-specific installation and support guidance for Windows, Linux, and macOS.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The correct package method depends on the operating system, architecture, and administrative policy.
- Revalidate when: Installation channels or supported platforms change.

## C2-S003: Windows PowerShell 5.1 and PowerShell 7 coexistence

- Publisher: Microsoft
- Title: Migrating from Windows PowerShell 5.1 to PowerShell 7
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/scripting/whats-new/migrating-from-windows-powershell-51-to-powershell-7?view=powershell-7.6
- Supports: Windows PowerShell 5.1 and PowerShell 7 are separate products that can run side by side. PowerShell 7 is started with `pwsh`.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Module compatibility must be assessed separately.
- Revalidate when: Microsoft changes migration or coexistence guidance.

## C2-S004: Command and concept help

- Publisher: Microsoft
- Title: Get-Help
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help?view=powershell-7.6
- Supports: `Get-Help` provides command, provider, script, function, and conceptual help. `-Examples`, `-Full`, and `-Online` provide different views.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Locally installed help can be incomplete or outdated until it is updated.
- Revalidate when: Help behavior changes.

## C2-S005: Command discovery

- Publisher: Microsoft
- Title: Get-Command
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-command?view=powershell-7.6
- Supports: `Get-Command` discovers commands available in the current session and can filter by name, verb, noun, module, and command type.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Results depend on installed modules and the current session.
- Revalidate when: Command-discovery behavior changes.

## C2-S006: Variables

- Publisher: Microsoft
- Title: about_Variables
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables?view=powershell-7.6
- Supports: PowerShell variables can store values, command results, paths, configuration, and objects.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: A variable is not a secure secret store merely because it is in memory.
- Revalidate when: Variable semantics change materially.

## C2-S007: Automatic variables and environment context

- Publisher: Microsoft
- Title: about_Automatic_Variables
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.6
- Supports: PowerShell provides automatic variables such as `$PSVersionTable`, `$HOME`, `$PWD`, `$Error`, and `$LASTEXITCODE` that expose session and execution context.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Availability and meaning can depend on host, platform, and command type.
- Revalidate when: Automatic-variable behavior changes.

## C2-S008: Path syntax

- Publisher: Microsoft
- Title: about_Path_Syntax
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_path_syntax?view=powershell-7.6
- Supports: PowerShell paths can identify items through providers, and path forms differ between absolute, relative, provider-qualified, and platform-specific representations.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Provider paths are not always filesystem paths.
- Revalidate when: Provider or path behavior changes.

## C2-S009: Cross-platform path construction

- Publisher: Microsoft
- Title: Join-Path
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/join-path?view=powershell-7.6
- Supports: `Join-Path` combines path segments using the active provider instead of requiring a hard-coded directory separator.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The resulting path can still be invalid for the target provider or filesystem.
- Revalidate when: Path-joining behavior changes.

## C2-S010: PowerShell output streams

- Publisher: Microsoft
- Title: about_Output_Streams
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams?view=powershell-7.6
- Supports: PowerShell has distinct success, error, warning, verbose, debug, information, and progress streams. Display text and pipeline data are not interchangeable.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Host applications can render streams differently.
- Revalidate when: Stream behavior changes.

## C2-S011: Error handling

- Publisher: Microsoft
- Title: about_Error_Handling
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_error_handling?view=powershell-7.6
- Supports: PowerShell distinguishes terminating and non-terminating errors. `-ErrorAction Stop`, `try`, `catch`, and error records support deliberate failure handling.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Native executable exit codes require separate inspection and can follow tool-specific conventions.
- Revalidate when: Error semantics change.

## C2-S012: PowerShell profiles

- Publisher: Microsoft
- Title: about_Profiles
- Track: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.6
- Supports: Profile scripts customize PowerShell hosts and users. Different hosts can use different profile paths.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Production automation should not depend on undocumented personal profile state.
- Revalidate when: Profile loading or location behavior changes.

## C2-S013: Cloning a repository

- Publisher: GitHub
- Title: Cloning a repository
- URL: https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository
- Supports: A repository can be copied locally with Git, GitHub CLI, or supported desktop tools. The clone preserves repository history and enables normal source-control workflows.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Authentication and network requirements depend on repository visibility and chosen protocol.
- Revalidate when: GitHub changes cloning guidance.

## C2-S014: Ignore rules

- Publisher: Git project
- Title: gitignore Documentation
- URL: https://git-scm.com/docs/gitignore
- Supports: Ignore patterns specify intentionally untracked files. Multiple ignore locations have defined precedence.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Ignore rules do not remove a file that was already committed, and they are not a substitute for secret scanning.
- Revalidate when: Git ignore behavior changes materially.

## Chapter boundary

Chapter 2 verifies the local runtime and teaches safe workspace behavior. It does not claim that the reader has a working FortiCNAPP tenant, an authorized service identity, a valid API key, or a populated datasource. Those subjects begin later and remain controlled by the verification ledger.

## Source decision

Chapter 2 may use official PowerShell and Git documentation to teach local behavior. Example readiness output is labeled `SYNTHETIC`, while a reader's actual `Test-FortiCNAPPEnvironment` result is local observed evidence rather than tenant evidence.
