<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Limitations

- No live HTTP request is made.
- No credential or token is accepted.
- No FortiCNAPP endpoint is implemented.
- No provider schema is validated.
- Raw response bodies are not archived.
- Binary, compressed, streaming, and multipart bodies are not modeled.
- HTTP date-form Retry-After is not converted to seconds.
- Tenant-specific behavior remains `VERIFY IN TENANT`.
