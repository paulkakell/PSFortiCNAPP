<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Manuscript and Repository Boundary

Review date: 2026-08-13

## Governing decision

The complete commercial manuscript for **PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring** is maintained outside the public companion repository.

`paulkakell/PSFortiCNAPP` is a first-class companion deliverable, not a public copy of the book.

## Public repository content

The repository may contain the master outline, approved sample, production notes, source registers, open-source tutorials, complete executable artifacts, tests, synthetic fixtures, report templates, and release documentation.

## Excluded publishing assets

The public companion repository does not publish complete commercial chapters, publisher layouts, cover artwork, commercially commissioned illustrations, or book-exclusive downloads without explicit authorization.

## Synchronization method

The commercial manuscript references repository paths, tags, releases, commands, object properties, and report fields. Repository tests verify the public artifacts. The manuscript production checklist verifies that printed code matches those artifacts.

## Legacy exception

A complete Chapter 1 draft predates this boundary. GitHub issue #6 records the required follow-up. No later complete chapter file is permitted.

## Enforcement

`tests/Content/ManuscriptBoundary.Tests.ps1` permits the documented Chapter 1 legacy exception temporarily and fails if another numbered complete chapter Markdown file appears under `manuscript/chapters/`.

The exception must be removed from the test when issue #6 is completed. Repository-wide U+2014, SPDX, and credential-pattern checks continue to apply.
