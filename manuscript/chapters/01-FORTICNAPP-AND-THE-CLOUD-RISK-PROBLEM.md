<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Chapter 1: FortiCNAPP and the Cloud Risk Problem

Cloud security teams rarely suffer from a complete absence of data. They suffer from data that arrived from different systems, at different times, under different permissions, and with different definitions of what should have been present.

That distinction shapes the entire book. PowerShell can retrieve and transform large collections of security records. FortiCNAPP, formerly Lacework, can expose cloud, workload, compliance, vulnerability, identity, and alert evidence through several interfaces. Neither fact guarantees that a report is complete, current, or suitable for a decision.

The first responsibility of automation is therefore not speed. It is honesty about scope and evidence.

## 1. Opening operational scenario

It is Monday morning at Kestrel Vale Health Services, the fictional organization used throughout this book. The cloud platform team has prepared a coverage report for the monthly security review. The report says that five cloud and workload environments are monitored. A compliance analyst presents a separate dashboard showing four environments. The container team claims six. The vulnerability team cannot reconcile its inventory with either total.

Each team believes its number is correct.

The cloud platform team counts cloud accounts and subscriptions. The compliance analyst counts only environments that produced a recent assessment. The container team counts two Kubernetes clusters and a registry as separate monitoring targets. The vulnerability team excludes an Azure subscription because its most recent records are older than the team's freshness threshold.

The CISO asks a direct question: "Which number can I use?"

No one can answer without first answering several smaller questions:

- What environments does the organization intend to monitor?
- Which of those environments should appear in FortiCNAPP?
- What evidence proves that each environment is currently visible?
- How old can evidence become before the report calls it stale?
- Which environments were deliberately excluded?
- Did the collection identity have permission to see every expected scope?
- Did the report count an unavailable source as a clean result?

The disagreement is not mainly a mathematical problem. It is a definition and evidence problem.

Kestrel Vale could resolve the meeting by choosing the largest number, the newest dashboard, or the tool owned by the most senior team. None of those methods would make the result defensible. The organization needs an independent statement of intended scope, followed by evidence that shows what was observed, what was missing, what was stale, and what was intentionally outside the calculation.

That independent statement is a **scope register**. It is the first artifact in the companion repository and the first control you will use before making a live request.

## 2. Reader outcomes

By the end of this chapter, you will be able to:

1. Distinguish visibility, evidence, finding, risk, and decision.
2. Explain why a successful query or console count does not prove complete coverage.
3. Define an expected monitoring scope before collecting provider data.
4. Separate observed, missing, stale, excluded, and unavailable evidence.
5. state a denominator before calculating coverage.
6. Read a small PowerShell script that turns a synthetic scope register into a transparent summary object.
7. Explain the same result to a security engineer and to a CISO without creating two incompatible versions of the truth.
8. Identify which Chapter 1 statements are supported by current official sources and which remain tenant-dependent.

You are not expected to know PowerShell yet. The chapter introduces only enough syntax to let you read the lab. Chapters 2 through 4 build the language, object, HTTP, and JSON skills needed to write the same kind of code yourself.

## 3. Executive relevance

Executives do not need every field returned by a security platform. They do need to know whether a metric represents the environment they believe it represents.

A statement such as "coverage is 60 percent" is incomplete by itself. It should prompt at least six questions:

- Sixty percent of what?
- Which scopes were included?
- Which scopes were excluded?
- What qualified as covered?
- When was the evidence collected?
- What prevented the remaining 40 percent from qualifying?

These questions are not technical objections to executive reporting. They are the information required to make the report useful.

Suppose the CISO must decide whether to fund an additional cloud-security engineer. A 60 percent coverage result caused by two newly acquired cloud environments suggests an onboarding and staffing problem. The same result caused by a temporary collection outage suggests an operational reliability problem. A 60 percent result caused by an incorrect denominator suggests a reporting-control problem. The percentage is identical. The decision is not.

A defensible executive metric therefore includes:

- A definition.
- A numerator.
- A denominator.
- A time or freshness rule.
- Included and excluded scope.
- Source and collection time.
- Known limitations.
- An explanation of the decision the metric supports.

PSFortiCNAPP will preserve those properties in objects before rendering them into charts, reports, or tickets. The executive view will be shorter than the engineer view, but it will not be a separate truth.

## 4. Concepts and architecture

Five terms will recur throughout the book. They are related, but they are not interchangeable.

### Visibility

**Visibility** means that a system or analyst can observe some part of an environment through a particular interface and identity.

Visibility is always scoped. A user may see one FortiCNAPP account but not another. An integration may collect configuration evidence but not activity logs. A query may return records for AWS while an Azure subscription is absent because of permission, configuration, timing, or feature differences.

Visibility is not binary at the organizational level. An organization can have strong visibility into one workload class and weak visibility into another.

### Evidence

**Evidence** is a record that supports a statement about what was observed, when it was observed, where it came from, and under what scope or authority it was collected.

A row in an API response can be evidence. So can a response status, a collection timestamp, an empty result, or a recorded failure. The important property is not that the record looks security-related. The record must be connected to a claim.

For example:

- "This account produced a compliance assessment at 22:15 UTC" is an evidence-backed statement when the source and timestamp are preserved.
- "This account is monitored" is broader. It may require several evidence types and a defined freshness rule.
- "No risk exists in this account" cannot be supported merely because a query returned no findings.

### Finding

A **finding** is a condition identified through evidence and a rule, policy, comparison, or analysis.

A missing expected account can be a finding. A stale integration can be a finding. A failed compliance policy can be a finding. A critical vulnerability can be a finding.

A finding should retain the rule that produced it. "Stale" has no stable meaning unless the report states the threshold. "Critical" has limited meaning unless the source and severity model are known.

### Risk

**Risk** is the potential effect of uncertainty on an objective. In practical cloud-security work, risk interpretation often considers likelihood, exposure, impact, business context, compensating controls, and evidence quality.

A finding contributes to risk analysis, but it is not automatically a complete risk statement. A critical vulnerability on an isolated, unused test host may require a different response from the same vulnerability on an internet-facing production service that processes clinical data.

Evidence quality also affects confidence. A severe alert with incomplete related evidence may demand urgent investigation, but the report should not pretend that the full cause or scope is already known.

### Decision

A **decision** is an action or explicit choice supported by the evidence and risk interpretation.

Examples include:

- Restore access to a missing subscription.
- Assign an owner to a stale integration.
- Investigate an alert.
- Contain a workload.
- Accept a documented exception.
- Fund an onboarding project.
- Delay an executive conclusion until coverage is restored.

Automation is valuable when it shortens the distance between evidence and a well-framed decision. It becomes dangerous when it hides uncertainty to make a result look complete.

### The evidence chain

The project uses a practical evidence chain:

1. **Intended scope:** What the organization expects to monitor.
2. **Collection context:** Identity, interface, environment, time, and request scope.
3. **Raw evidence:** The response or artifact as collected.
4. **Normalized evidence:** Stable objects created without discarding source meaning.
5. **Quality assessment:** Coverage, freshness, completeness, consistency, validity, and lineage.
6. **Finding or metric:** A calculation or rule applied to the normalized evidence.
7. **Technical interpretation:** What an engineer should verify or do next.
8. **Executive interpretation:** What decision is needed, with confidence and limitations.

The scope register begins at step one. It does not come from FortiCNAPP. That separation is deliberate. If a monitoring platform becomes the sole authority for what should be monitored, an environment that disappears from the platform can also disappear from the denominator. The report may improve precisely when visibility becomes worse.

## 5. Interface-selection decision

FortiCNAPP documentation currently describes several interfaces relevant to this book.

The console supports interactive investigation and administration. The command-line interface remains exposed through the `lacework` executable. The REST interface is documented as API v2, and current Fortinet documentation states that API v1 is no longer supported. Lacework Query Language, or LQL, is an SQL-like language that operates against curated datasources. Datasource names and metadata can be discovered through documented interfaces. These statements are recorded as `VERIFIED OFFICIAL` in the Chapter 1 source register. [C1-S001 through C1-S006]

No single interface is automatically best for every task.

### Console

Use the console when a human needs to explore context, compare visual relationships, or confirm how a current feature appears. The console is valuable for learning the product and for analyst investigation.

The console is less suitable as the only source for repeatable automation because screenshots and copied values usually lose request context, object structure, and machine-verifiable provenance.

### CLI

Use the CLI when it provides a documented operation, when an existing workflow depends on it, or when it helps compare behavior while an API client is being developed.

The CLI is still an external process. A production script must consider executable discovery, version recording, noninteractive behavior, output validation, timeouts, standard error, profile isolation, and secret handling. Those controls appear later in the book.

### API v2

Use API v2 when the goal requires structured, repeatable collection with explicit request and response handling. The module will be REST-first because direct API calls make transport behavior, pagination, validation, and testing easier to control.

Chapter 1 does not make a live request. Authentication belongs in Chapter 5, and the production transport belongs in Chapter 6. This order prevents the book from presenting unexplained credential and request code before the reader can inspect it responsibly.

### LQL

Use LQL when a verified datasource and query can answer an evidence question more directly than a general endpoint. LQL is not a bag of permanent query strings. Datasources, fields, and behavior must be discovered and validated in the current context.

Chapters 8 and 9 develop that process. Chapter 1 needs only the conceptual rule: discover before depending.

### Scope register

Use a scope register before all four interfaces when the question concerns coverage.

The register describes what leadership, asset owners, or an authoritative inventory says should be present. Provider evidence is then compared with that expectation. The register should not contain secrets, and it should not be silently rewritten to match whatever the provider returned.

For the Chapter 1 lab, the register is a synthetic JSON file stored in the repository. It contains no real account numbers, tenant names, customer details, or credentials.

## 6. Implementation

The synthetic scope register contains six records:

- An AWS production account.
- An Azure production subscription.
- A Google Cloud shared project.
- A production Kubernetes cluster.
- A shared container registry.
- An Azure training subscription.

Five records have `expectedInFortiCNAPP` set to `true`. These five form the denominator.

The training subscription has `expectedInFortiCNAPP` set to `false`. It is excluded because the fictional organization decided that the training environment is outside the monitoring requirement used by this metric. Exclusion is neither success nor failure. It is a scope decision that must remain visible.

The five expected records have three evidence states:

- Three are `Observed`.
- One is `Missing`.
- One is `Stale`.

The lab uses a simple definition of current observed coverage:

```text
current observed coverage = currently observed expected scopes / all expected scopes
```

For this synthetic register:

```text
3 / 5 = 0.60 = 60 percent
```

The stale scope does not count as current observed coverage. It is not merged with missing evidence, because stale and missing conditions suggest different investigation paths.

A missing scope has no current evidence in the register. The first questions may concern onboarding, permissions, integration status, inventory accuracy, or collection failure.

A stale scope has prior evidence that is older than the lab's accepted freshness condition. The first questions may concern data flow, delayed processing, disabled collection, changed permissions, or an inappropriate threshold.

The chapter deliberately does not assign a universal freshness interval. An appropriate threshold depends on the evidence type, product behavior, operational need, and documented service expectations. The fixture already labels the Google Cloud record as stale for this exercise. Later chapters will calculate freshness from timestamps and explicit rules.

## 7. Complete PowerShell code

The companion repository includes `examples/foundations/Review-SyntheticScopeRegister.ps1`. The script is shown here in full so that you can connect each output property to a visible operation.

```powershell
#requires -Version 7.6
# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Path)) {
    $repositoryRoot = (
        Resolve-Path -LiteralPath (
            Join-Path -Path $PSScriptRoot -ChildPath '../..'
        )
    ).Path

    $Path = Join-Path `
        -Path $repositoryRoot `
        -ChildPath 'tests/Fixtures/Synthetic/chapter-01-scope-register.json'
}

$register = Get-Content `
    -LiteralPath $Path `
    -Raw `
    -Encoding utf8 |
    ConvertFrom-Json -Depth 20

if ($register.dataClassification -ne 'Synthetic') {
    throw 'This example accepts only a scope register explicitly classified as Synthetic.'
}

$expectedScopes = @(
    $register.scopes |
        Where-Object -Property expectedInFortiCNAPP -EQ $true
)

$observedScopes = @(
    $expectedScopes |
        Where-Object -Property evidenceState -EQ 'Observed'
)

$missingScopes = @(
    $expectedScopes |
        Where-Object -Property evidenceState -EQ 'Missing'
)

$staleScopes = @(
    $expectedScopes |
        Where-Object -Property evidenceState -EQ 'Stale'
)

$coveragePercent = if ($expectedScopes.Count -eq 0) {
    $null
}
else {
    [math]::Round(
        ($observedScopes.Count / $expectedScopes.Count) * 100,
        2
    )
}

[pscustomobject][ordered]@{
    DataClassification = $register.dataClassification
    Organization       = $register.organization
    AsOfUtc            = [DateTimeOffset]::Parse($register.asOfUtc)
    Denominator        = $register.denominatorDefinition
    ExpectedScopeCount = $expectedScopes.Count
    ObservedScopeCount = $observedScopes.Count
    MissingScopeCount  = $missingScopes.Count
    StaleScopeCount    = $staleScopes.Count
    CoveragePercent    = $coveragePercent
    MissingScopeIds    = @($missingScopes.scopeId)
    StaleScopeIds      = @($staleScopes.scopeId)
}
```

You do not need to understand every symbol yet. Focus on the sequence.

First, the script determines the fixture path when no path is supplied. It reads the JSON file as one text value and converts the JSON into PowerShell objects.

Second, it enforces the data classification. The example refuses to process a file unless the top-level classification is exactly `Synthetic`. This does not make the script a general data-loss-prevention system. It creates a narrow safety boundary for a beginner lab.

Third, it creates four collections. The expected collection defines the denominator. The observed, missing, and stale collections are filtered from that expected set. The excluded training record never enters the denominator.

Fourth, it calculates coverage only when the denominator is greater than zero. A denominator of zero returns `$null`, which represents the absence of a valid percentage. Returning zero would make a different claim: that none of the expected scope was observed. When no expected scope exists, the percentage is undefined rather than zero.

Finally, the script returns a custom object. It does not print a decorative sentence or export a table. The object can be inspected, tested, formatted, serialized, or passed to a later report function without parsing display text.

## 8. Verified API or LQL examples

Chapter 1 uses no live API or LQL output. That is an intentional implementation boundary, not an omission.

Current Fortinet documentation supports several interface-level statements:

- The documented programmatic interface is REST and the project targets API v2. [C1-S001]
- Current access documentation describes account-scoped programmatic authorization and service-user patterns. [C1-S002]
- The CLI remains named `lacework` even though the product documentation uses FortiCNAPP branding. [C1-S003]
- The CLI documentation includes an API helper and schema-discovery guidance. [C1-S004]
- LQL is SQL-like and works with curated datasources. [C1-S005]
- Datasource information should be discovered before query design. [C1-S006]

Those are `VERIFIED OFFICIAL` statements because current first-party sources support them.

The chapter does not claim:

- That a specific endpoint is authorized in your tenant.
- That a particular datasource is populated.
- That the synthetic AWS, Azure, Google Cloud, Kubernetes, or registry records match a current tenant.
- That every FortiCNAPP feature is available uniformly across cloud providers.
- That an empty result means an environment is secure.

Fortinet's own feature-specific documentation shows that capabilities can differ by cloud provider and integration context. [C1-S007 through C1-S010] That is why this book avoids turning a broad product-support statement into a promise about a specific evidence source.

The first controlled API evidence appears only after you have learned the runtime, PowerShell object model, HTTP behavior, JSON processing, and authentication lifecycle.

## 9. Synthetic output

Run the example from the repository root:

```powershell
pwsh ./examples/foundations/Review-SyntheticScopeRegister.ps1
```

A normal result resembles the following:

```text
DataClassification : Synthetic
Organization       : Kestrel Vale Health Services
AsOfUtc            : 08/13/2026 00:00:00 +00:00
Denominator        : Scopes where expectedInFortiCNAPP is true
ExpectedScopeCount : 5
ObservedScopeCount : 3
MissingScopeCount  : 1
StaleScopeCount    : 1
CoveragePercent    : 60
MissingScopeIds    : {azure-analytics-production}
StaleScopeIds      : {gcp-research-shared}
```

**Evidence label: `SYNTHETIC`.**

The organization, identifiers, timestamps, states, and coverage result were created for this lab. They do not describe a real FortiCNAPP tenant or customer.

The output contains more than a percentage. It includes the denominator definition, expected count, state counts, and identifiers requiring review. A report renderer could later shorten this object, but the underlying evidence should remain available.

## 10. Technical interpretation

A security engineer should read the object as a collection-quality result.

Three of five expected scopes are currently observed. One expected Azure scope is missing. One expected Google Cloud scope is stale. The training scope does not participate in the metric.

The object does not explain why either gap exists. It identifies where investigation should begin.

For the missing Azure scope, useful next questions include:

- Is the subscription still part of the authoritative business inventory?
- Was it ever integrated?
- Did an identity, role, consent, or permission change?
- Is the expected evidence type supported by the configured integration?
- Did a collection or processing failure occur?
- Is the scope present under a different identifier?
- Is the scope visible in another FortiCNAPP account or subaccount?

For the stale Google Cloud scope, useful next questions include:

- What was the last successful observation?
- Which evidence source produced it?
- What freshness threshold applies to that evidence type?
- Did collection stop, or is processing delayed?
- Did the scope move or change ownership?
- Is the stale state caused by the fixture's rule or by provider behavior?

Notice what the engineer should not conclude.

The engineer should not conclude that the missing Azure scope has no vulnerabilities. The engineer should not conclude that the stale Google Cloud scope is compromised. The engineer should not conclude that the three observed scopes are healthy. Coverage says whether expected scope produced qualifying evidence, not whether the observed environments are secure.

This separation keeps collection quality and security posture from collapsing into one ambiguous number.

## 11. Executive interpretation

A concise executive statement based on the same object could read:

> Current monitoring evidence covers three of five expected production and shared scopes, or 60 percent. One Azure subscription has no qualifying evidence, and one Google Cloud project has stale evidence. The training subscription is outside the approved denominator. Confidence in organization-wide posture reporting is low until the two evidence gaps are resolved.

That statement contains five elements:

1. The numerator and denominator.
2. The percentage.
3. The reason the remainder did not qualify.
4. The excluded scope.
5. The confidence and required next action.

The CISO can now make a decision. The immediate decision is not whether overall cloud risk increased or decreased. The immediate decision is whether to restore and validate monitoring coverage before relying on broader posture metrics.

An owner and deadline can then be added:

- Cloud Platform owns the missing Azure scope review.
- Research Technology owns the stale Google Cloud scope review.
- Security Engineering verifies evidence restoration.
- The posture report remains qualified until completion.

The executive layer is shorter, but it remains traceable to the technical object and synthetic register.

## 12. Security and privacy considerations

A scope register can become sensitive even when it contains no credentials. Real registers may reveal account names, production systems, business services, owners, regions, data classifications, acquisition activity, or gaps in monitoring.

Treat a real register as security information.

For repository examples:

- Use fictional organization names.
- Use synthetic identifiers.
- Avoid real account numbers, subscription identifiers, project identifiers, cluster names, registry paths, or customer names.
- Do not include access material.
- Do not commit unredacted provider exports.
- Label synthetic and sanitized files explicitly.
- Preserve the license and provenance metadata.

For operational use:

- Store the register in an approved location.
- Restrict modification to accountable owners.
- Record changes to the denominator.
- Separate business-authoritative inventory from provider observations.
- Review exclusions and expiration dates.
- Protect exports and reports according to their content.

A malicious or accidental denominator change can alter every downstream percentage without changing a single provider record. Change control is therefore a security control, not merely an administrative preference.

## 13. Failure modes and troubleshooting

The lab is small, but it demonstrates several failures that occur in production reporting.

### The fixture is not classified as synthetic

The script stops with an error when `dataClassification` is not `Synthetic`.

This behavior protects the lab boundary. It also teaches a broader rule: automation should validate the contract of an input before trusting its contents.

### The denominator is zero

The script returns `$null` for `CoveragePercent` when no scope is expected.

A report should state that coverage could not be calculated because the denominator was empty. It should not display zero percent, 100 percent, or a green status.

### A scope has an unknown evidence state

The current script counts only `Observed`, `Missing`, and `Stale` among expected scopes. An unexpected value would remain in the denominator but would not enter one of those state counts.

The fixture contract tests limit accepted states. A future production command should also return an explicit unknown-state count rather than silently allowing the totals to stop reconciling.

### The expected count does not equal the state counts

For this lab, the following should be true:

```text
expected = observed + missing + stale
```

If it is not true, the input or calculation requires review. Later schemas may include additional states, but the reconciliation rule must change explicitly with them.

### Excluded scope is counted as covered

This can happen when a script filters by evidence state before applying the denominator rule. The correct order is to select expected scopes first, then calculate states within that set.

### Missing is converted to zero

A missing record is not the same as a numeric zero. Converting missing evidence to zero can create a false measurement. For example, an unavailable compliance assessment is not a zero-percent pass rate unless the metric definition explicitly says so and explains the consequence.

### Stale is treated as current

A record can be valid evidence of a past observation while failing the current reporting requirement. Preserve its timestamp and label it stale. Do not discard its history, and do not count it as current merely because a record exists.

### Platform support is generalized too broadly

FortiCNAPP documentation covers multiple cloud and workload contexts, but support varies by feature and integration. Use feature-specific documentation and tenant validation. The synthetic platform list is not a current support matrix.

## 14. Tests

The repository tests the fixture and example contract.

The fixture tests verify that:

- The file is explicitly synthetic and carries the expected license metadata.
- Scope identifiers are unique.
- The planned foundational platform categories are represented.
- Observed, missing, stale, and excluded states remain distinct.
- Observation timestamps appear only where the fixture says evidence was observed previously.
- Common credential and production-account patterns are absent.

Module and content tests also verify that:

- The module imports under the approved name.
- Only the approved foundation functions are exported.
- The repository contains no prohibited U+2014 characters.
- Required SPDX headers are present.
- Recognized credential patterns are absent.

Continuous integration runs these checks on Windows, Ubuntu, and macOS with the PowerShell 7.6 baseline. The actual runner patch version is recorded by the workflow. Microsoft currently lists PowerShell 7.6 as a long-term support release with support through November 14, 2028. [C1-S011]

Tests do not prove that a real tenant is configured correctly. They prove that the synthetic artifact and calculation obey the declared repository contract.

## 15. Hands-on lab

### Objective

Calculate current observed coverage from a synthetic scope register and explain the result without overstating it.

### Step 1: Locate the fixture

From the repository root, inspect:

```text
tests/Fixtures/Synthetic/chapter-01-scope-register.json
```

Confirm these top-level properties:

- `dataClassification` is `Synthetic`.
- `organization` is Kestrel Vale Health Services.
- `denominatorDefinition` identifies scopes where `expectedInFortiCNAPP` is true.
- `asOfUtc` is present.

### Step 2: Identify the denominator

List the scopes where `expectedInFortiCNAPP` is true. There should be five.

Do not count the Azure training sandbox. Record why it is excluded.

### Step 3: Reconcile evidence states

Within the denominator, count:

- Observed.
- Missing.
- Stale.

Confirm that the three counts add to five.

### Step 4: Run the example

```powershell
pwsh ./examples/foundations/Review-SyntheticScopeRegister.ps1
```

Confirm that the output is classified as synthetic and that `CoveragePercent` equals 60.

### Step 5: Inspect the gaps

Record the missing and stale scope identifiers.

For each identifier, write two possible causes. Label them as hypotheses rather than facts.

Example:

```text
Scope: azure-analytics-production
Observed state: Missing
Hypothesis 1: The fictional integration was never completed.
Hypothesis 2: The fictional collection identity lost visibility.
Evidence required: Integration inventory, permission evidence, and recent collection records.
```

### Step 6: Write two interpretations

Write one technical interpretation of no more than 120 words. It should identify the state, unknowns, and investigation steps.

Write one executive interpretation of no more than 80 words. It should identify the numerator, denominator, confidence, and decision required.

Both interpretations must refer to the same result.

### Step 7: Change the denominator deliberately

Make a temporary copy of the fixture. Change the training subscription so that `expectedInFortiCNAPP` is true, then run the script against the copy:

```powershell
pwsh ./examples/foundations/Review-SyntheticScopeRegister.ps1 `
    -Path ./path/to/your-copy.json
```

The denominator should increase from five to six. Because the newly included scope is marked `Excluded`, the state counts will no longer reconcile. This is useful. It demonstrates that changing scope requires a corresponding evidence-state decision and contract review.

Restore or delete the temporary copy after the exercise. Do not modify the committed fixture merely to make a preferred percentage appear.

## 16. Review questions and exercises

1. Why can a successful provider response still produce an incomplete report?
2. What is the difference between visibility and evidence?
3. Why is a finding not automatically a complete risk statement?
4. Why should the expected scope come from a source independent of the monitoring platform?
5. What is the difference between missing and stale evidence?
6. Why is excluded scope neither covered nor uncovered?
7. Why does the script return `$null` when the denominator is zero?
8. What information should accompany an executive coverage percentage?
9. How can a denominator change make a trend look better without improving security?
10. Which Chapter 1 claims are `VERIFIED OFFICIAL`, and which remain `VERIFY IN TENANT`?
11. Create a seventh synthetic record for a second Kubernetes cluster. Decide whether it belongs in the denominator and explain the decision.
12. Add an `Unavailable` state to a temporary fixture and describe how the script and tests should change before that state is accepted.
13. Draft a rule for evidence freshness. State which evidence type it applies to and why the same interval might be wrong for another evidence type.
14. Explain how an engineer and a CISO can use different presentations without using different underlying facts.

## 17. Key takeaways

- Automation begins with the decision and intended scope, not with the first available endpoint.
- Visibility, evidence, finding, risk, and decision describe different stages of security work.
- A monitoring platform should not be the sole authority for what should appear in its own coverage denominator.
- Missing, stale, excluded, unavailable, and current evidence must remain distinct.
- A percentage without its numerator, denominator, time, scope, and limitations is not a defensible executive metric.
- Synthetic data must be labeled so that it cannot be mistaken for tenant evidence.
- Official documentation can verify interface-level claims, but tenant-specific availability and behavior still require controlled validation.
- PowerShell objects can preserve technical detail and support concise executive reporting from the same evidence model.

## 18. Source and version notes

The Chapter 1 source register is stored at:

```text
docs/source-register/CHAPTER-01.md
```

The register was reviewed on August 13, 2026.

Primary source groups:

- Fortinet FortiCNAPP latest API Reference.
- Fortinet FortiCNAPP 26.2.0 Administration Guide.
- Fortinet FortiCNAPP 26.2.0 and latest CLI Reference.
- Fortinet FortiCNAPP 26.2.0 and latest LQL Reference.
- Microsoft PowerShell lifecycle documentation.

The product documentation continues to use both FortiCNAPP and Lacework names in interface contexts. The book uses **FortiCNAPP, formerly Lacework** at the first substantive reference and retains actual interface names such as `lacework` and LQL where accuracy requires them.

The chapter does not reproduce live output, endpoint payloads, secrets, customer data, or tenant identifiers.

## 19. Verification-ledger updates

No tenant-dependent verification item is closed by Chapter 1.

The following statements are supported as `VERIFIED OFFICIAL` through the source register:

- The project targets PowerShell 7.6 LTS.
- The current documented programmatic API family is v2.
- The CLI executable is named `lacework`.
- LQL is SQL-like and uses curated datasources.
- Datasource discovery is a documented step.
- Feature and integration expectations can vary by provider and context.

The following remain `VERIFY IN TENANT`:

- Configured cloud and workload integrations.
- Accessible accounts, subaccounts, projects, subscriptions, clusters, and registries.
- Permission scope of the collection identity.
- Returned API schemas and fields.
- Available and populated LQL datasources.
- Evidence freshness appropriate to a particular source.
- The cause of any absent or stale record.

These unresolved items become concrete validation work in Chapters 5 through 13.

## 20. Companion-repository artifacts

| Purpose | Repository path |
|---|---|
| Chapter source register | `docs/source-register/CHAPTER-01.md` |
| Evidence labels | `docs/reference/EVIDENCE-LABELS.md` |
| Synthetic scope register | `tests/Fixtures/Synthetic/chapter-01-scope-register.json` |
| Complete lab script | `examples/foundations/Review-SyntheticScopeRegister.ps1` |
| Fixture contract tests | `tests/Contract/SyntheticScopeFixture.Tests.ps1` |
| Repository content controls | `tests/Content/Repository.Tests.ps1` |
| Chapter production notes | `manuscript/chapters/01-FORTICNAPP-CLOUD-RISK-PRODUCTION-NOTES.md` |

The next chapter builds the local PowerShell workspace that will run these artifacts consistently on Windows, Linux, and macOS. It introduces the terminal, help system, variables, paths, files, and the module's environment-readiness command without introducing live FortiCNAPP credentials.
