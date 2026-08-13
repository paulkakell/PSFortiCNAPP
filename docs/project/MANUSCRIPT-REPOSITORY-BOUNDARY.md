<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Manuscript and Repository Boundary

Review date: 2026-08-13

## Governing decision

The complete commercial manuscript for **PowerShell 7 for FortiCNAPP: Security Automation with the v2 API and LQL for Compliance, Vulnerability, and Threat Monitoring** is not stored in the active public tree of `paulkakell/PSFortiCNAPP`.

The repository is a first-class companion deliverable, not a public copy of the book.

## Public repository content

The repository may contain:

- The master outline and chapter map.
- The approved Phase 1 sample section.
- Chapter production notes and completion records.
- Independent open-source documentation and tutorials.
- Complete PowerShell source, tests, executable examples, fixtures, schemas, and build tools.
- LQL files after their datasources and fields are verified.
- Source registers and verification-ledger records.
- Technical report and CISO brief templates.
- Synthetic sample output.
- Release, contribution, security, and support documentation.

## Excluded publishing assets

The active public tree must not contain:

- Complete commercial chapter manuscripts.
- Publisher layouts or edited publishing files.
- Cover artwork.
- Commercially commissioned illustrations.
- Book-exclusive downloads.
- Private editorial correspondence.
- Licensed third-party material that cannot be redistributed.

## Synchronization method

The commercial manuscript references repository paths, tags, releases, commands, object properties, and report fields. Repository tests verify the public artifacts. The manuscript production checklist verifies that printed code matches those artifacts.

The repository does not need the complete chapter prose to enforce synchronization.

## Existing Git history

Complete Chapter 1 and Chapter 2 draft files were previously committed during early production. The active-tree correction removes those files from the current branch. It does not erase earlier objects or commits from Git history.

History rewriting is not part of this correction. It requires explicit authorization, coordination with every open branch, assessment of cloned copies and forks, and publisher or legal review.

## Enforcement

`tests/Content/ManuscriptBoundary.Tests.ps1` fails when a numbered complete chapter Markdown file appears under `manuscript/chapters/`. Production-note files ending in `-PRODUCTION-NOTES.md` and the directory README remain permitted.

The repository-wide U+2014, SPDX, and credential-pattern checks continue to apply.
