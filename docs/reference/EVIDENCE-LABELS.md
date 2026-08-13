<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Evidence Labels

PSFortiCNAPP uses explicit labels so readers and reviewers can tell what a statement or value represents.

## Documented

Supported by a current approved primary source. The source, version, and access date should be recorded. Documentation does not prove that every tenant exposes identical behavior.

## Observed

Produced during a controlled test and recorded with the environment class, product version, method, expected result, observed result, and limitations. Public summaries are sanitized.

## Synthetic

Invented for instruction or testing. Synthetic data must not be produced by lightly editing a real tenant export. It may represent realistic structure, but it proves nothing about provider behavior.

## Sanitized

Derived from a controlled observation after protected identifiers and values have been removed or transformed under a documented method. Sanitization must preserve the technical property being tested.

## Derived

Calculated deterministically from identified source evidence. A derived value states its formula, denominator, scope, time window, and handling of missing data.

## Inferred

A reasoned interpretation supported by evidence but not directly stated by the source. Inference is labeled and includes credible alternatives when they matter.

## Recommended

An operational or design recommendation. A recommendation may be well supported without being a FortiCNAPP product guarantee.

## Unverified

Not yet supported well enough for publication as fact. Provider-dependent details use the exact marker `VERIFY IN TENANT` until the verification ledger allows a stronger label.

## Missing and unavailable evidence

Missing, unavailable, unsupported, denied, and empty are different states. None may be converted automatically into a favorable result.

- **Missing:** Expected evidence was not present.
- **Unavailable:** The collection method could not determine whether evidence exists.
- **Unsupported:** The source or installed tool does not expose the requested operation.
- **Denied:** The identity lacked required access.
- **Empty:** A valid request completed and returned zero records.

Reports preserve these distinctions in both technical and executive output.
