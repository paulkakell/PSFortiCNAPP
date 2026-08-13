<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Executive Metrics Framework

## Purpose

The module will not produce attractive but unauditable scorecards. Every executive measure must connect to source evidence, scope, time, transformation, and data quality.

A metric is useful only when a leader can answer:

- What decision does this support?
- What is included?
- What is missing?
- Is the trend real or caused by coverage change?
- Who owns the next action?

## Metric record

Every calculated metric should return an object containing at least:

```text
MetricId
MetricName
Definition
Value
Unit
Numerator
Denominator
PeriodStartUtc
PeriodEndUtc
CollectedAtUtc
Scope
Filters
SourceEvidenceTypes
CalculationVersion
DataQuality
Confidence
Trend
DecisionUse
Owner
Limitations
```

A rendered report may hide detail for readability, but the underlying object retains it.

## Metric families

### Coverage and visibility

| Metric | Proposed definition | Decision use |
|---|---|---|
| Cloud account coverage | Integrated in-scope accounts divided by known in-scope accounts | Identify visibility gaps |
| Workload coverage | Monitored in-scope workloads divided by known in-scope workloads | Assess detection and assessment reach |
| Evidence freshness | Evidence records within the approved freshness threshold divided by applicable records | Detect stale reporting |
| Inventory reconciliation gap | Known inventory count minus observed FortiCNAPP inventory count, with matched scope | Investigate integration or collection gaps |

The source of the known denominator must be disclosed. A FortiCNAPP-only inventory cannot prove complete coverage without an independent scope record.

### Compliance and control health

| Metric | Proposed definition | Decision use |
|---|---|---|
| Evaluated-control pass rate | Passing evaluated controls divided by all evaluated controls | Track control posture without treating not-assessed items as passing |
| Material control drift | Newly failed controls meeting the approved impact threshold | Direct remediation attention |
| Repeat control failure | Failed control-resource pairs recurring across consecutive periods | Identify ineffective remediation |
| Exception exposure | Active exceptions by age, scope, and impact | Review accepted risk and expiration |

Framework names and mappings are context, not proof that the organization is compliant.

### Vulnerability and exposure

| Metric | Proposed definition | Decision use |
|---|---|---|
| Critical actionable vulnerability backlog | Unique affected workload-package or image-package findings that meet approved severity and fix criteria | Size immediate remediation work |
| Internet-exposed critical findings | Critical actionable findings on assets with verified external exposure | Prioritize by reachable impact |
| Remediation aging | Age distribution from first observed to resolved or current time | Detect persistent backlog |
| Fix availability ratio | Findings with a known fix divided by applicable findings | Separate patchable backlog from compensating-control work |

Severity alone is not a sufficient prioritization model. Exposure, exploitability evidence, workload importance, identity privilege, fix availability, and data confidence should remain visible factors.

### Identity and privilege

| Metric | Proposed definition | Decision use |
|---|---|---|
| High-privilege identity exposure | High-privilege identities with approved risk indicators divided by high-privilege identities in scope | Target identity review |
| Dormant privileged identity count | Privileged identities without observed approved activity inside a defined period | Remove unnecessary access after validation |
| Cross-account privilege concentration | Identities or roles with privileged reach across multiple accounts | Assess blast radius |
| Service identity anomaly backlog | Unresolved identity findings involving service identities | Focus nonhuman identity governance |

An absence of observed activity does not prove an identity is unused. Collection coverage and time window must be shown.

### Detection and response

| Metric | Proposed definition | Decision use |
|---|---|---|
| Alert backlog by age and severity | Open alerts grouped by agreed age bands and severity | Allocate investigation capacity |
| Time to first review | Time from alert start or creation to first documented analyst review | Assess operational responsiveness |
| Time to disposition | Time from alert creation to approved outcome | Assess workflow efficiency |
| Evidence-complete investigation rate | Investigations containing the defined minimum evidence set divided by closed investigations | Improve investigation quality |
| Recurring alert pattern | Repeated alert fingerprints within an approved period | Identify noisy controls or persistent behavior |

The module must not invent analyst timestamps that FortiCNAPP does not supply. External ticket or workflow data may be required and must be labeled as a separate source.

### Automation reliability

| Metric | Proposed definition | Decision use |
|---|---|---|
| Collection success rate | Successful scheduled collections divided by attempted collections | Assess reporting reliability |
| Partial-data run rate | Runs completed with one or more declared scope or quality failures divided by all runs | Prevent false confidence |
| API retry rate | Requests that required retry divided by all requests | Detect provider or network instability |
| Schema-drift event count | Contract-test or mapping failures caused by unexpected provider shape | Trigger maintenance |
| Report timeliness | Reports delivered within the approved window divided by scheduled reports | Measure service reliability |

## Confidence model

A metric receives a transparent confidence assessment based on:

- Coverage quality.
- Freshness quality.
- Completeness quality.
- Validation status.
- Denominator quality.
- Transformation complexity.

The first implementation should use categorical values such as `High`, `Moderate`, `Low`, and `Insufficient`, with the reasons listed. It should not create an opaque mathematical confidence score.

## Trend rules

A trend comparison is valid only when:

- Metric definition and calculation version are compatible.
- Scope is equivalent or the change is disclosed.
- Collection freshness is comparable.
- Material schema or integration changes are accounted for.
- The prior period is available and valid.

When scope changes, report the current value and the scope change before asserting improvement or deterioration.

## Executive summary structure

1. **Decision headline:** The most consequential verified change.
2. **Scope and confidence:** What was measured and how trustworthy it is.
3. **Top risk concentrations:** Resources, accounts, identities, or controls requiring attention.
4. **Operational movement:** Backlog, aging, drift, and response trends.
5. **Required decisions:** Owner, action, due date, and risk of delay.
6. **Known blind spots:** Coverage, freshness, permissions, or unavailable data.
7. **Evidence references:** Links or identifiers for technical review.

## Anti-patterns

Do not publish:

- A percentage without its denominator.
- A green status based on missing data.
- A trend across materially different scope without disclosure.
- A single risk score that hides weighting.
- A vulnerability count that double-counts equivalent findings without explanation.
- A compliance percentage presented as legal or regulatory assurance.
- An alert-response metric when the required workflow timestamps do not exist.
- A claim that FortiCNAPP is the source when the value was derived from another system.

## Verification

Metric formulas will be tested with deterministic synthetic fixtures before tenant data is used. Tenant validation will then confirm that provider fields have the meaning assumed by each formula. Verification-ledger entries V-023 and V-024 control the initial publication gate.
