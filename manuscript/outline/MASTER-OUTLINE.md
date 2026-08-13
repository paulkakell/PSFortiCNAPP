<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Master Outline

Book: **PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring**

## Part I: FortiCNAPP and PowerShell Foundations

### Chapter 1: FortiCNAPP and the Cloud Risk Problem

**Purpose:** Establish why cloud security automation must preserve evidence quality, not merely retrieve more data.

**Reader outcomes:**

- Describe the broad security problems FortiCNAPP helps investigate.
- Distinguish visibility, evidence, finding, risk, and decision.
- Identify the roles of the console, CLI, API v2, LQL, and local fixtures.
- Explain why missing data cannot be interpreted as absence of risk.

**Operational scenario:** Kestrel Vale Health Services receives conflicting cloud-risk summaries from separate teams. The CISO asks which numbers are complete and actionable.

**Executive question:** Can leadership trust the reported coverage, risk concentration, and trend?

**Lab:** Build a synthetic cloud-scope register and identify evidence gaps before any API call.

**Repository artifacts:** Scope-register fixture, evidence-label reference, first data-quality checklist.

**Verification focus:** Current product naming, interface roles, and supported documentation hierarchy.

**Target words:** 5,500.

### Chapter 2: Starting Securely with PowerShell 7

**Purpose:** Give a true beginner a safe, cross-platform working environment.

**Reader outcomes:**

- Install and identify the supported PowerShell runtime.
- Use commands, help, variables, paths, and basic error inspection.
- Configure a project workspace without storing credentials in source.
- Distinguish terminal output, objects, files, and logs.

**Operational scenario:** A new engineer must reproduce a security report on Windows and Linux without copying a coworker's profile or secrets.

**Executive question:** Can the automation be operated consistently and safely by more than one person?

**Lab:** Create the local repository workspace, run environment checks, and produce a non-sensitive system-readiness object.

**Repository artifacts:** Environment test script, setup checklist, sample configuration template.

**Verification focus:** PowerShell support baseline and cross-platform path behavior.

**Target words:** 6,000.

### Chapter 3: Objects, Pipelines, Logic, and Reusable Functions

**Purpose:** Teach the PowerShell model needed for reliable security data handling.

**Reader outcomes:**

- Inspect object properties and types.
- Filter, group, sort, and calculate without parsing display text.
- Use conditions, loops, functions, parameters, and validation.
- Create stable custom objects with explicit meaning.

**Operational scenario:** A copied one-line command produces a table but cannot be reused for a weekly report or tested for missing fields.

**Executive question:** Is the calculation repeatable, reviewable, and resistant to a formatting change?

**Lab:** Transform synthetic cloud findings into normalized evidence objects and calculate a transparent backlog summary.

**Repository artifacts:** Synthetic finding fixture, transformation functions, unit tests for object shape.

**Verification focus:** None tenant-specific; all provider data remains synthetic.

**Target words:** 6,500.

### Chapter 4: HTTP, REST, and JSON for Security Automation

**Purpose:** Explain web requests before introducing live FortiCNAPP credentials.

**Reader outcomes:**

- Understand methods, URIs, headers, status codes, and JSON bodies.
- Use `Invoke-RestMethod` and inspect returned objects.
- Recognize authentication, authorization, validation, and server failures.
- Build a safe request/response diagnostic record.

**Operational scenario:** An analyst sees a 403 response and cannot tell whether the URL, token, role, or tenant context is wrong.

**Executive question:** Can failure be diagnosed without exposing credentials or silently producing partial reports?

**Lab:** Use a local mock service or fixture-backed request harness to process success, authorization, rate-limit, and malformed-JSON cases.

**Repository artifacts:** General HTTP exercise, synthetic responses, error-classification tests.

**Verification focus:** No FortiCNAPP endpoint is introduced until Chapter 5.

**Target words:** 6,500.

## Part II: Engineering the API Foundation

### Chapter 5: Secure Authentication and Configuration

**Purpose:** Implement a verified token lifecycle and safe configuration model.

**Reader outcomes:**

- Explain API key, secret, bearer token, user, service user, and permission scope.
- Obtain and refresh a temporary token without logging it.
- Use local, vault-based, and noninteractive credential patterns.
- Distinguish authentication from authorization failures.

**Operational scenario:** Kestrel Vale must replace a shared administrator credential with a read-only service identity for scheduled collection.

**Executive question:** Does the automation have only the access it needs, and can secret use be audited without revealing the secret?

**Lab:** Connect to a controlled tenant or use the token-service fixture, inspect expiry, test a denied permission, and verify redaction.

**Repository artifacts:** `Connect-FortiCNAPP` design, credential template, token fixtures, redaction tests.

**Verification focus:** V-001 through V-003.

**Target words:** 6,500.

### Chapter 6: Building a Production-Quality FortiCNAPP API Client

**Purpose:** Centralize reliable API v2 behavior behind a reusable transport layer.

**Reader outcomes:**

- Construct safe requests from a connection context.
- Handle status codes, timeouts, retries, and correlation identifiers.
- Discover schemas instead of hard-coding assumptions.
- Produce actionable errors and opt-in diagnostics.

**Operational scenario:** A report succeeds for one account but fails halfway through another after a transient error, leaving an apparently complete output file.

**Executive question:** Can a report declare partial data and recover safely rather than conceal a collection failure?

**Lab:** Exercise the transport against synthetic and controlled responses, inject failures, and verify bounded retry and partial-run status.

**Repository artifacts:** private transport layer, error model, diagnostic logger, unit and contract tests.

**Verification focus:** V-004 through V-007.

**Target words:** 7,500.

### Chapter 7: Asset Inventory, Pagination, and Data Quality

**Purpose:** Collect broad inventory without losing, duplicating, or misrepresenting records.

**Reader outcomes:**

- Implement endpoint-specific pagination adapters.
- Normalize multi-cloud identifiers and timestamps.
- Detect duplicate, stale, missing, and out-of-scope records.
- Reconcile observed inventory with an independent scope register.

**Operational scenario:** The CISO sees improved cloud coverage, but the increase came from a changed denominator rather than a new integration.

**Executive question:** What proportion of the intended environment is visible, current, and reconciled?

**Lab:** Collect or replay paged asset data, reconcile it with a synthetic authoritative scope list, and explain every mismatch.

**Repository artifacts:** asset command, pagination engine, inventory fixtures, reconciliation report, tests.

**Verification focus:** V-008 through V-010.

**Target words:** 6,000.

## Part III: Data Discovery and LQL

### Chapter 8: LQL Fundamentals and Datasource Discovery

**Purpose:** Teach LQL as a discoverable, versioned interface rather than a collection of copied queries.

**Reader outcomes:**

- Explain datasource, field, filter, projection, aggregation, and time scope.
- List and inspect datasources available to the tenant.
- Validate identifier case, field types, and documented limits.
- Build small queries and label unverified fragments correctly.

**Operational scenario:** A useful query from an older environment fails because the datasource or field does not exist in the current tenant.

**Executive question:** Are reported findings based on a query that is valid for the data source and period being measured?

**Lab:** Discover a safe datasource, inspect metadata, draft a minimal query, and record the result in the verification ledger.

**Repository artifacts:** datasource inventory, LQL metadata fixture, query-validation helper, ledger evidence template.

**Verification focus:** V-011 and V-012.

**Target words:** 6,500.

### Chapter 9: Operational LQL, Policies, and Query Lifecycle

**Purpose:** Turn a validated query into a maintained operational artifact.

**Reader outcomes:**

- Preview, test, and version a query.
- Handle empty, null, duplicate, and high-volume results.
- Separate on-demand investigation queries from policy logic.
- Define change, review, and rollback controls for operational queries.

**Operational scenario:** A query used in a weekly report changes behavior after a datasource update, but no one knows which report version used which query.

**Executive question:** Can the organization reproduce the logic behind a risk statement from a prior period?

**Lab:** Promote a validated synthetic or controlled query through draft, test, approved, and revalidation states.

**Repository artifacts:** versioned query folder, query manifest, test fixture, lifecycle checklist.

**Verification focus:** V-013 and V-014.

**Target words:** 6,500.

## Part IV: Security Monitoring Workflows

### Chapter 10: Compliance Monitoring and Control Drift

**Purpose:** Collect compliance evidence and report control movement without overstating assurance.

**Reader outcomes:**

- Normalize control, resource, status, framework, exception, and time evidence.
- Calculate an evaluated-control pass rate with a defensible denominator.
- Detect new, repeated, resolved, and reopened control failures.
- Explain why a platform assessment is not a legal compliance opinion.

**Operational scenario:** Kestrel Vale's pass rate improves while the number of unevaluated resources also grows.

**Executive question:** Which material controls changed, what is the affected scope, and what action is required?

**Lab:** Compare two deterministic assessment snapshots, identify drift, and generate technical and executive views from the same objects.

**Repository artifacts:** compliance command, normalized control objects, drift engine, Markdown report, formula tests.

**Verification focus:** V-015 and V-016.

**Target words:** 6,500.

### Chapter 11: Vulnerability Prioritization Across Workloads

**Purpose:** Move beyond severity counts to transparent, multi-factor remediation decisions.

**Reader outcomes:**

- Normalize host, container image, package, fix, severity, and workload evidence.
- Avoid double-counting equivalent or repeated findings.
- Combine exposure, exploitability evidence, workload importance, fix availability, and age.
- Produce a prioritized backlog without hiding weighting.

**Operational scenario:** Teams disagree because one report counts vulnerable packages, another counts hosts, and a third counts images.

**Executive question:** Which remediations reduce the most material reachable risk, and who owns them?

**Lab:** Reconcile synthetic host and image findings, apply a documented prioritization matrix, and compare it with severity-only ordering.

**Repository artifacts:** vulnerability command, deduplication rules, prioritization function, owner backlog report, tests.

**Verification focus:** V-017 and V-018.

**Target words:** 6,500.

### Chapter 12: Identity, Exposure, and Multi-Signal Risk

**Purpose:** Correlate identity privilege, resource exposure, and security findings while preserving uncertainty.

**Reader outcomes:**

- Normalize human and service identity relationships.
- Identify high-privilege and cross-account reach using verified fields.
- Combine identity, exposure, vulnerability, and control evidence.
- Explain why correlation is not proof of exploitation.

**Operational scenario:** A moderate resource finding becomes a priority because an externally reachable workload is operated by an over-privileged service identity.

**Executive question:** Where can multiple weaknesses combine into a larger blast radius?

**Lab:** Build a synthetic relationship graph and produce a transparent multi-signal finding with evidence references and confidence limits.

**Repository artifacts:** identity-risk command, relationship objects, correlation function, evidence graph export, tests.

**Verification focus:** V-019 and V-020.

**Target words:** 6,500.

## Part V: Threat Evidence and CISO Reporting

### Chapter 13: Alert Triage and Threat Investigation

**Purpose:** Create repeatable alert evidence packages without replacing analyst judgment.

**Reader outcomes:**

- Collect alert summary and detail evidence.
- Normalize severity, status, time, identity, host, process, cloud, and related-event information.
- Distinguish provider evidence from analyst conclusions.
- Build a package that supports review, escalation, and closure.

**Operational scenario:** A high-severity alert has little useful context in its summary, while the related evidence contains the details needed for triage.

**Executive question:** Are severe alerts reviewed with consistent evidence, and where is investigation quality weak?

**Lab:** Process a sanitized or synthetic alert, collect related evidence, create a timeline, and produce a technical dossier with explicit unknowns.

**Repository artifacts:** alert commands, evidence joiner, timeline builder, investigation package, tests.

**Verification focus:** V-021 and V-022.

**Target words:** 7,000.

### Chapter 14: From Security Evidence to CISO Decisions

**Purpose:** Convert validated evidence into decision-ready reporting without severing lineage.

**Reader outcomes:**

- Define metrics with numerator, denominator, scope, period, and quality.
- Distinguish product-native and module-derived values.
- Build technical, operational, and executive report layers.
- Write decision headlines that separate finding, interpretation, and action.

**Operational scenario:** Kestrel Vale's board packet contains a single cloud-risk score that no engineer can reproduce.

**Executive question:** What changed, how confident are we, and which decision must be made now?

**Lab:** Generate a CISO report from deterministic multi-domain fixtures and trace every headline value back to evidence objects.

**Repository artifacts:** metric functions, executive-summary command, Markdown and HTML renderers, lineage index, formula tests.

**Verification focus:** V-023 and V-024.

**Target words:** 6,500.

## Part VI: Production Operations and GitHub Release

### Chapter 15: Testing, Scheduling, Continuous Integration, and Reliability

**Purpose:** Operate the module repeatedly without treating one successful run as proof of reliability.

**Reader outcomes:**

- Build unit, contract, and controlled integration tests.
- Use PSScriptAnalyzer and Pester coverage appropriately.
- Schedule noninteractive collection with protected secrets.
- Detect partial runs, schema drift, stale data, and report-delivery failure.

**Operational scenario:** A scheduled report arrives on time but silently excludes one cloud account after an authorization change.

**Executive question:** Can the reporting service prove that it collected the intended scope and disclose when it did not?

**Lab:** Run the workflow in CI, inject a collection failure, verify quality flags, and test cross-platform module import.

**Repository artifacts:** CI workflow, scheduler examples, reliability dashboard objects, test suite, archive inspection.

**Verification focus:** V-025 and V-026.

**Target words:** 7,000.

### Chapter 16: Capstone Automation and GitHub Release

**Purpose:** Assemble the module into a reproducible, evidence-driven release and capstone workflow.

**Reader outcomes:**

- Run an end-to-end multi-domain collection against fixtures or a controlled tenant.
- Produce technical evidence, operational backlog, and executive summary outputs.
- Package the module with licenses, checksums, SBOM, and release notes.
- Install and validate the module from a GitHub Release asset.

**Operational scenario:** Kestrel Vale must transition the automation from its original engineer to a supported operational service.

**Executive question:** Is the automation maintainable, verifiable, securely distributable, and clear about its limits?

**Lab:** Build the release candidate, verify archive contents and checksums, install it in a clean environment, and execute the capstone report.

**Repository artifacts:** release workflow, build script, module archive, checksums, SBOM, release notes, capstone configuration and output.

**Verification focus:** V-027 and V-028.

**Target words:** 7,500.

## Appendices

### Appendix A: PowerShell 7 Installation, Shell Configuration, and Troubleshooting

Cross-platform installation, version checks, profiles, execution-policy context, paths, proxies, certificates, and common environment failures.

### Appendix B: Secure Authentication and Secret-Management Checklist

API-key lifecycle, service identities, SecretManagement, scheduler secrets, rotation, revocation, redaction, and incident response for exposed credentials.

### Appendix C: HTTP, API, Pagination, and Error-Recovery Reference

Methods, headers, status classes, JSON conversion, timeouts, retries, pagination adapter checklist, and safe diagnostic patterns.

### Appendix D: LQL Development and Validation Checklist

Datasource discovery, field inspection, syntax validation, preview, test cases, performance, lifecycle, evidence, and revalidation.

### Appendix E: PSFortiCNAPP Command and Reporting Metric Reference

Final public command synopsis, common parameters, output types, metric definitions, calculation versions, and report formats.

### Appendix F: Lacework-to-FortiCNAPP Terminology, Migration, and Version Notes

Product naming, retained Lacework terms, documentation transitions, version caveats, and a reader-facing revalidation guide.
