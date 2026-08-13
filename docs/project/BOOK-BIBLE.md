<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Book Bible

## Identity

Title: **PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring**

Author: Paul Kell

Companion module: `PSFortiCNAPP`

Target length: approximately 116,000 words, with an acceptable range of 110,000 to 125,000 words.

Target format: approximately 500 printed pages, subject to trim size, code layout, figures, tables, and publisher design.

Structure: six parts, sixteen chapters, and six appendices.

## Market promise

The book teaches a PowerShell beginner to build a production-minded FortiCNAPP automation module that turns API v2 and LQL evidence into reliable security operations and defensible executive decisions. The reader sees how every result was authenticated, collected, scoped, transformed, checked, and reported.

## Primary reader

The primary reader is a cloud security engineer, security analyst, systems administrator, or technical consultant who understands basic cloud and security concepts but has little or no PowerShell experience.

The reader may know how to navigate a FortiCNAPP console but may not understand REST, JSON, pagination, object pipelines, testing, secure secret handling, or release engineering.

## Secondary readers

- SOC analysts who need repeatable evidence collection and triage.
- Compliance analysts who need transparent control and drift reporting.
- Platform engineers who need safe integration patterns.
- Security architects who need reusable automation design.
- CISOs and security managers who need metrics with defensible lineage.
- Experienced PowerShell users who are new to FortiCNAPP API v2 and LQL.

## Prerequisites

Required:

- General familiarity with cloud resources and security operations.
- Access to PowerShell 7.6 LTS or a later approved PowerShell 7 LTS release.
- A computer running Windows, Linux, or macOS.
- Git and access to GitHub Releases.
- Either a controlled FortiCNAPP tenant or the synthetic fixtures supplied with the repository.

Helpful but not required:

- Experience with AWS, Azure, GCP, Kubernetes, or containers.
- Familiarity with the FortiCNAPP console.
- Visual Studio Code.
- Basic command-line experience.

Not required:

- Prior PowerShell scripting.
- Prior REST API programming.
- Prior LQL experience.
- A software-development background.

## Learning outcomes

By the end of the book, the reader should be able to:

1. Explain how FortiCNAPP evidence supports cloud risk decisions.
2. Use PowerShell objects, pipelines, functions, modules, and error handling.
3. Authenticate securely and protect API keys, secrets, and bearer tokens.
4. Build a reusable API v2 transport layer with logging, retries, pagination, and redaction.
5. Discover and validate LQL datasources and fields before relying on a query.
6. Collect and normalize evidence across cloud assets, compliance, vulnerabilities, identities, and alerts.
7. Preserve timestamps, scope, source, and data-quality information.
8. Produce technical reports and executive summaries from the same evidence model.
9. Test the module with Pester and inspect it with PSScriptAnalyzer.
10. Package and distribute a versioned module through GitHub Releases.

## Non-goals

The book is not:

- A substitute for Fortinet product documentation or support.
- An exhaustive API endpoint catalog.
- A complete FortiCNAPP administration guide.
- A promise that every feature exists in every tenant, region, subscription, or release.
- A guide to bypassing access control or obtaining unauthorized data.
- A default endorsement of automatic remediation.
- A PowerShell Gallery publishing guide.
- A repository for real customer data, credentials, screenshots, or tenant exports.

## Voice and teaching style

The voice is conversational, precise, and mentor-like. It explains why a step exists before asking the reader to trust it. It assumes intelligence, not prior PowerShell knowledge.

Editorial rules:

- Define a term at first use.
- Prefer direct statements over slogans.
- Show complete code when the reader is expected to run it.
- Explain small code units before composing them into larger functions.
- Do not hide important behavior behind unexplained helpers.
- Separate observed facts, inferences, design choices, and synthetic examples.
- Pair technical interpretation with executive interpretation when a result supports both.
- Avoid fear-based language and unsupported claims.
- Do not use Unicode U+2014.

## Evidence labels

Every technical artifact uses one of these labels when provenance might be unclear:

- `VERIFIED OFFICIAL`: Supported by a current approved official source.
- `VERIFIED IN TENANT`: Reproduced in a controlled tenant, with version and evidence recorded.
- `SYNTHETIC`: Created solely for teaching or testing.
- `SANITIZED`: Derived from observed output after removing sensitive details.
- `VERIFY IN TENANT`: Not yet safe to present as production fact.
- `REVERIFY`: Previously verified but affected by a product, tenant, or dependency change.

`VERIFY IN TENANT` is not a casual note. It creates a required entry in the verification ledger.

## Fictional case study

The book follows **Kestrel Vale Health Services**, a wholly fictional healthcare technology organization.

Its training environment includes:

- AWS production services, EC2, databases, and EKS.
- Azure workforce systems, business applications, and AKS.
- GCP analytics workloads, data services, and GKE.
- Containers, hosts, service identities, human identities, and cloud control-plane activity.
- A security team balancing operational triage, compliance evidence, remediation ownership, and executive reporting.

All names, accounts, identifiers, metrics, incidents, and outputs are synthetic unless a passage explicitly states that a sample was sanitized from a controlled validation tenant.

The case study provides continuity without suggesting that one architecture or compliance program fits every reader.

## Chapter anatomy

Every chapter follows this sequence unless the subject requires a documented exception:

1. Opening operational scenario.
2. Reader outcomes.
3. Executive relevance.
4. Concepts and architecture.
5. Interface-selection decision.
6. Implementation.
7. Complete PowerShell code.
8. Verified API or LQL examples.
9. Synthetic or sanitized output.
10. Technical interpretation.
11. Executive interpretation.
12. Security and privacy considerations.
13. Failure modes and troubleshooting.
14. Tests.
15. Hands-on lab.
16. Review questions and exercises.
17. Key takeaways.
18. Source and version notes.
19. Verification-ledger updates.
20. Companion-repository artifacts.

## Technical conventions

- PowerShell 7.6 LTS is the initial baseline.
- Examples must be cross-platform unless labeled otherwise.
- Cmdlets use approved PowerShell verbs and singular nouns.
- Public functions return objects, not display-only strings.
- Formatting belongs in views or report functions, not collection functions.
- Timestamps are normalized to UTC and represented with unambiguous ISO 8601 or RFC 3339-compatible values.
- Secrets and bearer tokens are never written to logs, transcripts, errors, fixtures, or reports.
- API v2 is the supported API family for the project.
- Endpoint and schema details must be discovered from current official references and target-tenant documentation.
- LQL queries must be validated against current datasource metadata and controlled tenant behavior.
- Examples default to read-only operations.
- Any write operation requires an explicit safety section, confirmation design, idempotency analysis, rollback consideration, and narrower permission discussion.

## Reporting conventions

Every metric or claim intended for an executive audience must disclose:

- Definition.
- Numerator and denominator when applicable.
- Time window.
- Collection timestamp.
- Included and excluded scope.
- Data source.
- Transformation or weighting.
- Data-quality limitations.
- Whether it is product-native or module-derived.

The manuscript must never treat missing data as proof that risk is absent.

## Word allocation

| Section | Target words |
|---|---:|
| Front matter and introduction | 2,000 |
| Chapters 1 through 16 | 105,000 |
| Appendices A through F | 9,000 |
| Total target | 116,000 |

Chapter targets are planning controls, not reasons to pad text. A chapter may vary when its lab, code, or architecture needs more space.

## Quality gates

A chapter cannot be marked complete until:

- All code parses and executes in its stated environment.
- Tests relevant to the chapter pass.
- PSScriptAnalyzer findings are resolved or explicitly justified.
- Every API and LQL claim has an approved source and required tenant evidence.
- Synthetic output is labeled.
- Secrets and identifying tenant data are absent.
- Executive metrics disclose scope and quality.
- The repository artifact matches the printed code.
- The chapter source and version note is current.
- The prohibited-character check passes.
- The chapter's actual word count is recorded.

## Change control

Changes to the title, audience, licensing, distribution channel, six-part structure, chapter count, evidence labels, or no-invention rule require an explicit decision record. Minor wording and implementation refinements do not require a book-bible revision unless they change reader expectations or technical behavior.
