<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: LicenseRef-Paul-Kell-Manuscript -->

# Sample Section: Evidence Before Automation

The first question in security automation is not, "Can PowerShell retrieve the data?" PowerShell can retrieve, transform, group, and export an impressive amount of data. The more important question is, "What will the result prove?"

Consider a Monday morning at Kestrel Vale Health Services, the fictional organization used throughout this book. The CISO receives a cloud security summary with a reassuring headline: compliance improved from 82 percent to 91 percent. The report looks complete. It has a chart, a green arrow, and a list of the five accounts with the most failed controls.

Then the CISO asks four ordinary questions.

Which accounts were included? What counted as an evaluated control? Did any integrations stop reporting? Can an engineer reproduce the 91 percent result?

The report cannot answer them. One Azure subscription was not collected after a permission change. Several resources were never evaluated. The script converted missing status values to zero and then excluded those zeroes from the denominator. The green arrow is mathematically correct for the data that survived the script, but the conclusion is not defensible.

This is the difference between moving data and preserving evidence.

## A result needs a chain of custody

In incident response, chain of custody describes how evidence was obtained, handled, and preserved. Cloud security reporting needs a practical version of the same discipline. You should be able to follow a reported value backward through each stage:

1. The decision or headline shown to a leader.
2. The metric and its exact formula.
3. The normalized security objects used by the formula.
4. The source records returned by an API or query.
5. The request scope, identity, time, and interface used to collect those records.

When that chain is intact, an engineer can reproduce the result, an auditor can understand the method, and a leader can judge the confidence. When it is broken, a polished report may still be useful as a conversation starter, but it should not be treated as reliable evidence.

PowerShell is well suited to this work because it passes objects through a pipeline. An object can carry the finding and the context needed to interpret it. You do not have to choose between raw technical detail and executive meaning. You can preserve the detail, calculate a transparent measure, and render a concise summary later.

A first evidence object might be as simple as this:

```powershell
$collection = [pscustomobject]@{
    SourceSystem       = 'FortiCNAPP'
    SourceInterface    = 'API v2'
    CollectedAtUtc     = [datetime]::UtcNow
    Scope              = 'Synthetic AWS production accounts'
    ExpectedAccountCount = 8
    ObservedAccountCount = 7
    VerificationStatus  = 'SYNTHETIC'
    DataQuality         = 'Incomplete scope'
}
```

This object does not yet contain a vulnerability, alert, or compliance result. That is intentional. It records whether the collection can support a conclusion. A later metric can use the seven observed accounts, but it must also disclose that eight were expected. The missing account is not a small technical detail. It changes what the organization can responsibly claim.

## Three questions before the first live request

Before you automate a FortiCNAPP workflow, answer three questions.

### What is the intended decision?

A request for "all vulnerabilities" is too broad to guide design. The engineer might need a remediation queue for exposed production workloads. The CISO might need to know whether critical actionable risk is increasing. Those are related goals, but they require different grouping, context, and time windows.

Start with the decision, then identify the evidence required to support it. This reduces the temptation to collect every available field and hope that a useful report emerges later.

### What scope is expected?

The API can return only what the authenticated identity, tenant context, integration state, product feature set, and selected time range make available. A successful response does not prove complete coverage.

Kestrel Vale maintains a separate scope register containing the cloud accounts, subscriptions, projects, and clusters that leadership expects to be monitored. The automation compares observed FortiCNAPP evidence with that register. A mismatch becomes a finding of its own. This approach prevents a report from becoming greener simply because part of the environment disappeared from view.

### What must be verified?

FortiCNAPP changes over time, and tenants can differ. An endpoint path, response field, pagination rule, LQL datasource, query limit, or feature may be current in one context and wrong in another. This book will not fill those gaps with plausible guesses.

When a detail has not been verified, it receives the marker `VERIFY IN TENANT`. The marker creates work. It points to a ledger entry that records the claim, approved source, validation method, observed behavior, version, and sanitized evidence. Once the evidence is reviewed, the item can become `VERIFIED IN TENANT`. If a later release affects it, the item returns to `REVERIFY`.

That may appear slower than copying an old query from a forum post. It is faster than diagnosing a misleading report after an executive decision has been made.

## Beginner code can still use professional controls

A beginner book should not bury the reader under a framework in the first chapter. It also should not teach shortcuts that must be discarded as soon as the script matters.

We will build the module in layers. You will first learn how PowerShell stores values and passes objects. Then you will learn functions, parameters, errors, HTTP, and JSON. Only after those pieces are understandable will we request a temporary bearer token and call a verified FortiCNAPP API v2 operation.

The first working request will be small. The production-quality client will come later. By the time retries, pagination, diagnostics, and schema checks are added, each one will solve a failure you have already seen. Nothing important will be hidden behind the word "best practice."

Secure defaults begin early. Credentials will not appear in source code. Tokens will not appear in verbose output. Collection functions will return objects rather than formatted tables. Missing values will remain unknown instead of becoming false. Read-only operations will come before mutating operations. Tests will verify the parts most likely to create false confidence: authentication, redaction, retry behavior, pagination, normalization, and metric formulas.

## The executive layer is not a separate truth

Security teams often build one report for engineers and another for leaders. That division can cause the two reports to drift. Engineers see raw findings. Leaders see percentages and trends. Neither side can easily move from one view to the other.

PSFortiCNAPP will use one evidence model to support both. A compliance engineer can inspect the affected control and resource. A leader can see the change in material control drift. Both views point to the same underlying evidence reference, collection time, scope, and quality state.

The leader does not need every property on every object. The leader does need to know whether the metric covers the intended environment, whether the evidence is current, whether the denominator is valid, and what decision follows.

At Kestrel Vale, the corrected Monday report does not say, "Compliance improved to 91 percent." It says:

> Evaluated-control pass rate increased from 82 percent to 91 percent across seven of eight expected production accounts. One Azure subscription was unavailable because the collection identity lost permission. Confidence is moderate. Restore visibility before treating the change as an organization-wide improvement.

That statement is less comfortable, but more useful. It tells the CISO what was observed, what was missing, how much confidence to place in the trend, and what must happen next.

That is the standard for the automation we will build. The goal is not to make every report look complete. The goal is to make every conclusion honest about the evidence behind it.
