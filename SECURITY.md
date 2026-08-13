<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Security Policy

## Supported code

Until the first GitHub Release, security fixes target the current development branch and `main` after merge. After releases begin, the latest release and current `main` receive security review.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability, exposed credential, unsafe redaction path, archive-verification defect, or other matter that could increase risk.

Create a private GitHub security advisory for this repository. When that route is not available, contact the maintainer through the GitHub profile without including exploit details in the first message.

A useful report includes:

- Affected commit, branch, or release.
- Operating system and PowerShell version.
- Reproduction steps using synthetic data.
- Expected and observed behavior.
- Security impact.
- A minimal sanitized proof.

Do not send real customer evidence, live access tokens, API secrets, private keys, or production account data.

## Project security boundaries

The project treats the following as security-sensitive:

- Authentication and temporary access-token handling.
- Diagnostic and error redaction.
- Tenant and subaccount isolation.
- Output provenance and collection-completeness claims.
- Evidence-pack manifests, hashes, and archive verification.
- State-changing commands and `ShouldProcess` behavior.
- Build, dependency, and release integrity.

Public examples and automated tests use synthetic or sanitized material only.
