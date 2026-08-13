<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 2: Starting Securely with PowerShell 7

## 1. Opening operational scenario

Mara Reyes has joined the cloud security team at Kestrel Vale Health Services. She understands cloud accounts, vulnerabilities, security findings, and incident queues. PowerShell is new to her.

On her first morning, a teammate sends a command in chat and says, "Run this before the weekly report." The command was copied from a personal profile, depends on an alias that exists only on the teammate's workstation, writes output to a fixed Windows path, and assumes that `powershell.exe` means PowerShell 7. It succeeds on the teammate's computer. On Mara's managed laptop, it fails halfway through and leaves a partially written report.

Nothing in the command identifies the runtime, source revision, workspace, or failure point. The report file exists, so a hurried reviewer might mistake it for a completed result.

The problem is not that Mara is a beginner. The problem is that the operating environment was treated as an invisible detail.

A production-minded automation project begins by making that environment visible. The script should be able to state which PowerShell version is running, which edition is active, which operating system family is in use, which workspace was selected, whether the workspace is a filesystem directory, and whether it can accept a temporary write probe. Those facts are not glamorous, but they decide whether later evidence collection can run consistently.

This chapter gives Mara a reproducible starting point. She will use PowerShell 7.6 or later, run the repository without a personal profile, inspect commands before relying on them, build paths without assuming an operating system, keep configuration separate from authentication material, and return readiness as an object instead of a green message.

No FortiCNAPP tenant connection is made in this chapter. No API key is requested. No live security evidence is collected. The subject is the workstation and project workspace that will support later work.

By the end of the lab, Mara can send another engineer a short, reviewable procedure instead of an unexplained one-line command. The second engineer can reproduce the same checks on Windows, Linux, or macOS and can see exactly why the environment passed or failed.

## 2. Reader outcomes

After completing this chapter, you will be able to:

1. Start PowerShell 7 with `pwsh` and distinguish it from Windows PowerShell 5.1.
2. Read `$PSVersionTable` and identify the runtime version, edition, and platform context.
3. Discover commands with `Get-Command` and read command help with `Get-Help`.
4. Store values in variables and inspect returned objects without parsing display text.
5. Construct cross-platform paths with `$HOME`, `$PWD`, and `Join-Path`.
6. Distinguish success output, errors, warnings, verbose messages, and host display.
7. Inspect basic failures with `$Error`, `Get-Error`, `-ErrorAction Stop`, `try`, and `catch`.
8. Explain why production automation should not depend on undocumented personal profile state.
9. Prepare a repository workspace without placing sensitive values in source control.
10. Run `Test-FortiCNAPPEnvironment` and interpret its readiness object.

These are foundation skills. The later API and LQL chapters depend on them. A reader who can recognize the runtime, inspect an object, follow a path, and read an error is better prepared to understand authentication and provider communication without memorizing unexplained code.

## 3. Executive relevance

A CISO does not need to approve every `Join-Path` call. Leadership does need confidence that the automation can be operated by more than one person and that a report is not silently tied to one engineer's laptop.

A reproducible operating environment reduces several forms of operational risk:

- **Key-person risk:** Another operator can run the documented process without inheriting a private profile or unexplained alias.
- **Integrity risk:** A failed prerequisite is reported before a later report is treated as complete.
- **Portability risk:** Paths and commands are not hard-coded to one operating system when the project claims cross-platform support.
- **Support risk:** The actual runtime version is recorded, making defects easier to reproduce.
- **Evidence risk:** Generated evidence and logs have intentional locations instead of appearing in an arbitrary working directory.
- **Source-control risk:** Configuration examples are separated from sensitive operational values.

The executive question for this chapter is: **Can the automation be operated consistently and safely by more than one person?**

The answer is not a claim such as "the script is portable." It is a set of observable controls: a supported runtime, an explicit repository revision, a profile-independent command, a readiness result, a known workspace, and documented exceptions.

## 4. Concepts and architecture

### PowerShell 7 is not Windows PowerShell 5.1

On Windows, the executable `powershell.exe` normally starts Windows PowerShell 5.1. The executable `pwsh` starts PowerShell 7. Microsoft documents the products as separate and able to run side by side. That distinction matters because module compatibility, language behavior, error rendering, native-command handling, and supported platforms can differ.

The project baseline is PowerShell 7.6 LTS. The manifest requires PowerShell 7.6 and the Core edition. A later patch release within the 7.6 line is acceptable. Continuous integration records the patch version actually used on each runner.

Start by asking the runtime to describe itself:

```powershell
$PSVersionTable
```

The two fields most important at this stage are:

```powershell
$PSVersionTable.PSVersion
$PSVersionTable.PSEdition
```

For this project, the version must be 7.6.0 or later and `PSEdition` must be `Core`.

### A command is not the text displayed after it

PowerShell commands usually emit objects to the success stream. The host formats those objects for the screen. A table that looks like plain text can still represent structured objects with properties and methods.

That distinction is central to the book. A script should return an environment-readiness object. A human can see a concise table or list, while another command can inspect `Ready`, `FailCount`, or `Checks` directly.

Use `Get-Member` to inspect an object:

```powershell
$result = Test-FortiCNAPPEnvironment -WorkspacePath $HOME
$result | Get-Member
```

Use property access when you need a value:

```powershell
$result.Ready
$result.Checks
```

Do not copy the formatted table into a string parser when the properties are already available.

### Commands can be discovered

You do not need to remember every command name. `Get-Command` discovers commands visible to the current session.

```powershell
Get-Command -Name Get-Help
Get-Command -Verb Get -Noun Command
Get-Command -Module PSFortiCNAPP
```

The returned command object identifies the command type, source module, version, and definition. This is useful when two commands share a name or when an alias hides the command you expected.

`Get-Help` explains syntax and examples:

```powershell
Get-Help Get-Command
Get-Help Get-Command -Examples
Get-Help Get-Command -Full
```

Local help may be incomplete. `Get-Help <name> -Online` opens the current online article when the command supports online help. On managed systems, `Update-Help` may require administrative access or internet permission. A failure to update help does not justify guessing.

### Variables store values and objects

A variable name begins with `$`:

```powershell
$workspacePath = $HOME
$minimumVersion = [version]'7.6.0'
$readiness = Test-FortiCNAPPEnvironment -WorkspacePath $workspacePath
```

The first variable stores a path string, the second stores a version object, and the third stores the object returned by a command. PowerShell variables can hold many types. Type matters because version comparison should be numeric by component, not alphabetical text comparison.

This is reliable:

```powershell
$PSVersionTable.PSVersion -ge [version]'7.6.0'
```

A text comparison such as `'7.10' -gt '7.6'` can produce a result based on string ordering rather than version meaning. Use the type that matches the concept.

### Paths belong to providers

PowerShell paths can refer to filesystems and other providers. `C:\Reports` is a Windows filesystem path. `/home/mara/reports` is a Unix-style filesystem path. `Env:\PATH` identifies an item through the environment provider. A command that expects a normal directory should confirm that the path resolves through the filesystem provider.

Use `Join-Path` instead of assembling separators manually:

```powershell
$evidencePath = Join-Path -Path $HOME -ChildPath 'PSFortiCNAPP/evidence'
```

The active provider supplies the appropriate separator. `Resolve-Path` confirms that an existing path can be resolved. `Get-Item` returns an object that can reveal whether the item is a directory and which provider supplied it.

The current location is available through `$PWD`, which is a path object. `$HOME` identifies the current user's home directory. Neither should be assumed to point to a specific literal path across every operating system.

### PowerShell has multiple output streams

PowerShell separates success output from error, warning, verbose, debug, information, and progress messages. This means screen appearance is not a reliable data contract.

Consider:

```powershell
Write-Output 'pipeline data'
Write-Warning 'review this condition'
Write-Verbose 'diagnostic detail' -Verbose
```

Only the success-stream value is ordinary pipeline output. Warnings and verbose messages carry different intent. `Write-Host` is useful for intentional host display, but it should not replace an object that another command needs to consume.

For PSFortiCNAPP, collection and validation commands return objects. Formatting belongs in views or report commands. A green host message must never be the only evidence that a required check passed.

### Errors are records

PowerShell distinguishes terminating and non-terminating errors. Some commands report a problem and continue. `-ErrorAction Stop` can make many non-terminating errors enter `catch` for the current command.

```powershell
try {
    Get-Item -LiteralPath './missing-path' -ErrorAction Stop
}
catch {
    $_ | Select-Object *
}
```

The automatic variable `$Error` contains recent error records. `$Error[0]` is normally the most recent. `Get-Error` provides a detailed view in PowerShell 7.

Native executables are different. They often communicate status through exit codes. `$LASTEXITCODE` records the most recent native exit code, but each executable defines what its codes mean. A nonzero value is often failure, but some tools use nonzero values for warnings or informational outcomes. Read the tool's documentation before interpreting the number.

### Profiles customize sessions

PowerShell profiles are scripts that run when certain hosts start. They can define aliases, variables, functions, formatting, and module imports. Profiles are useful for personal productivity. They are a poor hidden dependency for production automation.

The same user can have different profiles for different hosts. Another operator may have none. A CI runner usually starts from a controlled environment. A script that relies on a private alias can work interactively and fail under automation.

The chapter lab uses `pwsh -NoProfile` so the repository, not a personal profile, defines the behavior being tested.

## 5. Interface-selection decision

Chapter 1 compared the FortiCNAPP console, CLI, API v2, LQL, and fixtures. Chapter 2 selects none of the provider interfaces. The correct interface is the local PowerShell runtime and repository.

That decision is deliberate. Connecting to a tenant before the reader can inspect an object or error would hide too much behind copied commands. It would also create unnecessary pressure to place authentication material in a local file.

The Chapter 2 workflow uses:

1. `pwsh` as the runtime entry point.
2. Git or a verified repository download as the source boundary.
3. The module manifest as the module identity and runtime contract.
4. `Get-FortiCNAPPModuleInfo` as a non-network module information command.
5. `Test-FortiCNAPPEnvironment` as a non-network readiness command.
6. A synthetic settings template that contains no live environment material.
7. Pester contracts that verify the chapter and template.

No provider response is needed to prove that the local runtime is PowerShell 7.6 Core or that a workspace is writable. Adding a network dependency would make the readiness check less reliable, not more.

## 6. Implementation

### Obtain the repository from its canonical source

GitHub documents several cloning methods. With Git installed, the basic HTTPS form is:

```powershell
git clone https://github.com/paulkakell/PSFortiCNAPP.git
Set-Location -LiteralPath ./PSFortiCNAPP
```

Before running code, inspect the repository location and active revision:

```powershell
git remote -v
git status
git log -1 --oneline
```

A book example should name the release tag or commit it was tested against. Running whichever content happens to be on a mutable branch weakens reproducibility.

### Start a profile-independent session

From a terminal, start PowerShell 7:

```text
pwsh -NoProfile
```

Inside the session, record the environment:

```powershell
$PSVersionTable | Format-List
```

`Format-List` affects presentation only. The underlying `$PSVersionTable` object remains available as structured data.

### Choose the workspace

A workspace is the local directory where later exercises can place generated evidence, logs, and temporary files. The repository itself should remain source, not a dumping ground for operational output.

For a beginner lab, a directory under the user's home is reasonable:

```powershell
$workspacePath = Join-Path -Path $HOME -ChildPath 'PSFortiCNAPP-Workspace'
```

Create it only after reviewing the resulting path:

```powershell
$workspacePath
New-Item -ItemType Directory -Path $workspacePath -Force
```

`-Force` allows the command to return the existing directory. It does not mean every use of `-Force` is safe. Read the command help and understand the target before using it.

Create later-output directories with the same path discipline:

```powershell
$directoryNames = @('evidence', 'logs', 'tmp')

foreach ($directoryName in $directoryNames) {
    $directoryPath = Join-Path -Path $workspacePath -ChildPath $directoryName
    New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
}
```

The example uses a small loop because the action is the same for each name. `Out-Null` suppresses the directory objects only because this interactive setup step does not need to return them. A production function might return a workspace object instead.

### Review the settings template

The repository contains:

```text
examples/config/psforticnapp.settings.example.json
```

Read it as an object:

```powershell
$templatePath = Join-Path `
    -Path $PWD `
    -ChildPath 'examples/config/psforticnapp.settings.example.json'

$settingsTemplate = Get-Content `
    -LiteralPath $templatePath `
    -Raw `
    -Encoding utf8 |
    ConvertFrom-Json -Depth 20

$settingsTemplate
```

The template is classified `SyntheticTemplate`. Its connection source is `NotConfigured`, and `sensitiveValuesIncluded` is false. It demonstrates shape and safe defaults. It is not a request to fill live values into the tracked file.

If a later exercise needs a machine-specific configuration file, copy it to an intentional local location, add an appropriate ignore rule before using it, and confirm with `git status` that Git does not plan to include it. Ignore rules reduce accidental inclusion but do not erase history or replace review and scanning.

### Import the module by manifest

Use the manifest path rather than depending on a module already installed somewhere else:

```powershell
$manifestPath = Join-Path `
    -Path $PWD `
    -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'

Import-Module -Name $manifestPath -Force -ErrorAction Stop
```

This ties the session to the repository revision being reviewed. `-ErrorAction Stop` ensures that an import failure enters a surrounding `catch` if you add one.

Confirm the public commands:

```powershell
Get-Command -Module PSFortiCNAPP
```

At this stage, the module exposes only the approved foundation commands. Provider-facing commands remain outside the chapter.

### Run readiness

The repository example wraps module import and the readiness command:

```powershell
pwsh -NoProfile -File ./examples/foundations/Test-Environment.ps1 `
    -WorkspacePath $workspacePath
```

When invoked from another shell, `$workspacePath` exists only in the current PowerShell session. The clearest approach is to run the example from the same `pwsh` session or pass a literal reviewed path appropriate to the platform.

Inside PowerShell, this is simpler:

```powershell
./examples/foundations/Test-Environment.ps1 `
    -WorkspacePath $workspacePath
```

The example returns module information followed by the readiness object. Store the readiness result directly when you need to inspect properties:

```powershell
$readiness = Test-FortiCNAPPEnvironment -WorkspacePath $workspacePath
$readiness.Ready
$readiness.Complete
$readiness.Checks
```

## 7. Complete PowerShell code

The runnable Chapter 2 environment example is stored at `examples/foundations/Test-Environment.ps1`:

```powershell
#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$WorkspacePath = (Get-Location).Path,

    [Parameter()]
    [switch]$SkipWriteTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (
    Resolve-Path -LiteralPath (
        Join-Path -Path $PSScriptRoot -ChildPath '../..'
    )
).Path
$manifestPath = Join-Path `
    -Path $repositoryRoot `
    -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'

Import-Module -Name $manifestPath -Force -ErrorAction Stop

Get-FortiCNAPPModuleInfo
Test-FortiCNAPPEnvironment `
    -WorkspacePath $WorkspacePath `
    -SkipWriteTest:$SkipWriteTest
```

The repository version is authoritative. The printed version must stay synchronized with it.

Several details are worth noticing:

- `#requires -Version 7.6` stops the script before normal execution on an older runtime.
- Strict mode catches some accidental references to unset variables and invalid properties.
- `$ErrorActionPreference = 'Stop'` makes many non-terminating errors stop the script in this scope.
- `$PSScriptRoot` identifies the script's directory, not whichever directory the operator happened to use.
- `Join-Path` creates the manifest path without a hard-coded separator.
- The module is imported from the checked-out source tree.
- The script returns objects from both commands.
- `SkipWriteTest` is passed explicitly as a switch value.

## 8. Verified PowerShell examples

The examples in this section rely on official PowerShell behavior recorded in the Chapter 2 source register. They do not depend on a FortiCNAPP tenant.

### Confirm which executable started the session

```powershell
[pscustomobject]@{
    Version   = $PSVersionTable.PSVersion
    Edition   = $PSVersionTable.PSEdition
    ProcessId = $PID
    Home      = $HOME
    Location  = $PWD.Path
}
```

This object is more useful than a sentence because tests and later commands can inspect each property.

### Find the module commands

```powershell
Get-Command -Module PSFortiCNAPP |
    Select-Object Name, CommandType, Version, Source
```

If no commands appear, verify that the module imported successfully and that the manifest path points to the intended checkout.

### Read examples before experimenting

```powershell
Get-Help Test-FortiCNAPPEnvironment -Examples
Get-Help Test-FortiCNAPPEnvironment -Full
```

Comment-based help travels with the function. This matters when the module has not been publicly released and the local checkout is the current source.

### Inspect readiness checks as data

```powershell
$readiness = Test-FortiCNAPPEnvironment -WorkspacePath $workspacePath

$readiness.Checks |
    Select-Object Name, Status, Required, Message, Remediation
```

Filter only unsuccessful or incomplete checks:

```powershell
$readiness.Checks |
    Where-Object Status -In @('Fail', 'Warning', 'NotApplicable')
```

The display can change without changing the property contract.

### Demonstrate error inspection safely

Use a path that should not exist under the temporary lab workspace:

```powershell
$missingPath = Join-Path `
    -Path $workspacePath `
    -ChildPath 'does-not-exist'

try {
    Get-Item -LiteralPath $missingPath -ErrorAction Stop
}
catch {
    [pscustomobject]@{
        Message              = $_.Exception.Message
        FullyQualifiedErrorId = $_.FullyQualifiedErrorId
        Category             = $_.CategoryInfo.Category
        TargetName           = $_.CategoryInfo.TargetName
    }
}
```

The result keeps useful error fields without copying every internal property into a report.

### Compare output and display

```powershell
$data = [pscustomobject]@{
    Name  = 'WorkspaceReadiness'
    Ready = $readiness.Ready
}

$data
$data | Format-List
```

Both commands display the same object differently. Do not store `Format-List` output as the data source for a later calculation.

### Check the native Git exit code

```powershell
git status --short
$gitExitCode = $LASTEXITCODE

[pscustomobject]@{
    Command  = 'git status --short'
    ExitCode = $gitExitCode
    Success  = $gitExitCode -eq 0
}
```

This interpretation is appropriate for the documented Git command in this context. Do not generalize one native program's exit-code rules to every executable.

## 9. Synthetic or sanitized output

Evidence label: `SYNTHETIC`

A successful readiness result may resemble:

```text
CheckedAtUtc          : 2026-08-13T20:45:00.0000000+00:00
ComputerName          : TRAINING-WORKSTATION
OperatingSystem       : Linux
OperatingSystemDetail : Synthetic Linux training host
Architecture          : X64
PowerShellVersion     : 7.6.4
PSEdition             : Core
WorkspacePath         : /home/student/PSFortiCNAPP-Workspace
Ready                 : True
Complete              : True
CheckCount            : 5
PassCount             : 5
WarningCount          : 0
FailCount             : 0
NotApplicableCount    : 0
```

The displayed values are invented for teaching. They are not evidence from a reader's computer or from a FortiCNAPP tenant.

A skipped write probe can produce `Ready: True` and `Complete: False`. That distinction is intentional. The checks that ran may have passed, while one required capability remains untested. A later workflow that writes evidence should require both readiness and completeness.

A missing workspace can produce:

```text
Ready              : False
Complete           : False
FailCount          : 1
NotApplicableCount : 1
```

The failed `WorkspacePath` check explains the primary problem. The write check becomes `NotApplicable` because the command cannot fairly claim that it tested write access against a path that was never valid.

## 10. Technical interpretation

The readiness object is local operational evidence. It answers a narrow question: can this PowerShell session and workspace support the project foundation checks?

It does not prove that:

- the workstation is generally secure;
- every later dependency is installed;
- the operator is authorized for a tenant;
- a network path is reachable;
- a future evidence directory has enough capacity for every incident;
- a provider command will succeed;
- the repository checkout is free from every supply-chain risk.

The result remains useful because its scope is explicit.

`Ready` means no check returned `Fail`. `Complete` means no required check remained `NotApplicable`. An operator should inspect both. The detailed `Checks` collection preserves the status, requirement, message, evidence, and remediation for each check.

The command performs a temporary write probe unless `SkipWriteTest` is used. It writes a short file, reads the resulting file object, verifies a nonzero length, and removes the probe. That is stronger than checking an access-control flag alone because it tests the operation the later workflow needs. It is still a point-in-time result. Permissions, quotas, mounts, and storage health can change.

The command does not place a success marker in the repository. It returns an object to the caller. The operator decides whether and where a readiness record should be retained.

## 11. Executive interpretation

A concise leadership summary derived from the same object could say:

> The PSFortiCNAPP foundation was reproduced on the approved PowerShell 7.6 runtime using a profile-independent session. The selected workspace resolved through the filesystem provider and passed a temporary write test. All required readiness checks completed with no failures. No tenant connection or authentication material was used.

A partial result should be stated differently:

> Runtime and path checks passed, but the workspace write test was skipped. The environment is provisionally ready for read-only review and is not yet validated for evidence generation. Confidence is moderate until write capability is tested.

The second statement does not hide behind a green overall status. It tells the decision-maker what remains unverified and what work should happen next.

For operational governance, record:

- operator or automation identity;
- operating system family;
- PowerShell version;
- repository tag or commit;
- workspace path classification;
- readiness and completeness;
- failed or skipped checks;
- date and time.

Avoid collecting unnecessary workstation details. A readiness record should support reproducibility, not become an inventory of personal data.

## 12. Security and privacy considerations

### Do not place sensitive values in the repository

The Chapter 2 settings file is a template. It intentionally contains no live environment or authentication material. A tracked example should demonstrate structure and safe defaults, not invite the reader to replace placeholders in place.

A `.gitignore` pattern can prevent an untracked local file from appearing in normal status output. It does not remove a file that was already committed. It does not protect copies, editor backups, shell history, transcripts, or uploaded artifacts. Review and scanning remain necessary.

### Review code before execution

A repository URL is not proof that every branch or fork is trusted. Confirm the owner, remote, branch, commit, and changed files. Prefer a named release or reviewed commit for book exercises.

Do not pipe downloaded text directly into PowerShell. Save, inspect, verify, and run an intentional file.

### Be cautious with transcripts

PowerShell transcription can capture commands and output. That can be useful for audit and troubleshooting. It can also preserve values that should not be retained. Do not enable broad transcription around later authentication work without an approved design for access, storage, redaction, and retention.

### Avoid hidden profile dependencies

A profile can import modules, change preference variables, create aliases, or alter formatting. These changes can make an interactive session behave differently from CI.

Use `pwsh -NoProfile` for reproducible examples. When a production job requires initialization, place that initialization in versioned code rather than a personal profile.

### Understand execution policy boundaries

Windows execution policy can affect whether a script starts. It is a safety feature, not a complete security boundary. Do not solve a blocked script by permanently weakening policy without understanding why the file is blocked and how it was obtained.

A file downloaded from the internet can carry origin information. After reviewing and trusting the exact file, Windows provides mechanisms such as `Unblock-File`. Use them narrowly. The repository should never tell a beginner to disable security controls globally as the first response.

### Limit workspace access

Later evidence can include security-sensitive data. Choose a workspace with appropriate user and group access. Do not default to a shared public directory. Understand backup, synchronization, retention, and deletion behavior before storing live evidence.

### Minimize collected local data

The readiness command returns enough system context to explain the result. It does not enumerate installed software, user documents, network shares, browser data, or unrelated configuration. Collecting more would expand privacy and security risk without supporting the chapter outcome.

## 13. Failure modes and troubleshooting

### `pwsh` is not found

The operating system cannot locate PowerShell 7.

Check whether PowerShell 7 is installed using the current official installation guidance for the operating system. Close and reopen the terminal after installation if the path was updated. Do not assume that `powershell.exe` is an equivalent replacement.

### The version is below 7.6

`#requires -Version 7.6` stops the example. `$PSVersionTable.PSVersion` confirms the actual version.

Upgrade through the appropriate supported channel. On a managed workstation, follow organizational software procedures rather than installing an unapproved package.

### `PSEdition` is not `Core`

The session is probably Windows PowerShell 5.1. Start `pwsh`. Confirm the executable and version again.

### The manifest cannot be found

The command is being run from the wrong checkout or an incomplete download.

Use:

```powershell
Get-Location
git status
Test-Path -LiteralPath ./src/PSFortiCNAPP/PSFortiCNAPP.psd1
```

The repository example uses `$PSScriptRoot`, so it can locate the manifest relative to itself. A copied code fragment that assumes the current directory can fail more easily.

### Module import fails

Use a terminating error and inspect it:

```powershell
try {
    Import-Module -Name $manifestPath -Force -ErrorAction Stop
}
catch {
    Get-Error -Newest 1
}
```

Possible causes include an older runtime, malformed manifest, missing file, or analysis error. Do not replace the module with a similarly named package from an unrelated source.

### Help is incomplete

`Get-Help` can show basic syntax even when full local help is absent. Use `-Online` where supported, or update help according to local policy. The repository functions include comment-based help, so importing the local module should make their help available.

### The workspace does not exist

Create the reviewed directory or provide another existing path. The readiness command intentionally does not create an arbitrary path because path creation is a separate operator decision.

### The workspace path is a file

Choose a directory. The readiness result should show the item and a failed `WorkspacePath` check. Do not delete or overwrite the file merely to make the test pass.

### The workspace uses another provider

A PowerShell provider path can exist without being a normal filesystem directory. Evidence and report files require a filesystem destination. Select a local or mounted filesystem path appropriate to the organization.

### The write probe fails

Review permissions, read-only mounts, quotas, storage health, endpoint controls, synchronization locks, and path ownership. The failed probe is the desired warning. Do not edit the result object or bypass the check.

### The probe file remains

The command attempts cleanup in `finally`. If cleanup fails, inspect the workspace and remove only the known probe file after confirming its name. A future command should surface cleanup failures when they affect evidence integrity.

### `Ready` is true but `Complete` is false

A required check was `NotApplicable`, commonly because `SkipWriteTest` was used. The environment can be ready for the checks that ran but incomplete for workflows that need the skipped capability.

### A command works only without `-NoProfile`

The command has an undocumented dependency on profile state. Discover the alias, function, module, variable, or preference supplied by the profile and move the necessary behavior into versioned project code.

Compare sessions:

```powershell
pwsh -NoProfile
Get-Command <name>
```

and:

```powershell
pwsh
Get-Command <name>
```

Do not solve the problem by requiring every operator to copy one person's profile.

### A native command prints an error but PowerShell does not throw

Native executables communicate differently from cmdlets. Inspect `$LASTEXITCODE` and the program documentation. Do not assume that `try` and `catch` alone cover every native failure.

### Paths behave differently across operating systems

Look for hard-coded drive letters, backslashes, home directories, case assumptions, or shell-specific syntax. Use `$HOME`, `$PWD`, `Join-Path`, and repository-relative paths. Test on the supported operating systems through CI.

## 14. Tests

Chapter 2 uses several layers of validation.

### Module unit tests

The existing unit tests import the module, confirm the public command surface, verify typed module information, and exercise readiness outcomes for writable, missing, file, and skipped-write paths.

### Manifest contract

The manifest test confirms version `0.1.0`, PowerShell 7.6 Core requirements, project metadata, and the approved foundation exports.

### Configuration contract

`tests/Contract/Chapter02Configuration.Tests.ps1` parses the settings template and verifies:

- project copyright and license metadata;
- schema version;
- `SyntheticTemplate` classification;
- relative workspace directory names;
- no claim of a configured connection;
- UTC and object-output defaults.

The test treats configuration shape as a contract. A later change that adds fields should be deliberate and reviewed.

### Manuscript contract

`tests/Content/Chapter02.Tests.ps1` confirms:

- the manuscript license identifier;
- the twenty numbered chapter sections;
- the production word range;
- distinction between `pwsh` and `powershell.exe`;
- profile-independent lab execution;
- synthetic labeling;
- the no-tenant boundary;
- all Chapter 2 source identifiers;
- the canonical setup command.

### Repository controls

The general repository tests scan prohibited characters, SPDX headers, and recognized credential patterns. PSScriptAnalyzer reviews executable PowerShell. CI runs the same quality path on Windows, Ubuntu, and macOS.

Tests do not prove that every sentence is clear. They prevent known structural, licensing, portability, and safety regressions while human review addresses teaching quality.

## 15. Hands-on lab

### Goal

Create a safe local workspace and produce a non-sensitive readiness object from a profile-independent PowerShell 7 session.

### Prerequisites

- PowerShell 7.6 or later.
- Git or a verified repository download.
- A local user-owned filesystem directory.
- The repository at the revision named for this chapter.

### Step 1: Read the setup checklist

Open:

```text
docs/getting-started/CHAPTER-02-SETUP-CHECKLIST.md
```

Do not skip the repository and workspace checks. The lab result is meaningful only when its source and destination are understood.

### Step 2: Start PowerShell 7 without a profile

From the operating-system terminal:

```text
pwsh -NoProfile
```

Record:

```powershell
$PSVersionTable.PSVersion
$PSVersionTable.PSEdition
```

Stop if the version is below 7.6 or the edition is not Core.

### Step 3: enter the repository

Use the actual checkout path:

```powershell
Set-Location -LiteralPath '<repository-path>'
```

Confirm the source revision:

```powershell
git status
git log -1 --oneline
```

When Git is unavailable because the repository was downloaded as an archive, record the archive name and checksum instead.

### Step 4: Create the workspace

```powershell
$workspacePath = Join-Path -Path $HOME -ChildPath 'PSFortiCNAPP-Workspace'
New-Item -ItemType Directory -Path $workspacePath -Force
```

Display the path and confirm that it is the intended destination.

### Step 5: Inspect the template

```powershell
$template = Get-Content `
    -LiteralPath ./examples/config/psforticnapp.settings.example.json `
    -Raw `
    -Encoding utf8 |
    ConvertFrom-Json -Depth 20

$template.dataClassification
$template.authentication.sensitiveValuesIncluded
```

Expected values:

```text
SyntheticTemplate
False
```

Do not edit the repository template with live values.

### Step 6: Run the canonical environment example

```powershell
pwsh -NoProfile -File ./examples/foundations/Test-Environment.ps1 `
    -WorkspacePath $workspacePath
```

Then import and store the readiness object in the current session:

```powershell
Import-Module ./src/PSFortiCNAPP/PSFortiCNAPP.psd1 -Force
$readiness = Test-FortiCNAPPEnvironment -WorkspacePath $workspacePath
```

### Step 7: Inspect the object

```powershell
$readiness | Get-Member
$readiness | Format-List
$readiness.Checks | Format-Table Name, Status, Required, Message -AutoSize
```

Confirm:

```powershell
$readiness.Ready
$readiness.Complete
$readiness.FailCount
```

For a normal writable workspace, expected values are `True`, `True`, and `0`.

### Step 8: Observe an incomplete result

```powershell
$incomplete = Test-FortiCNAPPEnvironment `
    -WorkspacePath $workspacePath `
    -SkipWriteTest

$incomplete | Select-Object Ready, Complete, NotApplicableCount
```

Explain why readiness can be true while completeness is false.

### Step 9: Observe a failed result

```powershell
$missingPath = Join-Path -Path $workspacePath -ChildPath 'missing'
$failed = Test-FortiCNAPPEnvironment -WorkspacePath $missingPath

$failed.Checks |
    Where-Object Status -In @('Fail', 'NotApplicable') |
    Format-List
```

Do not create the missing path before reviewing the failure. The purpose is to see a controlled negative result.

### Step 10: Record completion

Use the completion block in the setup checklist. Record no sensitive local details beyond what the exercise requires.

### Lab success criteria

- The session uses PowerShell 7.6 Core.
- The source revision is recorded.
- The workspace is an intentional filesystem directory.
- The settings template remains synthetic and unmodified.
- The normal run is ready and complete.
- The skipped-write run is ready but incomplete.
- The missing-path run fails without creating the path.
- The operator can explain each result from the returned checks.

## 16. Review questions and exercises

1. Why is `pwsh` significant on Windows?
2. Which `$PSVersionTable` fields establish the project runtime contract?
3. Why is a formatted table a poor source for later calculations?
4. What does `Get-Command` tell you that guessing a command name cannot?
5. Why should a path be built with `Join-Path`?
6. What is the difference between `$HOME` and `$PWD`?
7. Why can `Ready` be true while `Complete` is false?
8. What does `-ErrorAction Stop` change for many cmdlet errors?
9. Why might a native executable require `$LASTEXITCODE` inspection?
10. Why is `.gitignore` not a complete control for sensitive files?
11. Name two risks created by a personal profile dependency.
12. What does the Chapter 2 readiness result not prove?

Exercises:

- Add a new synthetic relative directory field to a copy of the settings template and update the contract test.
- Produce a custom view of readiness checks with only `Name`, `Status`, and `Remediation` while preserving the original objects.
- Run the readiness command against a directory and a file, then compare the `Checks` collections.
- Start a normal session and a `-NoProfile` session. Compare `Get-Command` output for one alias or function defined in your profile.

## 17. Key takeaways

- PowerShell 7 starts with `pwsh`; Windows PowerShell 5.1 is a separate runtime.
- The project requires PowerShell 7.6 Core and records the actual patch version used.
- Commands return objects that can be inspected independently of screen formatting.
- `Get-Command`, `Get-Help`, and `Get-Member` reduce guesswork.
- Variables should use types that match their meaning.
- Cross-platform paths should be constructed rather than concatenated with a fixed separator.
- Errors and native exit codes require deliberate inspection.
- Personal profiles are useful for operators but should not become hidden production dependencies.
- A safe workspace separates source, generated evidence, logs, temporary files, and later local configuration.
- Readiness and completeness are related but different claims.
- Chapter 2 prepares the local environment without touching a FortiCNAPP tenant.

## 18. Source and version notes

The Chapter 2 source register is stored at `docs/source-register/CHAPTER-02.md`.

The runtime baseline and installation guidance come from current Microsoft documentation. PowerShell 7.6 is recorded as an LTS release, and the chapter uses the PowerShell 7.6 documentation track. Command discovery, help, variables, automatic variables, path syntax, path construction, streams, error handling, and profiles are supported by first-party Microsoft references C2-S001 through C2-S012.

Repository cloning and ignore behavior are supported by GitHub and the Git project in C2-S013 and C2-S014.

The chapter does not hard-code one package installation command because approved methods vary by platform and administrative policy. The reader is directed to current official installation guidance.

The chapter records project behavior at module version `0.1.0`. CI is the evidence for the actual PowerShell patch and operating-system runner used by the chapter branch.

## 19. Verification-ledger updates

No FortiCNAPP tenant verification item is closed by Chapter 2.

The following local claims are supported by official documentation and repository tests:

- PowerShell 7.6 is the project LTS baseline.
- `pwsh` identifies the PowerShell 7 executable in the documented coexistence model.
- The module manifest requires PowerShell 7.6 Core.
- The foundation commands make no network request.
- The readiness command reports version, edition, operating-system family, workspace validity, provider, and write capability.
- The chapter example and configuration template are covered by cross-platform CI contracts.

Tenant identity, permissions, product schemas, integrations, datasources, and provider results remain `VERIFY IN TENANT`. They begin in later chapters under the existing ledger.

A material PowerShell lifecycle change, runtime behavior change, or supported-platform change triggers source review and CI revalidation.

## 20. Companion-repository artifacts

Chapter 2 is paired with:

- `manuscript/chapters/02-STARTING-SECURELY-WITH-POWERSHELL-7.md`
- `manuscript/chapters/02-STARTING-SECURELY-WITH-POWERSHELL-7-PRODUCTION-NOTES.md`
- `docs/source-register/CHAPTER-02.md`
- `docs/getting-started/CHAPTER-02-SETUP-CHECKLIST.md`
- `examples/foundations/Test-Environment.ps1`
- `examples/config/psforticnapp.settings.example.json`
- `src/PSFortiCNAPP/Public/Get-FortiCNAPPModuleInfo.ps1`
- `src/PSFortiCNAPP/Public/Test-FortiCNAPPEnvironment.ps1`
- `tests/Content/Chapter02.Tests.ps1`
- `tests/Contract/Chapter02Configuration.Tests.ps1`
- existing module, manifest, unit, content, and packaging tests

The repository files are the executable and testable companions to the chapter. Printed code must be checked against the named revision before publication.
