<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 4 Design Decisions

- Use a local parser before a network client.
- Accept only synthetic or sanitized input.
- Remove query values from normalized output.
- Redact known sensitive header values.
- Parse only JSON-compatible media types.
- Distinguish empty, valid JSON, malformed JSON, and unsupported media types.
- Return body length and SHA-256 without raw body text.
- Treat HTTP success and local contract validity as separate facts.
- Defer authentication to Chapter 5.
- Defer retries, pagination, schema discovery, and observed provider behavior to Chapter 6 and later chapters.
