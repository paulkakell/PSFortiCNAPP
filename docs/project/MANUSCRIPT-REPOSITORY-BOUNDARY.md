<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Manuscript and Repository Boundary

Review date: 2026-08-13

## Governing decision

The complete commercial manuscript for **PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring** is maintained outside the public companion repository.

`paulkakell/PSFortiCNAPP` is a first-class companion deliverable, not a public copy of the book.

## Public repository content

The repository may contain the master outline, approved sample, production notes, source registers, independent tutorials, complete executable artifacts, tests, synthetic fixtures, report templates, and release documentation.

## Excluded publishing assets

The public companion repository does not publish complete commercial chapters, publisher layouts, cover artwork, commercially commissioned illustrations, or book-exclusive downloads without explicit authorization.

The active public tree contains no complete commercial chapter. A short publishing-asset notice may retain an established chapter path so existing links lead readers to the public companion artifacts.

## Synchronization method

The commercial manuscript references repository paths, tags, releases, commands, object properties, and report fields. Repository tests verify the public artifacts. The manuscript production checklist verifies that printed code matches those artifacts.

## Git history

Earlier Git history is a separate review question. Replacing a file in the active tree does not erase prior Git objects, clones, forks, caches, or downloaded copies.

No repository-history rewrite was performed. Any later history-cleanup decision requires explicit authorization, coordination, impact analysis, and appropriate publisher or legal review.

## Enforcement

`tests/Content/RepositoryChapterBoundary.Tests.ps1` requires numbered chapter files that are not production notes to remain short publishing-asset notices. Repository-wide U+2014, SPDX, and credential-pattern checks also apply.
