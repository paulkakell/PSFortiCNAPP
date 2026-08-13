<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 1 Source Register

Chapter: **FortiCNAPP and the Cloud Risk Problem**

Access date: 2026-08-13

This register records the first-party sources used for Chapter 1. It supports product naming, interface selection, scope language, and the PowerShell runtime baseline. It does not replace controlled tenant validation.

## C1-S001: FortiCNAPP API overview

- Publisher: Fortinet
- Title: About the Lacework FortiCNAPP API
- Track: FortiCNAPP, latest API Reference
- URL: https://docs.fortinet.com/document/forticnapp/latest/api-reference/863111/about-the-lacework-forticnapp-api
- Supports: The current documentation uses the Lacework FortiCNAPP name, describes the interface as REST, directs readers to API 2.0 documentation, and states that API v1 is no longer supported.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Availability and authorization remain tenant-dependent.
- Revalidate when: The API family or reference location changes.

## C1-S002: FortiCNAPP access model

- Publisher: Fortinet
- Title: API Keys and Access Tokens
- Track: FortiCNAPP, latest API Reference
- URL: https://docs.fortinet.com/document/forticnapp/latest/api-reference/932048/api-keys-and-access-tokens
- Supports: Programmatic access uses account-scoped credentials and temporary authorization. Service users can support programmatic access and narrower permissions.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Exact role behavior remains tenant-dependent.
- Revalidate when: The authentication or service-user model changes.

## C1-S003: FortiCNAPP CLI

- Publisher: Fortinet
- Title: Get Started with the FortiCNAPP CLI
- Track: FortiCNAPP 26.2.0 CLI Reference
- URL: https://docs.fortinet.com/document/forticnapp/26.2.0/cli-reference
- Supports: The command-line executable remains named `lacework` and is documented for Windows, macOS, Linux, and supported cloud-shell environments.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Installation is deferred to Chapter 2.
- Revalidate when: The CLI name, distribution, or supported platforms change.

## C1-S004: API helper and schema discovery

- Publisher: Fortinet
- Title: lacework api
- Track: FortiCNAPP, latest CLI Reference
- URL: https://docs.fortinet.com/document/forticnapp/latest/cli-reference/42146/lacework-api
- Supports: The CLI has an API v2 helper and documents schema discovery rather than fixed assumptions.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: No response is tenant evidence until controlled validation is recorded.
- Revalidate when: The helper or schema-discovery method changes.

## C1-S005: LQL overview

- Publisher: Fortinet
- Title: LQL Overview
- Track: FortiCNAPP 26.2.0 LQL Reference
- URL: https://docs.fortinet.com/document/forticnapp/26.2.0/lql-reference/598361/lql-overview
- Supports: Lacework Query Language is SQL-like, operates against curated datasources, and can select, filter, and manipulate available security data.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Datasource names, fields, and results require current discovery and validation.
- Revalidate when: LQL syntax or datasource behavior changes.

## C1-S006: LQL datasource discovery

- Publisher: Fortinet
- Title: Datasource Information
- Track: FortiCNAPP, latest LQL Reference
- URL: https://docs.fortinet.com/document/forticnapp/latest/lql-reference/459775/datasource-information
- Supports: Datasource names and metadata can be discovered through documented interfaces before queries are written.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: A documented datasource is not proof that it is populated or authorized in a particular tenant.
- Revalidate when: Datasource discovery changes.

## C1-S007: AWS integration categories

- Publisher: Fortinet
- Title: AWS integration
- Track: FortiCNAPP 26.2.0 Administration Guide
- URL: https://docs.fortinet.com/document/forticnapp/26.2.0/administration-guide/854470/aws-integration
- Supports: FortiCNAPP documents different AWS integration categories, so integration type affects expected evidence.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The Chapter 1 AWS scope is synthetic.
- Revalidate when: AWS onboarding or integration categories change.

## C1-S008: Azure integration categories

- Publisher: Fortinet
- Title: Azure integration
- Track: FortiCNAPP 26.2.0 Administration Guide
- URL: https://docs.fortinet.com/document/forticnapp/26.2.0/administration-guide/526129/azure-integration
- Supports: FortiCNAPP documents separate Azure integration categories for configuration, activity, and workload evidence.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The Chapter 1 missing Azure scope is synthetic.
- Revalidate when: Azure onboarding or integration categories change.

## C1-S009: Feature support varies by provider

- Publisher: Fortinet
- Title: Attack Path Cloud Feature Comparison
- Track: FortiCNAPP 26.1.0 Administration Guide
- URL: https://docs.fortinet.com/document/forticnapp/26.1.0/administration-guide/320766
- Supports: Feature availability is not uniform across cloud providers. A broad platform-support statement is not a sufficient contract for a specific report.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: This is a feature-specific comparison, not a complete support matrix.
- Revalidate when: A newer comparison or material support change appears.

## C1-S010: Kubernetes prerequisites

- Publisher: Fortinet
- Title: Supported environments and prerequisites
- Track: FortiCNAPP 26.2.0 Administration Guide
- URL: https://docs.fortinet.com/document/forticnapp/26.2.0/administration-guide/705253/supported-environments-and-prerequisites
- Supports: Kubernetes evidence depends on supported environments, versions, collectors, and related integrations.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: The source applies to its documented integration context.
- Revalidate when: Supported environments or prerequisites change.

## C1-S011: PowerShell lifecycle baseline

- Publisher: Microsoft
- Title: PowerShell - Microsoft Lifecycle
- URL: https://learn.microsoft.com/lifecycle/products/powershell
- Supports: PowerShell 7.6 is a long-term support release with published support from March 18, 2026 through November 14, 2028.
- Evidence class: `VERIFIED OFFICIAL`
- Limitation: Runner patch versions can differ, so continuous integration records the actual version used.
- Revalidate when: Support dates change or the project adopts a later LTS baseline.

## Tenant-dependent claims retained as unresolved

The chapter does not claim that a particular account, subscription, project, cluster, registry, datasource, field, or operation is present in a reader's tenant. Integration state, permission scope, evidence freshness, returned schemas, and the cause of missing records remain `VERIFY IN TENANT`.

## Source decision

Chapter 1 may proceed because its runnable lab is `SYNTHETIC` and its interface statements are supported by current primary sources. Live collection and tenant observations remain reserved for later chapters and verification-ledger work.
