<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Chapter 4 Examples

Run the synthetic HTTP contract lab from the repository root:

```powershell
pwsh -NoProfile -File ./examples/chapter-04/Review-SyntheticHttpExchanges.ps1
```

The lab uses only `tests/Fixtures/Synthetic/chapter-04-http-exchanges.json`. It makes no network request and accepts no credential.

Expected synthetic totals:

- Six exchanges
- Four HTTP successes
- Three valid local contracts
- Two warning contracts
- One invalid contract

The host `tenant.example.invalid` and path `/api/v2/example` are teaching placeholders, not a FortiCNAPP tenant or endpoint.
