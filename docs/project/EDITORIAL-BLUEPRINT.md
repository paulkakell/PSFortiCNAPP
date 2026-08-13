<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Editorial Blueprint

## Positioning

The book occupies the space between introductory PowerShell instruction, FortiCNAPP platform automation, and security-leadership reporting. Most introductory scripting material stops before production concerns. Most API references assume programming fluency. Most executive reporting guidance hides the engineering path behind the metric. This project connects all three.

The differentiator is evidence continuity. The same evidence object that helps an engineer investigate an alert should carry enough scope, source, time, and quality information to support an executive summary without inventing certainty.

## Reader transformation

At the beginning, the reader may be able to run commands but cannot yet judge whether an automated result is complete, current, secure, or defensible.

At the end, the reader can design, test, and release a PowerShell module that:

- Authenticates without leaking secrets.
- Handles API behavior deliberately.
- Discovers LQL capabilities instead of guessing.
- Normalizes heterogeneous security evidence.
- Reports risk without stripping away uncertainty.
- Supports engineers, analysts, auditors, and leaders from one evidence model.

## Persona matrix

| Persona | Starting point | Needs from the book | Completion evidence |
|---|---|---|---|
| PowerShell beginner | Can use a shell but has not built a module | Incremental syntax, objects, functions, debugging, safe examples | Completes labs and explains each module layer |
| Cloud security engineer | Understands cloud risk and FortiCNAPP basics | Reliable API/LQL automation, data normalization, tests | Builds read-only evidence workflows and diagnoses failures |
| SOC analyst | Investigates alerts manually | Repeatable alert collection, evidence joins, timestamps | Produces a sanitized investigation package |
| Compliance analyst | Reviews controls and exceptions | Transparent scope, denominators, drift history | Produces a control-drift report with limitations |
| Security leader | Consumes summaries | Metrics tied to source evidence and decisions | Can trace a headline metric to its definition and data quality |
| Platform engineer | Owns automation runtime | Cross-platform setup, secrets, scheduling, CI, release operations | Deploys a tested release without embedding credentials |

## Pedagogical progression

The book uses a spiral model. A concept is introduced in its simplest useful form and revisited when production requirements become visible.

Example progression:

1. Chapter 2 introduces variables, commands, and safe local configuration.
2. Chapter 3 introduces objects and reusable functions.
3. Chapter 4 performs a general HTTP and JSON exercise without assuming a FortiCNAPP endpoint.
4. Chapter 5 adds real authentication after the secret model is understood.
5. Chapter 6 turns the request into a resilient private module function.
6. Later chapters reuse the same transport layer while adding domain-specific adapters.

The reader is not asked to copy a complete framework before understanding its parts.

## Interface-selection discipline

Each workflow explicitly decides among:

- FortiCNAPP console for human exploration or confirmation.
- Official CLI for discovery, diagnosis, or a supported operation.
- API v2 for reusable automation and structured integration.
- LQL for tenant data discovery, policy logic, or query-driven evidence.
- Local fixture for teaching when tenant access is unavailable or unsafe.

The book does not force every task through the API. The interface is chosen by evidence needs, repeatability, supportability, permissions, and reader learning value.

## Lab design

Labs follow a consistent structure:

1. Objective.
2. Starting state.
3. Required permissions and data classification.
4. Steps.
5. Expected synthetic or tenant-verified behavior.
6. Verification checks.
7. Failure injection or troubleshooting branch.
8. Cleanup.
9. Evidence to retain.
10. Reflection question linking the lab to operational or executive decisions.

A reader without a tenant must be able to complete a meaningful fixture-based version of each core lab. Tenant-dependent extensions are clearly separated.

## Code presentation

- A runnable listing appears after the reader understands the component parts.
- Listings include parameter validation, error behavior, and expected object shape.
- Ellipses are not used inside code that is described as complete.
- Placeholders use obvious names and cannot be mistaken for real credentials.
- Long listings live in the repository and are excerpted only when layout requires it.
- Printed code is pinned to a repository tag or commit during production.

## Security and privacy treatment

Security is integrated into the teaching sequence rather than isolated in one warning chapter.

Every chapter asks:

- What secret or token exists here?
- What permission is required?
- What tenant data could be exposed?
- What could enter logs or error messages?
- What action is read-only, mutating, or destructive?
- What evidence must be retained, sanitized, or deleted?

Real customer names, account numbers, internal domains, resource identifiers, source IP addresses, email addresses, and credentials are prohibited from committed fixtures and manuscript examples.

## Executive translation pattern

Whenever a workflow creates an executive-facing result, the chapter uses three layers:

1. **Finding:** What the evidence directly shows.
2. **Interpretation:** Why the finding matters within the stated scope.
3. **Decision:** What action, owner, or question follows.

The text distinguishes an observed fact from an inference. Confidence is lowered when coverage, freshness, or denominator quality is weak.

## Repetition controls

Recurring architecture is referenced rather than re-taught in full. Each chapter still restates the minimum safety context needed to run its lab independently.

Repeated elements should add value through one of these changes:

- New evidence domain.
- New reliability problem.
- New data-quality problem.
- New executive decision.
- New test technique.
- New release or operational concern.

## Style controls

- Use concise paragraphs and meaningful headings.
- Prefer concrete verbs.
- Avoid marketing superlatives.
- Avoid declaring a workflow production-ready without stated tests and limits.
- Do not use Unicode U+2014.
- Do not use unexplained acronyms.
- Avoid second-person blame in troubleshooting.
- Use tables only when they improve comparison.
- Keep warnings specific: condition, consequence, and mitigation.

## Sample-section purpose

The Phase 1 sample demonstrates the intended voice, evidence-first thesis, beginner accessibility, CISO relevance, synthetic case continuity, and technical restraint. It intentionally avoids unverified endpoint or LQL details. It is not Chapter 1 and does not lock the final opening scene.

## Editorial acceptance criteria

Phase 1 editorial work is accepted when:

- The market promise is precise and does not overstate product coverage.
- Primary and secondary readers are identifiable.
- Prerequisites permit a true beginner path.
- The sixteen chapters form a cumulative learning sequence.
- Every chapter has a distinct lab and repository artifact.
- The executive layer remains traceable to technical evidence.
- The sample section falls between 1,000 and 1,500 words.
- The book bible and detailed outline do not conflict.
